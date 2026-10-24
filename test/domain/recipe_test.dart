import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/forge.dart';
import 'package:treadplay/domain/messenger.dart';
import 'package:treadplay/domain/movement.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/run_engine.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/sweet_spot.dart';
import 'package:treadplay/domain/wanderweg.dart';

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
  final t0 = DateTime(2026, 1, 1, 8);
  final allOpen = WanderwegProgress(
    reachedAt: List.filled(waymarks.length, t0),
    seen: waymarks.length,
  );

  Seal pair(Recipe r, int level) => Seal.combined(r.a, r.b, level);
  Seal triple(Recipe r, int level) => Seal.triple(r.a, r.b, r.extra!, level);

  /// A rare companion (2 sockets) with [seals] set.
  Companion rare(String id, List<Seal> seals) {
    var c = Companion.fresh(id: id, speciesId: 'dune', rarity: Rarity.rare);
    for (var i = 0; i < seals.length; i++) {
      c = c.withSeal(i, seals[i]);
    }
    return c;
  }

  /// Game with [along] taken along (and [others] owned), trail all open,
  /// one pouch found before (no sure first pouch or messenger).
  GameData game(Companion along, {List<Companion> others = const []}) =>
      GameData.initial(t0).copyWith(
        companions: [along, ...others],
        activeCompanionId: along.id,
        wanderweg: allOpen,
        pouches: const PouchState(found: {PouchColor.brown: 1}),
        messengers: const MessengerState(met: 1),
        lp: 10000,
      );

  RunSummary run(Companion c, double m, {DateTime? at, double breath = 6}) =>
      RunSummary(
        companionId: c.id,
        startedAt: at ?? t0,
        duration: const Duration(minutes: 30),
        distanceM: m,
        steps: 0,
        lp: 1,
        breathUsed: breath,
        valid: true,
        tankSize: 6,
      );

  group('recipes', () {
    test('six recipes: three of two stats, three of all three', () {
      expect(Recipe.values, hasLength(6));
      expect(Recipe.pairOf(SealType.grit, SealType.stride), Recipe.ausdauer);
      expect(Recipe.pairOf(SealType.fortune, SealType.stride), Recipe.faehrte);
      expect(Recipe.pairOf(SealType.grit, SealType.fortune), Recipe.schutz);
      expect(Recipe.wanderstern.base, Recipe.ausdauer);
      expect(Recipe.spurenleser.base, Recipe.faehrte);
      expect(Recipe.glutherz.base, Recipe.schutz);
      for (final r in Recipe.values) {
        expect(r.at(0), 0);
        expect(r.steps, hasLength(5));
      }
    });

    test('level-1 effects stay at most half of a single seal', () {
      // A single seal L1–L5 gives +4/9/15/22/31 %.
      for (final r in [Recipe.faehrte, Recipe.schutz]) {
        for (var l = 1; l <= 5; l++) {
          expect(r.at(l), lessThanOrEqualTo(Seal(SealType.grit, l).bonus / 2));
        }
      }
    });
  });

  group('effects', () {
    test('Ausdauer widens the sweet spot (gauge and LP factor)', () {
      // Moss: 4.5 km/h, core ±1.0, edge ±2.5.
      expect(sweetSpotFactor(CompanionType.moss, 6.2), lessThan(1));
      expect(sweetSpotFactor(CompanionType.moss, 6.2, widenKmh: .8), 1);
      expect(sweetSpotFactor(CompanionType.moss, 7.2), 0);
      expect(
        sweetSpotFactor(CompanionType.moss, 7.2, widenKmh: .8),
        greaterThan(0),
      );
      final c = Companion.pebble().withSeal(0, pair(Recipe.ausdauer, 5));
      expect(c.sweetSpotWidenKmh, .8);
      final engine = RunEngine(companion: c, breathAtStart: 6, startedAt: t0);
      engine.add(
        MovementSample(
          time: t0.add(const Duration(seconds: 1)),
          speedKmh: 6.2,
          distanceM: 1.7,
          steps: 2,
        ),
      );
      expect(engine.factor, 1);
      expect(engine.inBand, isTrue);
    });

    test('Fährte adds points to the pouch chance from 3 km only', () {
      final plain = rare('r-1', const []);
      final trail = rare('r-1', [pair(Recipe.faehrte, 3)]);
      // Distance itself does not change the chance, only the recipe does.
      final short = game(trail).pouchChanceFor(run(trail, 2999));
      expect(
        game(trail).pouchChanceFor(run(trail, 3000)),
        closeTo(short + Recipe.faehrte.at(3), 1e-9),
      );
      expect(Recipe.faehrte.at(3), .05);
      expect(
        game(plain).pouchChanceFor(run(plain, 3000)),
        game(plain).pouchChanceFor(run(plain, 2999)),
      );
      // No Breath used: no pouch, no bonus.
      expect(game(trail).pouchChanceFor(run(trail, 4000, breath: 0)), 0);
    });

    test('Schutzamulett cuts the fail chance and adds a splinter', () {
      final ward = rare('r-1', [pair(Recipe.schutz, 2)]);
      final g = game(
        ward,
      ).copyWith(forge: const ForgeState(stock: {'stride@1': 2}, glut: 10));
      final step = Forge.upgrades[1]!;
      expect(
        g.failChanceFor(step, step.minGlut),
        closeTo(step.failChance(step.minGlut) - .03, 1e-9),
      );
      final (next, out) = g.upgrading(
        const Seal(SealType.stride, 1),
        step.minGlut,
        _Fixed([0]),
      );
      expect(out.success, isFalse);
      expect(next.forge.splinters, Forge.splintersOnFail + 1);
      // Without the amulet: the usual splinters.
      final (plain, _) = game(rare('r-1', const []))
          .copyWith(forge: g.forge)
          .upgrading(const Seal(SealType.stride, 1), step.minGlut, _Fixed([0]));
      expect(plain.forge.splinters, Forge.splintersOnFail);
    });

    test('Wanderstern adds points to the messenger chance', () {
      final star = rare('r-1', [triple(Recipe.wanderstern, 2)]);
      final base = Messengers.chance(
        breathUsed: 6,
        tankSize: 6,
        fortuneFactor: star.fortuneFactor,
      );
      expect(base, greaterThan(0));
      expect(
        game(star).messengerChanceFor(run(star, 2000)),
        closeTo(base + .05, 1e-9),
      );
      final plain = rare('r-1', const []);
      expect(
        game(plain).messengerChanceFor(run(plain, 2000)),
        closeTo(
          Messengers.chance(
            breathUsed: 6,
            tankSize: 6,
            fortuneFactor: plain.fortuneFactor,
          ),
          1e-9,
        ),
      );
    });

    test('Spurenleser makes runs warm pouches faster', () {
      final pouch = Pouch(color: PouchColor.navy, foundAt: t0);
      GameData warmGame(Companion c) => game(c).copyWith(
        pouches: PouchState(found: const {PouchColor.navy: 1}, leash: [pouch]),
      );
      final plain = rare('r-1', const []);
      final tracker = rare('r-1', [triple(Recipe.spurenleser, 5)]);
      final a = warmGame(plain).recordingRun(run(plain, 1000));
      final b = warmGame(tracker).recordingRun(run(tracker, 1000));
      expect(a.pouches.leash.single.warmedM, 1000);
      expect(b.pouches.leash.single.warmedM, closeTo(1250, 1e-9));
    });

    test('Glutherz may bring one Glut more, once a day', () {
      final heart = rare('r-1', [triple(Recipe.glutherz, 1)]);
      final g = game(heart);
      expect(g.glutherzChanceFor(run(heart, 1500)), .15);
      expect(g.glutherzChanceFor(run(heart, 900)), 0);
      final plainGlut = game(
        rare('r-1', const []),
      ).recordingRun(run(heart, 1500), random: _Fixed([.99, .99, .99, .99]));
      // Pouch roll and messenger roll miss (.99), the heart roll hits (.0).
      final after = g.recordingRun(
        run(heart, 1500),
        random: _Fixed([.99, .99, 0]),
      );
      expect(after.forge.glut, plainGlut.forge.glut + 1);
      expect(after.forge.glutherzDay, Messengers.dayKey(t0));
      expect(after.lastRun!.glut, plainGlut.lastRun!.glut + 1);
      // Same day: no second chance; next day again.
      expect(after.glutherzChanceFor(run(heart, 1500)), 0);
      expect(
        after.glutherzChanceFor(
          run(heart, 1500, at: t0.add(const Duration(days: 1))),
        ),
        .15,
      );
    });

    test('only the companion taken along counts, levels do not stack', () {
      final two = rare('r-1', [
        pair(Recipe.ausdauer, 2),
        pair(Recipe.ausdauer, 4),
      ]);
      expect(two.recipeLevel(Recipe.ausdauer), 4);
      expect(two.sweetSpotWidenKmh, Recipe.ausdauer.at(4));
      final ward = rare('r-2', [pair(Recipe.schutz, 5)]);
      final home = game(rare('r-1', const []), others: [ward]);
      final step = Forge.upgrades[1]!;
      expect(
        home.failChanceFor(step, step.minGlut),
        step.failChance(step.minGlut),
      );
      final along = home.copyWith(activeCompanionId: 'r-2');
      expect(
        along.failChanceFor(step, step.minGlut),
        lessThan(step.failChance(step.minGlut)),
      );
    });
  });

  group('forging recipes', () {
    test('a level-2 recipe stays locked until its level-1 recipe is known', () {
      final g = game(rare('r-1', const [])).copyWith(
        forge: const ForgeState(stock: {'stride+grit@1': 1, 'fortune@1': 1}),
      );
      final p = pair(Recipe.ausdauer, 1);
      const f = Seal(SealType.fortune, 1);
      expect(g.combineBlock(p, f, 2), ForgeBlock.recipeLocked);
      final known = g.copyWith(
        forge: g.forge.discovering(Recipe.ausdauer, 1).copyWith(glut: 5),
      );
      expect(known.combineBlock(p, f, 2), isNull);
      // A pair and a seal of a stat it already has do not fit.
      expect(
        known.combineBlock(p, const Seal(SealType.grit, 1), 2),
        ForgeBlock.badCombine,
      );
    });

    test('combining records the recipe and uses up the recipe seal', () {
      var g = game(rare('r-1', const [])).copyWith(
        forge: const ForgeState(
          stock: {'stride@1': 1, 'grit@1': 1, 'fortune@1': 1},
          glut: 10,
        ),
      );
      final (a, outA) = g.combining(
        const Seal(SealType.stride, 1),
        const Seal(SealType.grit, 1),
        1,
        _Fixed([.99]),
      );
      expect(outA.made, pair(Recipe.ausdauer, 1));
      expect(a.forge.recipes, {Recipe.ausdauer: 1});
      g = a;
      final (b, outB) = g.combining(
        pair(Recipe.ausdauer, 1),
        const Seal(SealType.fortune, 1),
        2,
        _Fixed([.99]),
      );
      expect(outB.made, triple(Recipe.wanderstern, 1));
      expect(b.forge.stock, {'stride+grit+fortune@1': 1});
      expect(b.forge.recipes, {Recipe.ausdauer: 1, Recipe.wanderstern: 1});
      expect(b.lp, a.lp - Forge.tripleStep(1)!.lp);
    });
  });

  group('save migration', () {
    Uint8List file(int version, Map<String, Object?> game) =>
        Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              'format': SaveGame.format,
              'version': version,
              'exportedAt': t0.toIso8601String(),
              'game': game,
            }),
          ),
        );

    test('a v8 file keeps its combo seals and derives its recipes', () {
      final pebble = Companion.pebble().withCharm(0, 'grit+fortune@3');
      final json = game(pebble)
          .copyWith(forge: const ForgeState(stock: {'stride+fortune@2': 1}))
          .toJson();
      (json['forge']! as Map<String, Object?>)
        ..['recipes'] = {'glutherz': 5}
        ..['glutherzDay'] = '2026-01-01';
      final loaded = SaveGame.decode(file(8, json)).game;
      expect(loaded.forge.recipes, {Recipe.faehrte: 2, Recipe.schutz: 3});
      expect(loaded.forge.glutherzDay, isNull);
      expect(loaded.activeCompanion.seals.single, pair(Recipe.schutz, 3));
      expect(loaded.forge.stock, {'stride+fortune@2': 1});
    });

    test('a v9 file keeps its recipes', () {
      final g = game(rare('r-1', const [])).copyWith(
        forge: const ForgeState(
          recipes: {Recipe.glutherz: 2, Recipe.schutz: 4},
          glutherzDay: '2026-01-01',
        ),
      );
      final loaded = SaveGame.decode(SaveGame.encode(g, t0)).game;
      expect(loaded.forge.recipes, g.forge.recipes);
      expect(loaded.forge.glutherzDay, '2026-01-01');
    });
  });

  group('starter', () {
    test('a new save starts with uneven, low Common stats', () {
      final c = GameData.initial(t0).activeCompanion;
      expect(c.id, 'pebble-1');
      expect([c.stride, c.grit, c.fortune], [9.2, 9.4, 9.3]);
      expect(c.stride, greaterThanOrEqualTo(Rarity.common.minStat));
      expect({c.stride, c.grit, c.fortune}, hasLength(3));
    });

    test('market Commons usually roll better than the starter', () {
      final s = GameData.initial(t0).activeCompanion;
      final sum = s.stride + s.grit + s.fortune;
      final random = Random(7);
      var better = 0;
      for (var i = 0; i < 500; i++) {
        final c = Companion.rolled(
          id: 'm-$i',
          speciesId: 'pebble',
          rarity: Rarity.common,
          random: random,
        );
        if (c.stride + c.grit + c.fortune > sum) better++;
      }
      expect(better, greaterThan(475)); // > 95 %
    });

    test('an old game gives the original starter the new stats once', () {
      final old = Companion.pebble()
          .copyWith(level: 7, xp: 3, spirit: 61, tempo: CompanionType.brook)
          .withCharm(0, 'stride@2');
      final other = rare('r-1', const []);
      final json = game(old, others: [other]).toJson()
        ..remove(GameData.starterKey);
      final g = GameData.fromJson(json);
      final c = g.companions.firstWhere((c) => c.id == 'pebble-1');
      expect([c.stride, c.grit, c.fortune], [9.2, 9.4, 9.3]);
      expect(c.level, 7);
      expect(c.xp, 3);
      expect(c.spirit, 61);
      expect(c.type, CompanionType.brook);
      expect(c.charms, ['stride@2']);
      // Others stay as they were.
      expect(g.companions.last.toJson(), other.toJson());
      // Once: a stored game is not retuned again.
      final again = GameData.fromJson(
        g.replaceCompanion(c.copyWith(stride: 10.4)).toJson(),
      );
      expect(again.companions.first.stride, 10.4);
    });

    test('a v8 save file gets the starter stats, a v9 file keeps them', () {
      final json = game(Companion.pebble()).toJson();
      final v8 = SaveGame.decode(
        Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              'format': SaveGame.format,
              'version': 8,
              'exportedAt': t0.toIso8601String(),
              'game': json,
            }),
          ),
        ),
      ).game;
      expect(v8.activeCompanion.stride, 9.2);
      final v9 = SaveGame.decode(
        SaveGame.encode(game(Companion.pebble()), t0),
      ).game;
      expect(v9.activeCompanion.stride, 10);
    });
  });
}
