import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/battle.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/world.dart';
import 'package:treadplay/features/arena/arena_state.dart';

void main() {
  test('the starter wins most practice battles', () {
    final starter = Companion.starter();
    var wins = 0;
    const n = 400;
    for (var seed = 0; seed < n; seed++) {
      final teams = arenaTeams(
        lineup: [starter.id, null, null, null, null],
        owned: [starter],
        opponentSeed: seed,
      );
      if (teams.play(Random(seed)).winner == BattleSide.player) wins++;
    }
    expect(wins / n, inInclusiveRange(.6, .95));
  });

  test('practice rivals come from the arena world', () {
    final starter = Companion.starter();
    final teams = arenaTeams(
      lineup: [starter.id, null, null, null, null],
      owned: [starter],
      opponentSeed: 3,
      world: World.jungle,
    );
    final rival = teams.enemyFront.single;
    expect(rival.fighter.heart, lessThan(Fighter.of(starter).heart * 1.2));
    expect(rival.backAsset, startsWith('assets/companions_back/'));
  });
}
