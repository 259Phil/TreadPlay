import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/breath.dart';
import 'package:treadplay/domain/companion.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  test('new games start with Pebble only, taken along', () {
    final game = GameData.initial(t0);
    expect(game.companions.map((c) => c.name), ['Pebble']);
    expect(game.activeCompanion.name, 'Pebble');
  });

  test('Pebble cannot be sold until a second companion exists', () {
    final game = GameData.initial(t0);
    expect(game.canSell('pebble-1'), isFalse);
    final dune = Companion.fresh(
      id: 'dune-1',
      speciesId: 'dune',
      rarity: Rarity.rare,
    );
    final two = game.copyWith(companions: [...game.companions, dune]);
    expect(two.canSell('pebble-1'), isTrue);
    final worn = two.replaceCompanion(dune.copyWith(spirit: 90));
    expect(worn.canSell('dune-1'), isFalse);
  });

  test('json round trip', () {
    final game = GameData.initial(t0).copyWith(lp: 7.5);
    final copy = GameData.fromJson(game.toJson());
    expect(copy.toJson(), game.toJson());
  });

  final gilt = Companion.fresh(
    id: 'gilt-1',
    speciesId: 'gilt',
    rarity: Rarity.legendary,
  );

  GameData withGilt(double points) {
    final start = GameData.initial(t0);
    return start.copyWith(
      companions: [...start.companions, gilt],
      breath: Breath(points: points, updatedAt: t0),
    );
  }

  test('switching to Gilt Legendary with an empty bar keeps it empty', () {
    final game = withGilt(0).takingAlong('gilt-1', t0);
    expect(game.activeCompanionId, 'gilt-1');
    expect(game.breathCap, 12);
    expect(game.breath.points, 0);
  });

  test('switching back and forth never refills the bar', () {
    var game = withGilt(2.5);
    for (var i = 0; i < 10; i++) {
      game = game.takingAlong('gilt-1', t0).takingAlong('pebble-1', t0);
    }
    expect(game.breath.points, 2.5);
  });

  test('regen runs on the shared bar up to the current cap', () {
    final game = withGilt(5).takingAlong('gilt-1', t0);
    final later = game.regenerated(t0.add(const Duration(minutes: 180)));
    expect(later.breath.points, closeTo(7, 1e-9));
    final full = game.regenerated(t0.add(const Duration(days: 1)));
    expect(full.breath.points, 12);
  });

  test('a lower cap trims the bar, a higher cap does not fill it', () {
    final full = withGilt(12).copyWith(activeCompanionId: 'gilt-1');
    final pebble = full.takingAlong('pebble-1', t0);
    expect(pebble.breath.points, 6);
    expect(pebble.takingAlong('gilt-1', t0).breath.points, 6);
  });

  test('owning more companions adds no Breath', () {
    final start = GameData.initial(t0);
    final many = start.copyWith(
      companions: [
        ...start.companions,
        for (var i = 0; i < 9; i++)
          Companion.fresh(
            id: 'vine-$i',
            speciesId: 'vine',
            rarity: Rarity.rare,
          ),
      ],
    );
    expect(many.breathCap, 6);
    expect(many.regenerated(t0.add(const Duration(days: 1))).breath.points, 6);
  });

  test('old saves with a tank per companion keep only the one taken along', () {
    final json = withGilt(0).toJson()..remove('breath');
    final companions = json['companions']! as List<Object?>;
    for (final c in companions.cast<Map<String, Object?>>()) {
      c['breath'] = c['id'] == 'pebble-1' ? 1.5 : 12.0;
      c['breathUpdatedAt'] = t0.toIso8601String();
    }
    final game = GameData.fromJson(json);
    expect(game.breath.points, 1.5);
    expect(game.takingAlong('gilt-1', t0).breath.points, 1.5);
  });
}
