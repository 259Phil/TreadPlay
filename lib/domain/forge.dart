import 'dart:math';

import 'seal.dart';

/// One forge recipe: LP and Glut it takes and how often it fails.
class ForgeStep {
  const ForgeStep({
    required this.lp,
    required this.minGlut,
    required this.maxGlut,
    required this.failAtMin,
    required this.failAtMax,
  });

  final int lp;
  final int minGlut;
  final int maxGlut;

  /// Fail chance (0–1) with [minGlut] and with [maxGlut].
  final double failAtMin;
  final double failAtMax;

  /// Every Glut above the minimum lowers the fail chance by the same step,
  /// from [failAtMin] down to [failAtMax].
  double failChance(int glut) {
    final g = glut.clamp(minGlut, maxGlut);
    if (maxGlut == minGlut) return failAtMin;
    final t = (g - minGlut) / (maxGlut - minGlut);
    return failAtMin + (failAtMax - failAtMin) * t;
  }

  bool allows(int glut) => glut >= minGlut && glut <= maxGlut;
}

/// Seal prices, recipes and limits (progression plan, section 3).
class Forge {
  /// LP for a new seal L1 of any stat.
  static const int sealCost = 37;

  /// Forging up: two equal seals of level n (the key) make one of n+1.
  static const Map<int, ForgeStep> upgrades = {
    1: ForgeStep(
      lp: 13,
      minGlut: 1,
      maxGlut: 5,
      failAtMin: .12,
      failAtMax: .03,
    ),
    2: ForgeStep(
      lp: 34,
      minGlut: 1,
      maxGlut: 5,
      failAtMin: .21,
      failAtMax: .07,
    ),
    3: ForgeStep(
      lp: 79,
      minGlut: 2,
      maxGlut: 5,
      failAtMin: .29,
      failAtMax: .14,
    ),
    4: ForgeStep(
      lp: 167,
      minGlut: 3,
      maxGlut: 5,
      failAtMin: .38,
      failAtMax: .23,
    ),
  };

  /// Combining: two single seals of different stats at level n (the key)
  /// make one combined seal of level n. St.1 is cheap so new players can
  /// try it; L3 and L5 keep their earlier recipes.
  static const Map<int, ForgeStep> combines = {
    1: ForgeStep(
      lp: 15,
      minGlut: 1,
      maxGlut: 3,
      failAtMin: .10,
      failAtMax: .04,
    ),
    2: ForgeStep(
      lp: 40,
      minGlut: 2,
      maxGlut: 4,
      failAtMin: .14,
      failAtMax: .07,
    ),
    3: ForgeStep(
      lp: 97,
      minGlut: 4,
      maxGlut: 5,
      failAtMin: .17,
      failAtMax: .11,
    ),
    4: ForgeStep(
      lp: 150,
      minGlut: 4,
      maxGlut: 5,
      failAtMin: .22,
      failAtMax: .16,
    ),
    5: ForgeStep(
      lp: 233,
      minGlut: 5,
      maxGlut: 5,
      failAtMin: .27,
      failAtMax: .27,
    ),
  };

  /// A failed forge turns one input seal into this many splinters.
  static const int splintersOnFail = 3;

  /// Splinters that melt into one new seal L1.
  static const int splintersPerSeal = 5;

  /// Pouches are the Glut source. A valid run of at least this many metres
  /// that finds no pouch still brings [glutPerRun] Glut once the Forge is
  /// open (the plan's small per-run drop), so no run ends empty.
  static const double glutRunMinM = 1000;
  static const int glutPerRun = 1;

  /// True when the fail roll hits. One [Random.nextDouble] per attempt, so
  /// a seeded [Random] gives the same results every time.
  static bool rollsFail(double chance, Random random) =>
      random.nextDouble() < chance;
}

enum ForgeResult { success, failed }

/// What a forge attempt did.
class ForgeOutcome {
  const ForgeOutcome.success(Seal this.made)
    : result = ForgeResult.success,
      broken = null;

  const ForgeOutcome.failed(Seal this.broken)
    : result = ForgeResult.failed,
      made = null;

  final ForgeResult result;

  /// The new seal on success.
  final Seal? made;

  /// The input seal that fell to splinters on a fail.
  final Seal? broken;

  bool get success => result == ForgeResult.success;
}

/// The Forge side of a save: loose seals in the seal case, Glut, splinters
/// and lifetime counters the Wanderweg reads.
class ForgeState {
  const ForgeState({
    this.stock = const {},
    this.glut = 0,
    this.splinters = 0,
    this.placed = 0,
    this.combines = 0,
    this.bestLevel = 0,
    this.attempts = 0,
    this.fails = 0,
  });

  /// Seal code → count of loose seals (not set into a companion).
  final Map<String, int> stock;
  final int glut;
  final int splinters;

  /// Seals set into a companion (lifetime).
  final int placed;

  /// Successful combines (lifetime).
  final int combines;

  /// Highest seal level ever held (single or combined).
  final int bestLevel;

  /// Forge-up and combine attempts, and how many of them failed (lifetime).
  final int attempts;
  final int fails;

  int count(Seal s) => stock[s.code] ?? 0;

  /// Loose seals, highest level first, then by stat.
  List<(Seal, int)> get sealsInStock {
    final list = [
      for (final e in stock.entries)
        if (Seal.tryParse(e.key) case final s? when e.value > 0) (s, e.value),
    ];
    list.sort((a, b) {
      final byLevel = b.$1.level.compareTo(a.$1.level);
      if (byLevel != 0) return byLevel;
      final byCombo = (a.$1.combined ? 1 : 0).compareTo(b.$1.combined ? 1 : 0);
      if (byCombo != 0) return byCombo;
      return a.$1.code.compareTo(b.$1.code);
    });
    return list;
  }

  int get looseSeals => stock.values.fold(0, (n, v) => n + v);

  ForgeState adding(Seal s, [int n = 1]) {
    final next = {...stock};
    final v = (next[s.code] ?? 0) + n;
    if (v <= 0) {
      next.remove(s.code);
    } else {
      next[s.code] = v;
    }
    return copyWith(
      stock: next,
      bestLevel: n > 0 && s.level > bestLevel ? s.level : bestLevel,
    );
  }

  ForgeState removing(Seal s, [int n = 1]) => adding(s, -n);

  ForgeState copyWith({
    Map<String, int>? stock,
    int? glut,
    int? splinters,
    int? placed,
    int? combines,
    int? bestLevel,
    int? attempts,
    int? fails,
  }) => ForgeState(
    stock: stock ?? this.stock,
    glut: glut ?? this.glut,
    splinters: splinters ?? this.splinters,
    placed: placed ?? this.placed,
    combines: combines ?? this.combines,
    bestLevel: bestLevel ?? this.bestLevel,
    attempts: attempts ?? this.attempts,
    fails: fails ?? this.fails,
  );

  Map<String, Object?> toJson() => {
    'stock': stock,
    'glut': glut,
    'splinters': splinters,
    'placed': placed,
    'combines': combines,
    'bestLevel': bestLevel,
    'attempts': attempts,
    'fails': fails,
  };

  /// Unknown seal codes are dropped (an import checks them first, see
  /// [unknownCodes]).
  factory ForgeState.fromJson(Map<String, Object?> json) {
    final raw = json['stock'];
    final stock = <String, int>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        final s = Seal.tryParse(e.key as String?);
        final n = e.value;
        if (s != null && n is int && n > 0) {
          stock[s.code] = (stock[s.code] ?? 0) + n;
        }
      }
    }
    int read(String k) => max(0, json[k] as int? ?? 0);
    return ForgeState(
      stock: stock,
      glut: read('glut'),
      splinters: read('splinters'),
      placed: read('placed'),
      combines: read('combines'),
      bestLevel: read('bestLevel').clamp(0, Seal.maxLevel),
      attempts: read('attempts'),
      fails: read('fails'),
    );
  }

  /// Stock entries of [json] that are not valid seals; empty when fine.
  static List<Object?> unknownCodes(Map<String, Object?> json) {
    final raw = json['stock'];
    if (raw == null) return const [];
    if (raw is! Map) return [raw];
    return [
      for (final e in raw.entries)
        if (Seal.tryParse(e.key as String?) == null || e.value is! int) e.key,
    ];
  }
}
