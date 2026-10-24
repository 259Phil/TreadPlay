import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/messenger.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/wanderweg.dart';

void main() {
  final t0 = DateTime(2026, 3, 2, 8);

  /// A game with [n] waymarks reached (and seen) that found a pouch
  /// before (so the sure first pouch is used up).
  /// The starter has flat 10/10/10 stats here, so Fortune scales nothing.
  GameData at(int n, {DateTime? now}) => GameData.initial(now ?? t0).copyWith(
    companions: [Companion.pebble()],
    wanderweg: WanderwegProgress(reachedAt: List.filled(n, now ?? t0), seen: n),
    pouches: const PouchState(found: {PouchColor.brown: 1}),
  );

  RunSummary run(
    GameData g, {
    DateTime? at,
    double m = 1500,
    bool valid = true,
    double? share,
    double tankShare = 1,
  }) {
    final tank = g.activeCompanion.tankSize;
    return RunSummary(
      companionId: g.activeCompanionId,
      startedAt: at ?? t0,
      duration: const Duration(minutes: 25),
      distanceM: m,
      steps: 0,
      lp: 1,
      breathUsed: tank * tankShare,
      tankSize: tank,
      valid: valid,
      sweetSpotShare: share,
    );
  }

  /// Records one run on [g] with seeds from [seed] on until a messenger
  /// came whose visit matches [want].
  (GameData, MessengerVisit) visitWhere(
    GameData g,
    bool Function(MessengerVisit v) want, {
    int seed = 0,
  }) {
    for (var s = seed; s < seed + 5000; s++) {
      final next = g.recordingRun(run(g), random: Random(s));
      final v = next.messengers.pending;
      if (v != null && want(v)) return (next, v);
    }
    fail('no matching visit');
  }

  GameData metOnce(GameData g) =>
      g.copyWith(messengers: const MessengerState(met: 1));

  group('chance', () {
    test('13 % for a full tank, less with less Breath, times Fortune', () {
      expect(Messengers.chance(breathUsed: 6, tankSize: 6), closeTo(.13, 1e-9));
      expect(
        Messengers.chance(breathUsed: 3, tankSize: 6),
        closeTo(.065, 1e-9),
      );
      expect(
        Messengers.chance(breathUsed: 6, tankSize: 6, fortuneFactor: 1.47),
        closeTo(.1911, 1e-9),
      );
      expect(Messengers.chance(breathUsed: 0, tankSize: 6), 0);
      expect(
        Messengers.chance(breathUsed: 6, tankSize: 6, fortuneFactor: 99),
        1,
      );
    });

    test('only valid runs of 1 km or more, from waymark 2', () {
      final g = metOnce(at(2));
      expect(g.messengerChanceFor(run(g)), closeTo(.13, 1e-9));
      expect(g.messengerChanceFor(run(g, valid: false)), 0);
      expect(g.messengerChanceFor(run(g, m: 999)), 0);
      final early = metOnce(at(1));
      expect(early.messengerChanceFor(run(early)), 0);
    });

    test('the first messenger is sure from waymark 5', () {
      final g = at(5);
      expect(g.messengerChanceFor(run(g)), 1);
      expect(metOnce(g).messengerChanceFor(run(g)), closeTo(.13, 1e-9));
      final before = at(4);
      expect(before.messengerChanceFor(run(before)), closeTo(.13, 1e-9));
    });

    test('a Fortune seal raises the chance', () {
      final lucky = Companion.pebble().withSeal(
        0,
        const Seal(SealType.fortune, 3),
      );
      final g = metOnce(at(3)).replaceCompanion(lucky);
      expect(lucky.fortuneFactor, greaterThan(1));
      expect(
        g.messengerChanceFor(run(g)),
        closeTo(.13 * lucky.fortuneFactor, 1e-9),
      );
    });

    test('no second messenger while one is still waiting', () {
      final (g, _) = visitWhere(at(5), (_) => true);
      expect(g.messengerChanceFor(run(g)), 0);
    });

    test('roughly 13 % of full-tank runs without a pouch bring one', () {
      var visits = 0;
      var rolls = 0;
      final g = metOnce(at(3));
      for (var s = 0; s < 4000; s++) {
        final next = g.recordingRun(run(g), random: Random(s));
        if (next.lastRun!.pouch != null) continue;
        rolls++;
        if (next.lastRun!.messenger != null) visits++;
      }
      expect(visits / rolls, closeTo(.13, .02));
    });
  });

  group('rarity', () {
    test('one messenger per pouch colour, rarest last', () {
      expect([for (final m in Messenger.values) m.color], PouchColor.values);
      expect(Messenger.of(PouchColor.navy), Messenger.vesper);
      expect(Messenger.of(PouchColor.brown), Messenger.ruhu);
    });

    double shareOf(Messenger m, double fortune) {
      final r = Random(7);
      var n = 0;
      const draws = 20000;
      for (var i = 0; i < draws; i++) {
        if (Messengers.pick(PouchColor.values, r, fortuneFactor: fortune) ==
            m) {
          n++;
        }
      }
      return n / draws;
    }

    test('picks with the pouch colour weights', () {
      final shares = Pouches.colorShares(PouchColor.values, 1);
      for (final m in Messenger.values) {
        expect(shareOf(m, 1), closeTo(shares[m.color]!, .012), reason: m.name);
      }
    });

    test('more Fortune, rarer messengers', () {
      expect(
        shareOf(Messenger.vesper, 1.47),
        greaterThan(shareOf(Messenger.vesper, 1)),
      );
      expect(
        shareOf(Messenger.ruhu, 1.47),
        lessThan(shareOf(Messenger.ruhu, 1)),
      );
      final hi = Pouches.colorShares(PouchColor.values, 1.47);
      expect(
        shareOf(Messenger.vesper, 1.47),
        closeTo(hi[PouchColor.navy]!, .012),
      );
    });

    test('only messengers of unlocked colours come', () {
      final r = Random(1);
      for (var i = 0; i < 500; i++) {
        expect(
          Messengers.pick(const [PouchColor.brown, PouchColor.copper], r),
          isNot(anyOf(Messenger.flimm, Messenger.vesper)),
        );
      }
    });
  });

  group('delivery', () {
    test('hangs its pouch (source messenger) and adds its Glut', () {
      final start = metOnce(at(5));
      final (g, v) = visitWhere(start, (v) => v.kind == VisitKind.gift);
      expect(g.pouches.leash.last.color, v.messenger.color);
      expect(g.pouches.foundOf(v.messenger.color), greaterThanOrEqualTo(1));
      expect(g.lastRun!.messenger, v.messenger);
      // The pouch takes the place of the run Glut.
      expect(g.lastRun!.glut, 0);
      expect(g.forge.glut, start.forge.glut + v.messenger.giftGlut);
      expect(g.messengers.met, 2);
      expect(g.messengers.todayOn(Messengers.dayKey(t0)), 1);
      final shown = g.dismissingVisit();
      expect(shown.messengers.pending, isNull);
      expect(shown.pouches.leash, g.pouches.leash);
    });

    test(
      'a full leash: it still comes, hangs nothing, the run keeps its Glut',
      () {
        var start = metOnce(at(5));
        for (var i = 0; i < start.leashClips; i++) {
          start = start.hangingPouch(PouchColor.brown, t0);
        }
        expect(start.leashFull, isTrue);
        final (g, v) = visitWhere(start, (v) => v.kind == VisitKind.leashFull);
        expect(g.pouches.leash, hasLength(start.leashClips));
        expect(g.lastRun!.leashFull, isTrue);
        expect(g.lastRun!.glut, 1);
        expect(g.forge.glut, start.forge.glut + 1);
        expect(g.messengers.met, 2);
        // Leash-full visits don't use up the day.
        expect(g.messengers.todayOn(Messengers.dayKey(t0)), 0);
        expect(v.glut, 0);
      },
    );

    test('lines never repeat right away', () {
      final r = Random(5);
      for (var prev = 0; prev < Messengers.lines; prev++) {
        for (var i = 0; i < 200; i++) {
          final n = Messengers.pickLine('x', {'x': prev}, r);
          expect(n, isNot(prev));
          expect(n, inInclusiveRange(0, Messengers.lines - 1));
        }
      }
      final seen = <int>{};
      for (var i = 0; i < 200; i++) {
        seen.add(Messengers.pickLine('x', const {}, r));
      }
      expect(seen, hasLength(Messengers.lines));
    });

    test('back-to-back visits use a new greeting', () {
      var g = metOnce(at(5));
      MessengerVisit? last;
      var seed = 0;
      for (var k = 0; k < 6; k++) {
        final day = t0.add(Duration(days: k));
        final (next, v) = () {
          for (var s = seed; s < seed + 5000; s++) {
            final n = g.recordingRun(run(g, at: day), random: Random(s));
            final p = n.messengers.pending;
            if (p != null && p.kind == VisitKind.gift) {
              seed = s + 1;
              return (n, p);
            }
          }
          fail('no visit');
        }();
        if (last != null && last.messenger == v.messenger) {
          expect(v.greet, isNot(last.greet));
        }
        last = v;
        g = next.dismissingVisit().copyWith(
          pouches: const PouchState(found: {PouchColor.brown: 1}),
        );
      }
    });
  });

  group('daily cap', () {
    test('at most 2 counted visits a day, new ones the next day', () {
      final day = Messengers.dayKey(t0);
      final g = metOnce(at(3)).copyWith(
        messengers: MessengerState(
          met: 3,
          day: day,
          today: Messengers.dailyCap,
        ),
      );
      expect(g.messengerChanceFor(run(g)), 0);
      final tomorrow = t0.add(const Duration(days: 1));
      expect(g.messengerChanceFor(run(g, at: tomorrow)), greaterThan(0));
    });

    test('many runs in one day never bring more than the cap', () {
      var g = metOnce(at(3));
      var visits = 0;
      final r = Random(11);
      for (var i = 0; i < 300; i++) {
        final next = g.recordingRun(
          run(g, at: t0.add(Duration(minutes: i))),
          random: r,
        );
        if (next.lastRun!.messenger != null) visits++;
        // Accept or clear what came, empty the leash.
        g = next
            .dismissingVisit()
            .decliningTask(t0)
            .copyWith(pouches: const PouchState(found: {PouchColor.brown: 1}));
      }
      expect(visits, Messengers.dailyCap);
    });
  });

  group('task', () {
    test('about 1 in 5 visits brings a task', () {
      var tasks = 0;
      var visits = 0;
      final g = metOnce(at(5));
      for (var s = 0; s < 6000; s++) {
        final v = g.recordingRun(run(g), random: Random(s)).messengers.pending;
        if (v == null || v.kind == VisitKind.leashFull) continue;
        visits++;
        if (v.kind == VisitKind.task) tasks++;
      }
      expect(visits, greaterThan(300));
      expect(tasks / visits, closeTo(Messengers.taskShare, .05));
    });

    test('a task visit hangs no pouch until turned down', () {
      final start = metOnce(at(5));
      final (g, v) = visitWhere(start, (v) => v.kind == VisitKind.task);
      expect(g.pouches.leash, isEmpty);
      expect(g.lastRun!.glut, 1, reason: 'the run keeps its Glut');
      final declined = g.decliningTask(t0);
      expect(declined.messengers.pending, isNull);
      expect(declined.messengers.task, isNull);
      expect(declined.pouches.leash.single.color, v.messenger.color);
      expect(declined.forge.glut, g.forge.glut + v.messenger.giftGlut);
    });

    test('accepted: counts later runs, pays Glut and splinters, then goes', () {
      final start = metOnce(at(5));
      var (g, v) = visitWhere(
        start,
        (v) => v.kind == VisitKind.task && v.task!.type == TaskType.walk,
      );
      g = g.acceptingTask();
      final t = g.messengers.task!;
      expect(g.messengers.pending, isNull);
      expect(t.progress, 0, reason: 'the run that brought it does not count');
      final glut = g.forge.glut;
      final splinters = g.forge.splinters;
      var runs = 0;
      while (g.messengers.task != null) {
        g = g.recordingRun(
          run(g, at: t0.add(Duration(hours: ++runs)), m: 1000),
        );
        expect(runs, lessThan(10));
      }
      expect(runs, t.target ~/ 1000);
      expect(g.messengers.done!.messenger, v.messenger);
      expect(g.messengers.tasksDone, 1);
      expect(g.forge.splinters, splinters + v.messenger.taskSplinters);
      expect(
        g.forge.glut,
        glut + v.messenger.taskGlut + runs * 1,
        reason: 'task reward plus the Glut of each run',
      );
      expect(g.dismissingDone().messengers.done, isNull);
    });

    test('opening pouches counts for a pouch task', () {
      const t = MessengerTask(
        messenger: Messenger.kolk,
        type: TaskType.openPouches,
        target: 1,
      );
      final g = at(5)
          .copyWith(lp: 500, messengers: const MessengerState(met: 1, task: t))
          .hangingPouch(PouchColor.brown, t0);
      final opened = g.openingPouch(0, Random(1)).$1;
      expect(opened.messengers.task, isNull);
      expect(opened.messengers.done, isNotNull);
      expect(
        opened.forge.splinters,
        greaterThanOrEqualTo(Messenger.kolk.taskSplinters),
      );
    });

    test('while a task is open no other task is offered', () {
      const t = MessengerTask(
        messenger: Messenger.ruhu,
        type: TaskType.validRuns,
        target: 99,
      );
      final g = at(
        5,
      ).copyWith(messengers: const MessengerState(met: 1, task: t));
      for (var s = 0; s < 1500; s++) {
        final v = g.recordingRun(run(g), random: Random(s)).messengers.pending;
        expect(v?.kind, isNot(VisitKind.task));
      }
    });

    test('rewards are never companions', () {
      final (g, _) = visitWhere(
        metOnce(at(5)),
        (v) => v.kind == VisitKind.gift,
      );
      expect(g.companions, hasLength(1));
    });
  });

  group('save game', () {
    test('export and import keep messengers', () {
      final (g, _) = visitWhere(
        metOnce(at(5)),
        (v) => v.kind == VisitKind.task,
      );
      final loaded = SaveGame.decode(SaveGame.encode(g, t0)).game;
      expect(
        jsonEncode(loaded.messengers.toJson()),
        jsonEncode(g.messengers.toJson()),
      );
      expect(loaded.lastRun!.messenger, g.lastRun!.messenger);
      final accepted = g.acceptingTask();
      final back = SaveGame.decode(SaveGame.encode(accepted, t0)).game;
      expect(back.messengers.task!.type, accepted.messengers.task!.type);
    });

    test('version 4 files import with no messengers met', () {
      final json = at(5).toJson()..remove('messengers');
      final bytes = Uint8List.fromList(
        utf8.encode(
          jsonEncode({'format': 'treadplay-save', 'version': 4, 'game': json}),
        ),
      );
      final loaded = SaveGame.decode(bytes).game;
      expect(loaded.messengers.met, 0);
      expect(loaded.messengers.task, isNull);
    });

    test('broken messenger data is dropped, not an error', () {
      final json = at(5).toJson()
        ..['messengers'] = {
          'met': 'x',
          'pending': {'messenger': 'nobody'},
          'task': {'type': 'walk'},
        };
      final g = GameData.fromJson(json);
      expect(g.messengers.met, 0);
      expect(g.messengers.pending, isNull);
      expect(g.messengers.task, isNull);
    });

    test('waymark 6 counts messengers met', () {
      final g = at(5).copyWith(messengers: const MessengerState(met: 1));
      expect(g.waymarkCounters[WaymarkCounter.messengersMet], 1);
    });
  });
}
