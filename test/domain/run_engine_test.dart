import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/movement.dart';
import 'package:treadplay/domain/run_engine.dart';

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
    final engine = RunEngine(companion: Companion.pebble(t0), startedAt: t0);
    move(engine, 4.5, 800); // 1000 m
    expect(engine.blocks, 4);
    expect(engine.lp, 10);
    expect(engine.breathLeft, 2);
    final summary = engine.finish();
    expect(summary.valid, isTrue);
    expect(summary.lp, 10);
    expect(summary.breathUsed, 4);
  });

  test('standing still earns nothing', () {
    final engine = RunEngine(companion: Companion.pebble(t0), startedAt: t0);
    move(engine, 0, 600);
    expect(engine.lp, 0);
    expect(engine.breathLeft, 6);
  });

  test('outside the sweet spot earns nothing but still tracks', () {
    final engine = RunEngine(companion: Companion.pebble(t0), startedAt: t0);
    move(engine, 12, 300);
    expect(engine.lp, 0);
    expect(engine.distanceM, closeTo(1000, 1e-6));
  });

  test('empty breath stops LP but keeps tracking', () {
    final pebble = Companion.pebble(t0).copyWith(breath: 1);
    final engine = RunEngine(companion: pebble, startedAt: t0);
    move(engine, 4.5, 800);
    expect(engine.blocks, 1);
    expect(engine.lp, 2.5);
    expect(engine.distanceM, closeTo(1000, 1e-6));
  });

  test('distance without steps is not counted', () {
    final engine = RunEngine(companion: Companion.pebble(t0), startedAt: t0);
    move(engine, 4.5, 800, stepsPerMeter: 0);
    final summary = engine.finish();
    expect(summary.valid, isFalse);
    expect(summary.lp, 0);
    expect(summary.breathUsed, 0);
  });

  test('vehicle speed for over a minute is not counted', () {
    final engine = RunEngine(companion: Companion.pebble(t0), startedAt: t0);
    move(engine, 4.5, 400);
    move(engine, 50, 90);
    expect(engine.finish().valid, isFalse);
  });

  test('a Gale companion at walking pace earns nothing', () {
    final gale = Companion.fresh(
      t0,
      id: 'dune-1',
      speciesId: 'dune',
      rarity: Rarity.common,
    );
    expect(gale.type, CompanionType.gale);
    final engine = RunEngine(companion: gale, startedAt: t0);
    move(engine, 4.5, 800);
    expect(engine.lp, 0);
    expect(engine.distanceM, closeTo(1000, 1e-6));
  });

  test('no Spirit left, no LP', () {
    final worn = Companion.pebble(t0).copyWith(spirit: 0);
    final engine = RunEngine(companion: worn, startedAt: t0);
    move(engine, 4.5, 800);
    expect(engine.lp, 0);
    expect(engine.breathLeft, 6);
  });
}
