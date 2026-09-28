import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/companion_art.dart';
import 'package:treadplay/data/species.dart';
import 'package:treadplay/domain/world.dart';

void main() {
  test('ten species, one per world, each with common art', () {
    expect(speciesCatalog, hasLength(10));
    expect(speciesCatalog.map((s) => s.world).toSet(), World.values.toSet());
    for (final s in speciesCatalog) {
      expect(companionArt.containsKey('${s.id}_c'), isTrue, reason: s.id);
    }
  });

  test('every art file belongs to a species and exists on disk', () {
    for (final key in companionArt.keys) {
      final species = key.substring(0, key.lastIndexOf('_'));
      expect(speciesById.containsKey(species), isTrue, reason: key);
      expect(File('assets/companions/$key.png').existsSync(), isTrue);
    }
  });

  test('world backdrops exist on disk', () {
    for (final world in World.values) {
      final bg = world.background;
      if (bg != null) expect(File(bg).existsSync(), isTrue, reason: bg);
    }
  });
}
