import 'dart:math';

import '../data/companion_art.dart';
import '../data/companion_cutouts.dart';
import '../data/species.dart';
import 'seal.dart';
import 'world.dart';

export 'seal.dart' show Recipe, RecipeEffect, Seal, SealType;

/// A companion's gait: the pace it earns LP at. Shown as Schritt / Trab /
/// Galopp (EN Stroll / Trot / Gallop). The enum names are save ids from
/// when the gaits were elements and never change.
enum CompanionType {
  moss(sweetSpotKmh: 4.5, rangeKmh: 2.5),
  brook(sweetSpotKmh: 7.5, rangeKmh: 2.5),
  gale(sweetSpotKmh: 11, rangeKmh: 4);

  const CompanionType({required this.sweetSpotKmh, required this.rangeKmh});

  final double sweetSpotKmh;
  final double rangeKmh;

  /// Reads a saved gait; null when missing or unknown.
  static CompanionType? tryParse(Object? name) {
    for (final t in values) {
      if (t.name == name) return t;
    }
    return null;
  }
}

enum Rarity {
  common(
    code: 'c',
    tankSize: 6,
    lpPerBreath: 2.5,
    charmSlots: 1,
    baseStat: 10,
    spiritPerBreath: 1.0,
    levelCostFactor: 5,
  ),
  rare(
    code: 'r',
    tankSize: 8,
    lpPerBreath: 4.0,
    charmSlots: 2,
    baseStat: 14,
    spiritPerBreath: 1.2,
    levelCostFactor: 10,
  ),
  epic(
    code: 'e',
    tankSize: 10,
    lpPerBreath: 7.0,
    charmSlots: 2,
    baseStat: 20,
    spiritPerBreath: 1.5,
    levelCostFactor: 20,
  ),
  legendary(
    code: 'l',
    tankSize: 12,
    lpPerBreath: 12.0,
    charmSlots: 3,
    baseStat: 28,
    spiritPerBreath: 2.0,
    levelCostFactor: 40,
  );

  const Rarity({
    required this.code,
    required this.tankSize,
    required this.lpPerBreath,
    required this.charmSlots,
    required this.baseStat,
    required this.spiritPerBreath,
    required this.levelCostFactor,
  });

  /// Mut (in percent points) a companion of this rarity loses per Breath
  /// point used, before Grit.
  final double spiritPerBreath;

  /// LP to level up from level n is this times n.
  final int levelCostFactor;

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

/// Fortune at which [Companion.fortuneFactor] is ×1 (a Common's base).
const double fortuneReference = 10;

/// Highest [Companion.fortuneFactor].
const double maxFortuneFactor = 2.0;

/// XP a companion needs to go from [level] to the next: 6 per level, so
/// Lv 1→2 takes 6 XP (1.5 km in the sweet spot), Lv 24→25 takes 144.
int xpForLevel(int level) => 6 * level;

/// XP per Breath point used on a run (one point = 250 m in the sweet spot).
const int xpPerBreath = 1;

/// Levels at which the companion's tank holds one more Breath point: two
/// in all by [maxLevel], so a 6-point Common ends at 8.
const List<int> tankLevels = [10, 25];

/// Extra tank points a companion at [level] has.
int tankBonusAt(int level) => tankLevels.where((l) => level >= l).length;

/// The next level that adds a tank point, null after the last one.
int? nextTankLevel(int level) => tankLevels.where((l) => l > level).firstOrNull;

/// Lowest Mut at which a seal can be set into a companion.
const double sealSpiritMin = 50;

/// Below this Mut the companion asks for a salve.
const double lowSpirit = 30;

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
    this.xp = 0,
    CompanionType? tempo,
  }) : _tempo = tempo;

  /// The starter species with the flat Common base stats (10/10/10).
  factory Companion.pebble() => Companion.fresh(
    id: 'pebble-1',
    speciesId: 'pebble',
    rarity: Rarity.common,
  );

  /// Stride, Grit and Fortune of the starter on a new save: uneven and
  /// from the bottom of the Common roll (9.2–10.8), so most Commons in the
  /// market roll better and collecting pays off right away.
  static const starterStats = (stride: 9.2, grit: 9.4, fortune: 9.3);

  /// The starter every new player is given (see [starterStats]). Saves
  /// that already exist keep their companions as stored.
  factory Companion.starter() => Companion.pebble().copyWith(
    stride: starterStats.stride,
    grit: starterStats.grit,
    fortune: starterStats.fortune,
  );

  /// A level 1 companion with the unrolled base stats of its rarity.
  factory Companion.fresh({
    required String id,
    required String speciesId,
    required Rarity rarity,
    CompanionType? tempo,
  }) => Companion(
    id: id,
    speciesId: speciesId,
    rarity: rarity,
    tempo: tempo,
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
    CompanionType? tempo,
  }) {
    double roll() => _roundStat(
      rarity.baseStat * (1 - statRoll + 2 * statRoll * random.nextDouble()),
    );
    return Companion.fresh(
      id: id,
      speciesId: speciesId,
      rarity: rarity,
      tempo: tempo,
    ).copyWith(stride: roll(), grit: roll(), fortune: roll());
  }

  final String id;
  final String speciesId;
  final Rarity rarity;
  final int level;

  /// XP collected towards the next level (walking only). Kept when the
  /// level-up is not paid yet; the rest carries over after a level-up.
  final int xp;

  final CompanionType? _tempo;
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

  /// This instance's gait. Market offers roll their own (see
  /// `Market.rolled`); every other companion keeps its species' home gait.
  CompanionType get tempo => _tempo ?? species.type;

  /// The gait that sets the sweet spot; same as [tempo].
  CompanionType get type => tempo;

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

  /// Level of [recipe] in the sockets (the highest seal counts, the same
  /// recipe twice does not stack); 0 when it is not set.
  int recipeLevel(Recipe recipe) => seals
      .where((s) => s.recipe == recipe)
      .fold(0, (best, s) => max(best, s.level));

  /// Effect of [recipe] from the sockets, 0 when it is not set. Only the
  /// companion taken along counts; callers check that.
  double recipeEffect(Recipe recipe) => recipe.at(recipeLevel(recipe));

  /// The recipes set into this companion with their level.
  Map<Recipe, int> get recipes => {
    for (final r in Recipe.values)
      if (recipeLevel(r) case final lv when lv > 0) r: lv,
  };

  /// Sweet spot wider on each side by this (km/h), from [Recipe.ausdauer].
  double get sweetSpotWidenKmh => recipeEffect(Recipe.ausdauer);

  /// First empty charm socket, or null when all are filled.
  int? get freeSocket {
    final i = charms.indexOf(null);
    return i < 0 ? null : i;
  }

  double get strideTotal => stride * (1 + sealBonus(SealType.stride));

  double get gritTotal => grit * (1 + sealBonus(SealType.grit));

  double get fortuneTotal => fortune * (1 + sealBonus(SealType.fortune));

  /// Grit: Mut loss is scaled by the rarity base over [gritTotal] (roll
  /// plus seals). A base roll with full Grit seals (+47 %) loses about
  /// 32 % less; a low roll a little more.
  double get spiritLossFactor => rarity.baseStat / gritTotal;

  /// Mut (percent points) this companion loses for [breathUsed] Breath
  /// points used in the sweet spot, rounded to 0.1.
  double spiritLossFor(double breathUsed) => breathUsed <= 0
      ? 0
      : ((breathUsed * rarity.spiritPerBreath * spiritLossFactor) * 10)
                .roundToDouble() /
            10;

  /// Mut lost per Breath point with this companion's Grit.
  double get spiritPerBreath => rarity.spiritPerBreath * spiritLossFactor;

  /// XP for the next level, null at [maxLevel].
  int? get xpToNext => level >= maxLevel ? null : xpForLevel(level);

  /// True when enough XP is collected for the next level (LP still due).
  bool get xpReady => xpToNext != null && xp >= xpToNext!;

  /// LP the next level-up costs; null at [maxLevel].
  double? get levelUpCost =>
      level >= maxLevel ? null : (rarity.levelCostFactor * level).toDouble();

  /// One level up: XP for it is used, the rest carries over. Check
  /// [xpReady] first.
  Companion leveledUp() => Companion(
    id: id,
    speciesId: speciesId,
    rarity: rarity,
    tempo: _tempo,
    level: level + 1,
    xp: level + 1 >= maxLevel ? 0 : xp - xpForLevel(level),
    stride: stride,
    grit: grit,
    fortune: fortune,
    spirit: spirit,
    charms: charms,
  );

  /// After a valid run that used [breathUsed] Breath points in the sweet
  /// spot: Mut drops (Grit softens it, never below 0) and XP grows.
  Companion afterRun(double breathUsed) {
    if (breathUsed <= 0) return this;
    final gained = (breathUsed * xpPerBreath).round();
    return copyWith(
      spirit: max(0, ((spirit - spiritLossFor(breathUsed)) * 10).round() / 10),
      xp: level >= maxLevel ? 0 : xp + gained,
    );
  }

  /// Mut after a salve that adds [points] (never above 100).
  Companion healed(double points) =>
      copyWith(spirit: min(100, spirit + points));

  /// Extra tank points from levels: one at each of [tankLevels].
  int get tankBonus => tankBonusAt(level);

  /// Fortune: pouch and messenger chances after a run are multiplied by
  /// this (never above 100 %), and the pouch colour (which also picks the
  /// messenger) leans to the rarer ones.
  ///
  /// factor = √(Fortune / [fortuneReference]) × (1 + Fortune seals),
  /// at most [maxFortuneFactor]. The rolled base counts with a square root,
  /// so a Common at 10 is ×1, its ±8 % roll gives about ±4 %
  /// (9.2 → ×0.96, 10.8 → ×1.04), a Rare at 14 ×1.18, an Epic at 20 ×1.41;
  /// seals multiply on top (+47 % at most).
  double get fortuneFactor => min(
    maxFortuneFactor,
    sqrt(max(0.0, fortune) / fortuneReference) *
        (1 + sealBonus(SealType.fortune)),
  );

  /// Breath cap while this companion is taken along: the rarity's tank
  /// plus one point at each of [tankLevels].
  int get tankSize => rarity.tankSize + tankBonus;

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
    CompanionType? tempo,
    int? level,
    int? xp,
  }) => Companion(
    id: id,
    speciesId: speciesId,
    rarity: rarity,
    tempo: tempo ?? _tempo,
    level: level ?? this.level,
    xp: xp ?? this.xp,
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
    if (_tempo ?? speciesById[speciesId]?.type case final t?) 'tempo': t.name,
    'level': level,
    if (xp > 0) 'xp': xp,
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
      // Missing (saves before version 6) or unknown: the species' home gait.
      tempo: CompanionType.tryParse(json['tempo']),
      level: (json['level']! as int).clamp(1, maxLevel),
      // Saves before version 8 have no XP.
      xp: max(0, (json['xp'] as num?)?.toInt() ?? 0),
      stride: _savedStat(json['stride'], rarity),
      grit: _savedStat(json['grit'], rarity),
      fortune: _savedStat(json['fortune'], rarity),
      spirit: (json['spirit']! as num).toDouble().clamp(0.0, 100.0),
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
