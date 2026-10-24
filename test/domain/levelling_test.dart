import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/forge.dart';
import 'package:treadplay/domain/market.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/salve.dart';

/// nextDouble returns [rolls] in turn, nextInt always 0.
class _Fixed implements Random {
  _Fixed(this.rolls);

  final List<double> rolls;
  int _i = 0;

  @override
  double nextDouble() => rolls[_i++ % rolls.length];

  @override
  bool nextBool() => true;

  @override
  int nextInt(int max) => 0;
}

void main() {
  final t0 = DateTime(2026, 10, 1, 8);

  Companion fresh(Rarity r, [String id = 'c-1']) =>
      Companion.fresh(id: id, speciesId: 'pebble', rarity: r);

  RunSummary run(String id, double breath, {bool valid = true}) => RunSummary(
    companionId: id,
    startedAt: t0,
    duration: const Duration(minutes: 30),
    distanceM: breath * 250,
    steps: 3000,
    lp: breath * 2.5,
    breathUsed: breath,
    valid: valid,
    tankSize: 6,
    breathLeft: 0,
  );

  group('Mut loss per Breath point', () {
    test('by rarity at the base Grit roll', () {
      expect(fresh(Rarity.common).spiritLossFor(1), 1.0);
      expect(fresh(Rarity.rare).spiritLossFor(1), 1.2);
      expect(fresh(Rarity.epic).spiritLossFor(1), 1.5);
      expect(fresh(Rarity.legendary).spiritLossFor(1), 2.0);
      expect(fresh(Rarity.common).spiritLossFor(6), 6.0);
      expect(fresh(Rarity.common).spiritLossFor(0), 0);
    });

    test('Grit seals soften it, the rolled Grit counts too', () {
      final base = fresh(Rarity.common);
      expect(base.spiritLossFactor, 1);
      final sealed = base.withSeal(0, const Seal(SealType.grit, 5));
      expect(sealed.spiritLossFactor, closeTo(1 / 1.31, 1e-9));
      expect(sealed.spiritLossFor(6), closeTo(4.6, 1e-9));
      // A high Grit roll loses less, a low one a little more.
      expect(base.copyWith(grit: 12.5).spiritLossFactor, 0.8);
      expect(base.copyWith(grit: 9).spiritLossFor(9), 10.0);
    });

    test('a run drops Mut, never below 0, and only counts used Breath', () {
      final c = fresh(Rarity.legendary);
      expect(c.afterRun(6).spirit, 88);
      expect(c.copyWith(spirit: 3).afterRun(6).spirit, 0);
      expect(identical(c.afterRun(0), c), isTrue);
    });
  });

  group('XP and levels', () {
    test('6 XP per level, 1 XP per Breath point', () {
      expect(xpForLevel(1), 6);
      expect(xpForLevel(24), 144);
      final c = fresh(Rarity.common).afterRun(4);
      expect(c.xp, 4);
      expect(c.xpReady, isFalse);
      expect(c.afterRun(2.4).xp, 6);
      expect(c.afterRun(2.4).xpReady, isTrue);
    });

    test('level cost is the rarity factor times the level', () {
      expect(fresh(Rarity.common).levelUpCost, 5);
      expect(fresh(Rarity.rare).levelUpCost, 10);
      expect(fresh(Rarity.epic).levelUpCost, 20);
      expect(fresh(Rarity.legendary).levelUpCost, 40);
      expect(fresh(Rarity.common).copyWith(level: 7).levelUpCost, 35);
      expect(fresh(Rarity.legendary).copyWith(level: 24).levelUpCost, 960);
      expect(fresh(Rarity.common).copyWith(level: maxLevel).levelUpCost, null);
    });

    test('a level up keeps the rest of the XP', () {
      final c = fresh(Rarity.common).copyWith(xp: 9);
      final up = c.leveledUp();
      expect(up.level, 2);
      expect(up.xp, 3);
      expect(up.xpToNext, 12);
    });

    test('+4 % LP per Breath point per level', () {
      final c = fresh(Rarity.common);
      final lv2 = c.copyWith(level: 2);
      expect(lv2.lpPerBreath / c.lpPerBreath, closeTo(1.04, 1e-9));
    });

    test('the tank grows only at the milestone levels', () {
      expect(tankLevels, [10, 25]);
      final c = fresh(Rarity.common);
      final tanks = [
        for (var lv = 1; lv <= maxLevel; lv++) c.copyWith(level: lv).tankSize,
      ];
      expect(tanks.first, 6);
      expect(tanks[8], 6); // Lv 9
      expect(tanks[9], 7); // Lv 10
      expect(tanks[23], 7); // Lv 24
      expect(tanks.last, 8); // Lv 25
      expect(nextTankLevel(1), 10);
      expect(nextTankLevel(10), 25);
      expect(nextTankLevel(25), isNull);
      expect(fresh(Rarity.legendary).copyWith(level: 25).tankSize, 14);
    });

    test('max level gathers no XP', () {
      final top = fresh(Rarity.common).copyWith(level: maxLevel);
      expect(top.afterRun(6).xp, 0);
      expect(top.xpToNext, isNull);
      expect(top.xpReady, isFalse);
    });
  });

  group('game', () {
    test('a valid run brings XP and costs Mut, stored on the run', () {
      // The starter's Grit 9.4 costs a little more Mut than a flat 10.
      final g = GameData.initial(t0).recordingRun(run('pebble-1', 6));
      final c = g.activeCompanion;
      expect(c.spirit, closeTo(93.6, 1e-9));
      expect(c.xp, 6);
      final r = g.lastRun!;
      expect(r.spiritLost, 6.4);
      expect(r.spiritAfter, closeTo(93.6, 1e-9));
      expect(r.xpGained, 6);
      expect(r.levelReady, isTrue);
      final back = RunSummary.fromJson(r.toJson());
      expect(back.spiritAfter, closeTo(93.6, 1e-9));
      expect(back.xpGained, 6);
      expect(back.levelReady, isTrue);
    });

    test('an invalid run or one without Breath changes nothing', () {
      final g0 = GameData.initial(t0);
      final bad = g0.recordingRun(run('pebble-1', 6, valid: false));
      expect(bad.activeCompanion.spirit, 100);
      expect(bad.activeCompanion.xp, 0);
      final none = g0.recordingRun(run('pebble-1', 0));
      expect(none.activeCompanion.spirit, 100);
      expect(none.lastRun!.spiritAfter, isNull);
    });

    test('levelling up needs the XP and the LP', () {
      var g = GameData.initial(t0).copyWith(lp: 4);
      expect(g.levelUpBlock('pebble-1'), LevelBlock.needsXp);
      g = g.replaceCompanion(g.activeCompanion.copyWith(xp: 6));
      expect(g.levelUpBlock('pebble-1'), LevelBlock.notEnoughLp);
      g = g.copyWith(lp: 5);
      expect(g.levelUpBlock('pebble-1'), isNull);
      g = g.levelingUp('pebble-1', t0);
      expect(g.activeCompanion.level, 2);
      expect(g.activeCompanion.xp, 0);
      expect(g.lp, 0);
      expect(g.levelUpBlock('nobody'), LevelBlock.gone);
    });

    test('a level 10 tank fills by regenerating, not at once', () {
      var g = GameData.initial(t0).copyWith(lp: 100);
      g = g.replaceCompanion(g.activeCompanion.copyWith(level: 9, xp: 54));
      expect(g.breathCap, 6);
      g = g.levelingUp('pebble-1', t0);
      expect(g.breathCap, 7);
      expect(g.breath.points, 6);
      expect(
        g.regenerated(t0.add(const Duration(minutes: 90))).breath.points,
        7,
      );
    });

    test('salves are bought, kept and used', () {
      var g = GameData.initial(t0).withMarket(t0, Random(3)).copyWith(lp: 50);
      final price = g.market!.priceOfSalve(Salve.medium);
      expect(g.buySalveBlock(Salve.medium), isNull);
      g = g.buyingSalve(Salve.medium);
      expect(g.lp, 50 - price);
      expect(g.salves.count(Salve.medium), 1);
      expect(g.useSalveBlock('pebble-1', Salve.medium), SalveBlock.fullSpirit);
      g = g.replaceCompanion(g.activeCompanion.copyWith(spirit: 70));
      expect(g.useSalveBlock('pebble-1', Salve.small), SalveBlock.noneLeft);
      g = g.usingSalve('pebble-1', Salve.medium);
      expect(g.activeCompanion.spirit, 100);
      expect(g.salves.isEmpty, isTrue);
      final back = GameData.fromJson(g.buyingSalve(Salve.large).toJson());
      expect(back.salves.count(Salve.large), 1);
    });

    test('salve sizes', () {
      final c = fresh(Rarity.common).copyWith(spirit: 20);
      expect(c.healed(Salve.small.points).spirit, 35);
      expect(c.healed(Salve.medium.points).spirit, 60);
      expect(c.healed(Salve.large.points).spirit, 100);
      expect([for (final s in Salve.values) s.price], [5, 12, 28]);
    });

    test('a seal goes in from 50 % Mut', () {
      final g = GameData.initial(t0).copyWith(
        wanderweg: GameData.initial(t0).wanderweg,
        forge: const ForgeState(stock: {'stride@1': 1}),
      );
      final low = g.replaceCompanion(g.activeCompanion.copyWith(spirit: 49));
      final ok = g.replaceCompanion(g.activeCompanion.copyWith(spirit: 50));
      const seal = Seal(SealType.stride, 1);
      expect(low.setBlock('pebble-1', seal), isNot(isNull));
      // Before the Forge opens the block is "locked", not Mut.
      expect(ok.setBlock('pebble-1', seal), anyOf(isNull, ForgeBlock.locked));
    });
  });

  group('market', () {
    test('salve prices drift ±20 %, the offer is −30 %', () {
      for (var seed = 0; seed < 40; seed++) {
        final m = Market.rolled(t0, Random(seed));
        for (final s in Salve.values) {
          final p = m.priceOfSalve(s);
          if (m.salveDeal == s) {
            expect(p, (s.price * .7).roundToDouble());
          } else {
            expect(p, inInclusiveRange(s.price * .8 - .5, s.price * 1.2 + .5));
          }
        }
      }
    });

    test('salve draws come after the offers', () {
      // The same seed rolls the same offers as before salves.
      final a = Market.rolled(t0, Random(7));
      final b = Market.rolled(t0, Random(7));
      expect(a.toJson(), b.toJson());
      final back = Market.fromJson(a.toJson());
      for (final s in Salve.values) {
        expect(back.priceOfSalve(s), a.priceOfSalve(s));
      }
    });

    test('a market saved before salves sells at base price', () {
      final json = Market.rolled(t0, Random(1)).toJson()
        ..remove('salves')
        ..remove('salveDeal');
      final m = Market.fromJson(json);
      expect([for (final s in Salve.values) m.priceOfSalve(s)], [5, 12, 28]);
    });

    test('sell price +3 % per level above 1', () {
      final m = Market.rolled(t0, Random(1));
      final c = fresh(Rarity.common);
      expect(m.sellPriceOf(c), 120);
      expect(m.sellPriceOf(c.copyWith(level: 11)), 156);
      expect(
        m.sellPriceOf(fresh(Rarity.legendary).copyWith(level: 25)),
        (3000 * .6 * 1.72).roundToDouble(),
      );
    });
  });

  group('pouches', () {
    test('brown and copper sometimes hold a small salve', () {
      expect(Pouches.salveChance[PouchColor.brown], .1);
      expect(Pouches.salveChance[PouchColor.copper], .1);
      expect(Pouches.rollSalve(PouchColor.navy, _Fixed([0])), isNull);
      expect(
        Pouches.rollSalve(PouchColor.brown, _Fixed([.05])),
        const PouchReward.salve(Salve.small),
      );
      expect(Pouches.rollSalve(PouchColor.brown, _Fixed([.5])), isNull);
    });

    test('an opened pouch puts the salve into the Vorrat', () {
      final g = GameData.initial(
        t0,
      ).copyWith(lp: 100).hangingPouch(PouchColor.brown, t0);
      final (next, rewards) = g.openingPouch(0, _Fixed([0]));
      expect(rewards.last, const PouchReward.salve(Salve.small));
      expect(next.salves.count(Salve.small), 1);
    });
  });

  group('save game version 8', () {
    Map<String, Object?> file(int version, Map<String, Object?> game) => {
      'format': SaveGame.format,
      'version': version,
      'exportedAt': t0.toIso8601String(),
      'game': game,
    };

    test('a version 7 save keeps level and Mut, starts at 0 XP', () {
      final old = GameData.initial(t0);
      final json = old
          .replaceCompanion(old.activeCompanion.copyWith(spirit: 73))
          .toJson();
      // Stray keys a version 7 file can't have meant anything.
      ((json['companions']! as List).first as Map)['xp'] = 40;
      json['salves'] = {'large': 9};
      final loaded = SaveGame.decode(
        utf8.encode(jsonEncode(file(7, json))),
      ).game;
      final c = loaded.activeCompanion;
      expect(c.level, 1);
      expect(c.xp, 0);
      expect(c.spirit, 73);
      expect(loaded.salves.isEmpty, isTrue);
    });

    test('version 8 round trip keeps XP and salves', () {
      final g0 = GameData.initial(t0);
      final g = g0
          .replaceCompanion(g0.activeCompanion.copyWith(level: 3, xp: 11))
          .copyWith(salves: const SalveStock({Salve.small: 2}));
      final bytes = SaveGame.encode(g, t0);
      expect(jsonDecode(utf8.decode(bytes))['version'], 9);
      final back = SaveGame.decode(bytes).game;
      expect(back.activeCompanion.level, 3);
      expect(back.activeCompanion.xp, 11);
      expect(back.salves.count(Salve.small), 2);
    });

    test('stored game data from before levelling loads with defaults', () {
      final json = GameData.initial(t0).toJson();
      expect(json.containsKey('salves'), isFalse);
      final c = (json['companions']! as List).first as Map<String, Object?>;
      expect(c.containsKey('xp'), isFalse);
      final back = GameData.fromJson(json);
      expect(back.activeCompanion.xp, 0);
      expect(back.salves.isEmpty, isTrue);
    });
  });
}
