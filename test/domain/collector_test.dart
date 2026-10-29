import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/collector.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/messenger.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/run_engine.dart';
import 'package:treadplay/domain/wanderweg.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  Companion mate(int i, {double spirit = 100}) => Companion.fresh(
    id: 'c$i',
    speciesId: 'vine',
    rarity: Rarity.common,
  ).copyWith(spirit: spirit);

  /// The starter plus [n] more, the extra ones at [spirit] % Mut.
  GameData withMates(int n, {double spirit = 100, double lp = 0}) {
    final g = GameData.initial(t0);
    return g.copyWith(
      lp: lp,
      companions: [
        ...g.companions,
        for (var i = 0; i < n; i++) mate(i, spirit: spirit),
      ],
    );
  }

  group('Sammlerbonus steps', () {
    test('+1 from 5, +2 from 10, +3 from 20, never more', () {
      expect(
        [
          for (final n in [0, 1, 4, 5, 9, 10, 19, 20, 25, 30])
            Collector.bonusFor(n),
        ],
        [0, 0, 0, 1, 1, 2, 2, 3, 3, 3],
      );
      expect(Collector.nextTierFor(0), 5);
      expect(Collector.nextTierFor(5), 10);
      expect(Collector.nextTierFor(19), 20);
      expect(Collector.nextTierFor(20), isNull);
    });

    test('the shared tank grows with the collection', () {
      final tank = Rarity.common.tankSize;
      expect(withMates(3).breathCap, tank); // 4 companions
      expect(withMates(4).breathCap, tank + 1); // 5
      expect(withMates(9).breathCap, tank + 2); // 10
      expect(withMates(19).breathCap, tank + 3); // 20
      expect(withMates(29).breathCap, tank + 3); // 30
    });
  });

  group('Mut rule', () {
    test('only companions with at least 50 % Mut count', () {
      expect(Collector.counts(mate(0, spirit: 50)), isTrue);
      expect(Collector.counts(mate(0, spirit: 49.9)), isFalse);
      // Starter (100 %) plus 4 at exactly 50 %: the first step.
      expect(withMates(4, spirit: 50).collectorBonus, 1);
      // Starter plus 9 at 49.9 %: only one counts.
      expect(withMates(9, spirit: 49.9).collectorCount, 1);
      expect(withMates(9, spirit: 49.9).collectorBonus, 0);
    });

    test('losing Mut shrinks the tank, a full bar is trimmed', () {
      final g = withMates(4); // +1
      final full = g.copyWith(breath: g.breath.capped(99)).regenerated(t0);
      final filled = full.copyWith(
        breath: full.breath.regenerated(
          t0.add(const Duration(days: 2)),
          full.breathCap,
        ),
      );
      expect(filled.breath.points, filled.breathCap);
      final tired = filled.replaceCompanion(
        filled.companions.last.copyWith(spirit: 20),
      );
      expect(tired.collectorBonus, 0);
      final later = tired.regenerated(
        t0.add(const Duration(days: 2, minutes: 1)),
      );
      expect(later.breath.points, tired.breathCap);
    });
  });

  group('consistent use of the tank', () {
    test('runs, pouches and messengers use the bonus tank', () {
      final g = withMates(9); // +2
      final engine = RunEngine(
        companion: g.activeCompanion,
        tankSize: g.breathCap,
        breathAtStart: g.breathCap.toDouble(),
        startedAt: t0,
      );
      expect(engine.finish().tankSize, g.breathCap);
      // A full bonus tank is a full share; the old tank alone is not.
      final full = Pouches.chance(
        breathUsed: g.breathCap.toDouble(),
        tankSize: g.breathCap,
        fortuneFactor: 1,
      );
      final part = Pouches.chance(
        breathUsed: g.activeCompanion.tankSize.toDouble(),
        tankSize: g.breathCap,
        fortuneFactor: 1,
      );
      expect(part, lessThan(full));
      expect(
        Messengers.chance(
          breathUsed: g.breathCap.toDouble(),
          tankSize: g.breathCap,
          fortuneFactor: 1,
        ),
        Messengers.chance(
          breathUsed: g.activeCompanion.tankSize.toDouble(),
          tankSize: g.activeCompanion.tankSize,
          fortuneFactor: 1,
        ),
      );
    });
  });

  group('shelf slots', () {
    test('base 12, +2 from the waymark', () {
      final g = GameData.initial(t0);
      expect(g.shelfSlots, 12);
      final far = g.copyWith(wanderweg: WanderwegProgress.legacy(120000, t0));
      expect(far.shelfSlots, 14);
    });

    test('slot 15 costs 60 LP, each further one 30 LP more, up to 30', () {
      var g = GameData.initial(
        t0,
      ).copyWith(lp: 100000, wanderweg: WanderwegProgress.legacy(120000, t0));
      final prices = <int>[];
      for (var p = g.nextSlotPrice; p != null; p = g.nextSlotPrice) {
        prices.add(p);
        final before = g.lp;
        g = g.buyingSlot();
        expect(g.lp, before - p);
      }
      expect(prices.first, 60);
      expect(prices[1], 90);
      expect(prices[2], 120);
      expect(prices.length, 16);
      expect(prices.last, 60 + 30 * 15);
      expect(prices.fold<int>(0, (a, b) => a + b), 4560);
      expect(g.shelfSlots, ShelfSlots.max);
      expect(g.slotBlock, SlotBlock.max);
      expect(identical(g.buyingSlot(), g), isTrue);
    });

    test('not enough LP blocks, nothing changes', () {
      final g = GameData.initial(t0).copyWith(lp: 59);
      expect(g.slotBlock, SlotBlock.notEnoughLp);
      expect(identical(g.buyingSlot(), g), isTrue);
      expect(g.copyWith(lp: 60).buyingSlot().shelfSlots, 13);
    });

    test('bought before the waymark: never over 30', () {
      var g = GameData.initial(t0).copyWith(lp: 100000);
      while (g.slotBlock == null) {
        g = g.buyingSlot();
      }
      expect(g.shelfBought, ShelfSlots.maxBought);
      expect(g.shelfSlots, 28);
      final far = g.copyWith(wanderweg: WanderwegProgress.legacy(120000, t0));
      expect(far.shelfSlots, 30);
      expect(far.nextSlotPrice, isNull);
    });

    test('a full shelf takes a bought slot', () {
      final g = withMates(11, lp: 1000); // 12 on 12 slots
      expect(g.shelfFull, isTrue);
      expect(g.buyingSlot().shelfFull, isFalse);
    });

    test('bought slots survive save and load; old files have none', () {
      final g = GameData.initial(
        t0,
      ).copyWith(lp: 500).buyingSlot().buyingSlot();
      final back = GameData.fromJson(
        jsonDecode(jsonEncode(g.toJson())) as Map<String, Object?>,
      );
      expect(back.shelfBought, 2);
      expect(back.shelfSlots, 14);
      final file = SaveGame.decode(SaveGame.encode(g, t0)).game;
      expect(file.shelfBought, 2);
      expect(SaveGame.version, 13);
      // A v12 file with a stray key gets no slots.
      final raw =
          jsonDecode(utf8.decode(SaveGame.encode(g, t0)))
              as Map<String, Object?>;
      raw['version'] = 12;
      final old = SaveGame.decode(
        Uint8List.fromList(utf8.encode(jsonEncode(raw))),
      ).game;
      expect(old.shelfBought, 0);
      expect(GameData.initial(t0).toJson().containsKey('shelfBought'), isFalse);
    });
  });
}
