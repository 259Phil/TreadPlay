import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/battle.dart';
import 'package:treadplay/domain/companion.dart';

Fighter dummy(
  String id, {
  CompanionType tempo = CompanionType.brook,
  double attack = 10,
  double heart = 60,
  double crit = 0,
  double dodge = 0,
  BattleAbility? ability,
}) => Fighter(
  id: id,
  speciesId: 'pebble',
  tempo: tempo,
  attack: attack,
  heart: heart,
  crit: crit,
  dodge: dodge,
  fortune: 10,
  ability: ability ?? BattleAbility.forTempo(tempo),
);

void main() {
  test('stats come from Stride, Grit, Fortune and level', () {
    final f = Fighter.of(Companion.starter());
    expect(f.attack, closeTo(9.2, 1e-9));
    expect(f.heart, closeTo(9.4 * heartPerGrit, 1e-9));
    expect(f.crit, closeTo(0.093, 1e-9));
    expect(f.dodge, closeTo(0.0465, 1e-9));
    expect(f.tempo, CompanionType.moss);
    expect(f.ability, BattleAbility.mend);

    final l10 = Fighter.opponent(
      id: 'x',
      speciesId: 'pebble',
      rarity: Rarity.legendary,
      level: 10,
    );
    expect(l10.attack, closeTo(28 * levelFactor(10), 1e-9));
    expect(l10.crit, closeTo(0.28, 1e-9));
    expect(l10.dodge, closeTo(0.14, 1e-9));
  });

  test('gait circle: Stroll > Gallop > Trot > Stroll', () {
    const moss = CompanionType.moss;
    const brook = CompanionType.brook;
    const gale = CompanionType.gale;
    expect(beatsGait(moss, gale), isTrue);
    expect(beatsGait(gale, brook), isTrue);
    expect(beatsGait(brook, moss), isTrue);
    expect(beatsGait(gale, moss), isFalse);
    expect(beatsGait(brook, gale), isFalse);
    expect(beatsGait(moss, brook), isFalse);
    expect(beatsGait(moss, moss), isFalse);
  });

  test('a formation needs 1–3 in front and at most 2 behind', () {
    expect(() => Formation(front: []), throwsArgumentError);
    expect(
      () => Formation(front: List.generate(4, (i) => dummy('f$i'))),
      throwsArgumentError,
    );
    expect(
      () => Formation(
        front: [dummy('a')],
        back: List.generate(3, (i) => dummy('b$i')),
      ),
      throwsArgumentError,
    );
  });

  test('the same seed plays the same battle', () {
    BattleResult run() => Battle.fight(
      player: Formation(front: [Fighter.of(Companion.starter())]),
      enemy: Formation(
        front: [
          Fighter.opponent(
            id: 'e',
            speciesId: 'lumen',
            rarity: Rarity.common,
            level: 1,
          ),
        ],
      ),
      random: Random(7),
    );
    final a = run();
    final b = run();
    expect(a.winner, b.winner);
    expect(a.rounds, b.rounds);
    expect(a.events.length, b.events.length);
    expect(a.playerHeartLeft, b.playerHeartLeft);
  });

  test('a much stronger team wins every time', () {
    for (var seed = 0; seed < 20; seed++) {
      final r = Battle.fight(
        player: Formation(
          front: [
            Fighter.opponent(
              id: 'p',
              speciesId: 'gilt',
              rarity: Rarity.legendary,
              level: 10,
            ),
          ],
        ),
        enemy: Formation(
          front: [
            Fighter.opponent(
              id: 'e',
              speciesId: 'pebble',
              rarity: Rarity.common,
              level: 1,
            ),
          ],
        ),
        random: Random(seed),
      );
      expect(r.won, isTrue, reason: 'seed $seed');
      expect(r.knockedOut, isEmpty);
      expect(
        r.events.whereType<KnockedOut>().single.target.side,
        BattleSide.enemy,
      );
    }
  });

  test('the faster gait moves first; the beating gait gets the edge', () {
    final r = Battle.fight(
      player: Formation(front: [dummy('p', tempo: CompanionType.moss)]),
      enemy: Formation(front: [dummy('e', tempo: CompanionType.gale)]),
      random: Random(1),
    );
    final hits = r.events.whereType<Attacked>().toList();
    expect(hits.first.actor.side, BattleSide.enemy);
    expect(hits.first.edge, isFalse);
    final mine = hits.firstWhere((h) => h.actor.side == BattleSide.player);
    expect(mine.edge, isTrue);
  });

  test('the back row is only hit once the front row has fallen', () {
    final r = Battle.fight(
      player: Formation(
        front: [dummy('front', heart: 30)],
        back: [dummy('back', ability: BattleAbility.rally)],
      ),
      enemy: Formation(front: [dummy('e', attack: 12, heart: 400)]),
      random: Random(3),
    );
    final frontDown = r.events.indexWhere(
      (e) => e is KnockedOut && e.target.side == BattleSide.player,
    );
    expect(frontDown, isNonNegative);
    for (final e in r.events.take(frontDown).whereType<Attacked>()) {
      if (e.target.side == BattleSide.player) {
        expect(e.target.row, BattleRow.front);
      }
    }
    expect(
      r.events
          .skip(frontDown)
          .whereType<Attacked>()
          .any((e) => e.target.row == BattleRow.back),
      isTrue,
    );
    expect(r.won, isFalse);
    expect(r.knockedOut, {'front', 'back'});
  });

  test('mend heals the most hurt ally in front, never above full', () {
    final r = Battle.fight(
      player: Formation(
        front: [dummy('a', heart: 80), dummy('b', heart: 80)],
        back: [dummy('healer', tempo: CompanionType.moss, attack: 10)],
      ),
      enemy: Formation(front: [dummy('e', attack: 15, heart: 2000)]),
      random: Random(5),
    );
    final mends = r.events.whereType<Mended>().toList();
    expect(mends, isNotEmpty);
    for (final m in mends) {
      expect(m.target.row, BattleRow.front);
      expect(m.amount, inInclusiveRange(1, (10 * mendShare).round()));
      expect(m.heartLeft, lessThanOrEqualTo(80));
    }
  });

  test('rally makes the front hit harder', () {
    int firstHit(List<Fighter> back) =>
        Battle.fight(
              player: Formation(front: [dummy('p', attack: 100)], back: back),
              enemy: Formation(front: [dummy('e', heart: 5000)]),
              random: Random(11),
            ).events
            .whereType<Attacked>()
            .firstWhere((e) => e.actor.side == BattleSide.player)
            .damage;
    final plain = firstHit([]);
    final rallied = firstHit([dummy('r', ability: BattleAbility.rally)]);
    expect(rallied, greaterThan(plain));
    expect(rallied, closeTo(plain * (1 + rallyBonus), 1));
  });

  test('volley throws from the back at part of its attack', () {
    final r = Battle.fight(
      player: Formation(
        front: [dummy('p', heart: 5000)],
        back: [dummy('v', tempo: CompanionType.gale, attack: 100)],
      ),
      enemy: Formation(front: [dummy('e', tempo: CompanionType.gale)]),
      random: Random(2),
    );
    final volley = r.events.whereType<Attacked>().firstWhere((e) => e.volley);
    expect(volley.actor.row, BattleRow.back);
    expect(
      volley.damage,
      inInclusiveRange(
        (100 * volleyShare * (1 - damageSpread)).floor(),
        (100 * volleyShare * (1 + damageSpread)).ceil(),
      ),
    );
  });

  test('after the round limit the side with more Herz left wins; a tie '
      'goes to the enemy', () {
    final tie = Battle.fight(
      player: Formation(front: [dummy('p', attack: 0, heart: 1000)]),
      enemy: Formation(front: [dummy('e', attack: 0, heart: 1000)]),
      random: Random(1),
    );
    expect(tie.rounds, maxRounds);
    expect(tie.winner, BattleSide.enemy);

    final ahead = Battle.fight(
      player: Formation(front: [dummy('p', attack: 2, heart: 1000)]),
      enemy: Formation(front: [dummy('e', attack: 0, heart: 1000)]),
      random: Random(1),
    );
    expect(ahead.rounds, maxRounds);
    expect(ahead.won, isTrue);
  });

  test('every battle costs Mut; a knock-out twice as much', () {
    final c = Companion.starter();
    final loss = c.spiritLossFor(battleBreathEquivalent);
    expect(loss, greaterThan(0));
    expect(c.afterBattle(knockedOut: false).spirit, closeTo(100 - loss, 1e-9));
    expect(
      c.afterBattle(knockedOut: true).spirit,
      closeTo(100 - loss * knockoutSpiritFactor, 1e-9),
    );
    final low = c.copyWith(spirit: 1);
    expect(low.canBattle, isTrue);
    final spent = low.afterBattle(knockedOut: true);
    expect(spent.spirit, 0);
    expect(spent.canBattle, isFalse);
    expect(spent.xp, c.xp);
  });

  test('opponent strength scales attack and Herz only', () {
    Fighter rival(double k) => Fighter.opponent(
      id: 'r',
      speciesId: 'pebble',
      rarity: Rarity.common,
      level: 3,
      strength: k,
    );
    final full = rival(1);
    final weak = rival(.5);
    expect(weak.attack, closeTo(full.attack * .5, 1e-9));
    expect(weak.heart, closeTo(full.heart * .5, 1e-9));
    expect(weak.crit, full.crit);
    expect(weak.dodge, full.dodge);
  });
}
