import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/sweet_spot.dart';

void main() {
  test('full factor inside the core', () {
    expect(sweetSpotFactor(CompanionType.moss, 4.5), 1);
    expect(sweetSpotFactor(CompanionType.moss, 5.5), 1);
    expect(sweetSpotFactor(CompanionType.moss, 3.5), 1);
  });

  test('smooth falloff between core and range edge', () {
    final mid = sweetSpotFactor(CompanionType.moss, 4.5 + 1.75);
    expect(mid, closeTo(0.5, 1e-9));
    expect(
      sweetSpotFactor(CompanionType.moss, 6.0),
      greaterThan(sweetSpotFactor(CompanionType.moss, 6.5)),
    );
  });

  test('zero outside the range', () {
    expect(sweetSpotFactor(CompanionType.moss, 7.0), 0);
    expect(sweetSpotFactor(CompanionType.brook, 15), 0);
    expect(sweetSpotFactor(CompanionType.gale, 16), 0);
  });

  test('standing still earns nothing with any companion', () {
    for (final type in CompanionType.values) {
      expect(sweetSpotFactor(type, 0), 0, reason: type.name);
    }
  });
}
