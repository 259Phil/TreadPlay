import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/forge.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);
  final gilt = Companion.fresh(
    id: 'gilt-1',
    speciesId: 'gilt',
    rarity: Rarity.legendary,
  );

  GameData withGilt(double lp) {
    final start = GameData.initial(t0);
    return start.copyWith(lp: lp, companions: [...start.companions, gilt]);
  }

  test('seals cost 40, 90, 160 LP for the first, second, third on a stat', () {
    var game = withGilt(1000);
    final spent = <double>[];
    for (var i = 0; i < 3; i++) {
      final before = game.lp;
      expect(game.forgeBlock('gilt-1', SealType.stride), isNull);
      game = game.forging('gilt-1', SealType.stride);
      spent.add(before - game.lp);
    }
    expect(spent, Forge.costs);
    expect(spent, [40, 90, 160]);
    expect(game.lp, 710);
    final sealed = game.companions.last;
    expect(sealed.charms, ['stride', 'stride', 'stride']);
    expect(sealed.strideTotal, gilt.stride + 3);
    expect(sealed.gritTotal, gilt.grit);
  });

  test('each stat has its own price ladder', () {
    var game = withGilt(1000).forging('gilt-1', SealType.stride);
    expect(Forge.nextCost(game.companions.last, SealType.grit), 40);
    game = game.forging('gilt-1', SealType.grit);
    expect(game.lp, 1000 - 40 - 40);
    expect(Forge.nextCost(game.companions.last, SealType.stride), 90);
  });

  test('a stat caps at +3', () {
    var c = gilt;
    for (var i = 0; i < 3; i++) {
      c = c.withCharm(i, SealType.fortune.name);
    }
    expect(Forge.nextCost(c, SealType.fortune), isNull);
    final game = withGilt(
      1e6,
    ).replaceCompanion(c.copyWith(charms: [...c.charms, null]));
    expect(game.forgeBlock('gilt-1', SealType.fortune), ForgeBlock.statMaxed);
  });

  test('sockets follow rarity: a Common takes one seal', () {
    var game = GameData.initial(t0).copyWith(lp: 1000);
    game = game.forging('pebble-1', SealType.grit);
    expect(game.activeCompanion.charms, ['grit']);
    expect(game.forgeBlock('pebble-1', SealType.stride), ForgeBlock.noSocket);
  });

  test('forging needs 100 % Spirit and enough LP', () {
    final worn = withGilt(1000).replaceCompanion(gilt.copyWith(spirit: 99.9));
    expect(worn.forgeBlock('gilt-1', SealType.stride), ForgeBlock.needsSpirit);
    final poor = withGilt(39.9);
    expect(poor.forgeBlock('gilt-1', SealType.stride), ForgeBlock.notEnoughLp);
    expect(withGilt(40).forgeBlock('gilt-1', SealType.stride), isNull);
  });

  test('stride seals raise LP per Breath', () {
    final sealed = gilt.withCharm(0, SealType.stride.name);
    expect(sealed.lpPerBreath, greaterThan(gilt.lpPerBreath));
    expect(
      sealed.lpPerBreath,
      closeTo(gilt.lpPerBreath * (gilt.stride + 1) / gilt.stride, 1e-9),
    );
  });

  test('seals survive a save', () {
    final game = withGilt(1000).forging('gilt-1', SealType.grit);
    final copy = GameData.fromJson(game.toJson());
    expect(copy.companions.last.charms, ['grit', null, null]);
    expect(copy.lp, 960);
  });

  test('selling removes the seals and does not refund their LP', () {
    var game = withGilt(1000)
        .forging('gilt-1', SealType.stride)
        .forging('gilt-1', SealType.stride)
        .withMarket(t0, Random(1));
    final lpBefore = game.lp;
    final price = game.market!.sellPriceOf(gilt);
    game = game.selling('gilt-1', t0);
    expect(game.lp, lpBefore + price);
    expect(game.companions.map((c) => c.id), ['pebble-1']);
    expect(game.market!.offers.map((o) => o.id), isNot(contains('gilt-1')));
  });
}
