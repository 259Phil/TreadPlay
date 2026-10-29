import 'dart:math';

import '../data/species.dart';
import 'companion.dart';
import 'salve.dart';
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
    this.salveDrift = const {},
    this.salveDeal,
  });

  /// A fresh set of [offerCount] offers. Every offer is a new instance whose
  /// Stride, Grit and Fortune are rolled independently (see
  /// [Companion.rolled]).
  /// Offers only come from species of [worlds]; null or no match means
  /// the whole catalog. Species whose [Species.unlockKm] lies beyond
  /// [distanceM] (lifetime metres; null = no gate) stay out. A pool with
  /// fewer than [minSpecies] species is topped up with the next worlds in
  /// trail order ([starterWorlds]).
  ///
  /// Each offer picks its species by [Species.findRate] weight; a species
  /// fills at most [maxPerSpecies] offers while others are left, and at
  /// least [minSpecies] different species are always on offer.
  ///
  /// Each offer also rolls its gait: the species' home gait at
  /// [homeTempoWeight] %, each other gait at half the rest. At least
  /// [guaranteedTempoOffers] offers share [along] (the gait of the companion
  /// taken along) when given. Prices depend on rarity (and Schimmer).
  ///
  /// Each offer is a Schimmer at [shimmerChance]; with [shimmerDue] at
  /// least one offer is.
  factory Market.rolled(
    DateTime now,
    Random random, {
    Set<World>? worlds,
    CompanionType? along,
    double? distanceM,
    bool shimmerDue = false,
  }) {
    final pool = poolFor(worlds: worlds, distanceM: distanceM);
    final minutes =
        minDrift.inMinutes +
        random.nextInt(maxDrift.inMinutes - minDrift.inMinutes + 1);
    final picked = <String, int>{};
    final offers = [
      for (var i = 0; i < offerCount; i++)
        Companion.rolled(
          id: 'm${now.microsecondsSinceEpoch}-$i',
          speciesId: _pickSpecies(pool, picked, random).id,
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
    // Salve prices last, so every draw above stays as it was.
    final salveDrift = {
      for (final s in Salve.values)
        s: 1 - priceDrift + 2 * priceDrift * random.nextDouble(),
    };
    final deal = random.nextDouble() < salveDealChance
        ? Salve.values[random.nextInt(Salve.values.length)]
        : null;
    final shimmer = [
      for (var i = 0; i < offers.length; i++)
        random.nextDouble() < shimmerChance,
    ];
    if (shimmerDue && offers.isNotEmpty && !shimmer.contains(true)) {
      shimmer[random.nextInt(offers.length)] = true;
    }
    return Market(
      nextDriftAt: now.add(Duration(minutes: minutes)),
      drift: drift,
      offers: [
        for (var i = 0; i < offers.length; i++)
          offers[i].copyWith(tempo: gaits[i], shimmer: shimmer[i]),
      ],
      salveDrift: salveDrift,
      salveDeal: deal,
    );
  }

  /// The species a Market for [worlds] at [distanceM] lifetime metres can
  /// offer (see [Market.rolled]); null for either means no limit.
  static List<Species> poolFor({Set<World>? worlds, double? distanceM}) {
    bool open(Species s) => distanceM == null || s.openAt(distanceM);
    final inPool = [
      for (final s in speciesCatalog)
        if ((worlds == null || worlds.contains(s.world)) && open(s)) s,
    ];
    final pool = inPool.isEmpty
        ? [
            for (final s in speciesCatalog)
              if (open(s)) s,
          ]
        : inPool;
    for (final w in starterWorlds) {
      if (pool.length >= minSpecies) break;
      for (final s in speciesCatalog) {
        if (s.world == w && open(s) && !pool.contains(s)) pool.add(s);
      }
    }
    return pool;
  }

  /// Weighted by [Species.findRate]; species already in [maxPerSpecies]
  /// offers are skipped while others are left. Counts the pick in [picked].
  static Species _pickSpecies(
    List<Species> pool,
    Map<String, int> picked,
    Random random,
  ) {
    final free = [
      for (final s in pool)
        if ((picked[s.id] ?? 0) < maxPerSpecies) s,
    ];
    final from = free.isEmpty ? pool : free;
    final total = from.fold<double>(0, (n, s) => n + s.findRate.weight);
    var pick = random.nextDouble() * total;
    var chosen = from.last;
    for (final s in from) {
      pick -= s.findRate.weight;
      if (pick < 0) {
        chosen = s;
        break;
      }
    }
    picked[chosen.id] = (picked[chosen.id] ?? 0) + 1;
    return chosen;
  }

  /// Chance per offer that it is a Schimmer (0.1 %).
  static const double shimmerChance = 0.001;

  /// Lifetime metres without a Schimmer in the Market after which the next
  /// roll has one for sure (see `GameData.withMarket`).
  static const double shimmerPityM = 300000;

  /// Price factor of a Schimmer, buying and selling.
  static const double shimmerFactor = 1.5;

  /// Chance per drift that one salve is on offer at [salveDealFactor].
  static const double salveDealChance = 0.25;

  /// Price factor of the salve on offer (−30 %).
  static const double salveDealFactor = 0.7;

  /// Sell price bonus per level above 1 (+3 %).
  static const double sellLevelBonus = 0.03;

  /// Price factor per salve for this drift (±20 %); missing = 1.
  final Map<Salve, double> salveDrift;

  /// The salve on offer this drift (−30 %), if any.
  final Salve? salveDeal;

  /// Whole LP, at least 1: the salve's base price times its drift, or
  /// [salveDealFactor] of the base price while it is on offer.
  double priceOfSalve(Salve s) => max(
    1,
    (s.price * (s == salveDeal ? salveDealFactor : (salveDrift[s] ?? 1)))
        .roundToDouble(),
  ).toDouble();

  /// Version of the rolling rules. A saved market from an older version is
  /// rolled anew once on load (see `GameData.withMarket`).
  /// 2: per-offer gaits, at least [minSpecies] species, 2–9 h drift.
  /// 3: 30 species with find rates and km gates, [maxPerSpecies], Schimmer.
  static const int currentGeneration = 3;

  /// Different species per market at least (when the catalog has them).
  static const int minSpecies = 4;

  /// Offers one species fills at most while other species are left.
  static const int maxPerSpecies = 3;

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
    double? distanceM,
    bool shimmerDue = false,
  }) => now.isBefore(nextDriftAt)
      ? this
      : Market.rolled(
          now,
          random,
          worlds: worlds,
          along: along,
          distanceM: distanceM,
          shimmerDue: shimmerDue,
        );

  /// True when an offer is a Schimmer.
  bool get hasShimmer => offers.any((c) => c.shimmer);

  Companion? offer(String id) => offers.where((c) => c.id == id).firstOrNull;

  /// Whole LP: the rarity's base price times the offer's own drift, times
  /// [shimmerFactor] for a Schimmer.
  double priceOf(Companion c) =>
      (basePrice[c.rarity]! * (drift[c.id] ?? 1) * _shimmerOf(c))
          .roundToDouble();

  /// Whole LP: [sellShare] of the rarity's base price, plus
  /// [sellLevelBonus] for every level above 1, times [shimmerFactor] for a
  /// Schimmer.
  double sellPriceOf(Companion c) =>
      (basePrice[c.rarity]! *
              sellShare *
              (1 + sellLevelBonus * (c.level - 1)) *
              _shimmerOf(c))
          .roundToDouble();

  static double _shimmerOf(Companion c) => c.shimmer ? shimmerFactor : 1;

  Market without(String offerId) => Market(
    nextDriftAt: nextDriftAt,
    generation: generation,
    drift: drift,
    salveDrift: salveDrift,
    salveDeal: salveDeal,
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
    'salves': {for (final e in salveDrift.entries) e.key.name: e.value},
    if (salveDeal case final d?) 'salveDeal': d.name,
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
    // Markets saved before salves sell them at their base price.
    salveDrift: {
      if (json['salves'] case final Map<String, Object?> m)
        for (final e in m.entries)
          if ((Salve.tryParse(e.key), e.value) case (
            final s?,
            final num f,
          ) when f > 0)
            s: f.toDouble().clamp(1 - priceDrift, 1 + priceDrift),
    },
    salveDeal: Salve.tryParse(json['salveDeal']),
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
      offers[i] = o.copyWith(
        speciesId: missing[random.nextInt(missing.length)].id,
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
