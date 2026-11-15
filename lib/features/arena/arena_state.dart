import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../data/species.dart';
import '../../domain/battle.dart';
import '../../domain/companion.dart';
import '../../domain/market.dart';
import '../../domain/wanderweg.dart';
import '../../domain/world.dart';
import '../../state/providers.dart';

/// Field slots of the line-up: 0–2 front, 3–4 back.
const int fieldSlots = frontSlots + backSlots;

BattleRow rowOfSlot(int slot) =>
    slot < frontSlots ? BattleRow.front : BattleRow.back;

/// Companion ids on the field, one per slot (null = free).
final arenaLineupProvider = NotifierProvider<ArenaLineup, List<String?>>(
  ArenaLineup.new,
);

class ArenaLineup extends Notifier<List<String?>> {
  @override
  List<String?> build() => [
    ref.read(gameProvider).activeCompanionId,
    for (var i = 1; i < fieldSlots; i++) null,
  ];

  /// Puts [companionId] on [slot]; it leaves any other slot it held.
  void place(int slot, String companionId) => state = [
    for (var i = 0; i < fieldSlots; i++)
      i == slot ? companionId : (state[i] == companionId ? null : state[i]),
  ];

  void clear(int slot) => state = [
    for (var i = 0; i < fieldSlots; i++) i == slot ? null : state[i],
  ];
}

/// Seed of the current practice opponent; a new one rolls a new team.
final arenaOpponentSeedProvider = NotifierProvider<ArenaOpponentSeed, int>(
  ArenaOpponentSeed.new,
);

class ArenaOpponentSeed extends Notifier<int> {
  @override
  int build() => ref.read(randomProvider).nextInt(1 << 30);

  void reroll() => state = ref.read(randomProvider).nextInt(1 << 30);
}

/// One fighter on the field with what the screen needs to draw it.
class ArenaEntry {
  const ArenaEntry({
    required this.fighter,
    required this.artKey,
    required this.name,
    required this.level,
  });

  factory ArenaEntry.of(Companion c) => ArenaEntry(
    fighter: Fighter.of(c),
    artKey: c.artKey,
    name: c.name,
    level: c.level,
  );

  /// Back view for the player's side, seen over the shoulder; null when the
  /// species has none yet.
  String? get backAsset => speciesById.containsKey(fighter.speciesId)
      ? 'assets/companions_back/${fighter.speciesId}.webp'
      : null;

  final Fighter fighter;
  final String artKey;
  final String name;
  final int level;

  int get maxHeart => fighter.heart.round();
}

/// Both teams by row, in field order.
class ArenaTeams {
  const ArenaTeams({
    required this.playerFront,
    required this.playerBack,
    required this.enemyFront,
    required this.enemyBack,
  });

  final List<ArenaEntry> playerFront;
  final List<ArenaEntry> playerBack;
  final List<ArenaEntry> enemyFront;
  final List<ArenaEntry> enemyBack;

  bool get ready => playerFront.isNotEmpty;

  /// Every fighter by its battle position.
  Map<BattlePos, ArenaEntry> get byPos => {
    for (var i = 0; i < playerFront.length; i++)
      BattlePos(BattleSide.player, BattleRow.front, i): playerFront[i],
    for (var i = 0; i < playerBack.length; i++)
      BattlePos(BattleSide.player, BattleRow.back, i): playerBack[i],
    for (var i = 0; i < enemyFront.length; i++)
      BattlePos(BattleSide.enemy, BattleRow.front, i): enemyFront[i],
    for (var i = 0; i < enemyBack.length; i++)
      BattlePos(BattleSide.enemy, BattleRow.back, i): enemyBack[i],
  };

  BattleResult play(Random random) => Battle.fight(
    player: Formation(
      front: [for (final e in playerFront) e.fighter],
      back: [for (final e in playerBack) e.fighter],
    ),
    enemy: Formation(
      front: [for (final e in enemyFront) e.fighter],
      back: [for (final e in enemyBack) e.fighter],
    ),
    random: random,
  );
}

/// Practice rivals are weaker than a full Common: the starter's rolled stats
/// sit below the Common base, and at full strength it would win only about
/// one practice battle in twenty. At this strength it wins about four in
/// five.
const double practiceStrength = .8;

/// The world the arena stands in: the latest one the trail has opened.
World arenaWorldOf(GameData game) {
  final open = {
    ...WaymarkUnlocks.startWorlds,
    for (final w in waymarks.take(game.unlocks.progress.reached))
      ...w.unlock.marketWorlds,
  };
  return Market.starterWorlds.lastWhere(
    open.contains,
    orElse: () => World.medieval,
  );
}

final arenaWorldProvider = Provider<World>(
  (ref) => arenaWorldOf(ref.watch(gameProvider)),
);

/// The player's line-up against a practice team of the same shape: species
/// of the arena [world] at the same levels, Common.
ArenaTeams arenaTeams({
  required List<String?> lineup,
  required List<Companion> owned,
  required int opponentSeed,
  World world = World.medieval,
}) {
  final byId = {for (final c in owned) c.id: c};
  List<Companion> row(BattleRow r) => [
    for (var i = 0; i < fieldSlots; i++)
      if (rowOfSlot(i) == r) ?byId[lineup[i]],
  ].where((c) => c.canBattle).toList();
  final front = row(BattleRow.front);
  final back = row(BattleRow.back);
  final pool = [
    for (final s in speciesCatalog)
      if (s.world == world) s,
  ];
  if (pool.isEmpty) pool.addAll(speciesCatalog);
  final random = Random(opponentSeed);
  var n = 0;
  List<ArenaEntry> rival(List<Companion> mirror) => [
    for (final c in mirror)
      () {
        final s = pool[random.nextInt(pool.length)];
        n++;
        return ArenaEntry(
          fighter: Fighter.opponent(
            id: 'rival-$n',
            speciesId: s.id,
            rarity: Rarity.common,
            level: c.level,
            strength: practiceStrength,
          ),
          artKey: cutoutKeyFor(s.id, Rarity.common),
          name: s.name,
          level: c.level,
        );
      }(),
  ];
  return ArenaTeams(
    playerFront: [for (final c in front) ArenaEntry.of(c)],
    playerBack: [for (final c in back) ArenaEntry.of(c)],
    enemyFront: rival(front),
    enemyBack: rival(back),
  );
}

final arenaTeamsProvider = Provider<ArenaTeams>(
  (ref) => arenaTeams(
    lineup: ref.watch(arenaLineupProvider),
    owned: ref.watch(gameProvider).companions,
    opponentSeed: ref.watch(arenaOpponentSeedProvider),
    world: ref.watch(arenaWorldProvider),
  ),
);
