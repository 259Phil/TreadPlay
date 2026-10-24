import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/data/species.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/market.dart';
import 'package:treadplay/domain/world.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  Set<String> species(Market m) => {for (final c in m.offers) c.speciesId};

  group('species variety', () {
    test('a fresh save sees at least three species in every drift', () {
      for (var seed = 0; seed < 200; seed++) {
        final random = Random(seed);
        var game = GameData.initial(t0).withMarket(t0, random);
        expect(game.marketWorlds, {World.medieval}, reason: 'fresh save');
        for (var drift = 0; drift < 5; drift++) {
          final m = game.market!;
          expect(m.offers, hasLength(Market.offerCount));
          expect(
            species(m).length,
            greaterThanOrEqualTo(Market.minSpecies),
            reason: 'seed $seed, drift $drift',
          );
          // Starter worlds in trail order: medieval, jungle, underwater.
          expect(
            species(m),
            everyElement(isIn({'pebble', 'vine', 'brine'})),
            reason: 'seed $seed, drift $drift',
          );
          game = game.withMarket(m.nextDriftAt, random);
        }
      }
    });

    test('the gait split and the along guarantee still hold', () {
      final counts = {for (final t in CompanionType.values) t: 0};
      for (var seed = 0; seed < 400; seed++) {
        final m = Market.rolled(
          t0,
          Random(seed),
          worlds: {World.medieval},
          along: CompanionType.gale,
        );
        expect(
          m.offers.where((c) => c.tempo == CompanionType.gale).length,
          greaterThanOrEqualTo(Market.guaranteedTempoOffers),
        );
        for (final c in Market.rolled(t0, Random(seed)).offers) {
          counts[c.tempo] =
              counts[c.tempo]! + (c.tempo == c.species.type ? 1 : 0);
        }
      }
      final home = counts.values.reduce((a, b) => a + b);
      final share = home / (400 * Market.offerCount);
      expect(share, closeTo(Market.homeTempoWeight / 100, 0.05));
    });

    test('a bigger pool is not padded, a whole catalog stays varied', () {
      for (var seed = 0; seed < 100; seed++) {
        final m = Market.rolled(
          t0,
          Random(seed),
          worlds: {World.medieval, World.jungle, World.egypt, World.pirate},
        );
        expect(
          species(m),
          everyElement(isIn({'pebble', 'vine', 'dune', 'hookfin'})),
        );
        expect(species(m).length, greaterThanOrEqualTo(3));
        expect(
          species(Market.rolled(t0, Random(seed))).length,
          greaterThanOrEqualTo(3),
        );
      }
    });

    test('same seed, same market', () {
      String roll(int seed) => jsonEncode(
        GameData.initial(t0).withMarket(t0, Random(seed)).market!.toJson(),
      );
      for (var seed = 0; seed < 20; seed++) {
        expect(roll(seed), roll(seed));
      }
    });

    test('buying a starter species from another world just works', () {
      final start = GameData.initial(t0).withMarket(t0, Random(1));
      final m = start.market!;
      final vine = Companion.rolled(
        id: 'offer-vine',
        speciesId: 'vine',
        rarity: Rarity.common,
        random: Random(2),
      );
      final market = Market(
        nextDriftAt: m.nextDriftAt,
        drift: m.drift,
        offers: [vine, ...m.offers.skip(1)],
      );
      final game = start.copyWith(market: market, lp: 1e6);
      expect(game.buyBlock('offer-vine'), isNull);
      final bought = game.buying('offer-vine');
      expect(bought.companions.map((c) => c.id), contains('offer-vine'));
      expect(bought.marketWorlds, containsAll({World.medieval, World.jungle}));
      final taken = bought.takingAlong('offer-vine', t0);
      expect(taken.activeCompanion.speciesId, 'vine');
      final later = taken.withMarket(m.nextDriftAt, Random(3));
      expect(species(later.market!).length, greaterThanOrEqualTo(3));
      expect(GameData.fromJson(later.toJson()).toJson(), later.toJson());
    });
  });

  group('old markets', () {
    Map<String, Object?> oldMarketGame() {
      final start = GameData.initial(t0);
      final monotone = Market(
        nextDriftAt: t0.add(const Duration(hours: 8)),
        drift: const {},
        offers: [
          for (var i = 0; i < Market.offerCount; i++)
            Companion.fresh(
              id: 'old-$i',
              speciesId: 'pebble',
              rarity: Rarity.common,
            ),
        ],
      );
      final json =
          jsonDecode(jsonEncode(start.copyWith(market: monotone).toJson()))
              as Map<String, Object?>;
      (json['market']! as Map<String, Object?>).remove('generation');
      return json;
    }

    test('a market saved before this version is rolled anew once', () {
      final loaded = GameData.fromJson(oldMarketGame());
      expect(loaded.market!.generation, 1);
      expect(loaded.market!.outdated, isTrue);
      final now = t0.add(const Duration(minutes: 5));
      final fixed = loaded.withMarket(now, Random(4));
      final m = fixed.market!;
      expect(m.outdated, isFalse);
      expect(m.offers.map((c) => c.id), everyElement(isNot(startsWith('old'))));
      expect(species(m).length, greaterThanOrEqualTo(3));
      expect(fixed.companions.map((c) => c.toJson()), [
        for (final c in loaded.companions) c.toJson(),
      ]);
      // Once: the new market stays put after a save and reload.
      final reloaded = GameData.fromJson(
        jsonDecode(jsonEncode(fixed.toJson())) as Map<String, Object?>,
      );
      expect(reloaded.market!.generation, Market.currentGeneration);
      final again = reloaded.withMarket(
        now.add(const Duration(minutes: 1)),
        Random(9),
      );
      expect(again.market!.toJson(), m.toJson());
    });

    test('a version 6 save file gets a fresh market on import', () {
      final file = {
        'format': SaveGame.format,
        'version': 6,
        'exportedAt': t0.toIso8601String(),
        'game': oldMarketGame(),
      };
      final game = SaveGame.decode(utf8.encode(jsonEncode(file))).game;
      expect(game.companions.single.speciesId, 'pebble');
      expect(game.market!.outdated, isTrue);
      final now = t0.add(const Duration(hours: 1));
      final m = game.withMarket(now, Random(5)).market!;
      expect(species(m).length, greaterThanOrEqualTo(3));
      expect(jsonDecode(utf8.decode(SaveGame.encode(game, t0)))['version'], 8);
    });
  });

  group('restock hint', () {
    test('only in the last half hour before the drift', () {
      final m = Market.rolled(t0, Random(1));
      final at = m.nextDriftAt;
      expect(m.restocksSoon(t0), isFalse);
      expect(m.restocksSoon(at.subtract(const Duration(minutes: 31))), isFalse);
      expect(m.restocksSoon(at.subtract(const Duration(minutes: 30))), isTrue);
      expect(m.restocksSoon(at.subtract(const Duration(minutes: 1))), isTrue);
    });
  });

  test('the species catalog has the starter species', () {
    for (final id in ['pebble', 'vine', 'brine']) {
      expect(speciesCatalog.map((s) => s.id), contains(id));
    }
  });
}
