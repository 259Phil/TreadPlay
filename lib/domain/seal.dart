/// The stat a seal raises. Saved by [name] inside a seal code.
enum SealType { stride, grit, fortune }

/// One seal: a single stat at level 1–5, or a combined seal that raises two
/// different stats at level 3 or 5.
///
/// Saved as a short code: `stride@3` or `stride+grit@5` (stats in enum
/// order). Saves from before seal levels hold just `stride`; those read as
/// [legacyLevel].
class Seal {
  const Seal(this.type, this.level) : partner = null;

  const Seal._(this.type, this.partner, this.level);

  /// A combined seal of two different stats; order does not matter.
  factory Seal.combined(SealType a, SealType b, int level) {
    if (a == b) throw ArgumentError('combined seals need two stats');
    if (!combinedLevels.contains(level)) {
      throw RangeError.value(level, 'level', 'combined seals are L3 or L5');
    }
    return a.index < b.index ? Seal._(a, b, level) : Seal._(b, a, level);
  }

  static const int maxLevel = 5;

  /// Bonus of a single seal per level (index 0 = L1).
  static const List<double> singleBonus = [0.04, 0.09, 0.15, 0.22, 0.31];

  /// Bonus a combined seal gives to each of its two stats.
  static const Map<int, double> combinedBonus = {3: 0.09, 5: 0.19};

  static Iterable<int> get combinedLevels => combinedBonus.keys;

  /// What a bare `stride` / `grit` / `fortune` from an older save becomes.
  /// Those seals gave a flat +1 (+10 % on a Common); L2 (+9 %) is the
  /// closest level, so no player loses strength by the update.
  static const int legacyLevel = 2;

  final SealType type;

  /// Second stat of a combined seal, else null.
  final SealType? partner;
  final int level;

  bool get combined => partner != null;

  /// The stats this seal raises.
  List<SealType> get stats => [type, ?partner];

  /// Bonus on [stat] as a fraction (0.15 = +15 %), 0 when it doesn't touch it.
  double bonusOn(SealType stat) {
    if (stat != type && stat != partner) return 0;
    return combined ? combinedBonus[level]! : singleBonus[level - 1];
  }

  /// Bonus on each stat it raises.
  double get bonus => bonusOn(type);

  String get code =>
      combined ? '${type.name}+${partner!.name}@$level' : '${type.name}@$level';

  /// Painted art, sized so higher levels look bigger.
  String get asset => combined
      ? 'assets/seals/seal_combo_l$level.webp'
      : 'assets/seals/seal_${type.name}_l$level.webp';

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
    final parts = at[0].split('+');
    if (parts.length == 1) {
      final t = names[parts[0]];
      if (t == null || level < 1 || level > maxLevel) return null;
      return Seal(t, level);
    }
    if (parts.length != 2) return null;
    final a = names[parts[0]];
    final b = names[parts[1]];
    if (a == null || b == null || a == b || a.index > b.index) return null;
    if (!combinedLevels.contains(level)) return null;
    return Seal._(a, b, level);
  }

  /// [code] in its current form (older bare names get their level).
  static String? normalize(String? code) => tryParse(code)?.code ?? code;

  @override
  bool operator ==(Object other) =>
      other is Seal &&
      other.type == type &&
      other.partner == partner &&
      other.level == level;

  @override
  int get hashCode => Object.hash(type, partner, level);

  @override
  String toString() => 'Seal($code)';
}
