import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/movement.dart';
import 'package:treadplay/domain/run_engine.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/sweet_spot.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  /// Feeds [seconds] of 1 s samples at [kmh] with [stepsPerMeter].
  void move(
    RunEngine engine,
    double kmh,
    int seconds, {
    double stepsPerMeter = 1.3,
  }) {
    var t = engine.elapsed;
    for (var i = 0; i < seconds; i++) {
      t += const Duration(seconds: 1);
      final m = kmh / 3.6;
      engine.add(
        MovementSample(
          time: t0.add(t),
          speedKmh: kmh,
          distanceM: m,
          steps: (m * stepsPerMeter).round(),
        ),
      );
    }
  }

  /// The payout before pieces: only whole 250 m blocks. Returns LP, Breath
  /// left and the second of the first LP for 1 s samples at [kmh].
  ({double lp, double breathLeft, int? firstLpSecond}) wholeBlocks(
    Companion c,
    double breathAtStart,
    double kmh,
    int seconds,
  ) {
    var breath = breathAtStart;
    var lp = 0.0;
    var progress = 0.0;
    int? first;
    for (var i = 1; i <= seconds; i++) {
      bool canEarn() => c.spirit > 0 && breath >= 1;
      final f = canEarn()
          ? sweetSpotFactor(c.type, kmh, widenKmh: c.sweetSpotWidenKmh)
          : 0.0;
      if (f == 0) continue;
      progress += kmh / 3.6 * f;
      while (progress >= RunEngine.metersPerBreath && canEarn()) {
        progress -= RunEngine.metersPerBreath;
        breath -= 1;
        lp += c.lpPerBreath;
        first ??= i;
      }
      if (!canEarn()) progress = 0;
    }
    return (lp: lp, breathLeft: breath, firstLpSecond: first);
  }

  int? firstLpSecond(RunEngine engine, double kmh, int seconds) {
    for (var i = 1; i <= seconds; i++) {
      move(engine, kmh, 1);
      if (engine.lp > 0) return i;
    }
    return null;
  }

  group('pieces pay the same as whole blocks', () {
    final gaits = <String, (Companion, double)>{
      'Schritt': (Companion.pebble(), 4.5),
      'Trab': (
        Companion.fresh(id: 'g-1', speciesId: 'gilt', rarity: Rarity.common),
        7.5,
      ),
      'Galopp': (
        Companion.fresh(id: 'h-1', speciesId: 'hookfin', rarity: Rarity.common),
        11,
      ),
    };
    for (final MapEntry(key: gait, value: (c, kmh)) in gaits.entries) {
      test('$gait: a full tank ends with the same LP and Breath', () {
        final tank = c.tankSize.toDouble();
        // Long enough to empty the tank twice over.
        final seconds = (tank * 2 * 250 / (kmh / 3.6)).ceil();
        final old = wholeBlocks(c, tank, kmh, seconds);
        final engine = RunEngine(
          companion: c,
          breathAtStart: tank,
          startedAt: t0,
        );
        move(engine, kmh, seconds);
        expect(old.breathLeft, 0);
        expect(engine.breathLeft, old.breathLeft);
        expect(engine.lp, closeTo(old.lp, 1e-9));
        expect(engine.lp, closeTo(tank * c.lpPerBreath, 1e-9));
        expect(engine.blocks, c.tankSize);
        expect(engine.finish().breathUsed, tank);
      });

      test('$gait: whole blocks mid-run match exactly', () {
        for (final seconds in [300, 600, 901]) {
          final old = wholeBlocks(c, 6, kmh, seconds);
          final engine = RunEngine(
            companion: c,
            breathAtStart: 6,
            startedAt: t0,
          );
          move(engine, kmh, seconds);
          // Pieces past the last whole block are extra, paid at the same rate.
          final extra = engine.pieces % RunEngine.piecesPerBreath;
          expect(engine.lp, closeTo(old.lp + extra * engine.lpPerPiece, 1e-9));
          expect(
            engine.breathLeft,
            closeTo(old.breathLeft - extra / RunEngine.piecesPerBreath, 1e-9),
          );
          expect(engine.lp / engine.breathUsed, closeTo(c.lpPerBreath, 1e-9));
        }
      });

      test('$gait: first LP after a fifth of the time', () {
        final old = wholeBlocks(c, 6, kmh, 600).firstLpSecond!;
        final engine = RunEngine(companion: c, breathAtStart: 6, startedAt: t0);
        final now = firstLpSecond(engine, kmh, 600)!;
        expect(now, lessThanOrEqualTo((old / 5).ceil() + 1));
        expect(engine.lp, closeTo(c.lpPerBreath / 5, 1e-9));
        expect(engine.breathLeft, closeTo(6 - 0.2, 1e-9));
        // ignore: avoid_print
        print('$gait ${kmh}km/h: first LP after ${old}s -> ${now}s');
      });
    }

    test('a part-full tank stops at the same place', () {
      final c = Companion.pebble();
      final old = wholeBlocks(c, 3.4, 4.5, 2000);
      final engine = RunEngine(companion: c, breathAtStart: 3.4, startedAt: t0);
      move(engine, 4.5, 2000);
      expect(old.breathLeft, closeTo(0.4, 1e-9));
      expect(engine.breathLeft, closeTo(old.breathLeft, 1e-9));
      expect(engine.blocks, 3);
      expect(engine.lp, closeTo(old.lp, 1e-9));
      expect(engine.canEarn, isFalse);
      expect(engine.pieceProgress, 0);
    });

    test('off-centre pace pays the same per weighted metre', () {
      final c = Companion.pebble();
      final old = wholeBlocks(c, 6, 3.4, 4000);
      final engine = RunEngine(companion: c, breathAtStart: 6, startedAt: t0);
      move(engine, 3.4, 4000);
      expect(engine.breathLeft, closeTo(old.breathLeft, 1e-9));
      expect(engine.lp, closeTo(old.lp, 1e-9));
    });

    test('50 m in the sweet spot pays the first piece', () {
      final engine = RunEngine(
        companion: Companion.pebble(),
        breathAtStart: 6,
        startedAt: t0,
      );
      move(engine, 4.5, 39); // 48.75 m
      expect(engine.lp, 0);
      expect(engine.pieceProgress, closeTo(48.75 / 50, 1e-9));
      move(engine, 4.5, 1); // 50 m
      expect(engine.pieces, 1);
      expect(engine.blocks, 0);
      expect(engine.lp, 0.5);
      expect(engine.breathLeft, closeTo(5.8, 1e-9));
    });
  });

  test('1 km in the sweet spot gives 4 blocks', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    move(engine, 4.5, 800); // 1000 m
    expect(engine.blocks, 4);
    expect(engine.lp, 10);
    expect(engine.breathLeft, 2);
    final summary = engine.finish();
    expect(summary.valid, isTrue);
    expect(summary.lp, 10);
    expect(summary.breathUsed, 4);
    expect(summary.breathLeft, 2);
    expect(summary.tankSize, 6);
    expect(summary.pace, const Duration(minutes: 13, seconds: 20));
  });

  test('standing still earns nothing', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    move(engine, 0, 600);
    expect(engine.lp, 0);
    expect(engine.breathLeft, 6);
  });

  test('outside the sweet spot earns nothing but still tracks', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    move(engine, 12, 300);
    expect(engine.inBand, isFalse);
    expect(engine.lp, 0);
    expect(engine.breathLeft, 6);
    expect(engine.distanceM, closeTo(1000, 1e-6));
    final summary = engine.finish();
    expect(summary.distanceM, closeTo(1000, 1e-6));
    expect(summary.breathLeft, 6);
  });

  test('empty breath stops LP but keeps tracking', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 1,
      startedAt: t0,
    );
    move(engine, 4.5, 800);
    expect(engine.blocks, 1);
    expect(engine.lp, 2.5);
    expect(engine.distanceM, closeTo(1000, 1e-6));
  });

  test('distance without steps is not counted', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    move(engine, 4.5, 800, stepsPerMeter: 0);
    final summary = engine.finish();
    expect(summary.valid, isFalse);
    expect(summary.lp, 0);
    expect(summary.breathUsed, 0);
  });

  test('vehicle speed for over a minute is not counted', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    move(engine, 4.5, 400);
    move(engine, 50, 90);
    expect(engine.finish().valid, isFalse);
  });

  test('a Gale companion at walking pace earns nothing', () {
    final gale = Companion.fresh(
      id: 'dune-1',
      speciesId: 'dune',
      rarity: Rarity.common,
    );
    expect(gale.type, CompanionType.gale);
    final engine = RunEngine(companion: gale, breathAtStart: 6, startedAt: t0);
    move(engine, 4.5, 800);
    expect(engine.lp, 0);
    expect(engine.distanceM, closeTo(1000, 1e-6));
  });

  test('no Spirit left, no LP', () {
    final worn = Companion.pebble().copyWith(spirit: 0);
    final engine = RunEngine(companion: worn, breathAtStart: 6, startedAt: t0);
    move(engine, 4.5, 800);
    expect(engine.lp, 0);
    expect(engine.breathLeft, 6);
  });

  test('without movement access the run tracks but earns nothing', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
      earnsLp: false,
    );
    move(engine, 4.5, 800);
    expect(engine.inBand, isTrue);
    expect(engine.canEarn, isFalse);
    expect(engine.lp, 0);
    expect(engine.breathLeft, 6);
    expect(engine.distanceM, closeTo(1000, 1e-6));
    final summary = engine.finish();
    expect(summary.earnsLp, isFalse);
    expect(summary.lp, 0);
    expect(summary.breathLeft, 6);
  });

  test('GPS distance without a step counter is not flagged', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    for (var i = 1; i <= 800; i++) {
      engine.add(
        MovementSample(
          time: t0.add(Duration(seconds: i)),
          speedKmh: 4.5,
          distanceM: 1.25,
          steps: null,
        ),
      );
    }
    final summary = engine.finish();
    expect(summary.valid, isTrue);
    expect(summary.lp, 10);
  });

  test('a run summary round-trips and reads older saves', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    move(engine, 4.5, 400);
    final json = engine.finish().toJson();
    final back = RunSummary.fromJson(json);
    expect(back.breathLeft, 4);
    expect(back.tankSize, 6);
    expect(back.earnsLp, isTrue);

    final old = RunSummary.fromJson(
      {...json}..removeWhere(
        (k, _) => {'breathLeft', 'tankSize', 'earnsLp'}.contains(k),
      ),
    );
    expect(old.breathLeft, isNull);
    expect(old.earnsLp, isTrue);
  });

  test('sweet-spot share is the time inside the range', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 6,
      startedAt: t0,
    );
    expect(engine.sweetSpotShare, isNull);
    move(engine, 4.5, 300); // in band
    move(engine, 12, 100); // out of band
    expect(engine.sweetSpotShare, closeTo(0.75, 1e-9));
    final summary = engine.finish();
    expect(summary.sweetSpotShare, closeTo(0.75, 1e-9));
    final copy = RunSummary.fromJson(summary.toJson());
    expect(copy.sweetSpotShare, closeTo(0.75, 1e-9));
  });

  test('sweet-spot share also counts with an empty Breath bar', () {
    final engine = RunEngine(
      companion: Companion.pebble(),
      breathAtStart: 0,
      startedAt: t0,
    );
    move(engine, 4.5, 60);
    expect(engine.lp, 0);
    expect(engine.sweetSpotShare, 1);
  });
}
