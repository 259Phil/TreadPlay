import 'dart:math';

import '../data/companion_art.dart';
import '../data/companion_cutouts.dart';
import '../data/species.dart';
import 'seal.dart';
import 'world.dart';

export 'seal.dart' show Seal, SealType;

enum CompanionType {
  moss(sweetSpotKmh: 4.5, rangeKmh: 2.5),
  brook(sweetSpotKmh: 7.5, rangeKmh: 2.5),
  gale(sweetSpotKmh: 11, rangeKmh: 4);

  const CompanionType({required this.sweetSpotKmh, required this.rangeKmh});

  final double sweetSpotKmh;
  final double rangeKmh;
}

enum Rarity {
  common(code: 'c', tankSize: 6, lpPerBreath: 2.5, charmSlots: 1, baseStat: 10),
  rare(code: 'r', tankSize: 8, lpPerBreath: 4.0, charmSlots: 2, baseStat: 14),
  epic(code: 'e', tankSize: 10, lpPerBreath: 7.0, charmSlots: 2, baseStat: 20),
  legendary(
    code: 'l',
    tankSize: 12,
    lpPerBreath: 12.0,
    charmSlots: 3,
    baseStat: 28,
  );

  const Rarity({
    required this.code,
    required this.tankSize,
    required this.lpPerBreath,
    required this.charmSlots,
    required this.baseStat,
  });

  /// Suffix of the art file, e.g. `pebble_r`.
  final String code;
  final int tankSize;
  final double lpPerBreath;

  /// Charms a companion of this rarity wears; each holds at most one seal.
  final int charmSlots;

  /// Stride, Grit and Fortune before the instance roll.
  final double baseStat;

  /// Lowest stat an instance of this rarity can roll.
  double get minStat => _roundStat(baseStat * (1 - statRoll));

  /// Highest stat an instance of this rarity can roll.
  double get maxStat => _roundStat(baseStat * (1 + statRoll));
}

/// Each instance rolls its stats within ±8 % of [Rarity.baseStat].
const double statRoll = 0.08;

const int maxLevel = 25;

double _roundStat(double value) => (value * 10).roundToDouble() / 10;

/// Stride bonus from levels: +4 % per level up to 18, +2 % per level after.
double levelFactor(int level) {
  final l = level.clamp(1, maxLevel);
  return 1 + 0.04 * (min(l, 18) - 1) + 0.02 * max(0, l - 18);
}

/// Most a stat can gain from all its seals together (+47 %).
const double sealCap = 0.47;

/// One owned creature that can be taken along on a run.
class Companion {
  const Companion({
    required this.id,
    required this.speciesId,
    required this.rarity,
    required this.level,
    required this.stride,
    required this.grit,
    required this.fortune,
    required this.spirit,
    required this.charms,
  });

  /// The starter every player is given.
  factory Companion.pebble() => Companion.fresh(
    id: 'pebble-1',
    speciesId: 'pebble',
    rarity: Rarity.common,
  );

  /// A level 1 companion with the unrolled base stats of its rarity.
  factory Companion.fresh({
    required String id,
    required String speciesId,
    required Rarity rarity,
  }) => Companion(
    id: id,
    speciesId: speciesId,
    rarity: rarity,
    level: 1,
    stride: rarity.baseStat,
    grit: rarity.baseStat,
    fortune: rarity.baseStat,
    spirit: 100,
    charms: List.filled(rarity.charmSlots, null),
  );

  /// A level 1 companion whose stats are each rolled within ±[statRoll] of
  /// the rarity base.
  factory Companion.rolled({
    required String id,
    required String speciesId,
    required Rarity rarity,
    required Random random,
  }) {
    double roll() => _roundStat(
      rarity.baseStat * (1 - statRoll + 2 * statRoll * random.nextDouble()),
    );
    return Companion.fresh(
      id: id,
      speciesId: speciesId,
      rarity: rarity,
    ).copyWith(stride: roll(), grit: roll(), fortune: roll());
  }

  final String id;
  final String speciesId;
  final Rarity rarity;
  final int level;
  final double stride;
  final double grit;
  final double fortune;

  /// Durability in percent (0–100). At 0 the companion earns no LP.
  final double spirit;

  /// Seal code per charm slot (see [Seal.code]), null when empty.
  /// Length = [Rarity.charmSlots].
  final List<String?> charms;

  /// The seals set into the charms, in slot order (empty slots skipped).
  List<Seal> get seals => [
    for (final c in charms)
      if (Seal.tryParse(c) case final s?) s,
  ];

  /// Seal in charm [slot], or null when empty.
  Seal? sealAt(int slot) => Seal.tryParse(charms[slot]);

  Species get species => speciesById[speciesId]!;

  String get name => species.name;

  CompanionType get type => species.type;

  World get world => species.world;

  /// Art key for this rarity, falling back to the nearest lower rarity that
  /// has an image.
  String get artKey => cutoutKeyFor(speciesId, rarity);

  String get imageAsset => 'assets/companions/$artKey.png';

  /// Seals set into this companion that raise [type].
  int sealCount(SealType type) =>
      seals.where((s) => s.stats.contains(type)).length;

  /// Sum of the seal bonuses on [type] before the cap.
  double rawSealBonus(SealType type) =>
      seals.fold(0, (sum, s) => sum + s.bonusOn(type));

  /// Seal bonus on [type] as a fraction, at most [sealCap].
  double sealBonus(SealType type) => min(rawSealBonus(type), sealCap);

  /// True when the seals on [type] reach (or would pass) the cap.
  bool sealCapped(SealType type) => rawSealBonus(type) >= sealCap - 1e-9;

  /// First empty charm socket, or null when all are filled.
  int? get freeSocket {
    final i = charms.indexOf(null);
    return i < 0 ? null : i;
  }

  double get strideTotal => stride * (1 + sealBonus(SealType.stride));

  double get gritTotal => grit * (1 + sealBonus(SealType.grit));

  double get fortuneTotal => fortune * (1 + sealBonus(SealType.fortune));

  /// Grit: Spirit loss per run is divided by (1 + Grit bonus), so +31 %
  /// loses about 24 % less. Spirit does not drop in this version yet; the
  /// factor is ready for it.
  double get spiritLossFactor => 1 / (1 + sealBonus(SealType.grit));

  /// Fortune: pouch and messenger chances after a run are multiplied by
  /// this (never above 100 %), and the pouch colour (which also picks the
  /// messenger) leans to the rarer ones.
  double get fortuneFactor => 1 + sealBonus(SealType.fortune);

  /// Breath cap while this companion is taken along.
  int get tankSize => rarity.tankSize;

  /// LP per Breath point: the rarity rate, scaled by this instance's Stride
  /// (roll plus seals) against the rarity base and by level.
  double get lpPerBreath =>
      rarity.lpPerBreath * (strideTotal / rarity.baseStat) * levelFactor(level);

  Companion copyWith({
    double? stride,
    double? grit,
    double? fortune,
    double? spirit,
    List<String?>? charms,
  }) => Companion(
    id: id,
    speciesId: speciesId,
    rarity: rarity,
    level: level,
    stride: stride ?? this.stride,
    grit: grit ?? this.grit,
    fortune: fortune ?? this.fortune,
    spirit: spirit ?? this.spirit,
    charms: charms ?? this.charms,
  );

  /// Puts the seal [code] into charm [slot] (or clears it with null).
  Companion withCharm(int slot, String? code) {
    RangeError.checkValidIndex(slot, charms, 'slot');
    return copyWith(charms: [...charms]..[slot] = code);
  }

  /// Puts [seal] into charm [slot].
  Companion withSeal(int slot, Seal seal) => withCharm(slot, seal.code);

  Map<String, Object?> toJson() => {
    'id': id,
    'speciesId': speciesId,
    'rarity': rarity.name,
    'level': level,
    'stride': stride,
    'grit': grit,
    'fortune': fortune,
    'spirit': spirit,
    'charms': charms,
  };

  factory Companion.fromJson(Map<String, Object?> json) {
    final rarity = Rarity.values.byName(json['rarity']! as String);
    final saved = (json['charms'] as List<Object?>?) ?? const [];
    return Companion(
      id: json['id']! as String,
      speciesId: json['speciesId']! as String,
      rarity: rarity,
      level: json['level']! as int,
      stride: _savedStat(json['stride'], rarity),
      grit: _savedStat(json['grit'], rarity),
      fortune: _savedStat(json['fortune'], rarity),
      spirit: (json['spirit']! as num).toDouble(),
      charms: [
        for (var i = 0; i < rarity.charmSlots; i++)
          // Bare stat names from before seal levels become level codes.
          i < saved.length ? Seal.normalize(saved[i] as String?) : null,
      ],
    );
  }
}

/// Saves from before stats depended on rarity hold 10 for every rarity; those
/// are lifted to the lowest roll of the rarity.
double _savedStat(Object? value, Rarity rarity) =>
    max((value! as num).toDouble(), rarity.minStat);

String artKeyFor(String speciesId, Rarity rarity) {
  for (var i = rarity.index; i >= 0; i--) {
    final key = '${speciesId}_${Rarity.values[i].code}';
    if (companionArt.containsKey(key)) return key;
  }
  return 'pebble_c';
}

/// Cutout for [speciesId] at [rarity]: `{id}.png` is Common, the others are
/// `{id}-rare.png`, `{id}-epic.png`, `{id}-legendary.png`. Falls back to the
/// next lower rarity that has a cutout.
String cutoutKeyFor(String speciesId, Rarity rarity) {
  for (var i = rarity.index; i >= 0; i--) {
    final r = Rarity.values[i];
    final key = r == Rarity.common ? speciesId : '$speciesId-${r.name}';
    if (companionCutouts.containsKey(key)) return key;
  }
  return 'pebble';
}
