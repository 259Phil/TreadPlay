import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/species.dart';
import 'package:treadplay/domain/album.dart';
import 'package:treadplay/domain/market.dart';
import 'package:treadplay/domain/world.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);
  final allWorlds = World.values.toSet();

  Set<String> ids(Iterable<Species> s) => {for (final x in s) x.id};

  test('find rates: 18 frequent, 6 scarce, 4 elusive, 2 fabled', () {
    int n(FindRate r) => speciesCatalog.where((s) => s.findRate == r).length;
    expect(n(FindRate.frequent), 18);
    expect(n(FindRate.scarce), 6);
    expect(n(FindRate.elusive), 4);
    expect(n(FindRate.mythic), 2);
  });

  test('the new species open along the trail', () {
    final open = {for (final s in speciesCatalog) s.id: speciesOpenKm(s)};
    expect(open['zinnbuck'], 0);
    expect(open['ringelpanz'], 2.3);
    expect(open['farnix'], 4.1);
    expect(open['schwammo'], 9.4);
    expect(open['muschlo'], 13.2);
    expect(open['tangwell'], 22.9);
    expect(open['papyrix'], 28.4);
    expect(open['teerbock'], 28.4);
    expect(open['segelkamm'], 34.7);
    expect(open['emaillo'], 41.3);
    expect(open['lapisor'], 57.2);
    expect(open['messingor'], 66.9);
    expect(open['nebulo'], 77.4);
    expect(open['muttrix'], 77.4);
    expect(open['drahtel'], 88.8);
    expect(open['kraterix'], 101.3);
    expect(open['puderling'], 128.2);
    expect(open['karamello'], 128.2);
    expect(open['porzella'], 150);
    expect(open['lakrillo'], 175);
    // The first ten keep opening with their world.
    expect(open['pebble'], 0);
    expect(open['brine'], 13.2);
  });

  test('the pool grows with km, never shrinks', () {
    expect(ids(Market.poolFor(worlds: {World.medieval}, distanceM: 0)), {
      'pebble',
      'zinnbuck',
      'vine',
      'brine',
    });
    var last = <String>{};
    for (var km = 0.0; km <= 200; km += 0.5) {
      final pool = ids(Market.poolFor(worlds: allWorlds, distanceM: km * 1000));
      expect(pool.containsAll(last), isTrue, reason: '$km km');
      last = pool;
    }
    expect(last, ids(speciesCatalog));
    expect(
      ids(Market.poolFor(worlds: allWorlds, distanceM: 174999)),
      isNot(contains('lakrillo')),
    );
  });

  test('a species fills at most three offers', () {
    for (var seed = 0; seed < 500; seed++) {
      final m = Market.rolled(
        t0,
        Random(seed),
        worlds: {World.medieval},
        distanceM: 0,
      );
      final counts = <String, int>{};
      for (final c in m.offers) {
        counts[c.speciesId] = (counts[c.speciesId] ?? 0) + 1;
      }
      expect(counts.values.reduce(max), lessThanOrEqualTo(3));
      expect(counts.length, 4);
    }
  });

  test('rarer find rates turn up less often, but they do turn up', () {
    final perSpecies = {for (final s in speciesCatalog) s.id: 0};
    const markets = 4000;
    for (var seed = 0; seed < markets; seed++) {
      for (final c in Market.rolled(
        t0,
        Random(seed),
        worlds: allWorlds,
      ).offers) {
        perSpecies[c.speciesId] = perSpecies[c.speciesId]! + 1;
      }
    }
    double mean(FindRate r) {
      final xs = [
        for (final s in speciesCatalog)
          if (s.findRate == r) perSpecies[s.id]!,
      ];
      return xs.reduce((a, b) => a + b) / xs.length;
    }

    final f = mean(FindRate.frequent),
        s = mean(FindRate.scarce),
        e = mean(FindRate.elusive),
        m = mean(FindRate.mythic);
    expect(f, greaterThan(s * 1.6));
    expect(s, greaterThan(e * 1.6));
    expect(e, greaterThan(m * 1.8));
    // Fabled: about one offer in every 25 markets per species, never zero.
    expect(m / markets, inInclusiveRange(0.02, 0.07));
    expect(perSpecies.values, everyElement(greaterThan(0)));
  });

  test('a full market shows clearly more species than before', () {
    var distinct = 0;
    for (var seed = 0; seed < 1000; seed++) {
      final m = Market.rolled(t0, Random(seed), worlds: allWorlds);
      distinct += {for (final c in m.offers) c.speciesId}.length;
    }
    // Before: 10 species, uniform, about 7.2 in 12 offers.
    expect(distinct / 1000, greaterThan(8.5));
  });

  test('rarity odds stay the same', () {
    final counts = <String, int>{};
    for (var seed = 0; seed < 3000; seed++) {
      for (final c in Market.rolled(t0, Random(seed)).offers) {
        counts[c.rarity.name] = (counts[c.rarity.name] ?? 0) + 1;
      }
    }
    final all = counts.values.reduce((a, b) => a + b);
    for (final e in Market.rarityWeight.entries) {
      expect(counts[e.key.name]! / all, closeTo(e.value / 100, 0.015));
    }
  });
}
