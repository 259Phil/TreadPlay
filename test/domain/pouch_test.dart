import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/forge.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/wanderweg.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  RunSummary run(
    double m, {
    double breath = 6,
    bool valid = true,
    String companion = 'pebble-1',
    DateTime? at,
  }) => RunSummary(
    companionId: companion,
    startedAt: at ?? t0,
    duration: const Duration(minutes: 30),
    distanceM: m,
    steps: 0,
    lp: 1,
    breathUsed: breath,
    valid: valid,
    tankSize: 6,
  );

  /// Waymarks 1..[n] reached (Forge open from 2).
  GameData at(int n, {GameData? from}) => (from ?? GameData.initial(t0))
      .copyWith(wanderweg: WanderwegProgress(reachedAt: List.filled(n, t0)));

  group('find chance', () {
    test('43 % for a full tank, less for less Breath, one tank at most', () {
      expect(Pouches.chance(breathUsed: 6, tankSize: 6), closeTo(.43, 1e-9));
      expect(Pouches.chance(breathUsed: 3, tankSize: 6), closeTo(.215, 1e-9));
      // Two tanks in one run still count as one.
      expect(Pouches.chance(breathUsed: 12, tankSize: 6), closeTo(.43, 1e-9));
      expect(Pouches.chance(breathUsed: 0, tankSize: 6), 0);
    });

    test('Fortune raises the chance, never above 100 %', () {
      final base = Pouches.chance(breathUsed: 6, tankSize: 6);
      final lucky = Pouches.chance(
        breathUsed: 6,
        tankSize: 6,
        fortuneFactor: 1.15,
      );
      expect(lucky, closeTo(base * 1.15, 1e-9));
      expect(Pouches.chance(breathUsed: 6, tankSize: 6, fortuneFactor: 3), 1.0);
    });

    test('Fortune seals of the companion on the run count', () {
      final pebble = Companion.pebble().withSeal(
        0,
        const Seal(SealType.fortune, 3),
      );
      final game = at(1, from: GameData.initial(t0))
          .copyWith(companions: [pebble])
          .hangingPouch(PouchColor.brown, t0); // first pouch done
      final r = run(1500);
      expect(game.fortuneFactorFor(r), greaterThan(1));
      expect(
        game.pouchChanceFor(r),
        closeTo(Pouches.fullTankChance * pebble.fortuneFactor, 1e-9),
      );
    });

    test('no pouch before waymark 1 or for invalid runs', () {
      expect(GameData.initial(t0).pouchChanceFor(run(500)), 0);
      expect(at(1).pouchChanceFor(run(1500, valid: false)), 0);
      expect(at(1).pouchChanceFor(run(1500, breath: 0)), 0);
    });

    test('the very first pouch is sure', () {
      expect(at(1).pouchChanceFor(run(800, breath: 1)), 1);
    });
  });

  group('runs find pouches', () {
    test('a seeded run finds a brown pouch and gives no extra Glut', () {
      final game = at(
        2,
      ).copyWith(lp: 0).recordingRun(run(1500), random: Random(7));
      expect(game.pouches.leash.single.color, PouchColor.brown);
      expect(game.pouches.foundOf(PouchColor.brown), 1);
      expect(game.lastRun!.pouch, PouchColor.brown);
      expect(game.lastRun!.glut, 0);
      expect(game.forge.glut, 0);
    });

    test('a run without a pouch still brings the small run Glut', () {
      final game = at(2)
          .hangingPouch(PouchColor.brown, t0)
          .recordingRun(run(1500), random: _Fixed(.99));
      expect(game.pouches.leash, hasLength(1));
      expect(game.lastRun!.pouch, isNull);
      expect(game.lastRun!.glut, Forge.glutPerRun);
      expect(game.forge.glut, Forge.glutPerRun);
    });

    test('seeded runs find about 43 % with a full tank', () {
      final random = Random(2026);
      var game = at(1).hangingPouch(PouchColor.brown, t0);
      var finds = 0;
      for (var i = 0; i < 2000; i++) {
        final next = game.recordingRun(run(100), random: random);
        if (next.lastRun!.pouch != null) finds++;
        // Keep the leash empty-ish so it never blocks.
        game = next.copyWith(
          pouches: next.pouches.copyWith(leash: const []),
          runs: const [],
        );
      }
      expect(finds / 2000, closeTo(.43, .035));
    });

    test('a full leash finds nothing and says so', () {
      var game = at(1);
      for (var i = 0; i < 3; i++) {
        game = game.hangingPouch(PouchColor.brown, t0);
      }
      expect(game.leashFull, isTrue);
      final next = game.recordingRun(run(500), random: _Fixed(0));
      expect(next.pouches.leash, hasLength(3));
      expect(next.lastRun!.leashFull, isTrue);
      expect(next.lastRun!.pouch, isNull);
    });

    test('the 4th clip comes with waymark 7 and counts leash fills', () {
      var game = at(7);
      expect(game.leashClips, 4);
      for (var i = 0; i < 4; i++) {
        game = game.hangingPouch(PouchColor.brown, t0);
      }
      expect(game.pouches.leashFills, 1);
      expect(game.waymarkCounters[WaymarkCounter.leashFilled], 1);
      expect(at(6).leashClips, 3);
    });

    test('a newly unlocked colour comes first, then by weight', () {
      final r = Random(3);
      expect(
        Pouches.pickColor(
          [PouchColor.brown, PouchColor.copper],
          {PouchColor.brown: 4},
          r,
        ),
        PouchColor.copper,
      );
      final counts = <PouchColor, int>{};
      final all = PouchColor.values;
      final found = {for (final c in all) c: 1};
      for (var i = 0; i < 10000; i++) {
        final c = Pouches.pickColor(all, found, r);
        counts[c] = (counts[c] ?? 0) + 1;
      }
      expect(counts[PouchColor.brown]! / 10000, closeTo(.61, .03));
      expect(counts[PouchColor.navy]! / 10000, closeTo(.04, .015));
    });

    test('a messenger can hang a pouch too (hook)', () {
      final game = at(
        1,
      ).hangingPouch(PouchColor.brown, t0, source: PouchSource.messenger);
      expect(game.pouches.leash, hasLength(1));
    });
  });

  group('Fortune and colours', () {
    test('Fortune tilts the weights by colour rank, capped at +47 %', () {
      for (final c in PouchColor.values) {
        expect(Pouches.colorWeight(c, 1), c.findWeight.toDouble());
      }
      expect(
        Pouches.colorWeight(PouchColor.brown, 1.15),
        PouchColor.brown.findWeight.toDouble(),
      );
      expect(
        Pouches.colorWeight(PouchColor.navy, 1.15),
        closeTo(4 * pow(1.15, 3), 1e-9),
      );
      expect(
        Pouches.colorWeight(PouchColor.navy, 3),
        Pouches.colorWeight(PouchColor.navy, 1 + Pouches.fortuneColorCap),
      );
      // Below ×1 nothing is taken away.
      expect(Pouches.colorWeight(PouchColor.navy, .5), 4);
    });

    test('rarer colours gain share with Fortune, brown loses', () {
      final all = PouchColor.values;
      final base = Pouches.colorShares(all, 1);
      final lucky = Pouches.colorShares(all, 1.29);
      final max = Pouches.colorShares(all, 9);
      expect(base.values.fold(0.0, (a, b) => a + b), closeTo(1, 1e-9));
      expect(max.values.fold(0.0, (a, b) => a + b), closeTo(1, 1e-9));
      expect(base[PouchColor.navy], closeTo(.04, 1e-9));
      expect(lucky[PouchColor.navy]!, greaterThan(base[PouchColor.navy]!));
      expect(max[PouchColor.navy]!, greaterThan(lucky[PouchColor.navy]!));
      expect(max[PouchColor.navy]!, lessThan(.1));
      expect(lucky[PouchColor.brown]!, lessThan(base[PouchColor.brown]!));
    });

    test('a newly unlocked colour still comes first with Fortune', () {
      expect(
        Pouches.pickColor(
          [PouchColor.brown, PouchColor.copper, PouchColor.turquoise],
          {PouchColor.brown: 3, PouchColor.copper: 1},
          _Fixed(.999),
          fortuneFactor: 1.4,
        ),
        PouchColor.turquoise,
      );
    });

    test('seeded finds with full Fortune bring navy about 9.6 %', () {
      final r = Random(77);
      final all = PouchColor.values;
      final found = {for (final c in all) c: 1};
      var navy = 0;
      for (var i = 0; i < 20000; i++) {
        if (Pouches.pickColor(all, found, r, fortuneFactor: 1.47) ==
            PouchColor.navy) {
          navy++;
        }
      }
      expect(
        navy / 20000,
        closeTo(Pouches.colorShares(all, 1.47)[PouchColor.navy]!, .01),
      );
    });

    test('runs use the Fortune of the companion on the run', () {
      final lucky = Companion.pebble().withSeal(
        0,
        const Seal(SealType.fortune, 5),
      );
      var game = at(14).copyWith(companions: [lucky]);
      for (final c in PouchColor.values) {
        game = game.hangingPouch(c, t0);
      }
      game = game.copyWith(pouches: game.pouches.copyWith(leash: const []));
      final plain = game.copyWith(companions: [Companion.pebble()]);
      // Same rolls: 0 finds, .95 picks the colour.
      final a = plain.recordingRun(run(100), random: _Seq([0, .95]));
      final b = game.recordingRun(run(100), random: _Seq([0, .95]));
      expect(a.lastRun!.pouch, PouchColor.turquoise);
      expect(lucky.fortuneFactor, greaterThan(1.2));
      expect(b.lastRun!.pouch!.index, greaterThan(a.lastRun!.pouch!.index));
    });
  });

  group('warming and fading', () {
    test('runs walk pouches warm; a warm pouch opens for free', () {
      var game = at(1).hangingPouch(PouchColor.copper, t0);
      expect(game.pouches.leash.single.openLp, PouchColor.copper.openLp);
      game = game.recordingRun(run(600));
      final p = game.pouches.leash.single;
      expect(p.warmedM, 600);
      expect(p.openLp, (41 * (1 - 600 / 1500)).ceil());
      game = game.recordingRun(run(900));
      expect(game.pouches.leash.single.ready, isTrue);
      expect(game.pouches.leash.single.openLp, 0);
      expect(game.lastRun!.pouchesWarmed, 1);
    });

    test('invalid runs do not warm', () {
      final game = at(
        1,
      ).hangingPouch(PouchColor.brown, t0).recordingRun(run(900, valid: false));
      expect(game.pouches.leash.single.warmedM, 0);
    });

    test('unwarmed pouches fade after a day, warm ones stay', () {
      final ready = Pouch(color: PouchColor.brown, foundAt: t0, warmedM: 1000);
      var game = at(1).copyWith(
        pouches: PouchState(
          leash: [
            Pouch(color: PouchColor.brown, foundAt: t0),
            ready,
          ],
        ),
      );
      game = game.agingPouches(t0.add(const Duration(hours: 23)));
      expect(game.pouches.leash, hasLength(2));
      game = game.agingPouches(t0.add(const Duration(hours: 24, minutes: 1)));
      expect(game.pouches.leash.single.ready, isTrue);
      expect(game.pouches.faded, 1);
    });

    test('a warming run restarts the day', () {
      final p = Pouch(
        color: PouchColor.navy,
        foundAt: t0,
      ).warmed(100, t0.add(const Duration(hours: 20)));
      expect(p.fadedBy(t0.add(const Duration(hours: 30))), isFalse);
      expect(p.fadedBy(t0.add(const Duration(hours: 45))), isTrue);
    });
  });

  group('opening', () {
    test('LP opening pays the price and fills the case', () {
      final game = at(1).copyWith(lp: 50).hangingPouch(PouchColor.brown, t0);
      final (next, rewards) = game.openingPouch(0, Random(1));
      expect(next.lp, 50 - PouchColor.brown.openLp);
      expect(next.pouches.leash, isEmpty);
      expect(next.pouches.openedOf(PouchColor.brown), 1);
      final glut = rewards
          .where((r) => r.kind == PouchRewardKind.glut)
          .fold(0, (n, r) => n + r.amount);
      expect(next.forge.glut, glut);
      expect(next.waymarkCounters[WaymarkCounter.brownPouchesOpened], 1);
    });

    test('too few LP blocks a cold pouch, a warm one is free', () {
      final cold = at(1).copyWith(lp: 5).hangingPouch(PouchColor.navy, t0);
      expect(cold.openPouchBlock(0), PouchBlock.notEnoughLp);
      final warm = cold.copyWith(
        pouches: cold.pouches.copyWith(
          leash: [cold.pouches.leash.single.warmed(3000, t0)],
        ),
      );
      expect(warm.openPouchBlock(0), isNull);
      expect(warm.openingPouch(0, Random(1)).$1.lp, 5);
      expect(cold.openPouchBlock(3), PouchBlock.gone);
    });
  });

  group('contents tables', () {
    test('prices and walk distances grow with the colour', () {
      expect([for (final c in PouchColor.values) c.openLp], [23, 41, 67, 113]);
      expect(
        [for (final c in PouchColor.values) c.walkM],
        [1000, 1500, 2000, 3000],
      );
    });

    test('never above L3, navy tops at L3, brown only L1', () {
      expect(Pouches.tables[PouchColor.brown]!.maxSeal, 1);
      expect(Pouches.tables[PouchColor.copper]!.maxSeal, 2);
      expect(Pouches.tables[PouchColor.turquoise]!.maxSeal, 2);
      expect(Pouches.tables[PouchColor.navy]!.maxSeal, 3);
    });

    test('every roll has Glut first and 1–3 compartments after it', () {
      final r = Random(99);
      for (final c in PouchColor.values) {
        final t = Pouches.tables[c]!;
        final sizes = <int>{};
        for (var i = 0; i < 3000; i++) {
          final got = Pouches.roll(c, r);
          expect(got.first.kind, PouchRewardKind.glut);
          expect(got.first.amount, inInclusiveRange(t.glutMin, t.glutMax));
          final extra = got.length - 1;
          expect(extra, inInclusiveRange(1, 3));
          sizes.add(extra);
          for (final x in got.skip(1)) {
            if (x.kind == PouchRewardKind.seal) {
              expect(x.seal!.level, lessThanOrEqualTo(t.maxSeal));
              expect(x.seal!.combined, isFalse);
            }
          }
        }
        if (c == PouchColor.copper) expect(sizes, {1, 2});
      }
    });

    test('a seeded roll is the same every time', () {
      expect(
        Pouches.roll(PouchColor.navy, Random(5)),
        Pouches.roll(PouchColor.navy, Random(5)),
      );
    });
  });

  group('Wanderweg', () {
    test('opening a brown pouch reaches waymark 2 with its km', () {
      var game = GameData.initial(
        t0,
      ).recordingRun(run(2400), random: _Fixed(0));
      // Waymark 1 reached on this run, and the first pouch came with it.
      expect(game.wanderweg.reached, 1);
      expect(game.pouches.leash.single.color, PouchColor.brown);
      game = game.copyWith(lp: 100).openingPouch(0, Random(1)).$1;
      game = game.advancingWanderweg(t0);
      expect(game.wanderweg.reached, 2);
      expect(game.unlocks.forge, isTrue);
    });

    test('reached pouch waymarks stay when pouch counts are lost', () {
      final game = at(14).copyWith(pouches: const PouchState());
      expect(game.advancingWanderweg(t0).wanderweg.reached, 14);
      final back = GameData.fromJson(game.toJson()..remove('pouches'), now: t0);
      expect(back.wanderweg.reached, 14);
    });
  });

  group('save game', () {
    Uint8List file(Map<String, Object?> game, int version) =>
        Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              'format': 'treadplay-save',
              'version': version,
              'exportedAt': t0.toIso8601String(),
              'game': game,
            }),
          ),
        );

    final withPouches = at(7)
        .hangingPouch(PouchColor.copper, t0)
        .hangingPouch(PouchColor.brown, t0)
        .copyWith(lp: 100);
    final opened = withPouches.openingPouch(1, Random(2)).$1;

    test('export and import keep the leash and the counts', () {
      final loaded = SaveGame.decode(SaveGame.encode(opened, t0)).game;
      expect(SaveGame.version, 12);
      expect(loaded.pouches.leash, hasLength(1));
      expect(loaded.pouches.leash.single.color, PouchColor.copper);
      expect(loaded.pouches.foundOf(PouchColor.copper), 1);
      expect(loaded.pouches.openedOf(PouchColor.brown), 1);
      expect(
        jsonEncode(loaded.pouches.toJson()),
        jsonEncode(opened.pouches.toJson()),
      );
    });

    test('version 3 files import with an empty leash', () {
      final json = opened.toJson();
      final loaded = SaveGame.decode(file(json, 3)).game;
      expect(loaded.pouches.leash, isEmpty);
      expect(loaded.pouches.foundTotal, 0);
      expect(loaded.wanderweg.reached, 7);
    });

    test('broken pouches in a version 4 file are rejected', () {
      final json = opened.toJson()
        ..['pouches'] = {
          'leash': [
            {'color': 'gold', 'foundAt': t0.toIso8601String()},
          ],
        };
      expect(
        () => SaveGame.decode(file(json, 4)),
        throwsA(
          isA<SaveGameException>().having(
            (e) => e.error,
            'error',
            SaveGameError.damaged,
          ),
        ),
      );
    });

    test('a new game has no pouches', () {
      expect(GameData.initial(t0).pouches.leash, isEmpty);
      expect(GameData.initial(t0).pouches.foundTotal, 0);
    });
  });
}

class _Fixed implements Random {
  _Fixed(this.roll);

  final double roll;

  @override
  double nextDouble() => roll;

  @override
  bool nextBool() => true;

  @override
  int nextInt(int max) => 0;
}

class _Seq implements Random {
  _Seq(this.rolls);

  final List<double> rolls;
  var _i = 0;

  @override
  double nextDouble() => rolls[_i++ % rolls.length];

  @override
  bool nextBool() => true;

  @override
  int nextInt(int max) => 0;
}
