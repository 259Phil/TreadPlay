import 'dart:math';

import 'seal.dart';

/// The four treat pouch colours. Colour is weight only: a higher colour
/// leans to better seals and more Glut, nothing is promised.
///
/// Pouches never hold companions: those only come from the Market.
enum PouchColor {
  brown(walkM: 1000, openLp: 23, findWeight: 61),
  copper(walkM: 1500, openLp: 41, findWeight: 25),
  turquoise(walkM: 2000, openLp: 67, findWeight: 10),
  navy(walkM: 3000, openLp: 113, findWeight: 4);

  const PouchColor({
    required this.walkM,
    required this.openLp,
    required this.findWeight,
  });

  /// Distance of valid runs that warms the pouch open for free.
  final double walkM;

  /// LP to open it right away, before any warming.
  final int openLp;

  /// Weight when a found pouch picks its colour among the unlocked ones.
  final int findWeight;

  static PouchColor? tryParse(Object? name) =>
      name is String ? values.asNameMap()[name] : null;
}

enum PouchRewardKind { seal, glut, splinters }

/// One compartment of an opened pouch: a seal, or Glut, or splinters.
class PouchReward {
  const PouchReward.seal(Seal this.seal)
    : kind = PouchRewardKind.seal,
      amount = 1;

  const PouchReward.glut(this.amount)
    : kind = PouchRewardKind.glut,
      seal = null;

  const PouchReward.splinters(this.amount)
    : kind = PouchRewardKind.splinters,
      seal = null;

  final PouchRewardKind kind;
  final Seal? seal;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is PouchReward &&
      other.kind == kind &&
      other.amount == amount &&
      other.seal?.code == seal?.code;

  @override
  int get hashCode => Object.hash(kind, amount, seal?.code);

  @override
  String toString() => switch (kind) {
    PouchRewardKind.seal => 'seal ${seal!.code}',
    PouchRewardKind.glut => 'glut $amount',
    PouchRewardKind.splinters => 'splinters $amount',
  };
}

/// What one extra compartment can hold, with its weight.
class PouchSlot {
  const PouchSlot.seal(this.level, this.weight)
    : kind = PouchRewardKind.seal,
      amount = 1;
  const PouchSlot.glut(this.amount, this.weight)
    : kind = PouchRewardKind.glut,
      level = 0;
  const PouchSlot.splinters(this.amount, this.weight)
    : kind = PouchRewardKind.splinters,
      level = 0;

  final PouchRewardKind kind;
  final int level;
  final int amount;
  final int weight;
}

/// The contents table of one colour: a Glut compartment that is always
/// there, then extra compartments rolled from [slots].
class PouchTable {
  const PouchTable({
    required this.glutMin,
    required this.glutMax,
    required this.glutMaxChance,
    required this.extraSlots,
    required this.thirdSlotChance,
    required this.slots,
  });

  /// Glut is [glutMax] with [glutMaxChance], else [glutMin].
  final int glutMin;
  final int glutMax;
  final double glutMaxChance;

  /// Extra compartments always rolled.
  final int extraSlots;

  /// Chance of one more extra compartment (never more than 3 in all).
  final double thirdSlotChance;
  final List<PouchSlot> slots;

  int get maxSeal => slots
      .where((s) => s.kind == PouchRewardKind.seal)
      .fold(0, (n, s) => max(n, s.level));

  int get totalWeight => slots.fold(0, (n, s) => n + s.weight);
}

/// One pouch on the leash.
class Pouch {
  const Pouch({
    required this.color,
    required this.foundAt,
    this.warmedM = 0,
    this.warmedAt,
  });

  final PouchColor color;
  final DateTime foundAt;

  /// Valid run distance walked since it was found.
  final double warmedM;

  /// Last run that warmed it; keeps it on the leash for another day.
  final DateTime? warmedAt;

  /// Warmed all the way: opens for free and no longer fades.
  bool get ready => warmedM >= color.walkM - 1e-6;

  double get warmShare => (warmedM / color.walkM).clamp(0.0, 1.0);

  /// LP to open it now: the price shrinks with the distance already walked.
  int get openLp => ready ? 0 : (color.openLp * (1 - warmShare)).ceil();

  /// When an unwarmed pouch falls off the leash.
  DateTime get fadesAt => (warmedAt ?? foundAt).add(Pouches.life);

  bool fadedBy(DateTime now) => !ready && !now.isBefore(fadesAt);

  Pouch warmed(double meters, DateTime at) => Pouch(
    color: color,
    foundAt: foundAt,
    warmedM: min(color.walkM, warmedM + meters),
    warmedAt: at,
  );

  Map<String, Object?> toJson() => {
    'color': color.name,
    'foundAt': foundAt.toIso8601String(),
    if (warmedM > 0) 'warmedM': warmedM,
    if (warmedAt case final d?) 'warmedAt': d.toIso8601String(),
  };

  static Pouch? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final color = PouchColor.tryParse(json['color']);
    final found = DateTime.tryParse(json['foundAt'] as String? ?? '');
    if (color == null || found == null) return null;
    final warmed = json['warmedM'];
    return Pouch(
      color: color,
      foundAt: found,
      warmedM: warmed is num ? warmed.toDouble().clamp(0, color.walkM) : 0,
      warmedAt: DateTime.tryParse(json['warmedAt'] as String? ?? ''),
    );
  }
}

/// Where a pouch came from. Messengers will bring pouches too (next step);
/// they use the same [GameData.hangingPouch] path.
enum PouchSource { run, messenger }

/// The pouch side of a save: the leash and lifetime counters.
class PouchState {
  const PouchState({
    this.leash = const [],
    this.found = const {},
    this.opened = const {},
    this.leashFills = 0,
    this.faded = 0,
  });

  /// Pouches hanging on the leash, oldest first.
  final List<Pouch> leash;

  /// Pouches found / opened per colour (lifetime).
  final Map<PouchColor, int> found;
  final Map<PouchColor, int> opened;

  /// Times all 4 clips held a pouch at once (Wanderweg #10).
  final int leashFills;

  /// Pouches that faded unopened after a day.
  final int faded;

  int foundOf(PouchColor c) => found[c] ?? 0;
  int openedOf(PouchColor c) => opened[c] ?? 0;
  int get foundTotal => found.values.fold(0, (n, v) => n + v);
  int get openedTotal => opened.values.fold(0, (n, v) => n + v);

  PouchState copyWith({
    List<Pouch>? leash,
    Map<PouchColor, int>? found,
    Map<PouchColor, int>? opened,
    int? leashFills,
    int? faded,
  }) => PouchState(
    leash: leash ?? this.leash,
    found: found ?? this.found,
    opened: opened ?? this.opened,
    leashFills: leashFills ?? this.leashFills,
    faded: faded ?? this.faded,
  );

  static Map<String, int> _counts(Map<PouchColor, int> m) => {
    for (final e in m.entries)
      if (e.value > 0) e.key.name: e.value,
  };

  static Map<PouchColor, int> _readCounts(Object? raw) => {
    if (raw is Map)
      for (final e in raw.entries)
        if ((PouchColor.tryParse(e.key), e.value) case (
          final c?,
          final int n,
        ) when n > 0)
          c: n,
  };

  Map<String, Object?> toJson() => {
    'leash': [for (final p in leash) p.toJson()],
    'found': _counts(found),
    'opened': _counts(opened),
    'leashFills': leashFills,
    'faded': faded,
  };

  /// Unknown pouches are dropped (an import checks them first, see
  /// [problems]).
  factory PouchState.fromJson(Map<String, Object?> json) {
    int read(String k) => max(0, json[k] as int? ?? 0);
    final raw = json['leash'];
    return PouchState(
      leash: [
        if (raw is List)
          for (final p in raw)
            if (Pouch.tryFromJson(p) case final pouch?) pouch,
      ].take(Pouches.maxClips).toList(),
      found: _readCounts(json['found']),
      opened: _readCounts(json['opened']),
      leashFills: read('leashFills'),
      faded: read('faded'),
    );
  }

  /// True when [json] holds anything this version can't read.
  static bool problems(Object? json) {
    if (json is! Map<String, Object?>) return true;
    final raw = json['leash'];
    if (raw == null) return false;
    if (raw is! List || raw.length > Pouches.maxClips) return true;
    return raw.any((p) => Pouch.tryFromJson(p) == null);
  }
}

/// Pouch rules. Numbers are start values from the progression plan, kept
/// deliberately uneven.
class Pouches {
  /// An unwarmed pouch stays on the leash this long after it was found or
  /// last warmed.
  static const Duration life = Duration(hours: 24);

  static const int maxClips = 4;

  /// Chance of a pouch after a run that used a full Breath tank. A run
  /// counts at most one full tank: less Breath, smaller chance.
  static const double fullTankChance = 0.43;

  /// Find chance of a run: [fullTankChance] times the share of one tank
  /// used, times the Fortune factor; never above 100 %.
  static double chance({
    required double breathUsed,
    required int tankSize,
    double fortuneFactor = 1,
  }) {
    if (breathUsed <= 0 || tankSize <= 0) return 0;
    final share = min(1.0, breathUsed / tankSize);
    return min(1.0, fullTankChance * share * fortuneFactor);
  }

  static const Map<PouchColor, PouchTable> tables = {
    PouchColor.brown: PouchTable(
      glutMin: 1,
      glutMax: 2,
      glutMaxChance: .31,
      extraSlots: 1,
      thirdSlotChance: 0,
      slots: [PouchSlot.seal(1, 71), PouchSlot.splinters(2, 29)],
    ),
    PouchColor.copper: PouchTable(
      glutMin: 2,
      glutMax: 2,
      glutMaxChance: 0,
      extraSlots: 1,
      thirdSlotChance: .37,
      slots: [
        PouchSlot.seal(1, 43),
        PouchSlot.seal(2, 17),
        PouchSlot.glut(2, 23),
        PouchSlot.splinters(2, 17),
      ],
    ),
    PouchColor.turquoise: PouchTable(
      glutMin: 2,
      glutMax: 3,
      glutMaxChance: .43,
      extraSlots: 2,
      thirdSlotChance: 0,
      slots: [
        PouchSlot.seal(1, 31),
        PouchSlot.seal(2, 37),
        PouchSlot.glut(2, 13),
        PouchSlot.splinters(3, 19),
      ],
    ),
    PouchColor.navy: PouchTable(
      glutMin: 3,
      glutMax: 3,
      glutMaxChance: 0,
      extraSlots: 2,
      thirdSlotChance: 0,
      slots: [
        PouchSlot.seal(1, 19),
        PouchSlot.seal(2, 38),
        PouchSlot.seal(3, 23),
        PouchSlot.glut(3, 9),
        PouchSlot.splinters(3, 11),
      ],
    ),
  };

  /// Most Fortune can tilt the colours: the bonus above ×1 counts up to
  /// this much (+47 %), however many Fortune seals are set.
  static const double fortuneColorCap = .47;

  /// Find weight of [c] with [fortuneFactor]: the base weight times
  /// (1 + Fortune bonus, capped) to the power of the colour's rank, so
  /// copper gains once, turquoise twice and navy three times.
  static double colorWeight(PouchColor c, double fortuneFactor) {
    final bonus = (fortuneFactor - 1).clamp(0.0, fortuneColorCap);
    return c.findWeight * pow(1 + bonus, c.index).toDouble();
  }

  /// Share of each of [unlocked] among finds with [fortuneFactor]
  /// (once every colour was found at least once).
  static Map<PouchColor, double> colorShares(
    List<PouchColor> unlocked,
    double fortuneFactor,
  ) {
    final total = unlocked.fold(
      0.0,
      (n, c) => n + colorWeight(c, fortuneFactor),
    );
    return {for (final c in unlocked) c: colorWeight(c, fortuneFactor) / total};
  }

  /// Colour of a found pouch among [unlocked] (lowest first). A colour
  /// never found before comes first, so every Wanderweg pouch task can be
  /// done with the next find; otherwise colours go by [colorWeight], where
  /// Fortune tilts them toward the rarer ones.
  static PouchColor pickColor(
    List<PouchColor> unlocked,
    Map<PouchColor, int> found,
    Random random, {
    double fortuneFactor = 1,
  }) {
    for (final c in unlocked) {
      if ((found[c] ?? 0) == 0) return c;
    }
    final total = unlocked.fold(
      0.0,
      (n, c) => n + colorWeight(c, fortuneFactor),
    );
    var roll = random.nextDouble() * total;
    for (final c in unlocked) {
      roll -= colorWeight(c, fortuneFactor);
      if (roll < 0) return c;
    }
    return unlocked.last;
  }

  /// Rolls the contents of a [color] pouch: Glut first, then 1–2 extra
  /// compartments. Seals are L1–L3 only, of a random stat.
  static List<PouchReward> roll(PouchColor color, Random random) {
    final t = tables[color]!;
    final glut = random.nextDouble() < t.glutMaxChance ? t.glutMax : t.glutMin;
    final extra =
        t.extraSlots + (random.nextDouble() < t.thirdSlotChance ? 1 : 0);
    return [
      PouchReward.glut(glut),
      for (var i = 0; i < extra; i++) _slot(t, random),
    ];
  }

  static PouchReward _slot(PouchTable t, Random random) {
    var roll = random.nextInt(t.totalWeight);
    for (final s in t.slots) {
      roll -= s.weight;
      if (roll < 0) {
        return switch (s.kind) {
          PouchRewardKind.seal => PouchReward.seal(
            Seal(
              SealType.values[random.nextInt(SealType.values.length)],
              s.level,
            ),
          ),
          PouchRewardKind.glut => PouchReward.glut(s.amount),
          PouchRewardKind.splinters => PouchReward.splinters(s.amount),
        };
      }
    }
    throw StateError('weights');
  }
}
