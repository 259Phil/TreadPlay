import 'dart:math';

import '../data/species.dart';
import 'companion.dart';

/// The local companion market. Offers and prices are rolled together and
/// stay put until the next drift, 7–9 h later. The drift moment is kept in
/// the save but never shown.
class Market {
  const Market({
    required this.nextDriftAt,
    required this.drift,
    required this.offers,
  });

  /// A fresh set of [offerCount] offers. Every offer is a new instance whose
  /// Stride, Grit and Fortune are rolled independently (see
  /// [Companion.rolled]).
  factory Market.rolled(DateTime now, Random random) {
    final minutes =
        minDrift.inMinutes +
        random.nextInt(maxDrift.inMinutes - minDrift.inMinutes + 1);
    final offers = [
      for (var i = 0; i < offerCount; i++)
        Companion.rolled(
          id: 'm${now.microsecondsSinceEpoch}-$i',
          speciesId: speciesCatalog[random.nextInt(speciesCatalog.length)].id,
          rarity: _rollRarity(random),
          random: random,
        ),
    ];
    return Market(
      nextDriftAt: now.add(Duration(minutes: minutes)),
      drift: {
        for (final c in offers)
          c.id: 1 - priceDrift + 2 * priceDrift * random.nextDouble(),
      },
      offers: offers,
    );
  }

  static const int offerCount = 6;
  static const Duration minDrift = Duration(hours: 7);
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

  /// Price factor per offer id for this drift.
  final Map<String, double> drift;
  final List<Companion> offers;

  /// Same market until [nextDriftAt]; afterwards a newly rolled one.
  Market drifted(DateTime now, Random random) =>
      now.isBefore(nextDriftAt) ? this : Market.rolled(now, random);

  Companion? offer(String id) => offers.where((c) => c.id == id).firstOrNull;

  /// Whole LP: the rarity's base price times the offer's own drift.
  double priceOf(Companion c) =>
      (basePrice[c.rarity]! * (drift[c.id] ?? 1)).roundToDouble();

  /// Whole LP: [sellShare] of the rarity's base price.
  double sellPriceOf(Companion c) =>
      (basePrice[c.rarity]! * sellShare).roundToDouble();

  Market without(String offerId) => Market(
    nextDriftAt: nextDriftAt,
    drift: drift,
    offers: [
      for (final c in offers)
        if (c.id != offerId) c,
    ],
  );

  Map<String, Object?> toJson() => {
    'nextDriftAt': nextDriftAt.toIso8601String(),
    'drift': drift,
    'offers': [for (final c in offers) c.toJson()],
  };

  factory Market.fromJson(Map<String, Object?> json) => Market(
    nextDriftAt: DateTime.parse(json['nextDriftAt']! as String),
    drift: {
      for (final e in (json['drift']! as Map<String, Object?>).entries)
        e.key: (e.value! as num).toDouble(),
    },
    offers: [
      for (final c in json['offers']! as List<Object?>)
        Companion.fromJson(c! as Map<String, Object?>),
    ],
  );

  static Rarity _rollRarity(Random random) {
    var pick = random.nextInt(100);
    for (final e in rarityWeight.entries) {
      if (pick < e.value) return e.key;
      pick -= e.value;
    }
    return Rarity.common;
  }
}
