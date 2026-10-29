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

  /// Keys whose lines grow in right now, in unlock order.
  List<String>? _growing;

  /// Pan and pinch of the tree.
  final TransformationController _view = TransformationController();

  /// Root and size the view was last fitted for.
  String? _viewKey;

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
    _view.dispose();
    super.dispose();
  }

  /// Lines of seals owned or forged since the last look grow in now, one
  /// after another in unlock order (without motion they are just noted).
  void _growNew(ForgeState f) {
    if (_growing != null) return;
    final fresh = [
      for (final k in f.order)
        if (!f.grown.contains(k)) k,
    ];
    if (fresh.isEmpty) return;
    final motion = _motion;
    _growing = motion ? fresh : const [];
    if (motion) {
      _grow.duration = Duration(
        milliseconds: math.min(6000, 900 + 420 * fresh.length),
      );
      _grow.value = 0;
    }
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
          final tree = _tree(game.forge, nodes, node, sel);
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
    ForgeState f,
    List<_BN> nodes,
    _BN Function(String) node,
    String sel,
  ) {
    final g = _Grown.of(f);
    final drifting = [
      for (final n in nodes)
        if (!n.single && !n.lit) n.id,
    ];
    final lay = _layout(g, drifting);
    final edges = _edgesOf(g);
    final shift = -lay.bounds.topLeft;
    final size = lay.bounds.size;
    List<String> growing() => _growing ?? const [];
    return LayoutBuilder(
      builder: (context, box) {
        final key =
            '${g.root} ${f.seen.length} '
            '${box.maxWidth.round()}x${box.maxHeight.round()}';
        if (key != _viewKey) {
          _viewKey = key;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fit(box.biggest, lay.at[g.root]! + shift);
          });
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InteractiveViewer(
            key: const Key('baum-scroll'),
            transformationController: _view,
            constrained: false,
            minScale: .3,
            maxScale: 2.5,
            boundaryMargin: const EdgeInsets.all(220),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GrownPainter(
                        layout: lay,
                        edges: edges,
                        shift: shift,
                        grow: _grow,
                        growing: growing,
                        root: g.root,
                      ),
                    ),
                  ),
                  if (g.nodes.containsKey(_Grown.hub))
                    Positioned(
                      left: lay.at[_Grown.hub]!.dx + shift.dx - 26,
                      top: lay.at[_Grown.hub]!.dy + shift.dy - 26,
                      child: Image.asset(
                        'assets/forge/anvil_plain.webp',
                        width: 52,
                        height: 52,
                      ),
                    ),
                  for (final gn in g.nodes.values)
                    if (gn.id != _Grown.hub)
                      AnimatedBuilder(
                        animation: _grow,
                        builder: (context, _) {
                          final t = gn.owned
                              ? _GrownPainter.share(
                                  growing(),
                                  gn.key,
                                  _grow.value,
                                )
                              : 1.0;
                          final n = node(gn.id);
                          return _placed(
                            context,
                            n,
                            lay.at[gn.id]! + shift,
                            38,
                            n.id == sel,
                            fade: gn.id == g.root ? 1 : t,
                          );
                        },
                      ),
                  // Undiscovered recipe levels drift; nothing is tied to
                  // them yet.
                  for (final (i, id) in drifting.indexed)
                    AnimatedBuilder(
                      animation: _float,
                      builder: (context, _) {
                        final t =
                            (_float.value + (i * 7 % 30) / 30) * 2 * math.pi;
                        final n = node(id);
                        return _placed(
                          context,
                          n,
                          lay.drift[id]! +
                              shift +
                              Offset(math.cos(t) * 2.5, math.sin(t) * 4),
                          38,
                          n.id == sel,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Centres the root in [view], zoomed so the first ring and its labels
  /// read well (a phone shows the root and its St.1 neighbours).
  void _fit(Size view, Offset root) {
    final half = math.min(view.width, view.height) / 2;
    final s = (half / (_ringOf(1) + 48)).clamp(.72, 1.0);
    final t = view.center(Offset.zero) - root * s;
    _view.value = Matrix4.diagonal3Values(s, s, 1)
      ..setTranslationRaw(t.dx, t.dy, 0);
  }

  Widget _placed(
    BuildContext context,
    _BN n,
    Offset p,
    double size,
    bool selected, {
    double fade = 1,
  }) {
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
      left: p.dx - 58,
      top: p.dy - size / 2,
      width: 116,
      child: Opacity(
        opacity: fade,
        child: _node(n, art, glow, size, selected, label, sub, r),
      ),
    );
  }

  Widget _node(
    _BN n,
    Widget art,
    Color glow,
    double size,
    bool selected,
    String label,
    String? sub,
    Recipe? r,
  ) => GestureDetector(
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
                  child: Icon(Icons.lock, size: 15, color: ForgeColors.muted),
                ),
            ],
          ),
        ),
        // Owned seals read on a dark pill over the lines; ghosts stay
        // small and quiet.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: n.lit
              ? BoxDecoration(
                  color: const Color(0xCC070A14),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(
            label,
            key: n.lit ? Key('baum-lit-${n.id}') : null,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: n.lit
                  ? ForgeColors.text
                  : ForgeColors.muted.withValues(alpha: n.single ? .55 : .9),
              fontSize: n.lit ? 10.5 : 9,
              height: 1.2,
              fontWeight: n.lit ? FontWeight.w800 : FontWeight.w600,
              shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
            ),
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
              fontStyle: n.lit || n.ready ? FontStyle.normal : FontStyle.italic,
            ),
          ),
      ],
    ),
  );
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
