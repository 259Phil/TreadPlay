import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/shoe.dart';
import 'package:treadplay/domain/sweet_spot.dart';

void main() {
  test('full factor inside the core', () {
    expect(sweetSpotFactor(ShoeType.stomper, 4.5), 1);
    expect(sweetSpotFactor(ShoeType.stomper, 5.5), 1);
    expect(sweetSpotFactor(ShoeType.stomper, 3.5), 1);
  });

  test('smooth falloff between core and range edge', () {
    final mid = sweetSpotFactor(ShoeType.stomper, 4.5 + 1.75);
    expect(mid, closeTo(0.5, 1e-9));
    expect(
      sweetSpotFactor(ShoeType.stomper, 6.0),
      greaterThan(sweetSpotFactor(ShoeType.stomper, 6.5)),
    );
  });

  test('zero outside the range', () {
    expect(sweetSpotFactor(ShoeType.stomper, 7.0), 0);
    expect(sweetSpotFactor(ShoeType.strider, 15), 0);
    expect(sweetSpotFactor(ShoeType.dasher, 16), 0);
  });

  test('standing still earns nothing in any boot', () {
    for (final type in ShoeType.values) {
      expect(sweetSpotFactor(type, 0), 0, reason: type.name);
    }
  });
}
