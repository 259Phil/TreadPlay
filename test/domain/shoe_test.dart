import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/shoe.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  test('breath regenerates 1 point per 90 min', () {
    final shoe = Shoe.cobble(t0).copyWith(breath: 2);
    final later = shoe.regenerated(t0.add(const Duration(minutes: 90)));
    expect(later.breath, closeTo(3, 1e-9));
    final half = shoe.regenerated(t0.add(const Duration(minutes: 45)));
    expect(half.breath, closeTo(2.5, 1e-9));
  });

  test('breath is capped at the tank size', () {
    final shoe = Shoe.cobble(t0).copyWith(breath: 5);
    final later = shoe.regenerated(t0.add(const Duration(days: 2)));
    expect(later.breath, 6);
  });

  test('Cobble earns 2.5 LP per breath point', () {
    expect(Shoe.cobble(t0).lpPerBreath, 2.5);
  });

  test('json round trip', () {
    final shoe = Shoe.cobble(t0).copyWith(breath: 3.25);
    final copy = Shoe.fromJson(shoe.toJson());
    expect(copy.toJson(), shoe.toJson());
  });
}
