import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/live_speed.dart';

import '../support/run_pipeline.dart';
import '../support/synthetic_track.dart';

/// Phone-like GPS noise: a slowly drifting offset of about half the
/// reported accuracy (2.5–10 m per axis) plus 1.5 m jitter per fix.
SyntheticTrack phoneTrack(int seed) =>
    SyntheticTrack(seed: seed, correlation: 0.99, jitterM: 1.5);

/// [kmh] with a gentle curve, accuracy changing every 10 s between
/// [minAcc] and [maxAcc].
SyntheticTrack steady(
  int seed,
  double kmh, {
  int standS = 5,
  double minAcc = 5,
  double maxAcc = 20,
  SyntheticTrack? track,
}) {
  final r = Random(seed + 100);
  final t = (track ?? phoneTrack(seed))..stand(standS, accuracyM: 8);
  for (var k = 0; k < 30; k++) {
    t.move(
      10,
      kmh / 3.6,
      headingDeg: k * 6.0,
      accuracyM: minAcc + r.nextDouble() * (maxAcc - minAcc),
    );
  }
  return t;
}

double _median(Iterable<double> v) {
  final s = [...v]..sort();
  return s.isEmpty ? double.nan : s[s.length ~/ 2];
}

typedef Shares = ({
  double speed10,
  double speed20,
  double pace10,
  double old10,
  double oldPace10,
});

/// Prints before/after for seconds [from]..[to] at a true speed of [truth]
/// km/h: share of seconds within ±10 % and medians.
Shares report(String name, RunPipeline p, int from, int to, double truth) {
  final w = p.between(from, to);
  final r = (
    speed10: shareWithin(w.map((s) => s.speedKmh), truth, 0.1),
    speed20: shareWithin(w.map((s) => s.speedKmh), truth, 0.2),
    pace10: shareWithin(
      w.map((s) => ShownSample.kmhOf(s.livePace)),
      truth,
      0.1,
    ),
    old10: shareWithin(w.map((s) => s.oldSpeedKmh), truth, 0.1),
    oldPace10: shareWithin(
      w.map((s) => ShownSample.kmhOf(s.oldPace)),
      truth,
      0.1,
    ),
  );
  String pct(double x) => '${(x * 100).round()} %';
  String km(double x) => x.toStringAsFixed(1);
  // ignore: avoid_print
  print(
    'Tempo sim $name (truth ${km(truth)} km/h): '
    'km/h ±10 %: ${pct(r.old10)} -> ${pct(r.speed10)} '
    '(±20 %: ${pct(r.speed20)}); '
    'tempo field ±10 %: ${pct(r.oldPace10)} -> ${pct(r.pace10)}; '
    'median tempo field as km/h '
    '${km(_median(w.map((s) => ShownSample.kmhOf(s.oldPace) ?? 0)))} -> '
    '${km(_median(w.map((s) => ShownSample.kmhOf(s.livePace) ?? 0)))}; '
    'km/h p10-p90 before '
    '${km(_q(w.map((s) => s.oldSpeedKmh), .1))}-${km(_q(w.map((s) => s.oldSpeedKmh), .9))}, '
    'after ${km(_q(w.map((s) => s.speedKmh), .1))}-${km(_q(w.map((s) => s.speedKmh), .9))}',
  );
  return r;
}

double _q(Iterable<double> v, double q) {
  final s = [...v]..sort();
  return s[(s.length * q).floor().clamp(0, s.length - 1)];
}

/// Tempo field and gauge show the same speed whenever there is a tempo.
void expectConsistent(RunPipeline p) {
  for (final s in p.shown) {
    final k = ShownSample.kmhOf(s.livePace);
    if (k != null) expect(k, closeTo(s.speedKmh, 0.05));
  }
}

void main() {
  test('13 km/h with noisy fixes (5-20 m)', () {
    var sum10 = 0.0;
    for (var seed = 1; seed <= 5; seed++) {
      final p = RunPipeline(steady(seed, 13), seed: seed).run();
      final r = report('13 km/h, 5-20 m, seed $seed', p, 40, 300, 13);
      expectConsistent(p);
      sum10 += r.pace10;
      expect(r.speed20, greaterThanOrEqualTo(0.9));
      expect(r.speed10, greaterThan(r.old10));
      expect(
        _median(p.between(40, 300).map((s) => s.speedKmh)),
        closeTo(13, 0.65),
      );
    }
    expect(sum10 / 5, greaterThanOrEqualTo(0.75));
  });

  test('13 km/h with steadier fixes (5-10 m)', () {
    for (var seed = 1; seed <= 5; seed++) {
      final p = RunPipeline(steady(seed, 13, maxAcc: 10), seed: seed).run();
      final r = report('13 km/h, 5-10 m, seed $seed', p, 40, 300, 13);
      expect(r.pace10, greaterThanOrEqualTo(0.85));
    }
  });

  test('with Doppler speed from the device: within 10 % throughout', () {
    for (var seed = 1; seed <= 3; seed++) {
      final p = RunPipeline(
        steady(seed, 13),
        seed: seed,
        dopplerNoiseMps: 0.3,
      ).run();
      final r = report('13 km/h + Doppler, seed $seed', p, 40, 300, 13);
      expectConsistent(p);
      expect(r.pace10, greaterThanOrEqualTo(0.97));
    }
  });

  test('a long wait for GPS at the start no longer slows the tempo', () {
    final p = RunPipeline(steady(6, 13, standS: 60), seed: 6).run();
    final r = report('13 km/h after 60 s waiting', p, 100, 355, 13);
    expect(r.speed20, greaterThanOrEqualTo(0.9));
    expect(r.oldPace10, 0);
    // The whole-run average is slower and stays for the summary.
    expect(ShownSample.kmhOf(p.shown.last.oldPace)!, lessThan(11));
  });

  test('walking at 5 km/h stays a walk', () {
    for (var seed = 1; seed <= 3; seed++) {
      final p = RunPipeline(steady(seed, 5, maxAcc: 15), seed: seed).run();
      final r = report('walk 5 km/h, 5-15 m, seed $seed', p, 60, 300, 5);
      expectConsistent(p);
      // Slow movement against meters of GPS drift: ±20 % most of the time,
      // centred on the truth (the gait band is ±2.5 km/h, see below).
      expect(r.speed20, greaterThanOrEqualTo(0.6));
      expect(r.speed20, greaterThan(r.old10));
      expect(
        _median(p.between(60, 300).map((s) => s.speedKmh)),
        closeTo(5, 0.4),
      );
    }
  });

  test('a stop at the lights shows "–" and the tempo comes back', () {
    final t = phoneTrack(9)
      ..stand(5, accuracyM: 6)
      ..move(120, 13 / 3.6, accuracyM: 8)
      ..stand(60, accuracyM: 8)
      ..move(120, 13 / 3.6, headingDeg: 90, accuracyM: 8);
    final p = RunPipeline(t).run();
    report('lights, before the stop', p, 40, 125, 13);
    final r = report('lights, after the stop', p, 215, 305, 13);
    final still = p.between(140, 185);
    expect(still.every((s) => s.livePace == null), isTrue);
    expect(still.every((s) => s.speedKmh < 0.5), isTrue);
    expect(r.pace10, greaterThanOrEqualTo(0.85));
  });

  test('a GPS jump neither spikes the speed nor costs distance', () {
    final t = phoneTrack(10)
      ..stand(5, accuracyM: 6)
      ..move(100, 13 / 3.6, accuracyM: 8)
      ..spike(150)
      ..move(100, 13 / 3.6, accuracyM: 8);
    final p = RunPipeline(t).run();
    report('13 km/h with a 150 m jump', p, 40, 205, 13);
    for (final s in p.between(100, 130)) {
      expect(s.speedKmh, closeTo(13, 13 * 0.15));
    }
    expect(p.filter.jumps, greaterThanOrEqualTo(1));
    expect(
      p.engine.distanceM,
      closeTo(t.trueDistanceM, t.trueDistanceM * 0.05),
    );
  });

  test('no tempo before enough movement is seen', () {
    final p = RunPipeline(steady(11, 13)).run();
    expect(p.between(1, 8).every((s) => s.livePace == null), isTrue);
    expect(p.between(30, 40).every((s) => s.livePace != null), isTrue);
  });

  test('each gait at its own speed stays in its band and earns fairly', () {
    for (final (type, kmh) in [
      (CompanionType.moss, 4.5),
      (CompanionType.brook, 7.5),
      (CompanionType.gale, 11.0),
    ]) {
      double inBand(RunPipeline p) {
        final w = p.between(40, 300);
        return w
                .where(
                  (s) =>
                      (s.speedKmh - type.sweetSpotKmh).abs() <= type.rangeKmh,
                )
                .length /
            w.length;
      }

      final companion = Companion.pebble().copyWith(tempo: type);
      final before = RunPipeline(
        steady(12, kmh, maxAcc: 15),
        companion: companion,
        legacy: true,
      ).run();
      final after = RunPipeline(
        steady(12, kmh, maxAcc: 15),
        companion: companion,
      ).run();
      // ignore: avoid_print
      print(
        'Gait sim ${type.name} at $kmh km/h: in band '
        '${(inBand(before) * 100).round()} % -> '
        '${(inBand(after) * 100).round()} %, LP '
        '${before.engine.lp.toStringAsFixed(1)} -> '
        '${after.engine.lp.toStringAsFixed(1)}',
      );
      expect(inBand(after), greaterThanOrEqualTo(0.97));
      expect(after.engine.lp, greaterThanOrEqualTo(before.engine.lp));
      expect(after.engine.isValid, isTrue);
    }
  });

  group('LiveSpeed', () {
    final t0 = DateTime.utc(2026);
    DateTime at(num s) => t0.add(Duration(milliseconds: (s * 1000).round()));

    /// Straight line north at [mps], one fix per second.
    LiveSpeed line(
      double mps, {
      int seconds = 20,
      double? doppler,
      double noise = 0,
    }) {
      final l = LiveSpeed();
      for (var s = 0; s <= seconds; s++) {
        l.add(
          at(s),
          x: s.isEven ? noise : -noise,
          y: mps * s,
          accuracyM: 5,
          moving: true,
          dopplerMps: doppler,
        );
      }
      return l;
    }

    test('fits distance over time on the raw positions', () {
      final v = line(3).at(at(20));
      expect(v.mps, closeTo(3, 1e-9));
      expect(v.ready, isTrue);
    });

    test('side-to-side jitter barely moves it', () {
      expect(line(3, noise: 2).at(at(20)).mps, closeTo(3, 0.05));
    });

    test('not ready before enough movement', () {
      final l = line(3, seconds: 4);
      expect(l.at(at(4)).mps, closeTo(3, 1e-9));
      expect(l.at(at(4)).ready, isFalse);
      expect(line(3, seconds: 1).at(at(1)).mps, isNull);
    });

    test('standing is 0, and the window starts over when moving again', () {
      final l = line(3)..add(at(21), x: 0, y: 63, accuracyM: 5, moving: false);
      expect(l.at(at(22)).mps, 0);
      l.add(at(30), x: 0, y: 70, accuracyM: 5, moving: true);
      expect(l.at(at(30)).mps, isNull);
      expect(l.at(at(30)).ready, isFalse);
    });

    test('plausible Doppler leads, positions nudge it', () {
      expect(
        line(3, doppler: 3.3).at(at(20)).mps,
        closeTo(0.8 * 3.3 + 0.2 * 3, 1e-9),
      );
      // Far apart: Doppler alone.
      expect(line(3, doppler: 6).at(at(20)).mps, closeTo(6, 1e-9));
    });

    test('Doppler 0 (browser without speed) is ignored', () {
      expect(line(3, doppler: 0).at(at(20)).mps, closeTo(3, 1e-9));
    });

    test('Doppler faster than walking or running is passed on', () {
      final l = LiveSpeed()
        ..add(at(0), x: 0, y: 0, accuracyM: 5, moving: true)
        ..add(at(1), x: 0, y: 0, accuracyM: 5, moving: true, dopplerMps: 15);
      expect(l.at(at(1)).mps, 15);
    });
  });
}
