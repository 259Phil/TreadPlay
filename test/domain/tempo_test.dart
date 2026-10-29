import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/data/species.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/market.dart';
import 'package:treadplay/domain/movement.dart';
import 'package:treadplay/domain/run_engine.dart';
import 'package:treadplay/domain/sweet_spot.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  group('gait per companion', () {
    test('type follows the instance tempo, not the species', () {
      final pebble = Companion.pebble();
      expect(pebble.species.type, CompanionType.moss);
      expect(pebble.tempo, CompanionType.moss);
      expect(pebble.type, CompanionType.moss);

      final fast = pebble.copyWith(tempo: CompanionType.gale);
      expect(fast.tempo, CompanionType.gale);
      expect(fast.type, CompanionType.gale);
      expect(fast.species.type, CompanionType.moss);
      // Other copies keep the gait.
      expect(fast.copyWith(stride: 11).type, CompanionType.gale);
      expect(fast.withCharm(0, null).type, CompanionType.gale);
    });

    test('the gait is saved and read back', () {
      final c = Companion.fresh(
        id: 'p',
        speciesId: 'pebble',
        rarity: Rarity.rare,
        tempo: CompanionType.brook,
      );
      final json = c.toJson();
      expect(json['tempo'], 'brook');
      expect(Companion.fromJson(json).type, CompanionType.brook);
    });

    test('missing or unknown gaits fall back to the home gait', () {
      final json = Companion.fresh(
        id: 'd',
        speciesId: 'dune',
        rarity: Rarity.common,
      ).toJson();
      expect(
        Companion.fromJson({...json}..remove('tempo')).type,
        CompanionType.gale,
      );
      expect(
        Companion.fromJson({...json, 'tempo': 'warp'}).type,
        CompanionType.gale,
      );
      expect(
        Companion.fromJson({...json, 'tempo': 3}).type,
        CompanionType.gale,
      );
    });

    test('every gait earns the same LP at its own sweet spot', () {
      double lpAt(CompanionType t) {
        final engine = RunEngine(
          companion: Companion.pebble().copyWith(tempo: t),
          breathAtStart: 6,
          startedAt: t0,
        );
        final kmh = t.sweetSpotKmh;
        expect(sweetSpotFactor(t, kmh), 1);
        // 1025 m (4 blocks of 250 m = 20 pieces of 50 m, away from rounding edges) at the gait's own sweet spot, 1 s samples.
        final m = kmh / 3.6;
        var elapsed = Duration.zero;
        var done = 0.0;
        while (done < 1025 - 1e-9) {
          final step = min(m, 1025 - done);
          elapsed += const Duration(seconds: 1);
          engine.add(
            MovementSample(
              time: t0.add(elapsed),
              speedKmh: kmh,
              distanceM: step,
              steps: (step * 1.3).round(),
            ),
          );
          done += step;
        }
        expect(engine.finish().valid, isTrue);
        return engine.lp;
      }

      final lps = {for (final t in CompanionType.values) t: lpAt(t)};
      expect(lps[CompanionType.moss], 10);
      expect(lps.values.toSet(), hasLength(1));
    });

    test('the sweet spot curve has the same shape for every gait', () {
      for (final t in CompanionType.values) {
        expect(sweetSpotFactor(t, t.sweetSpotKmh), 1);
        expect(sweetSpotFactor(t, t.sweetSpotKmh + t.rangeKmh), 0);
      }
    });
  });

  group('market gaits', () {
    test('home gait about half the offers, the others a quarter each', () {
      final home = <bool>[];
      final counts = {for (final t in CompanionType.values) t: 0};
      var total = 0;
      for (var seed = 0; seed < 400; seed++) {
        for (final c in Market.rolled(t0, Random(seed)).offers) {
          home.add(c.tempo == c.species.type);
          counts[c.tempo] = counts[c.tempo]! + 1;
          total++;
        }
      }
      final homeShare = home.where((h) => h).length / home.length;
      expect(homeShare, closeTo(0.5, 0.03));
      // Every gait shows up across species.
      for (final n in counts.values) {
        expect(n / total, greaterThan(0.2));
      }
    });

    test('a slow species can come as trot and gallop', () {
      final mossik = [
        for (var seed = 0; seed < 200; seed++)
          ...Market.rolled(
            t0,
            Random(seed),
          ).offers.where((c) => c.speciesId == 'pebble'),
      ];
      final share = {
        for (final t in CompanionType.values)
          t: mossik.where((c) => c.tempo == t).length / mossik.length,
      };
      expect(share[CompanionType.moss], closeTo(0.5, 0.06));
      expect(share[CompanionType.brook], closeTo(0.25, 0.06));
      expect(share[CompanionType.gale], closeTo(0.25, 0.06));
    });

    test('at least three offers share the gait of the companion along', () {
      for (final along in CompanionType.values) {
        for (var seed = 0; seed < 300; seed++) {
          final m = Market.rolled(t0, Random(seed), along: along);
          expect(
            m.offers.where((c) => c.tempo == along).length,
            greaterThanOrEqualTo(Market.guaranteedTempoOffers),
            reason: 'seed $seed, $along',
          );
        }
      }
    });

    test('the guarantee holds with a one-world pool too', () {
      final medieval = speciesCatalog.first.world;
      for (var seed = 0; seed < 100; seed++) {
        final m = Market.rolled(
          t0,
          Random(seed),
          worlds: {medieval},
          along: CompanionType.gale,
        );
        expect(
          m.offers.where((c) => c.tempo == CompanionType.gale).length,
          greaterThanOrEqualTo(3),
        );
      }
    });

    test('same seed, same gaits', () {
      List<String> roll() => [
        for (final c in Market.rolled(
          t0,
          Random(7),
          along: CompanionType.brook,
        ).offers)
          '${c.speciesId}/${c.tempo.name}',
      ];
      expect(roll(), roll());
    });

    test('gaits do not change prices', () {
      final m = Market.rolled(t0, Random(4));
      for (final c in m.offers) {
        for (final t in CompanionType.values) {
          expect(m.priceOf(c.copyWith(tempo: t)), m.priceOf(c));
          expect(m.sellPriceOf(c.copyWith(tempo: t)), m.sellPriceOf(c));
        }
      }
    });

    test('the game rolls its market around the companion along', () {
      final start = GameData.initial(t0);
      final dune = Companion.fresh(
        id: 'dune-1',
        speciesId: 'dune',
        rarity: Rarity.common,
      );
      final game = start.copyWith(
        companions: [...start.companions, dune],
        activeCompanionId: 'dune-1',
      );
      for (var seed = 0; seed < 50; seed++) {
        final offers = game.withMarket(t0, Random(seed)).market!.offers;
        expect(
          offers.where((c) => c.tempo == CompanionType.gale).length,
          greaterThanOrEqualTo(3),
        );
      }
    });

    test('a bought offer keeps its gait', () {
      final game = GameData.initial(
        t0,
      ).copyWith(lp: 100000).withMarket(t0, Random(5));
      final offer = game.market!.offers.firstWhere(
        (c) => c.tempo != c.species.type,
      );
      final bought = game.buying(offer.id);
      final owned = bought.companions.firstWhere((c) => c.id == offer.id);
      expect(owned.tempo, offer.tempo);
      final back = GameData.fromJson(
        jsonDecode(jsonEncode(bought.toJson())) as Map<String, Object?>,
      );
      expect(
        back.companions.firstWhere((c) => c.id == offer.id).tempo,
        offer.tempo,
      );
    });
  });

  group('save game version 6', () {
    Map<String, Object?> v5File() {
      final start = GameData.initial(t0);
      final dune = Companion.fresh(
        id: 'dune-1',
        speciesId: 'dune',
        rarity: Rarity.rare,
      );
      final game = start
          .copyWith(companions: [...start.companions, dune])
          .withMarket(t0, Random(3));
      final json =
          jsonDecode(jsonEncode(game.toJson())) as Map<String, Object?>;
      // Version 5 files have no gaits; give one a stray key to drop.
      final owned = [
        for (final c in json['companions']! as List<Object?>)
          {...c! as Map<String, Object?>}..remove('tempo'),
      ];
      owned.first['tempo'] = 'gale';
      final market = json['market']! as Map<String, Object?>;
      json['companions'] = owned;
      json['market'] = {
        ...market,
        'offers': [
          for (final c in market['offers']! as List<Object?>)
            {...c! as Map<String, Object?>}..remove('tempo'),
        ],
      };
      return {
        'format': SaveGame.format,
        'version': 5,
        'exportedAt': t0.toIso8601String(),
        'game': json,
      };
    }

    test('version 5 files import with every home gait', () {
      final loaded = SaveGame.decode(utf8.encode(jsonEncode(v5File()))).game;
      for (final c in loaded.companions) {
        expect(c.tempo, c.species.type, reason: c.id);
      }
      expect(loaded.companions.first.tempo, CompanionType.moss);
      for (final c in loaded.market!.offers) {
        expect(c.tempo, c.species.type, reason: c.id);
      }
    });

    test('version 6 files keep their gaits; unknown ones go home', () {
      final start = GameData.initial(t0);
      final fast = start.companions.single.copyWith(tempo: CompanionType.gale);
      final game = start.copyWith(companions: [fast]).withMarket(t0, Random(3));
      final file =
          jsonDecode(utf8.decode(SaveGame.encode(game, t0)))
              as Map<String, Object?>;
      expect(file['version'], SaveGame.version);
      final loaded = SaveGame.decode(utf8.encode(jsonEncode(file))).game;
      expect(loaded.companions.single.tempo, CompanionType.gale);
      expect(
        [for (final c in loaded.market!.offers) c.tempo],
        [for (final c in game.market!.offers) c.tempo],
      );

      final g = file['game']! as Map<String, Object?>;
      g['companions'] = [
        {
          ...(g['companions']! as List<Object?>).single!
              as Map<String, Object?>,
          'tempo': 'hover',
        },
      ];
      final odd = SaveGame.decode(utf8.encode(jsonEncode(file))).game;
      expect(odd.companions.single.tempo, CompanionType.moss);
    });
  });
}
