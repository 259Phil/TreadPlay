import 'package:flutter_test/flutter_test.dart';

import '../support/ios_track.dart';
import '../support/run_pipeline.dart';

// Field test (iPhone, Safari, outdoors, 13 km/h): the build before this
// change showed 0.06 km after 50 s and 0.83 km after 15 min instead of
// about 0.18 and 3.3 km. iPhones report coarse accuracy steps (16, 35,
// 48, 65 m) for fixes that are better than that; the old 25 m limit threw
// them away, the gaps restarted the filter and every restart cost the
// escape distance again. Same tracks here at 1 Hz, with and without the
// receiver speed (coords.speed).

const _kmh = 13.0;
const _mps = _kmh / 3.6;

void _report(String line) {
  // ignore: avoid_print
  print(line);
}

double _median(List<double> v) => ([...v]..sort())[v.length ~/ 2];

void main() {
  for (final sky in IosSky.values) {
    test('iPhone ${sky.name} sky with coords.speed: 50 s, 5 and 15 min', () {
      final at50 = <double>[];
      for (var seed = 1; seed <= 4; seed++) {
        final p = RunPipeline(
          iosRun(seed, _kmh, 900, sky),
          seed: seed,
          dopplerNoiseMps: 0.3,
        ).run();
        final d50 = p.distanceAt(50);
        final d300 = p.distanceAt(300);
        final d900 = p.engine.distanceM;
        _report(
          'iOS ${sky.name} seed $seed: 50 s ${d50.toStringAsFixed(0)} m '
          '(truth ${(50 * _mps).toStringAsFixed(0)}), 5 min '
          '${d300.toStringAsFixed(0)} m (${(300 * _mps).toStringAsFixed(0)}), '
          '15 min ${d900.toStringAsFixed(0)} m '
          '(${(900 * _mps).toStringAsFixed(0)})',
        );
        at50.add(d50);
        expect(d50, greaterThan(110));
        expect(d50, lessThan(190));
        expect(d300, closeTo(300 * _mps, 300 * _mps * 0.05));
        expect(d900, closeTo(900 * _mps, 900 * _mps * 0.05));
      }
      expect(_median(at50), inInclusiveRange(150, 190));
    });
  }

  for (final sky in [IosSky.open, IosSky.mixed]) {
    test('iPhone ${sky.name} sky without coords.speed: 15 min', () {
      for (var seed = 1; seed <= 4; seed++) {
        final p = RunPipeline(iosRun(seed, _kmh, 900, sky), seed: seed).run();
        final d = p.engine.distanceM;
        _report(
          'iOS ${sky.name} no speed seed $seed: 15 min '
          '${d.toStringAsFixed(0)} m (${(900 * _mps).toStringAsFixed(0)})',
        );
        expect(d, closeTo(900 * _mps, 900 * _mps * 0.12));
      }
    });
  }

  test('live speed matches the run once moving', () {
    final p = RunPipeline(
      iosRun(2, _kmh, 300, IosSky.mixed),
      seed: 2,
      dopplerNoiseMps: 0.3,
    ).run();
    final shown = p.between(60, 300).map((s) => s.speedKmh).toList();
    expect(_median(shown), closeTo(_kmh, 1));
  });

  test('standing 5 min with iPhone accuracy and speed ~0 adds nothing', () {
    for (var seed = 1; seed <= 6; seed++) {
      for (final sky in IosSky.values) {
        final t = iosRun(seed, 0, 0, sky, standS: 300);
        final p = RunPipeline(t, seed: seed, dopplerNoiseMps: 0.8).run();
        expect(p.engine.distanceM, lessThan(15), reason: '${sky.name} $seed');
      }
    }
  });

  test('a car with coords.speed adds no distance', () {
    for (var seed = 1; seed <= 4; seed++) {
      final t = iosRun(seed, 54, 300, IosSky.mixed);
      final p = RunPipeline(t, seed: seed, dopplerNoiseMps: 0.3).run();
      expect(p.engine.distanceM, lessThan(50));
    }
  });
}
