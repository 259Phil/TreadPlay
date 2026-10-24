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

  /// Level-2 recipe (recipe seal St.n + single seal of the third stat St.n):
  /// the combine step of that level with 1.5× LP, one Glut more at both
  /// ends and a fail chance 5 points higher.
  static ForgeStep? tripleStep(int level) {
    final c = combines[level];
    if (c == null) return null;
    return ForgeStep(
      lp: (c.lp * 1.5).round(),
      minGlut: c.minGlut + 1,
      maxGlut: c.maxGlut + 1,
      failAtMin: c.failAtMin + .05,
      failAtMax: c.failAtMax + .05,
    );
  }

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
    this.recipes = const {},
    this.glutherzDay,
    this.seen = const {},
    this.forged = const {},
    this.grown = const {},
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

  /// Discovered recipes → highest level forged (or owned since the update
  /// that brought recipes). A level-2 recipe opens once its level-1 recipe
  /// is here.
  final Map<Recipe, int> recipes;

  /// Day key (see `dayKey`) of the last extra Glut from [Recipe.glutherz].
  final String? glutherzDay;

  /// Every seal kind ever owned or forged, as [seenKey]: single seals by
  /// stat and level (`stride@3`), recipe seals by recipe and level
  /// (`ausdauer@2`). The Schmiede-Baum lights these.
  final Set<String> seen;

  /// Recipe levels forged in Kombinieren → the two seals they were made
  /// from, all as [seenKey]: `ausdauer@2` ← `stride@2`, `grit@2`;
  /// `wanderstern@1` ← `ausdauer@1`, `fortune@1`. The Schmiede-Baum draws
  /// these as its only links into recipes.
  final Map<String, List<String>> forged;

  /// Keys of [forged] whose links the tree already drew growing once.
  final Set<String> grown;

  /// [made] noted as forged from [a] and [b] (the first combine counts).
  ForgeState forging(Seal made, Seal a, Seal b) {
    final key = seenKey(made);
    if (forged.containsKey(key)) return this;
    return copyWith(
      forged: {
        ...forged,
        key: [seenKey(a), seenKey(b)],
      },
    );
  }

  /// Older saves knew no [forged]: every recipe level ever owned is linked
  /// to the matching stats (or level-1 recipe and third stat) at that
  /// level, since combining always takes seals of one level.
  ForgeState linkingKnown() {
    final add = <String, List<String>>{};
    for (final r in Recipe.values) {
      for (var lv = 1; lv <= Seal.maxLevel; lv++) {
        final key = '${r.name}@$lv';
        if (!sawRecipe(r, lv) || forged.containsKey(key)) continue;
        add[key] = r.tier == 1
            ? ['${r.a.name}@$lv', '${r.b.name}@$lv']
            : ['${r.base.name}@$lv', '${r.extra!.name}@$lv'];
      }
    }
    return add.isEmpty ? this : copyWith(forged: {...forged, ...add});
  }

  /// [linkingKnown] when [old] is set.
  ForgeState linkingIf(bool old) => old ? linkingKnown() : this;

  /// [keys] of [forged] noted as drawn.
  ForgeState growing(Iterable<String> keys) {
    final add = {
      for (final k in keys)
        if (forged.containsKey(k)) k,
    };
    return grown.containsAll(add) ? this : copyWith(grown: {...grown, ...add});
  }

  /// What [seen] notes for [s]: its stat (single) or recipe, and level.
  static String seenKey(Seal s) =>
      '${s.recipe?.name ?? s.type.name}@${s.level}';

  /// A single [type] seal at [level] was owned at some point.
  bool sawSingle(SealType type, int level) =>
      seen.contains('${type.name}@$level');

  /// A recipe seal of [r] at [level] was owned or forged at some point.
  bool sawRecipe(Recipe r, int level) => seen.contains('${r.name}@$level');

  /// [seals] noted in [seen].
  ForgeState seeing(Iterable<Seal> seals) {
    final add = {for (final s in seals) seenKey(s)};
    return seen.containsAll(add) ? this : copyWith(seen: {...seen, ...add});
  }

  bool knows(Recipe r) => (recipes[r] ?? 0) > 0;

  /// True when [r] may be forged: level-1 recipes always, level-2 once
  /// their level-1 recipe was forged.
  bool canForge(Recipe r) => r.tier == 1 || knows(r.base);

  /// [r] noted as forged at [level] (keeps the highest).
  ForgeState discovering(Recipe r, int level) {
    final f = seen.contains('${r.name}@$level')
        ? this
        : copyWith(seen: {...seen, '${r.name}@$level'});
    return (f.recipes[r] ?? 0) >= level
        ? f
        : f.copyWith(recipes: {...f.recipes, r: level});
  }

  /// Recipes of [seals] noted as discovered and all of [seals] as seen
  /// (migration of older saves: case and sockets count as owned).
  ForgeState discoveringAll(Iterable<Seal> seals) {
    var f = seeing(seals);
    for (final s in seals) {
      if (s.recipe case final r?) f = f.discovering(r, s.level);
    }
    return f;
  }

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
    final key = seenKey(s);
    return copyWith(
      stock: next,
      bestLevel: n > 0 && s.level > bestLevel ? s.level : bestLevel,
      seen: n > 0 && !seen.contains(key) ? {...seen, key} : null,
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
    Map<Recipe, int>? recipes,
    String? glutherzDay,
    Set<String>? seen,
    Map<String, List<String>>? forged,
    Set<String>? grown,
  }) => ForgeState(
    stock: stock ?? this.stock,
    glut: glut ?? this.glut,
    splinters: splinters ?? this.splinters,
    placed: placed ?? this.placed,
    combines: combines ?? this.combines,
    bestLevel: bestLevel ?? this.bestLevel,
    attempts: attempts ?? this.attempts,
    fails: fails ?? this.fails,
    recipes: recipes ?? this.recipes,
    glutherzDay: glutherzDay ?? this.glutherzDay,
    seen: seen ?? this.seen,
    forged: forged ?? this.forged,
    grown: grown ?? this.grown,
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
    'recipes': {for (final e in recipes.entries) e.key.name: e.value},
    'glutherzDay': ?glutherzDay,
    'seen': [...seen]..sort(),
    'forged': {
      for (final k in [...forged.keys]..sort()) k: forged[k],
    },
    'grown': [...grown]..sort(),
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
    final names = Recipe.values.asNameMap();
    final recipes = <Recipe, int>{};
    if (json['recipes'] case final Map<Object?, Object?> raw) {
      for (final e in raw.entries) {
        final r = names[e.key];
        final lv = e.value;
        if (r != null && lv is int && lv > 0) {
          recipes[r] = lv.clamp(1, Seal.maxLevel);
        }
      }
    }
    final forged = <String, List<String>>{
      if (json['forged'] case final Map<Object?, Object?> raw)
        for (final e in raw.entries)
          if (e.key case final String k
              when _seenKeys.contains(k) && !_singleKeys.contains(k))
            if (e.value case [
              final String a,
              final String b,
            ] when _seenKeys.contains(a) && _seenKeys.contains(b))
              k: [a, b],
    };
    final state = ForgeState(
      stock: stock,
      glut: read('glut'),
      splinters: read('splinters'),
      placed: read('placed'),
      combines: read('combines'),
      bestLevel: read('bestLevel').clamp(0, Seal.maxLevel),
      attempts: read('attempts'),
      fails: read('fails'),
      recipes: recipes,
      glutherzDay: json['glutherzDay'] as String?,
      seen: {
        if (json['seen'] case final List<Object?> raw)
          for (final k in raw)
            if (k is String && _seenKeys.contains(k)) k,
        // Each discovered recipe was owned at least at its best level.
        for (final e in recipes.entries) '${e.key.name}@${e.value}',
      },
      forged: forged,
      grown: {
        if (json['grown'] case final List<Object?> raw)
          for (final k in raw)
            if (k is String && forged.containsKey(k)) k,
      },
    );
    // Seals in the case count as owned, recipe seals as discovered (older
    // saves had combined seals before recipes were noted).
    return state.discoveringAll([for (final (s, _) in state.sealsInStock) s]);
  }

  /// Every valid [seenKey].
  static final Set<String> _seenKeys = {
    for (final n in [
      for (final t in SealType.values) t.name,
      for (final r in Recipe.values) r.name,
    ])
      for (var lv = 1; lv <= Seal.maxLevel; lv++) '$n@$lv',
  };

  static final Set<String> _singleKeys = {
    for (final t in SealType.values)
      for (var lv = 1; lv <= Seal.maxLevel; lv++) '${t.name}@$lv',
  };

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
