import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/world.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  test('breath regenerates 1 point per 90 min', () {
    final pebble = Companion.pebble(t0).copyWith(breath: 2);
    final later = pebble.regenerated(t0.add(const Duration(minutes: 90)));
    expect(later.breath, closeTo(3, 1e-9));
    final half = pebble.regenerated(t0.add(const Duration(minutes: 45)));
    expect(half.breath, closeTo(2.5, 1e-9));
  });

  test('breath is capped at the tank size', () {
    final pebble = Companion.pebble(t0).copyWith(breath: 5);
    final later = pebble.regenerated(t0.add(const Duration(days: 2)));
    expect(later.breath, 6);
  });

  test('Pebble is a common Moss from the medieval world', () {
    final pebble = Companion.pebble(t0);
    expect(pebble.name, 'Pebble');
    expect(pebble.type, CompanionType.moss);
    expect(pebble.rarity, Rarity.common);
    expect(pebble.world, World.medieval);
    expect(pebble.lpPerBreath, 2.5);
  });

  test('missing rarity art falls back to a lower rarity', () {
    expect(artKeyFor('gilt', Rarity.rare), 'gilt_r');
    expect(artKeyFor('gilt', Rarity.epic), 'gilt_r');
    expect(artKeyFor('pebble', Rarity.rare), 'pebble_c');
    expect(artKeyFor('glaze', Rarity.legendary), 'glaze_c');
  });

  test('charm slots follow rarity and survive a save', () {
    expect(Companion.pebble(t0).charms, [null]);
    final gilt = Companion.fresh(
      t0,
      id: 'gilt-1',
      speciesId: 'gilt',
      rarity: Rarity.legendary,
    );
    expect(gilt.charms, hasLength(3));
    final sealed = gilt.withCharm(1, 'seal-a');
    expect(sealed.charms, [null, 'seal-a', null]);
    expect(gilt.charms, [null, null, null]);
    expect(Companion.fromJson(sealed.toJson()).charms, sealed.charms);
    expect(() => gilt.withCharm(3, 'seal-b'), throwsRangeError);
  });

  test('saves without charms load empty slots', () {
    final json = Companion.pebble(t0).toJson()..remove('charms');
    expect(Companion.fromJson(json).charms, [null]);
  });

  test('json round trip', () {
    final pebble = Companion.pebble(t0).copyWith(breath: 3.25, spirit: 80);
    final copy = Companion.fromJson(pebble.toJson());
    expect(copy.toJson(), pebble.toJson());
  });
}
