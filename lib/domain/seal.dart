/// The stat a seal raises. Saved by [name] inside a seal code.
enum SealType { stride, grit, fortune }

/// What a recipe seal does on top of its stats, see [Recipe].
enum RecipeEffect {
  /// Sweet spot wider on each side, in km/h.
  sweetSpotWidth,

  /// Pouch chance in percent points, on runs of at least
  /// [Recipe.pouchMinDistanceM].
  pouchChance,

  /// Fail chance in the forge in percent points less; a fail gives one
  /// splinter more.
  failCut,

  /// Messenger chance after a run in percent points.
  messengerChance,

  /// Pouches warm up faster, as a share (0.12 = 12 % faster).
  pouchWarmth,

  /// Chance of one extra Glut after a valid run of at least 1 km, at most
  /// once a day.
  glutChance,
}

/// The Schmiede-Baum: every pair of two different stats is a level-1
/// recipe; forging a level-1 recipe seal with a single seal of the third
/// stat makes its level-2 recipe.
///
/// A recipe works only while its seal is set into the companion taken
/// along. The same recipe twice does not stack: the highest level counts.
enum Recipe {
  ausdauer(SealType.stride, SealType.grit, RecipeEffect.sweetSpotWidth, [
    0.2,
    0.3,
    0.4,
    0.6,
    0.8,
  ]),
  faehrte(SealType.stride, SealType.fortune, RecipeEffect.pouchChance, [
    0.02,
    0.03,
    0.05,
    0.07,
    0.09,
  ]),
  schutz(SealType.grit, SealType.fortune, RecipeEffect.failCut, [
    0.02,
    0.03,
    0.04,
    0.06,
    0.08,
  ]),
  wanderstern(
    SealType.stride,
    SealType.grit,
    RecipeEffect.messengerChance,
    [0.03, 0.05, 0.07, 0.09, 0.12],
    extra: SealType.fortune,
  ),
  spurenleser(SealType.stride, SealType.fortune, RecipeEffect.pouchWarmth, [
    0.08,
    0.12,
    0.16,
    0.20,
    0.25,
  ], extra: SealType.grit),
  glutherz(SealType.grit, SealType.fortune, RecipeEffect.glutChance, [
    0.15,
    0.20,
    0.25,
    0.30,
    0.40,
  ], extra: SealType.stride);

  const Recipe(this.a, this.b, this.effect, this.steps, {this.extra});

  /// The two stats of the level-1 recipe (enum order).
  final SealType a;
  final SealType b;

  /// Third stat of a level-2 recipe, null on level 1.
  final SealType? extra;
  final RecipeEffect effect;

  /// Effect size per level (index 0 = L1), see [RecipeEffect].
  final List<double> steps;

  /// [Recipe.faehrte] only helps on runs this long.
  static const double pouchMinDistanceM = 3000;

  /// Extra splinters a fail gives with [Recipe.schutz] set.
  static const int schutzSplinters = 1;

  /// 1 for the pair recipes, 2 for the triples.
  int get tier => extra == null ? 1 : 2;

  /// The level-1 recipe a level-2 recipe grows from; itself on level 1.
  Recipe get base => switch (this) {
    wanderstern => ausdauer,
    spurenleser => faehrte,
    glutherz => schutz,
    _ => this,
  };

  /// The level-2 recipe that grows from this level-1 recipe.
  Recipe? get next => switch (this) {
    ausdauer => wanderstern,
    faehrte => spurenleser,
    schutz => glutherz,
    _ => null,
  };

  static List<Recipe> get firstTier =>
      values.where((r) => r.tier == 1).toList();

  /// Effect at [level] (1–5), 0 for level 0.
  double at(int level) => level < 1 ? 0 : steps[level.clamp(1, 5) - 1];

  /// The level-1 recipe of two different stats.
  static Recipe pairOf(SealType x, SealType y) {
    final lo = x.index < y.index ? x : y;
    final hi = x.index < y.index ? y : x;
    return firstTier.firstWhere((r) => r.a == lo && r.b == hi);
  }

  /// The level-2 recipe whose third stat is [extra].
  static Recipe tripleOf(SealType extra) =>
      values.firstWhere((r) => r.extra == extra);
}

/// One seal: a single stat at level 1–5, a recipe seal of two different
/// stats, or a level-2 recipe seal of all three, also at level 1–5.
///
/// Saved as a short code: `stride@3`, `stride+grit@5` (lead stat first) or
/// `stride+grit+fortune@2` (lead, second, then the stat that grew the
/// level-2 recipe). Saves from before seal levels hold just `stride`; those
/// read as [legacyLevel]. Combined seals from before the Schmiede-Baum were
/// saved in enum order and read as recipe seals led by the first stat.
class Seal {
  const Seal(this.type, this.level) : partner = null, extra = null;

  const Seal._(this.type, this.partner, this.extra, this.level);

  /// A level-1 recipe seal; [lead] gets the larger share (about 60 %).
  factory Seal.combined(SealType lead, SealType second, int level) {
    if (lead == second) throw ArgumentError('combined seals need two stats');
    if (!combinedLevels.contains(level)) {
      throw RangeError.value(level, 'level', 'combined seals are L1–L5');
    }
    return Seal._(lead, second, null, level);
  }

  /// A level-2 recipe seal: a recipe seal ([lead], [second]) forged with
  /// a single seal of [extra].
  factory Seal.triple(
    SealType lead,
    SealType second,
    SealType extra,
    int level,
  ) {
    if ({lead, second, extra}.length != 3) {
      throw ArgumentError('level-2 recipe seals need three stats');
    }
    if (!combinedLevels.contains(level)) {
      throw RangeError.value(level, 'level', 'recipe seals are L1–L5');
    }
    return Seal._(lead, second, extra, level);
  }

  static const int maxLevel = 5;

  /// Bonus of a single seal per level (index 0 = L1).
  static const List<double> singleBonus = [0.04, 0.09, 0.15, 0.22, 0.31];

  /// Recipe seal: bonus on the lead stat (about 60 % of the pair) and on
  /// the second (about 40 %). Together as much as the old combined seal.
  static const List<double> pairLead = [0.03, 0.07, 0.11, 0.16, 0.23];
  static const List<double> pairSecond = [0.02, 0.04, 0.07, 0.10, 0.15];

  /// Level-2 recipe seal: lead, second and third stat.
  static const List<double> tripleLead = [0.02, 0.05, 0.08, 0.12, 0.17];
  static const List<double> tripleSecond = [0.02, 0.04, 0.06, 0.09, 0.13];
  static const List<double> tripleExtra = [0.02, 0.04, 0.06, 0.08, 0.12];

  static Iterable<int> get combinedLevels => const [1, 2, 3, 4, 5];

  /// What a bare `stride` / `grit` / `fortune` from an older save becomes.
  /// Those seals gave a flat +1 (+10 % on a Common); L2 (+9 %) is the
  /// closest level, so no player loses strength by the update.
  static const int legacyLevel = 2;

  /// Lead stat (the only one of a single seal).
  final SealType type;

  /// Second stat of a recipe seal, else null.
  final SealType? partner;

  /// Third stat of a level-2 recipe seal, else null.
  final SealType? extra;
  final int level;

  /// Two or three stats (a recipe seal).
  bool get combined => partner != null;

  /// A level-2 recipe seal (three stats).
  bool get isTriple => extra != null;

  /// The recipe this seal carries, null for a single seal.
  Recipe? get recipe => partner == null
      ? null
      : extra == null
      ? Recipe.pairOf(type, partner!)
      : Recipe.tripleOf(extra!);

  /// The stats this seal raises.
  List<SealType> get stats => [type, ?partner, ?extra];

  /// Bonus on [stat] as a fraction (0.15 = +15 %), 0 when it doesn't touch it.
  double bonusOn(SealType stat) {
    final i = level - 1;
    if (!combined) return stat == type ? singleBonus[i] : 0;
    if (isTriple) {
      if (stat == type) return tripleLead[i];
      if (stat == partner) return tripleSecond[i];
      return tripleExtra[i];
    }
    if (stat == type) return pairLead[i];
    if (stat == partner) return pairSecond[i];
    return 0;
  }

  /// Bonus on the lead stat.
  double get bonus => bonusOn(type);

  String get code => switch ((partner, extra)) {
    (null, _) => '${type.name}@$level',
    (final p?, null) => '${type.name}+${p.name}@$level',
    (final p?, final e?) => '${type.name}+${p.name}+${e.name}@$level',
  };

  /// Painted art, sized so higher levels look bigger. Recipe seals have
  /// art for L3 and L5; L1–L2 use the L3 art and L4 the L5 art, drawn
  /// smaller by [artScale].
  String get asset => combined
      ? 'assets/seals/seal_combo_l${level <= 3 ? 3 : 5}.webp'
      : 'assets/seals/seal_${type.name}_l$level.webp';

  /// How large [asset] is drawn (1 = full size).
  double get artScale => !combined
      ? 1
      : switch (level) {
          1 => 0.7,
          2 => 0.85,
          4 => 0.88,
          _ => 1,
        };

  Seal? get nextLevel =>
      combined || level >= maxLevel ? null : Seal(type, level + 1);

  /// Reads a seal code; null when it is not a seal this version knows.
  static Seal? tryParse(String? code) {
    if (code == null) return null;
    final names = SealType.values.asNameMap();
    if (names[code] case final t?) return Seal(t, legacyLevel);
    final at = code.split('@');
    if (at.length != 2) return null;
    final level = int.tryParse(at[1]);
    if (level == null || at[1] != '$level') return null;
    if (level < 1 || level > maxLevel) return null;
    final parts = at[0].split('+');
    final types = [for (final p in parts) names[p]];
    if (types.contains(null) || types.toSet().length != types.length) {
      return null;
    }
    return switch (types) {
      [final a?] => Seal(a, level),
      [final a?, final b?] => Seal._(a, b, null, level),
      [final a?, final b?, final c?] => Seal._(a, b, c, level),
      _ => null,
    };
  }

  /// [code] in its current form (older bare names get their level).
  static String? normalize(String? code) => tryParse(code)?.code ?? code;

  @override
  bool operator ==(Object other) =>
      other is Seal &&
      other.type == type &&
      other.partner == partner &&
      other.extra == extra &&
      other.level == level;

  @override
  int get hashCode => Object.hash(type, partner, extra, level);

  @override
  String toString() => 'Seal($code)';
}
