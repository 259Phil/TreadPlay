import 'package:flutter_test/flutter_test.dart';

import '../support/gps_scenarios.dart';

// Simulated runs over many seeds: GPS drift while standing indoors must not
// become distance, real walking and running must still count.
const _seeds = 20;

double _median(List<double> v) => ([...v]..sort())[v.length ~/ 2];

double _max(List<double> v) => v.reduce((a, b) => a > b ? a : b);

void _report(String line) {
  // ignore: avoid_print
  print(line);
}

void main() {
  test('standing indoors for 10 minutes adds (almost) no distance', () {
    final dist = <double>[];
    final speed = <double>[];
    for (var seed = 1; seed <= 2 * _seeds; seed++) {
      final r = runFilter(GpsScenario(seed: seed)..indoorStill(600));
      dist.add(r.distanceM);
      speed.add(r.maxStillSpeedKmh);
    }
    _report(
      'indoor 10 min: median ${_median(dist).toStringAsFixed(1)} m, '
      'mean ${(dist.reduce((a, b) => a + b) / dist.length).toStringAsFixed(1)} m, '
      'max ${_max(dist).toStringAsFixed(1)} m, '
      '${dist.where((d) => d < 5).length}/${dist.length} under 5 m',
    );
    expect(_median(dist), lessThan(5));
    expect(dist.reduce((a, b) => a + b) / dist.length, lessThan(5));
    expect(dist.where((d) => d < 5).length, greaterThanOrEqualTo(38));
    expect(_max(dist), lessThan(50));
    // Standing means speed 0 (tempo "--", no off-sweet-spot hint).
    expect(_median(speed), 0);
  });

  for (final kmh in [3.0, 4.5, 7.5, 11.0]) {
    test('outdoor 1 km at $kmh km/h is counted', () {
      final errs = <double>[];
      final detect = <double>[];
      for (var seed = 1; seed <= _seeds; seed++) {
        final s = GpsScenario(seed: seed)
          ..outdoor(20, 0)
          ..outdoor(GpsScenario.secondsFor(1000, kmh), kmh);
        final r = runFilter(s);
        errs.add((r.distanceM - s.trueDistanceM) / s.trueDistanceM * 100);
        detect.add(r.detectSecs.first ?? 999);
      }
      _report(
        'outdoor $kmh km/h: error median ${_median(errs).toStringAsFixed(1)}% '
        'range ${errs.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}..'
        '${_max(errs).toStringAsFixed(1)}%, first distance after median '
        '${_median(detect)} s, max ${_max(detect)} s',
      );
      // 3 km/h is a slow stroll with 5–15 m noise: looser bounds.
      final slow = kmh < 4;
      for (final e in errs) {
        expect(e.abs(), lessThan(slow ? 10 : 5));
      }
      expect(_median(errs).abs(), lessThan(slow ? 5 : 2));
      expect(_median(detect), lessThanOrEqualTo(slow ? 30 : 20));
      expect(_max(detect), lessThanOrEqualTo(slow ? 60 : 40));
    });
  }

  test('walk, stand 3 minutes, walk again', () {
    final errs = <double>[];
    final drift = <double>[];
    final detect = <double>[];
    for (var seed = 1; seed <= _seeds; seed++) {
      final s = GpsScenario(seed: seed)
        ..outdoor(20, 0)
        ..outdoor(GpsScenario.secondsFor(300, 4.5), 4.5)
        // The first 30 s of the stop let the smoothing settle.
        ..outdoor(30, 0);
      final settled = runFilter(s).distanceM;
      s.outdoor(150, 0);
      drift.add(runFilter(s).distanceM - settled);
      s.outdoor(GpsScenario.secondsFor(300, 4.5), 4.5);
      final r = runFilter(s);
      errs.add((r.distanceM - s.trueDistanceM) / s.trueDistanceM * 100);
      detect.add(r.detectSecs[1] ?? 999);
    }
    _report(
      'walk-stop-walk 600 m: error median ${_median(errs).toStringAsFixed(1)}% '
      'range ${errs.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}..'
      '${_max(errs).toStringAsFixed(1)}%, standing adds median '
      '${_median(drift).toStringAsFixed(1)} m max ${_max(drift).toStringAsFixed(1)} m, '
      're-start after median ${_median(detect)} s max ${_max(detect)} s',
    );
    for (final e in errs) {
      expect(e.abs(), lessThan(8));
    }
    expect(_median(drift), lessThan(5));
    expect(_median(detect), lessThanOrEqualTo(25));
  });
}
