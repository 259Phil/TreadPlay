import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/shoe.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  test('new games start with the three starter boots, Cobble on', () {
    final game = GameData.initial(t0);
    expect(game.shoes.map((s) => s.name), ['Cobble', 'Gearbuckle', 'Orbithop']);
    expect(game.activeShoe.name, 'Cobble');
  });

  test('older saves get missing starter boots and keep their state', () {
    final cobble = Shoe.cobble(t0).copyWith(breath: 2);
    final old = GameData(
      lp: 7.5,
      shoes: [cobble],
      activeShoeId: cobble.id,
      runs: const [],
    );
    final upgraded = GameData.fromJson(old.toJson()).withStarterShoes(t0);
    expect(upgraded.shoes.map((s) => s.id), [
      'cobble-1',
      'gearbuckle-1',
      'orbithop-1',
    ]);
    expect(upgraded.shoes.first.breath, 2);
    expect(upgraded.lp, 7.5);
    expect(upgraded.activeShoeId, 'cobble-1');
    expect(identical(upgraded.withStarterShoes(t0), upgraded), isTrue);
  });
}
