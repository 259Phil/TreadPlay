import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
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
      t0,
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
}
