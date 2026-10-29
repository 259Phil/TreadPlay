import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/market.dart';
import 'package:treadplay/domain/world.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  GameData walked(double km, {double? markKm}) {
    final g = GameData.initial(t0);
    return g.copyWith(
      totals: g.totals.copyWith(distanceM: km * 1000),
      album: g.album.withMark(markKm == null ? null : markKm * 1000),
    );
  }

  group('chance', () {
    test('about 0.1 % of all offers are a Schimmer', () {
      var shimmer = 0, all = 0;
      for (var seed = 0; seed < 25000; seed++) {
        final m = Market.rolled(t0, Random(seed), worlds: World.values.toSet());
        all += m.offers.length;
        shimmer += m.offers.where((c) => c.shimmer).length;
      }
      expect(all, 300000);
      expect(shimmer / all, closeTo(Market.shimmerChance, 0.0003));
    });

    test('a due market always has one', () {
      for (var seed = 0; seed < 300; seed++) {
        final m = Market.rolled(t0, Random(seed), shimmerDue: true);
        expect(m.hasShimmer, isTrue, reason: 'seed $seed');
      }
    });
  });

  group('300 km guarantee', () {
    test('due from 300 km without a Schimmer, counted from the mark', () {
      expect(walked(0).shimmerDue, isFalse);
      expect(walked(299.9).shimmerDue, isFalse);
      expect(walked(300).shimmerDue, isTrue);
      expect(walked(450, markKm: 200).shimmerDue, isFalse);
      expect(walked(500, markKm: 200).shimmerDue, isTrue);
    });

    test('the next market has one and restarts the count', () {
      for (var seed = 0; seed < 50; seed++) {
        final game = walked(312).withMarket(t0, Random(seed));
        expect(game.market!.hasShimmer, isTrue, reason: 'seed $seed');
        expect(game.album.lastShimmerAtM, 312000);
        expect(game.shimmerDue, isFalse);
        // The same market again (no drift yet) changes nothing.
        final again = game.withMarket(
          t0.add(const Duration(minutes: 5)),
          Random(seed + 1),
        );
        expect(identical(again.market, game.market), isTrue);
        expect(again.album.lastShimmerAtM, 312000);
      }
    });

    test('a lucky Schimmer before 300 km also restarts the count', () {
      var found = false;
      for (var seed = 0; seed < 4000 && !found; seed++) {
        final game = walked(120).withMarket(t0, Random(seed));
        if (game.market!.hasShimmer) {
          found = true;
          expect(game.album.lastShimmerAtM, 120000);
        } else {
          expect(game.album.lastShimmerAtM, isNull);
        }
      }
      expect(found, isTrue);
    });
  });

  group('value and album', () {
    final plain = Companion.rolled(
      id: 'm1',
      speciesId: 'nebulo',
      rarity: Rarity.epic,
      random: Random(1),
    );
    final shiny = plain.copyWith(shimmer: true);
    final market = Market(
      nextDriftAt: t0.add(const Duration(hours: 3)),
      drift: const {'m1': 1.1},
      offers: [shiny],
    );

    test('buying and selling are worth ×1.5', () {
      expect(market.priceOf(plain), 1320);
      expect(market.priceOf(shiny), 1980);
      expect(market.sellPriceOf(plain), 720);
      expect(market.sellPriceOf(shiny), 1080);
    });

    test('a bought Schimmer stays one and goes into the album', () {
      final game = GameData.initial(
        t0,
      ).copyWith(lp: 5000, market: market).buying('m1');
      final c = game.companions.last;
      expect(c.shimmer, isTrue);
      expect(game.album.owned, containsAll({'pebble', 'nebulo'}));
      expect(game.album.shimmer, {'nebulo'});
      final back = GameData.fromJson(
        jsonDecode(jsonEncode(game.toJson())) as Map<String, Object?>,
      );
      expect(back.companions.last.shimmer, isTrue);
      expect(back.album.shimmer, {'nebulo'});
      expect(back.toJson(), game.toJson());
      // Levelling keeps the look.
      expect(c.copyWith(xp: 99).leveledUp().shimmer, isTrue);
      // Sold again: the album still remembers it.
      final sold = game.selling('m1', t0);
      expect(sold.album.shimmer, {'nebulo'});
      expect(sold.lp, game.lp + 1080);
    });

    test('a save from before the album starts the count where it is', () {
      final g = walked(42.5);
      final json = jsonDecode(jsonEncode(g.toJson())) as Map<String, Object?>
        ..remove('album');
      final back = GameData.fromJson(json);
      expect(back.album.owned, {'pebble'});
      expect(back.album.lastShimmerAtM, 42500);
    });

    test('version 11 files drop stray album and Schimmer keys', () {
      final g = walked(10).copyWith(market: market);
      final json = jsonDecode(jsonEncode(g.toJson())) as Map<String, Object?>;
      (json['market']! as Map<String, Object?>)['offers'] = [
        {...shiny.toJson()},
      ];
      json['album'] = {
        'owned': ['lakrillo'],
        'shimmer': ['lakrillo'],
      };
      final file = {
        'format': SaveGame.format,
        'version': 11,
        'exportedAt': t0.toIso8601String(),
        'game': json,
      };
      final game = SaveGame.decode(utf8.encode(jsonEncode(file))).game;
      expect(game.album.owned, {'pebble'});
      expect(game.album.shimmer, isEmpty);
      expect(game.album.lastShimmerAtM, 10000);
      expect(game.market!.offers.single.shimmer, isFalse);
      // Version 12 keeps them.
      final now = SaveGame.decode(SaveGame.encode(g, t0)).game;
      expect(now.market!.offers.single.shimmer, isTrue);
    });
  });
}
