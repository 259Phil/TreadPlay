import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/breath.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  test('regenerates 1 point per 90 min', () {
    final bar = Breath(points: 2, updatedAt: t0);
    final later = bar.regenerated(t0.add(const Duration(minutes: 90)), 6);
    expect(later.points, closeTo(3, 1e-9));
    final half = bar.regenerated(t0.add(const Duration(minutes: 45)), 6);
    expect(half.points, closeTo(2.5, 1e-9));
  });

  test('regeneration stops at the cap', () {
    final bar = Breath(points: 5, updatedAt: t0);
    expect(bar.regenerated(t0.add(const Duration(days: 2)), 6).points, 6);
    expect(bar.regenerated(t0.add(const Duration(days: 2)), 12).points, 12);
  });

  test('json round trip', () {
    final bar = Breath(points: 3.25, updatedAt: t0);
    expect(Breath.fromJson(bar.toJson()).toJson(), bar.toJson());
  });
}
