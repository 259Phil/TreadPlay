import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/data/species.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/totals.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/domain/world.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);
  final t1 = DateTime(2026, 2, 1, 8);

  RunSummary run(double m, {double? share, bool valid = true}) => RunSummary(
    companionId: 'pebble-1',
    startedAt: t0,
    duration: const Duration(minutes: 30),
    distanceM: m,
    steps: 0,
    lp: 1,
    breathUsed: 1,
    valid: valid,
    sweetSpotShare: share,
  );

  /// A game that opened one brown pouch (the waymark 2 task).
  GameData brownOpened([GameData? from]) {
    final g = (from ?? GameData.initial(t0)).hangingPouch(PouchColor.brown, t0);
    final lp = g.lp;
    return g.copyWith(lp: 1000).openingPouch(0, Random(1)).$1.copyWith(lp: lp);
  }

  GameData walked(double km, {GameData? from}) => (from ?? GameData.initial(t0))
      .recordingRun(run(km * 1000))
      .advancingWanderweg(t1);

  group('plan data', () {
    test('19 waymarks with the km thresholds of the plan', () {
      expect(waymarks, hasLength(19));
      expect(
        [for (final w in waymarks) w.km],
        [
          0.7, 2.3, 4.1, 6.8, 9.4, 13.2, 17.6, 22.9, 28.4, 34.7, //
          41.3, 48.6, 57.2, 66.9, 77.4, 88.8, 101.3, 114.7, 128.2,
        ],
      );
      for (var i = 0; i < waymarks.length; i++) {
        expect(waymarks[i].number, i + 1);
        // Even waymarks carry tasks, odd ones are distance only.
        expect(waymarks[i].tasks.isEmpty, i.isEven);
      }
      expect({
        for (final w in waymarks) w.unlock,
      }, hasLength(WaymarkUnlock.values.length));
    });
  });

  group('thresholds', () {
    test('a waymark is reached exactly at its km', () {
      expect(walked(0.69).wanderweg.reached, 0);
      expect(walked(0.7).wanderweg.reached, 1);
      // Reached when the run that crossed it ends.
      expect(
        walked(0.7).wanderweg.reachedAt.single,
        t0.add(const Duration(minutes: 30)),
      );
    });

    test('invalid runs do not move along the trail', () {
      final game = GameData.initial(
        t0,
      ).recordingRun(run(5000, valid: false)).advancingWanderweg(t1);
      expect(game.wanderweg.reached, 0);
    });

    test('distance-only waymarks fall one after the other', () {
      // WM2 asks for an opened brown pouch, WM4 for a placed seal, which a
      // fresh game does not have.
      expect(walked(10).wanderweg.reached, 1);
      final game = walked(10, from: brownOpened());
      expect(game.wanderweg.reached, 3);
      expect(game.wanderweg.next!.number, 4);
    });
  });

  group('tasks', () {
    test('a set seal completes waymark 4', () {
      var game = walked(10, from: brownOpened());
      game = game
          .buyingSeal(SealType.stride)
          .settingSeal('pebble-1', const Seal(SealType.stride, 1))
          .copyWith(lp: 100)
          .advancingWanderweg(t1);
      expect(game.wanderweg.reached, 5);
    });

    test('sweet spot runs count at 58 % and 71 %', () {
      var t = const Totals();
      t = t.addingRun(run(100, share: 0.579));
      t = t.addingRun(run(100, share: 0.58));
      t = t.addingRun(run(100, share: 0.71));
      t = t.addingRun(run(100, share: 0.9, valid: false));
      expect(t.sweetSpot58Runs, 2);
      expect(t.sweetSpot71Runs, 1);
    });

    test('waymark 6 waits for a sweet spot run and a messenger', () {
      var game = brownOpened()
          .copyWith(wanderweg: const WanderwegProgress(legacyForge: true))
          .buyingSeal(SealType.grit)
          .settingSeal('pebble-1', const Seal(SealType.grit, 1))
          .copyWith(lp: 0);
      game = walked(14, from: game);
      expect(game.wanderweg.reached, 5);
      final c = game.waymarkCounters;
      expect(
        c.met(const WaymarkTask(WaymarkCounter.messengersMet, 1)),
        isFalse,
      );
      game = game.recordingRun(run(100, share: 0.6)).advancingWanderweg(t1);
      expect(game.wanderweg.reached, 5, reason: 'no messenger met yet');
      // From waymark 5 the first messenger is sure after a valid run.
      game = game.recordingRun(run(1200), random: Random(3));
      expect(game.messengers.met, 1);
      expect(game.lastRun!.messenger, isNotNull);
      expect(game.advancingWanderweg(t1).wanderweg.reached, 6);
    });

    test('buying in the market counts for waymark 14', () {
      final game = GameData.initial(t0).withMarket(t0, Random(1));
      final offer = game.market!.offers.first;
      final bought = game.copyWith(lp: 10000).buying(offer.id);
      expect(bought.totals.companionsBought, 1);
      expect(bought.waymarkCounters[WaymarkCounter.companionsBought], 1);
    });
  });

  group('retroactive counting', () {
    test('old saves count sweet spot runs and bought companions', () {
      final gilt = Companion.fresh(
        id: 'm123-0',
        speciesId: 'gilt',
        rarity: Rarity.rare,
      );
      final json = GameData.initial(t0)
          .copyWith(
            companions: [Companion.pebble(), gilt],
            runs: [run(2000, share: 0.75), run(2000, share: 0.6)],
          )
          .toJson();
      (json['totals']! as Map<String, Object?>)
        ..remove('sweetSpot58Runs')
        ..remove('sweetSpot71Runs')
        ..remove('companionsBought');
      json.remove('wanderweg');
      final game = GameData.fromJson(json, now: t1);
      expect(game.totals.sweetSpot58Runs, 2);
      expect(game.totals.sweetSpot71Runs, 1);
      expect(game.totals.companionsBought, 1);
    });

    test('seals already set count as forged and placed', () {
      final pebble = Companion.pebble().withCharm(0, SealType.stride.name);
      final game = GameData.initial(t0).copyWith(companions: [pebble]);
      expect(game.waymarkCounters[WaymarkCounter.sealsPlaced], 1);
      expect(game.unlocks.forge, isTrue);
    });

    test('old saves get every waymark their km allow, tasks not asked', () {
      final json = GameData.initial(t0).recordingRun(run(30000)).toJson()
        ..remove('wanderweg');
      final game = GameData.fromJson(json, now: t1);
      expect(game.wanderweg.reached, 9);
      expect(game.wanderweg.unseen, 9);
      expect(game.unlocks.forge, isTrue);
      expect(game.wanderweg.legacyForge, isTrue);
    });
  });

  group('never re-lock', () {
    test('reached waymarks stay after the counters drop', () {
      var game = walked(10, from: brownOpened());
      game = game
          .buyingSeal(SealType.stride)
          .settingSeal('pebble-1', const Seal(SealType.stride, 1))
          .advancingWanderweg(t1);
      expect(game.wanderweg.reached, 5);
      // Seal removed, runs erased: nothing is taken back.
      game = game
          .clearingSeal('pebble-1', 0)
          .erasingRuns()
          .advancingWanderweg(t1);
      expect(game.wanderweg.reached, 5);
      final back = GameData.fromJson(game.toJson(), now: t1);
      expect(back.wanderweg.reached, 5);
      expect(back.advancingWanderweg(t1).wanderweg.reached, 5);
    });

    test('progress can only grow', () {
      const p = WanderwegProgress();
      final counters = WaymarkCounters(
        distanceM: 3000,
        values: const {WaymarkCounter.brownPouchesOpened: 1},
      );
      final grown = p.advanced(counters, t1);
      expect(grown.reached, 2);
      final same = grown.advanced(
        WaymarkCounters(distanceM: 0, values: const {}),
        t1,
      );
      expect(identical(same, grown), isTrue);
    });
  });

  group('unlocks', () {
    test('a new game has the Forge closed and only Medieval unlocked; the '
        'market tops up with the next trail worlds', () {
      final game = GameData.initial(t0);
      expect(game.unlocks.forge, isFalse);
      expect(game.marketWorlds, {World.medieval});
      final market = game.withMarket(t0, Random(3)).market!;
      expect(
        market.offers.every(
          (c) => const {
            World.medieval,
            World.jungle,
            World.underwater,
          }.contains(speciesById[c.speciesId]!.world),
        ),
        isTrue,
      );
    });

    test('waymarks open the Forge and the market pool step by step', () {
      expect(walked(4.1).unlocks.forge, isFalse);
      final game = walked(4.1, from: brownOpened());
      expect(game.unlocks.forge, isTrue);
      expect(game.marketWorlds, {World.medieval, World.jungle});
    });

    test('species in the den stay in the market pool', () {
      final brine = Companion.fresh(
        id: 'brine-1',
        speciesId: 'brine',
        rarity: Rarity.common,
      );
      final game = GameData.initial(
        t0,
      ).copyWith(companions: [Companion.pebble(), brine]);
      expect(game.marketWorlds, contains(World.underwater));
    });

    test('waymark 17 adds two den slots', () {
      final all = WanderwegProgress(
        reachedAt: List.filled(17, t1),
        legacyForge: true,
      );
      final game = GameData.initial(t0).copyWith(wanderweg: all);
      expect(game.shelfSlots, 14);
      expect(GameData.initial(t0).shelfSlots, 12);
      expect(game.unlocks.forgeLevel, 5);
      expect(game.unlocks.combineLevel, 5);
      expect(game.unlocks.leashClips, 4);
    });
  });

  group('save game', () {
    test('export and import keep the reached waymarks', () {
      final game = walked(
        30,
      ).copyWith(wanderweg: walked(30).wanderweg.markedSeen());
      final loaded = SaveGame.decode(SaveGame.encode(game, t1)).game;
      expect(loaded.wanderweg.reached, game.wanderweg.reached);
      expect(loaded.wanderweg.reachedAt, game.wanderweg.reachedAt);
      expect(loaded.wanderweg.seen, game.wanderweg.seen);
      expect(loaded.totals.sweetSpot58Runs, game.totals.sweetSpot58Runs);
    });

    test('version 1 files still import and get their km waymarks', () {
      final json = walked(10).toJson()..remove('wanderweg');
      final bytes = Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'format': 'treadplay-save',
            'version': 1,
            'exportedAt': t0.toIso8601String(),
            'game': json,
          }),
        ),
      );
      final loaded = SaveGame.decode(bytes).game;
      // Legacy grant: km only, so waymark 4's seal task is not asked.
      expect(loaded.wanderweg.reached, 5);
      expect(loaded.unlocks.forge, isTrue);
      expect(SaveGame.version, 12);
    });
  });
}
