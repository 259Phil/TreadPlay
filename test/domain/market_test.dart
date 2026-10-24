import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/market.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  test('a roll has six full-Spirit level 1 offers', () {
    final m = Market.rolled(t0, Random(1));
    expect(m.offers, hasLength(Market.offerCount));
    expect(m.offers.map((c) => c.id).toSet(), hasLength(Market.offerCount));
    for (final c in m.offers) {
      expect(c.spirit, 100);
      expect(c.level, 1);
    }
  });

  test('the next drift is 2–9 h after the roll, spread over the range', () {
    final gaps = <Duration>{};
    for (var seed = 0; seed < 500; seed++) {
      final gap = Market.rolled(t0, Random(seed)).nextDriftAt.difference(t0);
      expect(gap, greaterThanOrEqualTo(const Duration(hours: 2)));
      expect(gap, lessThanOrEqualTo(const Duration(hours: 9)));
      gaps.add(gap);
    }
    expect(gaps.any((g) => g < const Duration(hours: 3)), isTrue);
    expect(gaps.any((g) => g > const Duration(hours: 8)), isTrue);
  });

  test('the same seed gives the same drift moment', () {
    for (var seed = 0; seed < 50; seed++) {
      expect(
        Market.rolled(t0, Random(seed)).nextDriftAt,
        Market.rolled(t0, Random(seed)).nextDriftAt,
      );
    }
  });

  test('offers stay put until the drift, then roll anew', () {
    final m = Market.rolled(t0, Random(2));
    final before = m.nextDriftAt.subtract(const Duration(minutes: 1));
    expect(identical(m.drifted(before, Random(3)), m), isTrue);
    final after = m.drifted(m.nextDriftAt, Random(3));
    expect(identical(after, m), isFalse);
    expect(after.nextDriftAt.isAfter(m.nextDriftAt), isTrue);
    expect(
      after.offers
          .map((c) => c.id)
          .toSet()
          .intersection(m.offers.map((c) => c.id).toSet()),
      isEmpty,
    );
  });

  test('market stats roll ±8 % per stat, independently, not a migration', () {
    final offers = [
      for (var seed = 0; seed < 100; seed++)
        ...Market.rolled(t0, Random(seed)).offers,
    ];
    expect(offers.map((c) => c.rarity).toSet(), Rarity.values.toSet());
    for (final c in offers) {
      for (final s in [c.stride, c.grit, c.fortune]) {
        expect(s, inInclusiveRange(c.rarity.minStat, c.rarity.maxStat));
      }
    }
    final allEqual = offers.where(
      (c) => c.stride == c.grit && c.grit == c.fortune,
    );
    expect(allEqual.length, lessThan(offers.length ~/ 20));
    final legendaries = offers.where((c) => c.rarity == Rarity.legendary);
    expect(legendaries, isNotEmpty);
    expect(
      legendaries.where(
        (c) => c.stride == 25.8 && c.grit == 25.8 && c.fortune == 25.8,
      ),
      isEmpty,
    );
    expect(
      offers.where((c) => c.stride == 10 && c.rarity != Rarity.common),
      isEmpty,
    );
  });

  test('prices are whole LP, rise with rarity and buy-back pays less', () {
    final m = Market.rolled(t0, Random(4));
    for (final c in m.offers) {
      final price = m.priceOf(c);
      expect(price, price.roundToDouble());
      expect(m.sellPriceOf(c), lessThan(price));
      expect(m.sellPriceOf(c), greaterThan(0));
    }
    final flat = Market(nextDriftAt: t0, drift: const {}, offers: const []);
    final prices = [
      for (final r in Rarity.values)
        flat.priceOf(Companion.fresh(id: 'x', speciesId: 'gilt', rarity: r)),
    ];
    expect(prices, [200, 500, 1200, 3000]);
  });

  test('each offer drifts on its own within ±20 % of the base price', () {
    final factors = <double>{};
    for (var seed = 0; seed < 100; seed++) {
      final m = Market.rolled(t0, Random(seed));
      expect(m.drift.keys.toSet(), {for (final c in m.offers) c.id});
      for (final c in m.offers) {
        final base = Market.basePrice[c.rarity]!;
        expect(m.priceOf(c), inInclusiveRange(base * 0.8, base * 1.2));
        factors.add(m.drift[c.id]!);
      }
    }
    expect(factors.length, greaterThan(500));
  });

  test('buy-back pays 60 % of the base price', () {
    final m = Market.rolled(t0, Random(2));
    final sells = [
      for (final r in Rarity.values)
        m.sellPriceOf(Companion.fresh(id: 'x', speciesId: 'gilt', rarity: r)),
    ];
    expect(sells, [120, 300, 720, 1800]);
  });

  test('json round trip keeps offers and rolled stats', () {
    final m = Market.rolled(t0, Random(5));
    final copy = Market.fromJson(m.toJson());
    expect(copy.toJson(), m.toJson());
  });
}
