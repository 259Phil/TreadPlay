import 'dart:math';

import 'companion.dart';

/// Arena battles: two formations of companions fight on their own, round
/// by round, until one side has nobody left standing. The player only
/// picks who stands where; [Battle.fight] plays it out and returns every
/// step for the animation.
///
/// Stats: Stride → attack, Grit → Herz (the health bar; never called LP,
/// that is the walking currency), Fortune → critical hits and dodging. The
/// gait sets who moves first and closes a circle where each beats one:
/// Stroll beats Gallop, Gallop beats Trot, Trot beats Stroll.
enum BattleSide { player, enemy }

enum BattleRow { front, back }

/// What a companion does from the back row while its front row stands.
/// For now every gait has one; species can get their own later.
enum BattleAbility {
  /// Stroll: heals the most hurt ally in front.
  mend,

  /// Trot: allies in front hit harder while it stands.
  rally,

  /// Gallop: throws at an enemy in front for part of its attack.
  volley;

  static BattleAbility forTempo(CompanionType tempo) => switch (tempo) {
    CompanionType.moss => mend,
    CompanionType.brook => rally,
    CompanionType.gale => volley,
  };
}

/// Places per row on the field.
const int frontSlots = 3;
const int backSlots = 2;

/// Herz per point of Grit (before the level factor).
const double heartPerGrit = 6;

/// Damage bonus of the gait that beats the other one (+15 %).
const double gaitEdge = 0.15;

/// Damage of a critical hit, as a multiple.
const double critMultiplier = 1.5;

/// Critical hit chance per point of Fortune, and its cap.
const double critPerFortune = 0.01;
const double maxCrit = 0.35;

/// Dodge chance per point of Fortune, and its cap.
const double dodgePerFortune = 0.005;
const double maxDodge = 0.2;

/// Damage rolls within ±10 % of the attack.
const double damageSpread = 0.1;

/// [BattleAbility.mend] heals this share of the healer's attack.
const double mendShare = 0.8;

/// [BattleAbility.rally] adds this to the attack of each ally in front.
const double rallyBonus = 0.1;

/// [BattleAbility.volley] hits for this share of the thrower's attack.
const double volleyShare = 0.6;

/// After this many rounds the side with more Herz left (as a share) wins;
/// a tie goes to the enemy.
const int maxRounds = 30;

/// Mut a companion loses for one battle, in Breath points of a run (so
/// Grit softens it the same way): 3 points, about 750 m of walking.
const double battleBreathEquivalent = 3;

/// A companion knocked out in battle loses this many times the Mut.
const double knockoutSpiritFactor = 2;

/// Gait order: who moves first in a round.
int _initiative(CompanionType t) => switch (t) {
  CompanionType.gale => 3,
  CompanionType.brook => 2,
  CompanionType.moss => 1,
};

/// True when [attacker]'s gait beats [defender]'s.
bool beatsGait(CompanionType attacker, CompanionType defender) =>
    switch (attacker) {
      CompanionType.moss => defender == CompanionType.gale,
      CompanionType.gale => defender == CompanionType.brook,
      CompanionType.brook => defender == CompanionType.moss,
    };

/// One companion as it enters a battle. Built from an owned [Companion]
/// or, for opponents, from a species at a rarity and level.
class Fighter {
  const Fighter({
    required this.id,
    required this.speciesId,
    required this.tempo,
    required this.attack,
    required this.heart,
    required this.crit,
    required this.dodge,
    required this.fortune,
    required this.ability,
  });

  factory Fighter.of(Companion c) {
    final lf = levelFactor(c.level);
    return Fighter(
      id: c.id,
      speciesId: c.speciesId,
      tempo: c.tempo,
      attack: c.strideTotal * lf,
      heart: c.gritTotal * heartPerGrit * lf,
      crit: min(maxCrit, c.fortuneTotal * critPerFortune),
      dodge: min(maxDodge, c.fortuneTotal * dodgePerFortune),
      fortune: c.fortuneTotal,
      ability: BattleAbility.forTempo(c.tempo),
    );
  }

  /// An opponent with the unrolled base stats of [rarity] at [level].
  factory Fighter.opponent({
    required String id,
    required String speciesId,
    required Rarity rarity,
    required int level,
    CompanionType? tempo,
  }) {
    final c = Companion.fresh(
      id: id,
      speciesId: speciesId,
      rarity: rarity,
      tempo: tempo,
    ).copyWith(level: level.clamp(1, maxLevel));
    return Fighter.of(c);
  }

  final String id;
  final String speciesId;
  final CompanionType tempo;
  final double attack;

  /// Full Herz.
  final double heart;
  final double crit;
  final double dodge;

  /// Breaks initiative ties within a gait.
  final double fortune;
  final BattleAbility ability;
}

/// Who stands where on one side: up to [frontSlots] in front (at least
/// one) and up to [backSlots] behind.
class Formation {
  Formation({required this.front, this.back = const []}) {
    if (front.isEmpty || front.length > frontSlots) {
      throw ArgumentError.value(front.length, 'front', '1–$frontSlots');
    }
    if (back.length > backSlots) {
      throw ArgumentError.value(back.length, 'back', '0–$backSlots');
    }
  }

  final List<Fighter> front;
  final List<Fighter> back;

  int get size => front.length + back.length;
}

/// A place on the field.
class BattlePos {
  const BattlePos(this.side, this.row, this.slot);

  final BattleSide side;
  final BattleRow row;
  final int slot;

  @override
  bool operator ==(Object other) =>
      other is BattlePos &&
      other.side == side &&
      other.row == row &&
      other.slot == slot;

  @override
  int get hashCode => Object.hash(side, row, slot);

  @override
  String toString() => '${side.name}.${row.name}[$slot]';
}

/// One step of a battle, in order, for the animation.
sealed class BattleEvent {
  const BattleEvent();
}

class RoundStarted extends BattleEvent {
  const RoundStarted(this.round);
  final int round;
}

/// A hit (or a miss when [dodged]); [volley] when thrown from the back.
class Attacked extends BattleEvent {
  const Attacked({
    required this.actor,
    required this.target,
    required this.damage,
    required this.heartLeft,
    this.crit = false,
    this.dodged = false,
    this.edge = false,
    this.volley = false,
  });

  final BattlePos actor;
  final BattlePos target;

  /// Whole Herz taken, 0 when dodged.
  final int damage;
  final int heartLeft;
  final bool crit;
  final bool dodged;

  /// The actor's gait beats the target's.
  final bool edge;
  final bool volley;
}

class Mended extends BattleEvent {
  const Mended({
    required this.actor,
    required this.target,
    required this.amount,
    required this.heartLeft,
  });

  final BattlePos actor;
  final BattlePos target;
  final int amount;
  final int heartLeft;
}

class KnockedOut extends BattleEvent {
  const KnockedOut(this.target);
  final BattlePos target;
}

class BattleResult {
  const BattleResult({
    required this.winner,
    required this.rounds,
    required this.events,
    required this.playerHeartLeft,
    required this.knockedOut,
  });

  final BattleSide winner;
  final int rounds;
  final List<BattleEvent> events;

  /// Whole Herz left per player fighter id, 0 when knocked out.
  final Map<String, int> playerHeartLeft;

  /// Ids of player fighters that were knocked out.
  final Set<String> knockedOut;

  bool get won => winner == BattleSide.player;
}

class _Unit {
  _Unit(this.fighter, this.pos)
    : maxHeart = fighter.heart.roundToDouble(),
      heart = fighter.heart.roundToDouble();

  final Fighter fighter;
  final BattlePos pos;
  final double maxHeart;
  double heart;

  bool get alive => heart > 0;
  double get share => max(0, heart) / maxHeart;
}

abstract final class Battle {
  /// Plays the battle out. The same [random] seed gives the same battle.
  static BattleResult fight({
    required Formation player,
    required Formation enemy,
    required Random random,
  }) {
    List<_Unit> place(BattleSide side, Formation f) => [
      for (var i = 0; i < f.front.length; i++)
        _Unit(f.front[i], BattlePos(side, BattleRow.front, i)),
      for (var i = 0; i < f.back.length; i++)
        _Unit(f.back[i], BattlePos(side, BattleRow.back, i)),
    ];
    final units = [
      ...place(BattleSide.player, player),
      ...place(BattleSide.enemy, enemy),
    ];
    Iterable<_Unit> side(BattleSide s) =>
        units.where((u) => u.pos.side == s && u.alive);
    Iterable<_Unit> row(BattleSide s, BattleRow r) =>
        side(s).where((u) => u.pos.row == r);
    BattleSide other(BattleSide s) =>
        s == BattleSide.player ? BattleSide.enemy : BattleSide.player;

    final order = [...units]
      ..sort((a, b) {
        final byGait = _initiative(
          b.fighter.tempo,
        ).compareTo(_initiative(a.fighter.tempo));
        if (byGait != 0) return byGait;
        final byFortune = b.fighter.fortune.compareTo(a.fighter.fortune);
        if (byFortune != 0) return byFortune;
        final bySide = a.pos.side.index.compareTo(b.pos.side.index);
        if (bySide != 0) return bySide;
        final byRow = a.pos.row.index.compareTo(b.pos.row.index);
        if (byRow != 0) return byRow;
        return a.pos.slot.compareTo(b.pos.slot);
      });

    final events = <BattleEvent>[];

    /// Front row first; the back row is open once the front has fallen.
    _Unit? targetFor(_Unit actor) {
      final foe = other(actor.pos.side);
      final front = row(foe, BattleRow.front).toList();
      final pool = front.isNotEmpty ? front : side(foe).toList();
      if (pool.isEmpty) return null;
      return pool.firstWhere(
        (u) => u.pos.slot == actor.pos.slot,
        orElse: () => pool.first,
      );
    }

    double rallyFor(_Unit actor) {
      if (actor.pos.row != BattleRow.front) return 1;
      final rallies = row(
        actor.pos.side,
        BattleRow.back,
      ).where((u) => u.fighter.ability == BattleAbility.rally).length;
      return 1 + rallyBonus * rallies;
    }

    void hit(_Unit actor, _Unit target, double share, {bool volley = false}) {
      final edge = beatsGait(actor.fighter.tempo, target.fighter.tempo);
      if (random.nextDouble() < target.fighter.dodge) {
        events.add(
          Attacked(
            actor: actor.pos,
            target: target.pos,
            damage: 0,
            heartLeft: target.heart.round(),
            dodged: true,
            edge: edge,
            volley: volley,
          ),
        );
        return;
      }
      final crit = random.nextDouble() < actor.fighter.crit;
      final spread = 1 - damageSpread + 2 * damageSpread * random.nextDouble();
      final raw =
          actor.fighter.attack *
          share *
          rallyFor(actor) *
          (edge ? 1 + gaitEdge : 1) *
          (crit ? critMultiplier : 1) *
          spread;
      final damage = max(1, raw.round());
      target.heart = max(0, target.heart - damage);
      events.add(
        Attacked(
          actor: actor.pos,
          target: target.pos,
          damage: damage,
          heartLeft: target.heart.round(),
          crit: crit,
          edge: edge,
          volley: volley,
        ),
      );
      if (!target.alive) events.add(KnockedOut(target.pos));
    }

    void act(_Unit actor) {
      final s = actor.pos.side;
      final frontStands = row(s, BattleRow.front).isNotEmpty;
      if (actor.pos.row == BattleRow.back && frontStands) {
        switch (actor.fighter.ability) {
          case BattleAbility.mend:
            final hurt = row(
              s,
              BattleRow.front,
            ).where((u) => u.heart < u.maxHeart).toList();
            if (hurt.isEmpty) return;
            hurt.sort((a, b) => a.share.compareTo(b.share));
            final t = hurt.first;
            final before = t.heart;
            t.heart = min(
              t.maxHeart,
              t.heart + (actor.fighter.attack * mendShare).round(),
            );
            events.add(
              Mended(
                actor: actor.pos,
                target: t.pos,
                amount: (t.heart - before).round(),
                heartLeft: t.heart.round(),
              ),
            );
          case BattleAbility.rally:
            return;
          case BattleAbility.volley:
            if (targetFor(actor) case final t?) {
              hit(actor, t, volleyShare, volley: true);
            }
        }
        return;
      }
      if (targetFor(actor) case final t?) hit(actor, t, 1);
    }

    var round = 0;
    while (round < maxRounds &&
        side(BattleSide.player).isNotEmpty &&
        side(BattleSide.enemy).isNotEmpty) {
      round++;
      events.add(RoundStarted(round));
      for (final u in order) {
        if (!u.alive) continue;
        if (side(other(u.pos.side)).isEmpty) break;
        act(u);
      }
    }

    final BattleSide winner;
    if (side(BattleSide.enemy).isEmpty) {
      winner = BattleSide.player;
    } else if (side(BattleSide.player).isEmpty) {
      winner = BattleSide.enemy;
    } else {
      double total(BattleSide s) => units
          .where((u) => u.pos.side == s)
          .fold(0.0, (sum, u) => sum + u.share);
      final p = total(BattleSide.player) / player.size;
      final e = total(BattleSide.enemy) / enemy.size;
      winner = p > e + 1e-9 ? BattleSide.player : BattleSide.enemy;
    }

    final mine = units.where((u) => u.pos.side == BattleSide.player);
    return BattleResult(
      winner: winner,
      rounds: round,
      events: List.unmodifiable(events),
      playerHeartLeft: {for (final u in mine) u.fighter.id: u.heart.round()},
      knockedOut: {
        for (final u in mine)
          if (!u.alive) u.fighter.id,
      },
    );
  }
}

/// Battles cost Mut; salves (bought with LP) bring it back.
extension BattleSpirit on Companion {
  /// A companion needs some Mut left to fight.
  bool get canBattle => spirit > 0;

  /// Mut this companion loses for one battle.
  double battleSpiritLoss({required bool knockedOut}) =>
      spiritLossFor(battleBreathEquivalent) *
      (knockedOut ? knockoutSpiritFactor : 1);

  /// After a battle: Mut drops (Grit softens it, never below 0). No XP;
  /// XP comes from walking only.
  Companion afterBattle({required bool knockedOut}) => copyWith(
    spirit: max(
      0,
      ((spirit - battleSpiritLoss(knockedOut: knockedOut)) * 10).round() / 10,
    ),
  );
}
