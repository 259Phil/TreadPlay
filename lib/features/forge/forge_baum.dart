part of 'forge_screen.dart';

// Stufen-Tab, "Schmiede-Baum", growing upwards: the 15 single seals
// (three stats, St.1–5) in columns at the root, above them the level-1
// recipes and on top the level-2 recipes, each as its own column of five
// level nodes (30 in all). Every recipe level not forged yet drifts as a
// dark ??? silhouette, tied to nothing. Each level forged in Kombinieren
// lights up and grows a glowing line from the exact seals it was made
// from (stat + level; a level-2 recipe from its level-1 recipe of that
// level and the third seal). Lit levels of one recipe chain up like the
// single seals. A green ring marks what the case can forge right now.

const _brass = Color(0xFFD9B26A);
const _glowEmber = Color(0xFFFF9A3C);
const _cyan = Color(0xFF8FF0E2);

/// Gap between two levels of one column, and between two blocks.
const double _rowGap = 70;
const double _blockGap = 124;

/// Height of the tree canvas (three blocks of five rows); it scrolls.
const double _baumH = 64 + 3 * 4 * _rowGap + 2 * _blockGap + 56;

/// Column of each stat's single seals and of each recipe (share of the
/// width): every block uses the same three columns.
const _singleX = {
  SealType.stride: .17,
  SealType.grit: .5,
  SealType.fortune: .83,
};
const _recipeX = {
  Recipe.ausdauer: .17,
  Recipe.faehrte: .5,
  Recipe.schutz: .83,
  Recipe.wanderstern: .17,
  Recipe.spurenleser: .5,
  Recipe.glutherz: .83,
};

/// Centre of St.[level] in block [block] (0 = level-2 recipes on top,
/// 1 = level-1 recipes, 2 = single seals at the bottom). St.1 is lowest.
double _rowY(int block, int level) =>
    64 + block * (4 * _rowGap + _blockGap) + (Seal.maxLevel - level) * _rowGap;

double _singleY(int level) => _rowY(2, level);

/// One node of the tree as the game stands: a single seal or one level of
/// a recipe.
class _BN {
  const _BN({
    required this.id,
    required this.lit,
    required this.level,
    this.seal,
    this.recipe,
    this.levels = const {},
    this.ready = false,
    this.locked = false,
  });

  final String id;
  final SealType? seal;
  final int level;
  final Recipe? recipe;

  /// Levels of this recipe ever owned or forged.
  final Set<int> levels;

  /// This seal or recipe level was ever owned or forged.
  final bool lit;

  /// The case, Glut and LP can forge this recipe level right now.
  final bool ready;

  /// A level-2 recipe whose level-1 recipe was not forged yet.
  final bool locked;

  bool get single => seal != null;

  /// Some level of this recipe is known (its name and effects show).
  bool get known => levels.isNotEmpty;

  /// Highest recipe level ever forged; 0 = none.
  int get tiers => levels.isEmpty ? 0 : levels.reduce(math.max);

  double get xShare => single ? _singleX[seal]! : _recipeX[recipe]!;

  Offset at(double w) => Offset(
    w * xShare,
    single ? _singleY(level) : _rowY(recipe!.tier == 2 ? 0 : 1, level),
  );
}

String _singleId(SealType t, int level) => 'single-${t.name}-$level';
String _recipeId(Recipe r, int level) => '${r.name}-$level';

/// Recipe levels (as [ForgeState.seenKey]) that two seals in the case make
/// and the forge allows now (Glut and LP for the lowest Glut of the step).
Set<String> _forgeableNow(GameData game) {
  final stock = [for (final (s, _) in game.forge.sealsInStock) s];
  final out = <String>{};
  for (final x in stock) {
    for (final y in stock) {
      if (x == y) continue;
      final made = GameData.combineResult(x, y);
      if (made == null) continue;
      final step = GameData.combineStep(made);
      if (step != null && game.combineBlock(x, y, step.minGlut) == null) {
        out.add(ForgeState.seenKey(made));
      }
    }
  }
  return out;
}

List<_BN> _baumNodes(GameData game) {
  final f = game.forge;
  final ready = _forgeableNow(game);
  return [
    for (final t in SealType.values)
      for (var lv = 1; lv <= Seal.maxLevel; lv++)
        _BN(id: _singleId(t, lv), seal: t, level: lv, lit: f.sawSingle(t, lv)),
    for (final r in Recipe.values)
      ...() {
        final levels = {
          for (var lv = 1; lv <= Seal.maxLevel; lv++)
            if (f.sawRecipe(r, lv)) lv,
          if ((f.recipes[r] ?? 0) case final best when best > 0) best,
        };
        return [
          for (var lv = 1; lv <= Seal.maxLevel; lv++)
            _BN(
              id: _recipeId(r, lv),
              recipe: r,
              level: lv,
              levels: levels,
              lit: levels.contains(lv),
              ready: ready.contains('${r.name}@$lv'),
              locked: !f.canForge(r),
            ),
        ];
      }(),
  ];
}

/// The chains: each stat's St.1 → St.5 always, and two neighbouring lit
/// levels of one recipe.
List<(String, String)> _chainLinks(_BN Function(String) node) => [
  for (final t in SealType.values)
    for (var lv = 1; lv < Seal.maxLevel; lv++)
      (_singleId(t, lv), _singleId(t, lv + 1)),
  for (final r in Recipe.values)
    for (var lv = 1; lv < Seal.maxLevel; lv++)
      if (node(_recipeId(r, lv)).lit && node(_recipeId(r, lv + 1)).lit)
        (_recipeId(r, lv), _recipeId(r, lv + 1)),
];

/// Node id of a [ForgeState.seenKey] (`stride@2`, `ausdauer@1`).
String? _nodeOfKey(String key) {
  final [name, lv] = key.split('@');
  final level = int.tryParse(lv) ?? 1;
  if (SealType.values.asNameMap()[name] case final t?) {
    return _singleId(t, level);
  }
  if (Recipe.values.asNameMap()[name] case final r?) return _recipeId(r, level);
  return null;
}

/// A line drawn into a recipe level: [grow] is its [ForgeState.forged]
/// key.
typedef _Link = ({Path path, bool lit, bool ready, String? grow});

/// Lines of [forged] into the recipe levels. A source leaves its column
/// sideways into a gutter between the columns, climbs it and turns into
/// the recipe level; a run across the middle column goes between two rows
/// and enters from below. Lines sharing a gutter get their own lane.
List<_Link> _forgedLinks(
  Map<String, List<String>> forged,
  _BN Function(String) node,
  double w,
) {
  final out = <_Link>[];
  final lanes = <double, int>{};
  final keys = [...forged.keys]..sort();
  for (final key in keys) {
    final targetId = _nodeOfKey(key);
    if (targetId == null) continue;
    final target = node(targetId);
    final q = target.at(w);
    for (final src in forged[key]!) {
      final id = _nodeOfKey(src);
      if (id == null) continue;
      final from = node(id);
      final p = from.at(w);
      final sx = from.xShare;
      final tx = target.xShare;
      final gutter = sx < .4
          ? .335
          : sx > .6
          ? .665
          : (tx > .6 ? .665 : .335);
      final n = lanes[gutter] = (lanes[gutter] ?? 0) + 1;
      final lane = (n.isEven ? 1 : -1) * (n ~/ 2) * 2.6;
      final gx = w * gutter + lane;
      final dir = gx > p.dx ? 1.0 : -1.0;
      final side = gx < q.dx ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(p.dx + dir * 17, p.dy)
        ..lineTo(gx, p.dy);
      if ((gutter - tx).abs() < .2) {
        final y = q.dy + lane * .6;
        path
          ..lineTo(gx, y)
          ..lineTo(q.dx + side * 22, y);
      } else {
        final y = q.dy + 42 + lane * .6;
        final ex = q.dx + side * 18;
        path
          ..lineTo(gx, y)
          ..lineTo(ex, y)
          ..lineTo(ex, q.dy + 16);
      }
      out.add((path: path, lit: true, ready: false, grow: key));
    }
  }
  return out;
}

class _SchmiedeBaum extends ConsumerStatefulWidget {
  const _SchmiedeBaum();

  @override
  ConsumerState<_SchmiedeBaum> createState() => _SchmiedeBaumState();
}

class _SchmiedeBaumState extends ConsumerState<_SchmiedeBaum>
    with TickerProviderStateMixin {
  String? _sel;

  /// Gentle drift of the undiscovered recipes.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  /// A newly forged recipe's lines growing in, once.
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  /// [ForgeState.forged] keys growing right now.
  Set<String>? _growing;

  bool get _motion =>
      forgeAmbientMotion &&
      TickerMode.of(context) &&
      !MediaQuery.disableAnimationsOf(context);

  /// The drift only runs while the tree is on screen (TickerMode) and
  /// without reduced motion.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motion) {
      _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _grow.dispose();
    super.dispose();
  }

  /// Lines of recipes forged since the last look grow in now (or, without
  /// motion, are just noted as drawn).
  void _growNew(ForgeState f) {
    if (_growing != null) return;
    final fresh = {
      for (final k in f.forged.keys)
        if (!f.grown.contains(k)) k,
    };
    if (fresh.isEmpty) return;
    final motion = _motion;
    // Without motion the lines simply stand; otherwise they start empty.
    _growing = motion ? fresh : const {};
    if (motion) _grow.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (motion) {
        await _grow.forward(from: 0).orCancel.catchError((_) {});
      }
      if (!mounted) return;
      ref.read(gameProvider.notifier).markLinksGrown(fresh);
      _growing = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final nodes = _baumNodes(game);
    _growNew(game.forge);
    _BN node(String id) => nodes.firstWhere((n) => n.id == id);
    final recipes = nodes.where((n) => !n.single).toList();
    final known = recipes.where((n) => n.lit).length;
    // Recipes known at some level (each counted once).
    final names = {
      for (final n in recipes)
        if (n.lit) n.recipe,
    };
    final singles = nodes.where((n) => n.single).toList();
    final seenSingles = singles.where((n) => n.lit).length;
    final sel =
        _sel ??
        (recipes.where((n) => n.ready).firstOrNull ??
                recipes.where((n) => n.lit).lastOrNull ??
                recipes.first)
            .id;
    // Wraps on narrow phones rather than squeezing the counters.
    final header = Wrap(
      spacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l.baumTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _brass.withValues(alpha: .9),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        Text(
          l.baumSeen(seenSingles, singles.length),
          key: const Key('baum-seen'),
          style: const TextStyle(color: ForgeColors.muted, fontSize: 10.5),
        ),
        Text(
          l.baumLevels(known, recipes.length),
          key: const Key('baum-levels'),
          style: const TextStyle(color: ForgeColors.muted, fontSize: 10.5),
        ),
        Text(
          l.baumCount(names.length, Recipe.values.length),
          key: const Key('baum-count'),
          style: const TextStyle(color: ForgeColors.muted, fontSize: 10.5),
        ),
      ],
    );
    return Padding(
      key: const Key('forge-ladder-tab'),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth > 700;
          final tree = _tree(nodes, node, sel, game.forge.forged);
          final detail = _Detail(
            node: node(sel),
            compact: !wide || box.maxHeight < 560,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Text(
                l.baumTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _cyan,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: wide
                    ? Row(
                        children: [
                          Expanded(flex: 3, child: tree),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 330,
                            child: SingleChildScrollView(child: detail),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: tree),
                          detail,
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tree(
    List<_BN> nodes,
    _BN Function(String) node,
    String sel,
    Map<String, List<String>> forged,
  ) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth;
      final links = <_Link>[
        for (final (a, b) in _chainLinks(node))
          () {
            final na = node(a);
            final nb = node(b);
            final p = na.at(w);
            final q = nb.at(w);
            return (
              path: Path()
                ..moveTo(p.dx, p.dy)
                ..lineTo(q.dx, q.dy),
              lit: na.lit && nb.lit,
              ready: false,
              grow: null,
            );
          }(),
        ..._forgedLinks(forged, node, w),
      ];
      // Every recipe level not forged yet drifts on its own.
      final floating = [
        for (final (i, n) in nodes.where((n) => !n.single).indexed)
          if (!n.lit) (n.id, (i * 7 % 30) / 30),
      ];
      return SingleChildScrollView(
        key: const Key('baum-scroll'),
        // Starts at the root (the single seals); scroll up to the
        // recipes.
        reverse: true,
        child: SizedBox(
          width: w,
          height: _baumH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TreePainter(
                    links,
                    _singleY(1),
                    _grow,
                    () => _growing ?? const {},
                  ),
                ),
              ),
              for (final n in nodes)
                if (n.single || n.lit)
                  _placed(context, n, n.at(w), n.single ? 36 : 40, n.id == sel),
              // Undiscovered recipes drift; nothing is tied to them yet.
              for (final (id, phase) in floating)
                AnimatedBuilder(
                  animation: _float,
                  builder: (context, _) {
                    final t = (_float.value + phase) * 2 * math.pi;
                    final n = node(id);
                    return _placed(
                      context,
                      n,
                      n.at(w) + Offset(math.cos(t) * 2.5, math.sin(t) * 4),
                      40,
                      n.id == sel,
                    );
                  },
                ),
            ],
          ),
        ),
      );
    },
  );

  Widget _placed(
    BuildContext context,
    _BN n,
    Offset p,
    double size,
    bool selected,
  ) {
    final l = AppLocalizations.of(context);
    final r = n.recipe;
    final label = n.single
        ? '${sealStat(l, n.seal!)} ${l.sealLevelShort(n.level)}'
        : n.lit
        ? '${recipeName(l, r!)} ${l.sealLevelShort(n.level)}'
        : '??? ${l.sealLevelShort(n.level)}';
    // One caption per column: what can be forged now, or below the St.1
    // of a recipe not known yet, its hint (or what opens it).
    final sub = n.single || n.lit
        ? null
        : n.ready
        ? l.baumReady
        : n.level > 1 || n.known
        ? null
        : n.locked
        ? l.baumLocked(recipeName(l, r!.base))
        : recipeHint(l, r!);
    final img = n.single
        ? SealArt(seal: Seal(n.seal!, n.level), size: size)
        : RecipeArt(recipe: r!, size: size, level: n.level);
    final art = n.lit
        ? img
        : n.single
        ? Opacity(
            opacity: .55,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                .3, .5, .1, 0, 0, //
                .3, .5, .1, 0, 0,
                .3, .5, .1, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: img,
            ),
          )
        : Opacity(
            opacity: .9,
            child: ColorFiltered(
              // A dark silhouette; the frame's outline still tells the
              // level (more spikes higher up).
              colorFilter: const ColorFilter.matrix([
                .06, .06, .06, 0, 62, //
                .05, .05, .05, 0, 50,
                .04, .04, .04, 0, 40,
                0, 0, 0, 1, 0,
              ]),
              child: img,
            ),
          );
    final glow = n.ready ? _arcane.glow : _glowEmber;
    return Positioned(
      left: p.dx - 50,
      top: p.dy - size / 2,
      width: 100,
      child: GestureDetector(
        key: Key('baum-${n.id}'),
        onTap: () => setState(() => _sel = n.id),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size + 8,
              height: size + 8,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (n.lit || n.ready)
                    Container(
                      width: size * .9,
                      height: size * .9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glow.withValues(alpha: .4),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  if (n.ready || selected)
                    Container(
                      key: n.ready ? Key('baum-ready-${n.id}') : null,
                      width: size + 6,
                      height: size + 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: n.ready
                              ? _arcane.accent.withValues(alpha: .9)
                              : _brass,
                          width: n.ready ? 2 : 1.6,
                        ),
                      ),
                    ),
                  art,
                  if (n.locked && n.level == 1)
                    const Positioned(
                      right: 2,
                      top: 0,
                      child: Icon(
                        Icons.lock,
                        size: 15,
                        color: ForgeColors.muted,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              label,
              key: n.lit ? Key('baum-lit-${n.id}') : null,
              maxLines: 1,
              style: TextStyle(
                color: n.lit
                    ? ForgeColors.text
                    : ForgeColors.muted.withValues(alpha: n.single ? .6 : 1),
                fontSize: 9.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
                shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
              ),
            ),
            if (sub != null)
              Text(
                sub,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: n.lit || n.ready
                      ? _cyan
                      : ForgeColors.muted.withValues(alpha: .8),
                  fontSize: 9,
                  height: 1.15,
                  fontStyle: n.lit || n.ready
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The selected node: a single seal, or one level of a recipe with the
/// recipe's St.1–5 (forged levels, the next one as a preview, the rest
/// hidden) and the hint while the recipe is dark.
class _Detail extends StatelessWidget {
  const _Detail({required this.node, this.compact = false});

  final _BN node;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final n = node;
    final r = n.recipe;
    const small = TextStyle(color: ForgeColors.text, fontSize: 11);
    final lines = <Widget>[];
    String title;
    if (n.single) {
      final stat = sealStat(l, n.seal!);
      title = '$stat ${l.sealLevelShort(n.level)}'.toUpperCase();
      lines.add(
        Text(
          n.lit
              ? l.baumSingleSeen(stat, n.level)
              : l.baumSingleNever(stat, n.level),
          style: small,
        ),
      );
      lines.add(
        Text(
          n.level == 1 ? l.baumSingleFirst : l.baumSingleUp(n.level - 1),
          style: const TextStyle(color: ForgeColors.muted, fontSize: 10),
        ),
      );
    } else {
      title = n.known
          ? '${recipeName(l, r!)} ${l.sealLevelShort(n.level)}'.toUpperCase()
          : l.baumUndiscovered;
      final parts = r!.tier == 1
          ? l.sealComboName(sealStat(l, r.a), sealStat(l, r.b))
          : l.sealComboName(recipeName(l, r.base), sealStat(l, r.extra!));
      lines.add(Text(n.known ? parts : '??? + ???', style: small));
      if (n.known) {
        lines.add(
          Text(
            '${l.baumFor(recipeFor(l, r))} · ${l.baumForged(n.tiers)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ForgeColors.muted, fontSize: 10),
          ),
        );
      }
      if (n.locked) {
        lines.add(
          Text(
            l.forgeRecipeLocked(recipeName(l, r.base)),
            style: const TextStyle(color: ForgeColors.ember, fontSize: 10),
          ),
        );
      } else if (n.ready) {
        lines.add(
          Text(
            l.baumReady,
            style: TextStyle(color: _arcane.accent, fontSize: 10),
          ),
        );
      }
      lines.add(const SizedBox(height: 4));
      final first = compact ? n.level : 1;
      final last = compact ? math.min(5, n.level + 1) : 5;
      for (var i = first; i <= last; i++) {
        final done = n.levels.contains(i);
        // The selected level and the one after the best show as a preview.
        final next =
            !done && (i == n.tiers + 1 || i == n.level) && (n.known || n.ready);
        lines.add(
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '${i == n.level ? '▸' : ' '}${l.sealLevelShort(i)}',
                    style: TextStyle(
                      color: done ? _brass : ForgeColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    done || next
                        ? '${recipeEffectText(context, r, i)}  ·  '
                              '${recipeSplitText(context, r, i)}'
                        : '???',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: done
                          ? ForgeColors.text
                          : next
                          ? _cyan.withValues(alpha: .8)
                          : ForgeColors.muted.withValues(alpha: .6),
                      fontSize: 10,
                      fontStyle: next ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                if (next)
                  Text(
                    l.baumNext,
                    style: const TextStyle(color: _cyan, fontSize: 9),
                  ),
              ],
            ),
          ),
        );
      }
      if (compact && last < 5) {
        lines.add(
          Text(
            '${l.sealLevelShort(last + 1)}–5  ???',
            style: TextStyle(
              color: ForgeColors.muted.withValues(alpha: .6),
              fontSize: 10,
            ),
          ),
        );
      }
      if (!n.known) {
        lines.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.baumHint(recipeHint(l, r)),
              style: const TextStyle(
                color: ForgeColors.muted,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }
    }
    if (!compact) {
      lines.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l.baumWhere,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ForgeColors.muted.withValues(alpha: .85),
              fontSize: 9.5,
            ),
          ),
        ),
      );
    }
    return Container(
      key: const Key('baum-detail'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F17).withValues(alpha: .92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7A6040)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: const Key('baum-detail-title'),
            style: const TextStyle(
              color: _brass,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 2),
          ...lines,
        ],
      ),
    );
  }
}

/// Iron chains between nodes; brass rods with an ember glow once both ends
/// are forged; a faint verdigris chain where the next recipe can be forged.
class _TreePainter extends CustomPainter {
  _TreePainter(this.links, this.baseY, this.grow, this.growing)
    : super(repaint: grow);

  final List<_Link> links;
  final double baseY;

  /// Progress of the lines in [growing] (0 → 1).
  final Animation<double> grow;
  final Set<String> Function() growing;

  @override
  void paint(Canvas canvas, Size size) {
    final beam = Rect.fromLTWH(
      size.width * .06,
      baseY + 30,
      size.width * .88,
      5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(beam, const Radius.circular(2)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF5A4630), Color(0xFFB08A50), Color(0xFF5A4630)],
        ).createShader(beam),
    );
    final now = growing();
    final t = Curves.easeInOut.transform(
      const Interval(.15, 1).transform(grow.value),
    );
    final sorted = [...links]
      ..sort((x, y) => (x.lit ? 1 : 0) - (y.lit ? 1 : 0));
    for (final (:path, :lit, :ready, :grow) in sorted.map(
      (k) => (
        path: k.grow != null && now.contains(k.grow)
            ? _part(k.path, t)
            : k.path,
        lit: k.lit,
        ready: k.ready,
        grow: k.grow,
      ),
    )) {
      if (grow != null && now.contains(grow) && t < 1) {
        _spark(canvas, path);
      }
      if (lit) {
        // Forged lines run in bundles, so they are finer than the chains.
        final fine = grow != null;
        canvas.drawPath(
          path,
          Paint()
            ..color = _glowEmber.withValues(alpha: fine ? .28 : .35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = fine ? 4 : 7
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, fine ? 2.5 : 4),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = _brass
            ..style = PaintingStyle.stroke
            ..strokeWidth = fine ? 1.4 : 2.6,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFE6B0).withValues(alpha: .7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = fine ? .5 : .8,
        );
        continue;
      }
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d < metric.length; d += 7) {
          final tan = metric.getTangentForOffset(d)!;
          canvas.save();
          canvas.translate(tan.position.dx, tan.position.dy);
          canvas.rotate(tan.angle);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: 7,
              height: (d ~/ 7).isEven ? 4 : 1.6,
            ),
            Paint()
              ..color = ready
                  ? _arcane.accent.withValues(alpha: .6)
                  : const Color(0xFF5A4E44)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.1,
          );
          canvas.restore();
        }
      }
    }
  }

  /// The first [t] of [path].
  static Path _part(Path path, double t) {
    final out = Path();
    for (final m in path.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * t), Offset.zero);
    }
    return out;
  }

  /// A spark at the growing tip.
  static void _spark(Canvas canvas, Path path) {
    for (final m in path.computeMetrics()) {
      if (m.length == 0) continue;
      final tip = m.getTangentForOffset(m.length)!.position;
      canvas.drawCircle(
        tip,
        6,
        Paint()
          ..color = _glowEmber.withValues(alpha: .7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(tip, 2.2, Paint()..color = const Color(0xFFFFF1C8));
    }
  }

  @override
  bool shouldRepaint(_TreePainter old) => true;
}
