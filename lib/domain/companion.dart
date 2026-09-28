import 'dart:math';

import '../data/companion_art.dart';
import '../data/species.dart';
import 'world.dart';

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

  /// Seal id per charm slot, null when empty. Length = [Rarity.charmSlots].
  final List<String?> charms;

  Species get species => speciesById[speciesId]!;

  String get name => species.name;

  CompanionType get type => species.type;

  World get world => species.world;

  /// Art key for this rarity, falling back to the nearest lower rarity that
  /// has an image.
  String get artKey => artKeyFor(speciesId, rarity);

  String get imageAsset => 'assets/companions/$artKey.png';

  /// Breath cap while this companion is taken along.
  int get tankSize => rarity.tankSize;

  /// LP per Breath point: the rarity rate, scaled by how this instance's
  /// Stride rolled against the rarity base and by level.
  double get lpPerBreath =>
      rarity.lpPerBreath * (stride / rarity.baseStat) * levelFactor(level);

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

  /// Puts [sealId] into charm [slot] (or clears it with null).
  Companion withCharm(int slot, String? sealId) {
    RangeError.checkValidIndex(slot, charms, 'slot');
    return copyWith(charms: [...charms]..[slot] = sealId);
  }

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
          i < saved.length ? saved[i] as String? : null,
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
