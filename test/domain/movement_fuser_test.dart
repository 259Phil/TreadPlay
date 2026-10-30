import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/movement_fuser.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);
  DateTime at(int s) => t0.add(Duration(seconds: s));

  test('GPS distance gives distance and pace speed', () {
    final fuser = MovementFuser();
    var last = fuser.tick(at(0));
    for (var s = 1; s <= 6; s++) {
      fuser.addGps(at(s), 1.25, accuracyM: 5);
      last = fuser.tick(at(s));
      expect(last.distanceM, 1.25);
    }
    expect(last.speedKmh, closeTo(4.5, 1e-9));
    expect(last.steps, isNull);
  });

  test('inaccurate fixes are ignored', () {
    final fuser = MovementFuser();
    fuser.addGps(at(1), 40, accuracyM: 60);
    expect(fuser.tick(at(1)).distanceM, 0);
  });

  test('without GPS the pedometer gives the distance', () {
    final fuser = MovementFuser();
    fuser.addStepTotal(1000);
    expect(fuser.tick(at(1)).distanceM, 0);
    fuser.addStepTotal(1008);
    final sample = fuser.tick(at(2));
    expect(sample.steps, 8);
    expect(sample.distanceM, 8 * MovementFuser.strideM);
  });

  test('a stale GPS fix falls back to steps', () {
    final fuser = MovementFuser();
    fuser.addGps(at(0), 0, accuracyM: 5);
    fuser.addStepTotal(0);
    fuser.tick(at(0));
    fuser.addStepTotal(4);
    expect(fuser.tick(at(10)).distanceM, 4 * MovementFuser.strideM);
  });

  test('the GPS filter speed is used while GPS is live', () {
    final fuser = MovementFuser();
    fuser.tick(at(0));
    fuser.addGps(at(1), 6, accuracyM: 5, speedKmh: 5);
    expect(fuser.tick(at(1)).speedKmh, 5);
    fuser.addGps(at(2), 0, accuracyM: 5, speedKmh: 5);
    final s = fuser.tick(at(2));
    expect(s.distanceM, 0);
    expect(s.speedKmh, 5);
  });

  test('with positions, the live speed is fitted and the tempo waits', () {
    final fuser = MovementFuser();
    fuser.tick(at(0));
    late var s = fuser.tick(at(0));
    for (var i = 1; i <= 12; i++) {
      // 3 m/s north; the filter counts 6 m every other second.
      fuser.addGps(
        at(i),
        i.isEven ? 6 : 0,
        accuracyM: 5,
        speedKmh: i.isEven ? 30 : 0,
        x: 0,
        y: 3.0 * i,
      );
      s = fuser.tick(at(i));
      if (i < 4) expect(s.speedReady, isFalse);
    }
    expect(s.speedKmh, closeTo(10.8, 1e-6));
    expect(s.speedReady, isTrue);
  });

  test('standing reported by the filter gives 0', () {
    final fuser = MovementFuser();
    fuser.addGps(at(1), 0, accuracyM: 5, x: 0, y: 0, moving: false);
    final s = fuser.tick(at(1));
    expect(s.speedKmh, 0);
  });
}
