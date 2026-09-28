import 'dart:math';

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

  test('base stats and LP per Breath follow rarity', () {
    const expected = {
      Rarity.common: (10.0, 2.5),
      Rarity.rare: (14.0, 4.0),
      Rarity.epic: (20.0, 7.0),
      Rarity.legendary: (28.0, 12.0),
    };
    for (final MapEntry(key: rarity, value: (stat, lp)) in expected.entries) {
      final c = Companion.fresh(id: 'x', speciesId: 'gilt', rarity: rarity);
      expect([c.stride, c.grit, c.fortune], [stat, stat, stat]);
      expect(c.lpPerBreath, closeTo(lp, 1e-9));
    }
  });

  test('Gilt Legendary never rolls 10/10/10', () {
    final random = Random(7);
    for (var i = 0; i < 200; i++) {
      final gilt = Companion.rolled(
        id: 'gilt-$i',
        speciesId: 'gilt',
        rarity: Rarity.legendary,
        random: random,
      );
      for (final stat in [gilt.stride, gilt.grit, gilt.fortune]) {
        expect(stat, inInclusiveRange(25.8, 30.2));
      }
      expect(gilt.lpPerBreath, inInclusiveRange(12 * 0.92, 12 * 1.08));
    }
  });

  test('rolls spread within ±8 % and are independent per stat', () {
    final random = Random(1);
    final rolls = [
      for (var i = 0; i < 500; i++)
        Companion.rolled(
          id: 'r-$i',
          speciesId: 'lumen',
          rarity: Rarity.rare,
          random: random,
        ),
    ];
    final strides = rolls.map((c) => c.stride);
    expect(strides.reduce(min), lessThan(13.2));
    expect(strides.reduce(max), greaterThan(14.8));
    expect(strides.every((s) => s >= 12.9 && s <= 15.1), isTrue);
    expect(rolls.any((c) => c.stride != c.grit), isTrue);
    expect(Companion.fromJson(rolls.first.toJson()).stride, rolls.first.stride);
  });

  test('level adds 4 % up to 18, 2 % after, capped at 25', () {
    expect(levelFactor(1), 1);
    expect(levelFactor(2), closeTo(1.04, 1e-9));
    expect(levelFactor(18), closeTo(1.68, 1e-9));
    expect(levelFactor(19), closeTo(1.70, 1e-9));
    expect(levelFactor(25), closeTo(1.82, 1e-9));
    expect(levelFactor(40), levelFactor(25));
  });

  test('old saves with 10/10/10 on a higher rarity load its lowest roll', () {
    final json = Companion.fresh(
      id: 'gilt-1',
      speciesId: 'gilt',
      rarity: Rarity.legendary,
    ).toJson()..addAll({'stride': 10, 'grit': 10, 'fortune': 10});
    final gilt = Companion.fromJson(json);
    expect([gilt.stride, gilt.grit, gilt.fortune], [25.8, 25.8, 25.8]);
    final pebble = Companion.fromJson(Companion.pebble().toJson());
    expect(pebble.stride, 10);
  });
}
