import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/movement.dart';
import 'package:treadplay/domain/run_engine.dart';
import 'package:treadplay/domain/run_summary.dart';

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
