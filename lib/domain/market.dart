import 'dart:math';

import '../data/species.dart';
import 'companion.dart';
import 'world.dart';

/// The local companion market. Offers and prices are rolled together and
/// stay put until the next drift, 2–9 h later. The drift moment is rolled
/// once and kept in the save, so reloading does not change it; it is never
/// shown exactly.
class Market {
  const Market({
    required this.nextDriftAt,
    required this.drift,
    required this.offers,
    this.generation = currentGeneration,
  });

  /// A fresh set of [offerCount] offers. Every offer is a new instance whose
  /// Stride, Grit and Fortune are rolled independently (see
  /// [Companion.rolled]).
  /// Offers only come from species of [worlds]; null or no match means
  /// the whole catalog. A pool with fewer than [minSpecies] species is
  /// topped up with the next worlds in trail order ([starterWorlds]), and
  /// at least [minSpecies] different species are always on offer.
  ///
  /// Each offer also rolls its gait: the species' home gait at
  /// [homeTempoWeight] %, each other gait at half the rest. At least
  /// [guaranteedTempoOffers] offers share [along] (the gait of the companion
  /// taken along) when given. Prices still depend on rarity only.
  factory Market.rolled(
    DateTime now,
    Random random, {
    Set<World>? worlds,
    CompanionType? along,
  }) {
    final inPool = [
      for (final s in speciesCatalog)
        if (worlds == null || worlds.contains(s.world)) s,
    ];
    final pool = inPool.isEmpty ? [...speciesCatalog] : inPool;
    for (final w in starterWorlds) {
      if (pool.length >= minSpecies) break;
      for (final s in speciesCatalog) {
        if (s.world == w && !pool.contains(s)) pool.add(s);
      }
    }
    final minutes =
        minDrift.inMinutes +
        random.nextInt(maxDrift.inMinutes - minDrift.inMinutes + 1);
    final offers = [
      for (var i = 0; i < offerCount; i++)
        Companion.rolled(
          id: 'm${now.microsecondsSinceEpoch}-$i',
          speciesId: pool[random.nextInt(pool.length)].id,
          rarity: _rollRarity(random),
          random: random,
        ),
    ];
    _ensureVariety(offers, pool, random);
    final drift = {
      for (final c in offers)
        c.id: 1 - priceDrift + 2 * priceDrift * random.nextDouble(),
    };
    // Gaits are rolled after rarity, stats and drift so those keep their
    // draws from before gaits were per offer.
    final gaits = [for (final c in offers) _rollTempo(c.species.type, random)];
    if (along != null) {
      var short = guaranteedTempoOffers - gaits.where((t) => t == along).length;
      while (short > 0) {
        final others = [
          for (var i = 0; i < gaits.length; i++)
            if (gaits[i] != along) i,
        ];
        if (others.isEmpty) break;
        gaits[others[random.nextInt(others.length)]] = along;
        short--;
      }
    }
    return Market(
      nextDriftAt: now.add(Duration(minutes: minutes)),
      drift: drift,
      offers: [
        for (var i = 0; i < offers.length; i++)
          offers[i].copyWith(tempo: gaits[i]),
      ],
    );
  }

  /// Version of the rolling rules. A saved market from an older version is
  /// rolled anew once on load (see `GameData.withMarket`).
  /// 2: per-offer gaits, at least [minSpecies] species, 2–9 h drift.
  static const int currentGeneration = 2;

  /// Different species per market at least (when the catalog has them).
  static const int minSpecies = 3;

  /// Worlds in the order the trail opens them for the Market; tops up a
  /// pool that is too small, e.g. for fresh players.
  static const List<World> starterWorlds = [
    World.medieval,
    World.jungle,
    World.underwater,
    World.egypt,
    World.pirate,
    World.steampunk,
    World.space,
    World.robot,
    World.rococo,
    World.candy,
  ];

  /// The last stretch before a drift, when the Market hints at it.
  static const Duration soonWindow = Duration(minutes: 30);

  /// Chance in percent that an offer has its species' home gait.
  static const int homeTempoWeight = 50;

  /// Offers per market that match the gait of the companion taken along.
  static const int guaranteedTempoOffers = 3;

  static const int offerCount = 12;
  static const Duration minDrift = Duration(hours: 2);
  static const Duration maxDrift = Duration(hours: 9);

  /// Price factor range per offer (±20 %).
  static const double priceDrift = 0.2;

  /// Share of the base price the market pays when buying back.
  static const double sellShare = 0.6;

  static const Map<Rarity, double> basePrice = {
    Rarity.common: 200,
    Rarity.rare: 500,
    Rarity.epic: 1200,
    Rarity.legendary: 3000,
  };

  /// Chance per offer slot, in percent.
  static const Map<Rarity, int> rarityWeight = {
    Rarity.common: 55,
    Rarity.rare: 28,
    Rarity.epic: 13,
    Rarity.legendary: 4,
  };

  final DateTime nextDriftAt;

  /// [currentGeneration] when rolled; 1 for markets saved before it.
  final int generation;

  /// True for a market rolled under older rules.
  bool get outdated => generation < currentGeneration;

  /// True in the last [soonWindow] before the drift.
  bool restocksSoon(DateTime now) =>
      !now.isBefore(nextDriftAt.subtract(soonWindow));

  /// Price factor per offer id for this drift.
  final Map<String, double> drift;
  final List<Companion> offers;

  /// Same market until [nextDriftAt]; afterwards a newly rolled one.
  Market drifted(
    DateTime now,
    Random random, {
    Set<World>? worlds,
    CompanionType? along,
  }) => now.isBefore(nextDriftAt)
      ? this
      : Market.rolled(now, random, worlds: worlds, along: along);

  Companion? offer(String id) => offers.where((c) => c.id == id).firstOrNull;

  /// Whole LP: the rarity's base price times the offer's own drift.
  double priceOf(Companion c) =>
      (basePrice[c.rarity]! * (drift[c.id] ?? 1)).roundToDouble();

  /// Whole LP: [sellShare] of the rarity's base price.
  double sellPriceOf(Companion c) =>
      (basePrice[c.rarity]! * sellShare).roundToDouble();

  Market without(String offerId) => Market(
    nextDriftAt: nextDriftAt,
    generation: generation,
    drift: drift,
    offers: [
      for (final c in offers)
        if (c.id != offerId) c,
    ],
  );

  Map<String, Object?> toJson() => {
    'generation': generation,
    'nextDriftAt': nextDriftAt.toIso8601String(),
    'drift': drift,
    'offers': [for (final c in offers) c.toJson()],
  };

  factory Market.fromJson(Map<String, Object?> json) => Market(
    nextDriftAt: DateTime.parse(json['nextDriftAt']! as String),
    generation: (json['generation'] as num?)?.toInt() ?? 1,
    drift: {
      for (final e in (json['drift']! as Map<String, Object?>).entries)
        e.key: (e.value! as num).toDouble(),
    },
    offers: [
      for (final c in json['offers']! as List<Object?>)
        Companion.fromJson(c! as Map<String, Object?>),
    ],
  );

  /// Swaps offers of the most frequent species for missing ones until
  /// [minSpecies] species (or the whole pool) are on offer. Rarity, stats
  /// and ids stay; only the species changes.
  static void _ensureVariety(
    List<Companion> offers,
    List<Species> pool,
    Random random,
  ) {
    final want = min(minSpecies, pool.length);
    while (true) {
      final counts = <String, int>{};
      for (final c in offers) {
        counts[c.speciesId] = (counts[c.speciesId] ?? 0) + 1;
      }
      if (counts.length >= want) return;
      final missing = [
        for (final s in pool)
          if (!counts.containsKey(s.id)) s,
      ];
      final most = counts.values.reduce(max);
      final crowded = [
        for (var i = 0; i < offers.length; i++)
          if (counts[offers[i].speciesId] == most) i,
      ];
      final i = crowded[random.nextInt(crowded.length)];
      final o = offers[i];
      offers[i] = Companion(
        id: o.id,
        speciesId: missing[random.nextInt(missing.length)].id,
        rarity: o.rarity,
        level: o.level,
        stride: o.stride,
        grit: o.grit,
        fortune: o.fortune,
        spirit: o.spirit,
        charms: o.charms,
      );
    }
  }

  static CompanionType _rollTempo(CompanionType home, Random random) {
    final pick = random.nextInt(100);
    if (pick < homeTempoWeight) return home;
    final others = [
      for (final t in CompanionType.values)
        if (t != home) t,
    ];
    final share = (100 - homeTempoWeight) / others.length;
    return others[min(others.length - 1, (pick - homeTempoWeight) ~/ share)];
  }

  static Rarity _rollRarity(Random random) {
    var pick = random.nextInt(100);
    for (final e in rarityWeight.entries) {
      if (pick < e.value) return e.key;
      pick -= e.value;
    }
    return Rarity.common;
  }
}
