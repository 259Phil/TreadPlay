import 'dart:math';

enum ShoeType {
  stomper(sweetSpotKmh: 4.5, rangeKmh: 2.5),
  strider(sweetSpotKmh: 7.5, rangeKmh: 2.5),
  dasher(sweetSpotKmh: 11, rangeKmh: 4);

  const ShoeType({required this.sweetSpotKmh, required this.rangeKmh});

  final double sweetSpotKmh;
  final double rangeKmh;
}

enum Rarity {
  common(tankSize: 6, lpPerBreath: 2.5),
  rare(tankSize: 8, lpPerBreath: 4.0),
  epic(tankSize: 10, lpPerBreath: 7.0),
  legendary(tankSize: 12, lpPerBreath: 12.0);

  const Rarity({required this.tankSize, required this.lpPerBreath});

  final int tankSize;
  final double lpPerBreath;
}

const Duration breathRegenInterval = Duration(minutes: 90);
const double baseStride = 10;

class Shoe {
  const Shoe({
    required this.id,
    required this.modelId,
    required this.name,
    required this.type,
    required this.rarity,
    required this.level,
    required this.stride,
    required this.grit,
    required this.fortune,
    required this.sole,
    required this.breath,
    required this.breathUpdatedAt,
  });

  factory Shoe.cobble(DateTime now) => Shoe._starter(
    now,
    id: 'cobble-1',
    modelId: 'boot_01',
    name: 'Cobble',
    type: ShoeType.stomper,
    rarity: Rarity.common,
  );

  factory Shoe.gearbuckle(DateTime now) => Shoe._starter(
    now,
    id: 'gearbuckle-1',
    modelId: 'boot_07',
    name: 'Gearbuckle',
    type: ShoeType.strider,
    rarity: Rarity.common,
  );

  factory Shoe.orbithop(DateTime now) => Shoe._starter(
    now,
    id: 'orbithop-1',
    modelId: 'boot_08',
    name: 'Orbithop',
    type: ShoeType.dasher,
    rarity: Rarity.rare,
  );

  factory Shoe._starter(
    DateTime now, {
    required String id,
    required String modelId,
    required String name,
    required ShoeType type,
    required Rarity rarity,
  }) => Shoe(
    id: id,
    modelId: modelId,
    name: name,
    type: type,
    rarity: rarity,
    level: 1,
    stride: baseStride,
    grit: baseStride,
    fortune: baseStride,
    sole: 100,
    breath: rarity.tankSize.toDouble(),
    breathUpdatedAt: now,
  );

  /// The boots every player starts with on the garage shelf.
  static List<Shoe> starterSet(DateTime now) => [
    Shoe.cobble(now),
    Shoe.gearbuckle(now),
    Shoe.orbithop(now),
  ];

  final String id;
  final String modelId;
  final String name;
  final ShoeType type;
  final Rarity rarity;
  final int level;
  final double stride;
  final double grit;
  final double fortune;

  /// Durability in percent (0–100).
  final double sole;
  final double breath;
  final DateTime breathUpdatedAt;

  String get imageAsset => 'assets/boots/$modelId.png';

  int get tankSize => rarity.tankSize;

  double get lpPerBreath =>
      rarity.lpPerBreath * (stride / baseStride) * (1 + 0.04 * (level - 1));

  Shoe regenerated(DateTime now) {
    if (!now.isAfter(breathUpdatedAt)) return this;
    final gained =
        now.difference(breathUpdatedAt).inSeconds /
        breathRegenInterval.inSeconds;
    return copyWith(
      breath: min(tankSize.toDouble(), breath + gained),
      breathUpdatedAt: now,
    );
  }

  Shoe copyWith({double? breath, DateTime? breathUpdatedAt, double? sole}) =>
      Shoe(
        id: id,
        modelId: modelId,
        name: name,
        type: type,
        rarity: rarity,
        level: level,
        stride: stride,
        grit: grit,
        fortune: fortune,
        sole: sole ?? this.sole,
        breath: breath ?? this.breath,
        breathUpdatedAt: breathUpdatedAt ?? this.breathUpdatedAt,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'modelId': modelId,
    'name': name,
    'type': type.name,
    'rarity': rarity.name,
    'level': level,
    'stride': stride,
    'grit': grit,
    'fortune': fortune,
    'sole': sole,
    'breath': breath,
    'breathUpdatedAt': breathUpdatedAt.toIso8601String(),
  };

  factory Shoe.fromJson(Map<String, Object?> json) => Shoe(
    id: json['id']! as String,
    modelId: json['modelId']! as String,
    name: json['name']! as String,
    type: ShoeType.values.byName(json['type']! as String),
    rarity: Rarity.values.byName(json['rarity']! as String),
    level: json['level']! as int,
    stride: (json['stride']! as num).toDouble(),
    grit: (json['grit']! as num).toDouble(),
    fortune: (json['fortune']! as num).toDouble(),
    sole: (json['sole']! as num).toDouble(),
    breath: (json['breath']! as num).toDouble(),
    breathUpdatedAt: DateTime.parse(json['breathUpdatedAt']! as String),
  );
}
