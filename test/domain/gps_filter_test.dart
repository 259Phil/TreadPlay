import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/gps_filter.dart';

import '../support/synthetic_track.dart';

void main() {
  void report(String name, SyntheticTrack t) {
    final after = t.filtered();
    // ignore: avoid_print
    print(
      'GPS sim $name: truth ${t.trueDistanceM.toStringAsFixed(0)} m, '
      'before ${t.legacy().toStringAsFixed(0)} m, '
      'after ${after.toStringAsFixed(0)} m',
    );
  }

  test('steady walk stays within 5 % of the true distance', () {
    for (var seed = 1; seed <= 5; seed++) {
      final t = SyntheticTrack(seed: seed)
        ..stand(5, accuracyM: 6)
        ..move(300, 1.4, accuracyM: 6)
        ..move(200, 1.4, headingDeg: 90, accuracyM: 8)
        ..move(150, 1.4, headingDeg: 200, accuracyM: 5);
      if (seed == 1) report('walk 4.9 km/h', t);
      expect(t.filtered(), closeTo(t.trueDistanceM, t.trueDistanceM * 0.05));
    }
  });

  test('jog at 10 km/h stays within 5 %', () {
    final t = SyntheticTrack(seed: 7)
      ..stand(5, accuracyM: 5)
      ..move(600, 10 / 3.6, accuracyM: 6)
      ..move(300, 10 / 3.6, headingDeg: 120, accuracyM: 6);
    report('jog 10 km/h', t);
    expect(t.filtered(), closeTo(t.trueDistanceM, t.trueDistanceM * 0.05));
  });

  test('slow walk with poorer accuracy stays within 7 %', () {
    for (var seed = 1; seed <= 5; seed++) {
      final t = SyntheticTrack(seed: seed, correlation: 0.6)
        ..stand(5, accuracyM: 12)
        ..move(400, 3 / 3.6, accuracyM: 12)
        ..move(400, 3 / 3.6, headingDeg: 60, accuracyM: 15);
      if (seed == 1) report('slow walk 3 km/h, 12-15 m', t);
      expect(t.filtered(), closeTo(t.trueDistanceM, t.trueDistanceM * 0.07));
    }
  });

  test('walk, pause, walk: the pause adds almost nothing', () {
    final t = SyntheticTrack(seed: 12)
      ..stand(5, accuracyM: 6)
      ..move(200, 1.4, accuracyM: 6)
      ..stand(180, accuracyM: 10)
      ..move(200, 1.4, headingDeg: 180, accuracyM: 6);
    report('walk + 3 min pause + walk', t);
    expect(t.filtered(), closeTo(t.trueDistanceM, t.trueDistanceM * 0.05));
  });

  test('jitter while standing adds almost nothing', () {
    for (var seed = 1; seed <= 5; seed++) {
      final t = SyntheticTrack(seed: seed)..stand(300, accuracyM: 12);
      if (seed == 1) report('standing 5 min, 12 m', t);
      expect(t.filtered(), lessThan(15));
    }
  });

  test('a 300 m spike is rejected', () {
    final t = SyntheticTrack(seed: 3)
      ..stand(5, accuracyM: 6)
      ..move(200, 1.4, accuracyM: 6)
      ..spike(300)
      ..move(200, 1.4, accuracyM: 6);
    report('walk with 300 m spike', t);
    final d = t.filtered();
    expect(t.lastFilter!.jumps, greaterThanOrEqualTo(1));
    expect(d, closeTo(t.trueDistanceM, t.trueDistanceM * 0.05));
  });

  test('a burst of three spikes in a row is rejected', () {
    final t = SyntheticTrack(seed: 4)
      ..stand(5, accuracyM: 6)
      ..move(200, 1.4, accuracyM: 6)
      ..spike(300)
      ..spike(-250)
      ..spike(400)
      ..move(200, 1.4, accuracyM: 6);
    final d = t.filtered();
    expect(d, closeTo(t.trueDistanceM, t.trueDistanceM * 0.05));
  });

  test('a gap is not bridged with a straight jump', () {
    final t = SyntheticTrack(seed: 5)
      ..stand(5, accuracyM: 6)
      ..move(300, 1.4, accuracyM: 6)
      // Tab in background for 2 minutes while still walking: no fixes.
      ..move(120, 1.4, accuracyM: 6, record: false, countTruth: false)
      ..move(300, 1.4, accuracyM: 6);
    report('walk with 2 min gap (gap not counted)', t);
    final d = t.filtered();
    expect(t.lastFilter!.gaps, 1);
    expect(d, closeTo(t.trueDistanceM, t.trueDistanceM * 0.05));
  });

  test('poor fixes during warm-up are discarded', () {
    final t = SyntheticTrack(seed: 6)
      ..coldStart(6)
      ..stand(20, accuracyM: 14)
      ..move(300, 1.4, accuracyM: 6);
    report('cold start + walk', t);
    expect(t.filtered(), closeTo(t.trueDistanceM, t.trueDistanceM * 0.05));
  });

  test('a single inaccurate fix among good ones is dropped', () {
    final t = SyntheticTrack(seed: 8)
      ..stand(5, accuracyM: 5)
      ..move(60, 1.4, accuracyM: 5)
      ..spike(40, accuracyM: 28)
      ..move(60, 1.4, accuracyM: 5);
    t.filtered();
    expect(t.lastFilter!.lastVerdict, GpsVerdict.accepted);
    expect(t.lastFilter!.rejected, greaterThanOrEqualTo(1));
  });

  test('duplicate timestamps are ignored', () {
    final t = SyntheticTrack(seed: 9)
      ..stand(5, accuracyM: 5)
      ..move(10, 1.4, accuracyM: 5)
      ..duplicate();
    t.filtered();
    expect(t.lastFilter!.lastVerdict, GpsVerdict.duplicate);
  });

  test('stale cached fixes are ignored on Web', () {
    final f = GpsFilter(checkFixAge: true);
    final t0 = DateTime.utc(2026);
    final fix = GpsFix(time: t0, latitude: 52.5, longitude: 13.4, accuracyM: 5);
    expect(f.add(fix, receivedAt: t0.add(const Duration(minutes: 2))), 0);
    expect(f.lastVerdict, GpsVerdict.stale);
  });

  test('driving speed adds no distance', () {
    final t = SyntheticTrack(seed: 10)
      ..stand(5, accuracyM: 5)
      ..move(120, 15, accuracyM: 5);
    expect(t.filtered(), lessThan(50));
  });

  test('a lasting position correction re-anchors instead of freezing', () {
    final t = SyntheticTrack(seed: 11)
      ..stand(5, accuracyM: 5)
      ..move(100, 1.4, accuracyM: 5);
    final before = t.fixes.length;
    t.move(100, 1.4, accuracyM: 5);
    // Shift every later fix by 80 m: the GPS "snapped" to a new solution.
    for (var i = before; i < t.fixes.length; i++) {
      final f = t.fixes[i];
      t.fixes[i] = GpsFix(
        time: f.time,
        latitude: f.latitude + 80 / 111320,
        longitude: f.longitude,
        accuracyM: f.accuracyM,
      );
    }
    final d = t.filtered();
    expect(d, closeTo(t.trueDistanceM, t.trueDistanceM * 0.1));
  });

  test('speed is steady while walking and falls to 0 when standing', () {
    final t = SyntheticTrack(seed: 13)
      ..stand(5, accuracyM: 6)
      ..move(120, 1.4, accuracyM: 6);
    final walkEnd = t.fixes.length;
    t.stand(30, accuracyM: 6);
    final f = GpsFilter();
    final speeds = <double>[];
    for (var i = 0; i < t.fixes.length; i++) {
      f.add(t.fixes[i]);
      if (i > 40 && i < walkEnd) speeds.add(f.speedMps * 3.6);
    }
    final mean = speeds.reduce((a, b) => a + b) / speeds.length;
    expect(mean, closeTo(5.04, 0.6));
    for (final s in speeds) {
      expect(s, inInclusiveRange(2.5, 8));
    }
    expect(f.speedMps * 3.6, lessThan(1));
  });
}
