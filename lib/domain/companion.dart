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
  common(code: 'c', tankSize: 6, lpPerBreath: 2.5),
  rare(code: 'r', tankSize: 8, lpPerBreath: 4.0),
  epic(code: 'e', tankSize: 10, lpPerBreath: 7.0),
  legendary(code: 'l', tankSize: 12, lpPerBreath: 12.0);

  const Rarity({
    required this.code,
    required this.tankSize,
    required this.lpPerBreath,
  });

  /// Suffix of the art file, e.g. `pebble_r`.
  final String code;
  final int tankSize;
  final double lpPerBreath;
}

const Duration breathRegenInterval = Duration(minutes: 90);
const double baseStride = 10;

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
    required this.breath,
    required this.breathUpdatedAt,
  });

  /// The starter every player is given.
  factory Companion.pebble(DateTime now) => Companion.fresh(
    now,
    id: 'pebble-1',
    speciesId: 'pebble',
    rarity: Rarity.common,
  );

  factory Companion.fresh(
    DateTime now, {
    required String id,
    required String speciesId,
    required Rarity rarity,
  }) => Companion(
    id: id,
    speciesId: speciesId,
    rarity: rarity,
    level: 1,
    stride: baseStride,
    grit: baseStride,
    fortune: baseStride,
    spirit: 100,
    breath: rarity.tankSize.toDouble(),
    breathUpdatedAt: now,
  );

  final String id;
  final String speciesId;
  final Rarity rarity;
  final int level;
  final double stride;
  final double grit;
  final double fortune;

  /// Durability in percent (0–100). At 0 the companion earns no LP.
  final double spirit;
  final double breath;
  final DateTime breathUpdatedAt;

  Species get species => speciesById[speciesId]!;

  String get name => species.name;

  CompanionType get type => species.type;

  World get world => species.world;

  /// Art key for this rarity, falling back to the nearest lower rarity that
  /// has an image.
  String get artKey => artKeyFor(speciesId, rarity);

  String get imageAsset => 'assets/companions/$artKey.png';

  int get tankSize => rarity.tankSize;

  double get lpPerBreath =>
      rarity.lpPerBreath * (stride / baseStride) * (1 + 0.04 * (level - 1));

  Companion regenerated(DateTime now) {
    if (!now.isAfter(breathUpdatedAt)) return this;
    final gained =
        now.difference(breathUpdatedAt).inSeconds /
        breathRegenInterval.inSeconds;
    return copyWith(
      breath: min(tankSize.toDouble(), breath + gained),
      breathUpdatedAt: now,
    );
  }

  Companion copyWith({
    double? breath,
    DateTime? breathUpdatedAt,
    double? spirit,
  }) => Companion(
    id: id,
    speciesId: speciesId,
    rarity: rarity,
    level: level,
    stride: stride,
    grit: grit,
    fortune: fortune,
    spirit: spirit ?? this.spirit,
    breath: breath ?? this.breath,
    breathUpdatedAt: breathUpdatedAt ?? this.breathUpdatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'speciesId': speciesId,
    'rarity': rarity.name,
    'level': level,
    'stride': stride,
    'grit': grit,
    'fortune': fortune,
    'spirit': spirit,
    'breath': breath,
    'breathUpdatedAt': breathUpdatedAt.toIso8601String(),
  };

  factory Companion.fromJson(Map<String, Object?> json) => Companion(
    id: json['id']! as String,
    speciesId: json['speciesId']! as String,
    rarity: Rarity.values.byName(json['rarity']! as String),
    level: json['level']! as int,
    stride: (json['stride']! as num).toDouble(),
    grit: (json['grit']! as num).toDouble(),
    fortune: (json['fortune']! as num).toDouble(),
    spirit: (json['spirit']! as num).toDouble(),
    breath: (json['breath']! as num).toDouble(),
    breathUpdatedAt: DateTime.parse(json['breathUpdatedAt']! as String),
  );
}

String artKeyFor(String speciesId, Rarity rarity) {
  for (var i = rarity.index; i >= 0; i--) {
    final key = '${speciesId}_${Rarity.values[i].code}';
    if (companionArt.containsKey(key)) return key;
  }
  return 'pebble_c';
}
