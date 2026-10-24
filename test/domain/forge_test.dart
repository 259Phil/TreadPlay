import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/forge.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/totals.dart';
import 'package:treadplay/domain/wanderweg.dart';

/// Returns [rolls] in turn for nextDouble; nextBool follows [bools].
class _Fixed implements Random {
  _Fixed(this.rolls, [this.bools = const [true]]);

  final List<double> rolls;
  final List<bool> bools;
  int _i = 0;
  int _b = 0;

  @override
  double nextDouble() => rolls[_i++ % rolls.length];

  @override
  bool nextBool() => bools[_b++ % bools.length];

  @override
  int nextInt(int max) => 0;
}

void main() {
  final t0 = DateTime(2026, 1, 1, 8);
  const stride1 = Seal(SealType.stride, 1);
  const grit3 = Seal(SealType.grit, 3);
  const stride3 = Seal(SealType.stride, 3);

  final gilt = Companion.fresh(
    id: 'gilt-1',
    speciesId: 'gilt',
    rarity: Rarity.legendary,
  );

  /// All 19 waymarks reached: every forge level and combine open.
  final allOpen = WanderwegProgress(
    reachedAt: List.filled(waymarks.length, t0),
  );

  GameData game({
    double lp = 10000,
    Map<String, int> stock = const {},
    int glut = 50,
    WanderwegProgress? wanderweg,
  }) {
    final start = GameData.initial(t0);
    return start.copyWith(
      lp: lp,
      companions: [...start.companions, gilt],
      wanderweg: wanderweg ?? allOpen,
      forge: ForgeState(stock: stock, glut: glut),
    );
  }

  group('seal values', () {
    test('single seals L1–L5 give +4/9/15/22/31 %', () {
      expect(
        [for (var l = 1; l <= 5; l++) Seal(SealType.grit, l).bonus],
        [0.04, 0.09, 0.15, 0.22, 0.31],
      );
    });

    test('combined seals give +9/+9 % at L3 and +19/+19 % at L5', () {
      final k3 = Seal.combined(SealType.grit, SealType.stride, 3);
      final k5 = Seal.combined(SealType.fortune, SealType.stride, 5);
      expect(k3.bonusOn(SealType.stride), 0.09);
      expect(k3.bonusOn(SealType.grit), 0.09);
      expect(k3.bonusOn(SealType.fortune), 0);
      expect(k5.bonusOn(SealType.stride), 0.19);
      expect(k5.bonusOn(SealType.fortune), 0.19);
      expect(
        () => Seal.combined(SealType.grit, SealType.grit, 3),
        throwsArgumentError,
      );
      expect(
        () => Seal.combined(SealType.grit, SealType.stride, 4),
        throwsRangeError,
      );
    });

    test('codes round-trip; order of a combined seal does not matter', () {
      final k = Seal.combined(SealType.stride, SealType.grit, 5);
      expect(k.code, 'stride+grit@5');
      expect(Seal.tryParse(k.code), k);
      expect(Seal.combined(SealType.grit, SealType.stride, 5), k);
      expect(Seal.tryParse('fortune@4'), const Seal(SealType.fortune, 4));
      for (final bad in [
        'stride@0',
        'stride@6',
        'grit+stride@5',
        'stride+stride@3',
        'stride+grit@4',
        'x@1',
        'stride@01',
        '',
      ]) {
        expect(Seal.tryParse(bad), isNull, reason: bad);
      }
      // Bare names from before seal levels.
      expect(
        Seal.tryParse('grit'),
        const Seal(SealType.grit, Seal.legacyLevel),
      );
    });

    test('stride seals scale LP per Breath by (1 + bonus)', () {
      final sealed = gilt.withSeal(0, const Seal(SealType.stride, 5));
      expect(sealed.strideTotal, closeTo(gilt.stride * 1.31, 1e-9));
      expect(sealed.lpPerBreath, closeTo(gilt.lpPerBreath * 1.31, 1e-9));
      expect(sealed.gritTotal, gilt.grit);
    });

    test('Common example from the plan: 2.5 LP per Breath → 3.28 at L5', () {
      final pebble = Companion.pebble().withSeal(
        0,
        const Seal(SealType.stride, 5),
      );
      expect(pebble.lpPerBreath, closeTo(3.275, 1e-9));
    });

    test('a stat caps at +47 %', () {
      // L5 + L4 = 53 % → 47 %.
      var c = gilt
          .withSeal(0, const Seal(SealType.stride, 5))
          .withSeal(1, const Seal(SealType.stride, 4));
      expect(c.rawSealBonus(SealType.stride), closeTo(0.53, 1e-9));
      expect(c.sealBonus(SealType.stride), 0.47);
      expect(c.sealCapped(SealType.stride), isTrue);
      // Three L5 = 93 % → 47 %.
      c = c
          .withSeal(1, const Seal(SealType.stride, 5))
          .withSeal(2, const Seal(SealType.stride, 5));
      expect(c.sealBonus(SealType.stride), 0.47);
      expect(c.strideTotal, closeTo(gilt.stride * 1.47, 1e-9));
      // Below the cap nothing is cut.
      final mixed = gilt
          .withSeal(0, const Seal(SealType.grit, 5))
          .withSeal(1, Seal.combined(SealType.grit, SealType.fortune, 3));
      expect(mixed.sealBonus(SealType.grit), closeTo(0.40, 1e-9));
      expect(mixed.sealCapped(SealType.grit), isFalse);
      expect(mixed.sealBonus(SealType.fortune), closeTo(0.09, 1e-9));
    });

    test('Grit divides Spirit loss, Fortune multiplies chances', () {
      final c = gilt
          .withSeal(0, const Seal(SealType.grit, 5))
          .withSeal(1, const Seal(SealType.fortune, 3));
      expect(c.spiritLossFactor, closeTo(1 / 1.31, 1e-9)); // about −24 %
      expect(c.fortuneFactor, closeTo(1.15, 1e-9));
    });
  });

  group('costs and fail chances (plan section 3)', () {
    test('a seal L1 costs 37 LP and goes into the case', () {
      final g = game(lp: 100).buyingSeal(SealType.stride);
      expect(g.lp, 63);
      expect(g.forge.count(stride1), 1);
      expect(g.totals.forgeUses, 1);
      expect(game(lp: 36.9).buySealBlock(), ForgeBlock.notEnoughLp);
      expect(game(lp: 37).buySealBlock(), isNull);
    });

    test('forge-up steps cost 13 / 34 / 79 / 167 LP', () {
      expect(
        [for (var l = 1; l <= 4; l++) Forge.upgrades[l]!.lp],
        [13, 34, 79, 167],
      );
      expect(
        [for (var l = 1; l <= 4; l++) Forge.upgrades[l]!.minGlut],
        [1, 1, 2, 3],
      );
      expect(Forge.combines[3]!.lp, 97);
      expect(Forge.combines[5]!.lp, 233);
    });

    test('fail chance at min and at 5 Glut matches the table', () {
      double at(ForgeStep s, int g) => (s.failChance(g) * 1000).round() / 1000;
      final u = Forge.upgrades;
      expect([at(u[1]!, 1), at(u[1]!, 5)], [0.12, 0.03]);
      expect([at(u[2]!, 1), at(u[2]!, 5)], [0.21, 0.07]);
      expect([at(u[3]!, 2), at(u[3]!, 5)], [0.29, 0.14]);
      expect([at(u[4]!, 3), at(u[4]!, 5)], [0.38, 0.23]);
      expect(
        [at(Forge.combines[3]!, 4), at(Forge.combines[3]!, 5)],
        [0.17, 0.11],
      );
      expect(at(Forge.combines[5]!, 5), 0.27);
    });

    test('each extra Glut lowers the fail chance by the same step', () {
      final s = Forge.upgrades[3]!; // 29 % at 2 Glut → 14 % at 5
      expect(s.failChance(3), closeTo(0.24, 1e-9));
      expect(s.failChance(4), closeTo(0.19, 1e-9));
      expect(s.allows(1), isFalse);
      expect(s.allows(6), isFalse);
    });

    test('the full path to one L5 without fails: 16 × L1 + 565 LP', () {
      // 8 forges L1→2, 4 L2→3, 2 L3→4, 1 L4→5.
      final lp =
          16 * Forge.sealCost +
          8 * Forge.upgrades[1]!.lp +
          4 * Forge.upgrades[2]!.lp +
          2 * Forge.upgrades[3]!.lp +
          Forge.upgrades[4]!.lp;
      expect(lp - 16 * Forge.sealCost, 565);
      final minGlut = 8 * 1 + 4 * 1 + 2 * 2 + 1 * 3;
      expect(minGlut, 19);
      expect(15 * 5, 75);
    });
  });

  group('forging up', () {
    test('success: 2 equal seals + LP + Glut → one seal a level higher', () {
      final g = game(lp: 100, stock: {'stride@1': 3}, glut: 4);
      final (next, out) = g.upgrading(stride1, 2, _Fixed([0.99]));
      expect(out.success, isTrue);
      expect(out.made, const Seal(SealType.stride, 2));
      expect(next.lp, 100 - 13);
      expect(next.forge.glut, 2);
      expect(next.forge.count(stride1), 1);
      expect(next.forge.count(const Seal(SealType.stride, 2)), 1);
      expect(next.forge.bestLevel, 2);
      expect(next.forge.attempts, 1);
      expect(next.totals.forgeUses, 1);
    });

    test(
      'fail: LP and Glut spent, one seal → 3 splinters, the other stays',
      () {
        final g = game(lp: 100, stock: {'stride@1': 2}, glut: 1);
        final (next, out) = g.upgrading(stride1, 1, _Fixed([0.05]));
        expect(out.success, isFalse);
        expect(out.broken, stride1);
        expect(next.lp, 87);
        expect(next.forge.glut, 0);
        expect(next.forge.count(stride1), 1);
        expect(next.forge.splinters, 3);
        expect(next.forge.fails, 1);
        expect(next.totals.forgeUses, 0);
      },
    );

    test('the roll is compared against the chance for the Glut used', () {
      final g = game(stock: {'grit@3': 2});
      // 3 Glut on L3→L4 = 24 %: 0.239 fails, 0.24 holds.
      expect(g.upgrading(grit3, 3, _Fixed([0.239])).$2.success, isFalse);
      expect(g.upgrading(grit3, 3, _Fixed([0.24])).$2.success, isTrue);
    });

    test('the same seed always gives the same results', () {
      List<bool> runWith(int seed) {
        final r = Random(seed);
        var g = game(stock: {'stride@1': 40}, glut: 100);
        final results = <bool>[];
        for (var i = 0; i < 15; i++) {
          final (next, out) = g.upgrading(stride1, 1, r);
          results.add(out.success);
          g = next;
        }
        return results;
      }

      expect(runWith(7), runWith(7));
      expect(runWith(7).where((s) => !s), isNotEmpty);
    });

    test('over many seeded tries the fail rate matches the chance', () {
      final r = Random(2026);
      var fails = 0;
      const n = 20000;
      final step = Forge.upgrades[4]!;
      for (var i = 0; i < n; i++) {
        if (Forge.rollsFail(step.failChance(3), r)) fails++;
      }
      expect(fails / n, closeTo(0.38, 0.015));
    });

    test('blocks: pair, level gate, Glut range, Glut and LP', () {
      expect(
        game(stock: {'stride@1': 1}).upgradeBlock(stride1, 1),
        ForgeBlock.needsPair,
      );
      final early = game(
        stock: {'stride@1': 2},
        wanderweg: WanderwegProgress(reachedAt: List.filled(4, t0)),
      );
      expect(early.unlocks.forgeLevel, 1);
      expect(early.upgradeBlock(stride1, 1), ForgeBlock.levelLocked);
      final g = game(stock: {'grit@3': 2, 'stride@5': 2}, glut: 2, lp: 78);
      expect(g.upgradeBlock(grit3, 1), ForgeBlock.glutRange);
      expect(g.upgradeBlock(grit3, 3), ForgeBlock.notEnoughGlut);
      expect(g.upgradeBlock(grit3, 2), ForgeBlock.notEnoughLp);
      expect(g.copyWith(lp: 79).upgradeBlock(grit3, 2), isNull);
      expect(
        g.upgradeBlock(const Seal(SealType.stride, 5), 5),
        ForgeBlock.maxLevel,
      );
      final locked = GameData.initial(t0).copyWith(
        lp: 1000,
        forge: const ForgeState(stock: {'stride@1': 2}, glut: 5),
      );
      expect(locked.upgradeBlock(stride1, 1), ForgeBlock.locked);
      expect(locked.buySealBlock(), ForgeBlock.locked);
    });

    test(
      'forge levels open along the trail: L2 at 5, L3 at 8, L4 at 12, L5 at 16',
      () {
        int levelAt(int reached) => WaymarkUnlocks(
          WanderwegProgress(reachedAt: List.filled(reached, t0)),
        ).forgeLevel;
        expect(
          [
            levelAt(1),
            levelAt(2),
            levelAt(5),
            levelAt(8),
            levelAt(12),
            levelAt(16),
          ],
          [0, 1, 2, 3, 4, 5],
        );
        int combineAt(int reached) => WaymarkUnlocks(
          WanderwegProgress(reachedAt: List.filled(reached, t0)),
        ).combineLevel;
        expect([combineAt(12), combineAt(13), combineAt(18)], [0, 3, 5]);
      },
    );
  });

  group('combining', () {
    test('two different L3 → one combined L3', () {
      final g = game(lp: 200, stock: {'grit@3': 1, 'stride@3': 1}, glut: 5);
      final (next, out) = g.combining(grit3, stride3, 4, _Fixed([0.5]));
      final k3 = Seal.combined(SealType.grit, SealType.stride, 3);
      expect(out.made, k3);
      expect(next.lp, 103);
      expect(next.forge.glut, 1);
      expect(next.forge.count(k3), 1);
      expect(next.forge.count(grit3), 0);
      expect(next.forge.count(stride3), 0);
      expect(next.forge.combines, 1);
      expect(next.waymarkCounters[WaymarkCounter.combines], 1);
    });

    test('a fail breaks one of the two (picked by the roll)', () {
      final g = game(stock: {'grit@3': 1, 'stride@3': 1});
      final (a, outA) = g.combining(grit3, stride3, 4, _Fixed([0.1], [true]));
      expect(outA.broken, grit3);
      expect(a.forge.count(grit3), 0);
      expect(a.forge.count(stride3), 1);
      expect(a.forge.splinters, 3);
      final (b, outB) = g.combining(grit3, stride3, 4, _Fixed([0.1], [false]));
      expect(outB.broken, stride3);
      expect(b.forge.count(grit3), 1);
    });

    test('L5 combine needs exactly 5 Glut and fails 27 %', () {
      const g5 = Seal(SealType.grit, 5);
      const f5 = Seal(SealType.fortune, 5);
      final g = game(stock: {'grit@5': 1, 'fortune@5': 1});
      expect(g.combineBlock(g5, f5, 4), ForgeBlock.glutRange);
      expect(g.combineBlock(g5, f5, 5), isNull);
      expect(g.combining(g5, f5, 5, _Fixed([0.269])).$2.success, isFalse);
      expect(
        g.combining(g5, f5, 5, _Fixed([0.27])).$2.made,
        Seal.combined(SealType.grit, SealType.fortune, 5),
      );
    });

    test('bad pairs and locked levels are refused', () {
      final g = game(stock: {'grit@3': 2, 'stride@2': 1, 'stride@3': 1});
      expect(g.combineBlock(grit3, grit3, 4), ForgeBlock.badCombine);
      expect(
        g.combineBlock(grit3, const Seal(SealType.stride, 2), 4),
        ForgeBlock.badCombine,
      );
      final early = g.copyWith(
        wanderweg: WanderwegProgress(reachedAt: List.filled(12, t0)),
      );
      expect(early.combineBlock(grit3, stride3, 4), ForgeBlock.levelLocked);
    });
  });

  group('splinters, setting and taking out', () {
    test('5 splinters melt into a seal L1 of any stat', () {
      var g = game().copyWith(forge: const ForgeState(splinters: 4));
      expect(g.meltBlock(), ForgeBlock.needsSplinters);
      g = g.copyWith(forge: const ForgeState(splinters: 6));
      g = g.meltingSplinters(SealType.fortune);
      expect(g.forge.splinters, 1);
      expect(g.forge.count(const Seal(SealType.fortune, 1)), 1);
    });

    test('setting moves a seal from the case into a free socket', () {
      var g = game(stock: {'grit@3': 1});
      expect(g.setBlock('gilt-1', grit3), isNull);
      g = g.settingSeal('gilt-1', grit3);
      expect(g.companions.last.sealAt(0), grit3);
      expect(g.forge.count(grit3), 0);
      expect(g.forge.placed, 1);
      expect(g.setBlock('gilt-1', grit3), ForgeBlock.needsPair);
    });

    test('a Common holds one seal; setting needs 50 % Spirit', () {
      var g = game(stock: {'stride@1': 2});
      g = g.settingSeal('pebble-1', stride1);
      expect(g.setBlock('pebble-1', stride1), ForgeBlock.noSocket);
      final worn = game(
        stock: {'stride@1': 1},
      ).replaceCompanion(gilt.copyWith(spirit: 49.9));
      expect(worn.setBlock('gilt-1', stride1), ForgeBlock.needsSpirit);
      final half = game(
        stock: {'stride@1': 1},
      ).replaceCompanion(gilt.copyWith(spirit: 50));
      expect(half.setBlock('gilt-1', stride1), isNull);
    });

    test('taking a seal out puts it back into the case', () {
      var g = game(stock: {'grit@3': 1}).settingSeal('gilt-1', grit3);
      g = g.clearingSeal('gilt-1', 0);
      expect(g.companions.last.sealAt(0), isNull);
      expect(g.forge.count(grit3), 1);
    });

    test('selling a companion returns its seals to the case', () {
      var g = game(stock: {'grit@3': 1, 'stride@1': 1})
          .settingSeal('gilt-1', grit3)
          .settingSeal('gilt-1', stride1)
          .withMarket(t0, Random(1));
      g = g.selling('gilt-1', t0);
      expect(g.forge.count(grit3), 1);
      expect(g.forge.count(stride1), 1);
    });

    test('forge state survives a save', () {
      final g = game(stock: {'grit@3': 2}, glut: 9).copyWith(
        forge: const ForgeState(
          stock: {'grit@3': 2},
          glut: 9,
          splinters: 3,
          combines: 2,
          bestLevel: 4,
        ),
      );
      final back = GameData.fromJson(g.toJson());
      expect(back.forge.toJson(), g.forge.toJson());
    });
  });

  group('Glut', () {
    RunSummary run(double m, {bool valid = true}) => RunSummary(
      companionId: 'pebble-1',
      startedAt: t0,
      duration: const Duration(minutes: 20),
      distanceM: m,
      steps: 2000,
      lp: 10,
      breathUsed: 2,
      valid: valid,
    );

    test('+1 Glut per valid run of 1 km or more once the Forge is open', () {
      var g = game(glut: 0);
      g = g.recordingRun(run(1000));
      expect(g.forge.glut, 1);
      expect(g.lastRun!.glut, 1);
      g = g.recordingRun(run(999));
      expect(g.forge.glut, 1);
      expect(g.lastRun!.glut, 0);
      g = g.recordingRun(run(5000, valid: false));
      expect(g.forge.glut, 1);
    });

    test('no Glut while the Forge is still closed', () {
      final g = GameData.initial(t0).recordingRun(run(2000));
      expect(g.forge.glut, 0);
      expect(g.totals, isA<Totals>());
    });
  });

  group('Wanderweg counters', () {
    test('counters read what the save holds (retroactive)', () {
      final g = game().copyWith(
        companions: [
          Companion.pebble().withSeal(0, const Seal(SealType.stride, 2)),
          gilt.withSeal(0, Seal.combined(SealType.grit, SealType.stride, 3)),
        ],
        forge: const ForgeState(stock: {'fortune@1': 2}),
      );
      final c = g.waymarkCounters;
      expect(c[WaymarkCounter.sealsPlaced], 2);
      expect(c[WaymarkCounter.sealsForged], 4);
      expect(c[WaymarkCounter.bestSealLevel], 3);
      expect(c[WaymarkCounter.combines], 1);
    });

    test('waymark 12 needs 5 forged seals and one at L3', () {
      final wm12 = waymarks[11];
      final base = game().copyWith(
        totals: const Totals(distanceM: 50000, forgeUses: 5),
      );
      expect(base.waymarkCounters.reaches(wm12), isFalse);
      final withL3 = base.copyWith(
        forge: const ForgeState(stock: {'grit@3': 1}),
      );
      expect(withL3.waymarkCounters.reaches(wm12), isTrue);
    });

    test('waymark 16 asks for a combine and a companion at level 3', () {
      final wm16 = waymarks[15];
      final base = game().copyWith(totals: const Totals(distanceM: 90000));
      expect(base.waymarkCounters.reaches(wm16), isFalse);
      final combined = base.copyWith(forge: const ForgeState(combines: 1));
      expect(combined.waymarkCounters.reaches(wm16), isFalse);
      final lv2 = combined.replaceCompanion(gilt.copyWith(level: 2));
      expect(lv2.waymarkCounters.reaches(wm16), isFalse);
      final lv3 = combined.replaceCompanion(gilt.copyWith(level: 3));
      expect(lv3.waymarkCounters.reaches(wm16), isTrue);
    });

    test('forge unlocks are wired now', () {
      for (final u in [
        WaymarkUnlock.forgeL2,
        WaymarkUnlock.forgeL3,
        WaymarkUnlock.forgeL4,
        WaymarkUnlock.forgeL5,
        WaymarkUnlock.combineL3,
        WaymarkUnlock.combineL5,
      ]) {
        expect(u.wired, isTrue, reason: u.name);
      }
      expect(WaymarkCounter.bestSealLevel.built, isTrue);
      expect(WaymarkCounter.combines.built, isTrue);
      expect(WaymarkCounter.brownPouchesOpened.built, isTrue);
      expect(WaymarkCounter.leashFilled.built, isTrue);
      expect(WaymarkCounter.messengersMet.built, isTrue);
      expect(WaymarkCounter.companionLevel.built, isTrue);
    });
  });
}
