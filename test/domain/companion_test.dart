import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/world.dart';

void main() {
  test('Pebble is a common Moss from the medieval world', () {
    final pebble = Companion.pebble();
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
    expect(Companion.pebble().charms, [null]);
    final gilt = Companion.fresh(
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
    final json = Companion.pebble().toJson()..remove('charms');
    expect(Companion.fromJson(json).charms, [null]);
  });

  test('json round trip', () {
    final pebble = Companion.pebble().copyWith(spirit: 80);
    final copy = Companion.fromJson(pebble.toJson());
    expect(copy.toJson(), pebble.toJson());
  });
}
