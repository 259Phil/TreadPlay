import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/breath.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/market.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  test('new games start with Mossik only, taken along', () {
    final game = GameData.initial(t0);
    expect(game.companions.map((c) => c.name), ['Mossik']);
    expect(game.activeCompanion.name, 'Mossik');
  });

  test('Mossik cannot be sold until a second companion exists', () {
    final game = GameData.initial(t0);
    expect(game.canSell('pebble-1'), isFalse);
    final dune = Companion.fresh(
      id: 'dune-1',
      speciesId: 'dune',
      rarity: Rarity.rare,
    );
    final two = game.copyWith(companions: [...game.companions, dune]);
    expect(two.canSell('pebble-1'), isTrue);
    final worn = two.replaceCompanion(dune.copyWith(spirit: 90));
    expect(worn.canSell('dune-1'), isFalse);
  });

  test('json round trip', () {
    final game = GameData.initial(t0).copyWith(lp: 7.5);
    final copy = GameData.fromJson(game.toJson());
    expect(copy.toJson(), game.toJson());
  });

  final gilt = Companion.fresh(
    id: 'gilt-1',
    speciesId: 'gilt',
    rarity: Rarity.legendary,
  );

  GameData withGilt(double points) {
    final start = GameData.initial(t0);
    return start.copyWith(
      companions: [...start.companions, gilt],
      breath: Breath(points: points, updatedAt: t0),
    );
  }

  test('switching to Frilla Legendary with an empty bar keeps it empty', () {
    final game = withGilt(0).takingAlong('gilt-1', t0);
    expect(game.activeCompanionId, 'gilt-1');
    expect(game.breathCap, 12);
    expect(game.breath.points, 0);
  });

  test('switching back and forth never refills the bar', () {
    var game = withGilt(2.5);
    for (var i = 0; i < 10; i++) {
      game = game.takingAlong('gilt-1', t0).takingAlong('pebble-1', t0);
    }
    expect(game.breath.points, 2.5);
  });

  test('regen runs on the shared bar up to the current cap', () {
    final game = withGilt(5).takingAlong('gilt-1', t0);
    final later = game.regenerated(t0.add(const Duration(minutes: 180)));
    expect(later.breath.points, closeTo(7, 1e-9));
    final full = game.regenerated(t0.add(const Duration(days: 1)));
    expect(full.breath.points, 12);
  });

  test('a lower cap trims the bar, a higher cap does not fill it', () {
    final full = withGilt(12).copyWith(activeCompanionId: 'gilt-1');
    final pebble = full.takingAlong('pebble-1', t0);
    expect(pebble.breath.points, 6);
    expect(pebble.takingAlong('gilt-1', t0).breath.points, 6);
  });

  test('owning more companions adds no Breath', () {
    final start = GameData.initial(t0);
    final many = start.copyWith(
      companions: [
        ...start.companions,
        for (var i = 0; i < 9; i++)
          Companion.fresh(
            id: 'vine-$i',
            speciesId: 'vine',
            rarity: Rarity.rare,
          ),
      ],
    );
    expect(many.breathCap, 6);
    expect(many.regenerated(t0.add(const Duration(days: 1))).breath.points, 6);
  });

  test('old saves with a tank per companion keep only the one taken along', () {
    final json = withGilt(0).toJson()..remove('breath');
    final companions = json['companions']! as List<Object?>;
    for (final c in companions.cast<Map<String, Object?>>()) {
      c['breath'] = c['id'] == 'pebble-1' ? 1.5 : 12.0;
      c['breathUpdatedAt'] = t0.toIso8601String();
    }
    final game = GameData.fromJson(json);
    expect(game.breath.points, 1.5);
    expect(game.takingAlong('gilt-1', t0).breath.points, 1.5);
  });

  group('market', () {
    final dune = Companion.fresh(
      id: 'dune-1',
      speciesId: 'dune',
      rarity: Rarity.rare,
    );
    final offer = Companion.rolled(
      id: 'offer-1',
      speciesId: 'gilt',
      rarity: Rarity.legendary,
      random: Random(7),
    );
    final market = Market(
      nextDriftAt: t0.add(const Duration(hours: 8)),
      drift: const {},
      offers: [offer],
    );
    final price = market.priceOf(offer);
    GameData withLp(double lp) =>
        GameData.initial(t0).copyWith(lp: lp, market: market);

    test('buying moves the offer to the den for its LP price', () {
      final game = withLp(price + 5);
      expect(game.buyBlock('offer-1'), isNull);
      final bought = game.buying('offer-1');
      expect(bought.lp, 5);
      expect(bought.companions.last.toJson(), offer.toJson());
      expect(bought.market!.offers, isEmpty);
      expect(bought.buyBlock('offer-1'), TradeBlock.gone);
      expect(bought.activeCompanionId, 'pebble-1');
    });

    test('buying needs enough LP', () {
      expect(withLp(price - 1).buyBlock('offer-1'), TradeBlock.notEnoughLp);
    });

    test('the den holds at most 12 companions', () {
      expect(GameData.inventoryCap, 12);
      final start = withLp(1e6);
      final full = start.copyWith(
        companions: [
          ...start.companions,
          for (var i = 1; i < 12; i++)
            Companion.fresh(
              id: 'vine-$i',
              speciesId: 'vine',
              rarity: Rarity.common,
            ),
        ],
      );
      expect(full.companions, hasLength(12));
      expect(full.buyBlock('offer-1'), TradeBlock.shelfFull);
      final eleven = full.selling('vine-1', t0);
      expect(eleven.buyBlock('offer-1'), isNull);
      expect(eleven.buying('offer-1').companions, hasLength(12));
    });

    test('buying and selling need 100 % Spirit', () {
      final worn = market.offers.single.copyWith(spirit: 99);
      final m = Market(
        nextDriftAt: market.nextDriftAt,
        drift: market.drift,
        offers: [worn],
      );
      expect(
        withLp(1e6).copyWith(market: m).buyBlock('offer-1'),
        TradeBlock.needsSpirit,
      );
      final two = withLp(
        0,
      ).copyWith(companions: [Companion.pebble(), dune.copyWith(spirit: 99.9)]);
      expect(two.sellBlock('dune-1'), TradeBlock.needsSpirit);
      expect(two.sellBlock('pebble-1'), isNull);
    });

    test('Mossik cannot be sold while it is the only companion', () {
      final game = withLp(0);
      expect(game.sellBlock('pebble-1'), TradeBlock.lastCompanion);
      final two = game.copyWith(companions: [...game.companions, dune]);
      expect(two.sellBlock('pebble-1'), isNull);
    });

    test('selling pays the buy-back price and removes the companion', () {
      final game = withLp(10);
      final two = game.copyWith(companions: [...game.companions, dune]);
      final sold = two.selling('dune-1', t0);
      expect(sold.lp, 10 + market.sellPriceOf(dune));
      expect(sold.companions.map((c) => c.id), ['pebble-1']);
      expect(sold.sellBlock('pebble-1'), TradeBlock.lastCompanion);
    });

    test('selling the one taken along switches without refilling Breath', () {
      final game = withLp(0).copyWith(
        companions: [Companion.pebble(), offer],
        activeCompanionId: 'offer-1',
        breath: Breath(points: 1, updatedAt: t0),
      );
      final sold = game.selling('offer-1', t0);
      expect(sold.activeCompanionId, 'pebble-1');
      expect(sold.breath.points, 1);
      expect(sold.breathCap, 6);
    });

    test('the market drifts only when due and survives a save', () {
      final game = withLp(0);
      final soon = t0.add(const Duration(hours: 7, minutes: 59));
      expect(
        identical(game.withMarket(soon, Random(1)).market, market),
        isTrue,
      );
      final later = game.withMarket(market.nextDriftAt, Random(1));
      expect(identical(later.market, market), isFalse);
      final copy = GameData.fromJson(later.toJson());
      expect(copy.market!.toJson(), later.market!.toJson());
    });

    test('old saves without a market get one rolled on load', () {
      final old = GameData.initial(t0).toJson()..remove('market');
      final loaded = GameData.fromJson(old);
      expect(loaded.market, isNull);
      expect(
        loaded.withMarket(t0, Random(1)).market!.offers,
        hasLength(Market.offerCount),
      );
    });
  });

  test('settings keep the movement answer, old saves start unasked', () {
    expect(
      AppSettings.fromJson(const {'localeCode': 'de'}).movementAccess,
      MovementAccess.unasked,
    );
    for (final a in MovementAccess.values) {
      final s = const AppSettings().copyWith(movementAccess: a);
      expect(AppSettings.fromJson(s.toJson()).movementAccess, a);
    }
  });
}
