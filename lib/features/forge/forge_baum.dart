part of 'forge_screen.dart';

// Stufen-Tab, "Schmiede-Baum": the three single seals at the root, the
// three level-1 recipes (two different single seals) above them and the
// three level-2 recipes (recipe seal + the third single seal) on top.
// Discovered recipes light up, undiscovered ones stay dark with a hint,
// a green ring marks what can be forged with the case right now. A tap
// shows the detail with St.1–5 (the next level as a preview).

const _brass = Color(0xFFD9B26A);
const _glowEmber = Color(0xFFFF9A3C);
const _cyan = Color(0xFF8FF0E2);

/// Height of the tree canvas; it scrolls when the screen is shorter.
const double _baumH = 880;

/// Column of each stat's single seals (share of the width).
const _singleX = {
  SealType.stride: .17,
  SealType.grit: .5,
  SealType.fortune: .83,
};

/// Centre of St.[level] of a single seal (St.1 at the bottom).
double _singleY(int level) => _baumH - 44 - (level - 1) * 74;

/// Where each recipe sits (share of the width, y on the canvas).
const _recipeAt = {
  Recipe.ausdauer: Offset(.2, 400),
  Recipe.faehrte: Offset(.5, 290),
  Recipe.schutz: Offset(.8, 400),
  Recipe.wanderstern: Offset(.2, 92),
  Recipe.spurenleser: Offset(.5, 92),
  Recipe.glutherz: Offset(.8, 92),
};

/// One node of the tree as the game stands: a single seal at one level,
/// or a recipe with its levels.
class _BN {
  const _BN({
    required this.id,
    required this.lit,
    this.seal,
    this.level = 0,
    this.recipe,
    this.levels = const {},
    this.ready = false,
    this.locked = false,
  });

  final String id;
  final SealType? seal;

  /// Level of a single-seal node.
  final int level;
  final Recipe? recipe;

  /// Recipe levels ever owned or forged.
  final Set<int> levels;

  /// Ever owned (single seal) or discovered (recipe).
  final bool lit;

  /// Can be forged with the case, Glut and LP right now.
  final bool ready;

  /// A level-2 recipe whose level-1 recipe was not forged yet.
  final bool locked;

  bool get single => seal != null;

  /// Highest recipe level ever forged; 0 = none.
  int get tiers => levels.isEmpty ? 0 : levels.reduce(math.max);

  Offset at(double w) => single
      ? Offset(w * _singleX[seal]!, _singleY(level))
      : Offset(w * _recipeAt[recipe]!.dx, _recipeAt[recipe]!.dy);
}

String _singleId(SealType t, int level) => 'single-${t.name}-$level';

/// True when the case holds two seals that make [r] and the forge allows
/// it now (Glut and LP for the lowest Glut of the step).
bool _forgeableNow(GameData game, Recipe r) {
  final stock = [for (final (s, _) in game.forge.sealsInStock) s];
  for (final x in stock) {
    for (final y in stock) {
      if (x == y) continue;
      final made = GameData.combineResult(x, y);
      if (made?.recipe != r) continue;
      final step = GameData.combineStep(made!);
      if (step != null && game.combineBlock(x, y, step.minGlut) == null) {
        return true;
      }
    }
  }
  return false;
}

List<_BN> _baumNodes(GameData game) {
  final f = game.forge;
  return [
    for (final t in SealType.values)
      for (var lv = 1; lv <= Seal.maxLevel; lv++)
        _BN(id: _singleId(t, lv), seal: t, level: lv, lit: f.sawSingle(t, lv)),
    for (final r in Recipe.values)
      () {
        final levels = {
          for (var lv = 1; lv <= Seal.maxLevel; lv++)
            if (f.sawRecipe(r, lv)) lv,
          if ((f.recipes[r] ?? 0) case final best when best > 0) best,
        };
        return _BN(
          id: r.name,
          recipe: r,
          levels: levels,
          lit: levels.isNotEmpty || f.knows(r),
          ready: _forgeableNow(game, r),
          locked: !f.canForge(r),
        );
      }(),
  ];
}

/// Links of the one tree: each stat's chain St.1 → St.5, the stats' tops
/// into their level-1 recipes, those into their level-2 recipes.
List<(String, String)> get _baumLinks => [
  for (final t in SealType.values)
    for (var lv = 1; lv < Seal.maxLevel; lv++)
      (_singleId(t, lv), _singleId(t, lv + 1)),
  for (final r in Recipe.firstTier) ...[
    (_singleId(r.a, Seal.maxLevel), r.name),
    (_singleId(r.b, Seal.maxLevel), r.name),
    (r.name, r.next!.name),
  ],
];

class _SchmiedeBaum extends ConsumerStatefulWidget {
  const _SchmiedeBaum();

  @override
  ConsumerState<_SchmiedeBaum> createState() => _SchmiedeBaumState();
}

class _SchmiedeBaumState extends ConsumerState<_SchmiedeBaum> {
  String? _sel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final nodes = _baumNodes(game);
    _BN node(String id) => nodes.firstWhere((n) => n.id == id);
    final recipes = nodes.where((n) => !n.single).toList();
    final known = recipes.where((n) => n.lit).length;
    final singles = nodes.where((n) => n.single).toList();
    final seenSingles = singles.where((n) => n.lit).length;
    final sel =
        _sel ??
        (recipes.where((n) => n.ready).firstOrNull ??
                recipes.where((n) => n.lit).lastOrNull ??
                recipes.first)
            .id;
    final header = Row(
      children: [
        Flexible(
          child: Text(
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
        ),
        const SizedBox(width: 8),
        Text(
          l.baumSeen(seenSingles, singles.length),
          key: const Key('baum-seen'),
          style: const TextStyle(color: ForgeColors.muted, fontSize: 10.5),
        ),
        const SizedBox(width: 10),
        Text(
          l.baumCount(known, recipes.length),
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
          final tree = _tree(nodes, node, sel);
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
  ) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth;
      final links = <(Path, bool, bool)>[];
      for (final (a, b) in _baumLinks) {
        final na = node(a);
        final nb = node(b);
        final p = na.at(w);
        final q = nb.at(w);
        final path = Path()..moveTo(p.dx, p.dy);
        if (na.single && nb.recipe == Recipe.faehrte) {
          // The outer stats reach the middle recipe by brass rods
          // along the edge, above the other level-1 recipes.
          final left = p.dx < q.dx;
          final edge = left ? w * .035 : w * .965;
          path
            ..lineTo(edge, p.dy - 30)
            ..lineTo(edge, q.dy)
            ..lineTo(q.dx + (left ? -26 : 26), q.dy);
        } else if (na.single && nb.single) {
          path.lineTo(q.dx, q.dy);
        } else {
          final midY = (p.dy + q.dy) / 2;
          path.cubicTo(p.dx, midY, q.dx, midY + 4, q.dx, q.dy);
        }
        links.add((path, na.lit && nb.lit, nb.ready));
      }
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
                child: CustomPaint(painter: _TreePainter(links, _singleY(1))),
              ),
              for (final n in nodes)
                _placed(context, n, n.at(w), n.single ? 36 : 48, n.id == sel),
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
        ? recipeName(l, r!)
        : '???';
    final sub = n.single
        ? null
        : n.lit
        ? null
        : n.locked
        ? l.baumLocked(recipeName(l, r!.base))
        : n.ready
        ? l.baumReady
        : recipeHint(l, r!);
    final img = n.single
        ? SealArt(seal: Seal(n.seal!, n.level), size: size)
        : RecipeArt(recipe: r!, size: size);
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
            opacity: .8,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0, 0, 0, 0, 46, //
                0, 0, 0, 0, 36,
                0, 0, 0, 0, 29,
                0, 0, 0, 1, 0,
              ]),
              child: img,
            ),
          );
    final glow = n.ready ? _arcane.glow : _glowEmber;
    return Positioned(
      left: p.dx - 56,
      top: p.dy - size / 2,
      width: 112,
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
                  if (r?.extra case final x?)
                    Positioned(
                      left: -16,
                      bottom: -2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+',
                            style: TextStyle(
                              color: n.lit ? _brass : ForgeColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Opacity(
                            opacity: n.lit ? 1 : .45,
                            child: SealArt(seal: Seal(x, 1), size: 18),
                          ),
                        ],
                      ),
                    ),
                  if (n.locked)
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
            if (!n.single) _Pips(levels: n.levels),
            Text(
              label,
              key: n.lit ? Key('baum-lit-${n.id}') : null,
              maxLines: 1,
              style: TextStyle(
                color: n.lit
                    ? ForgeColors.text
                    : ForgeColors.muted.withValues(alpha: n.single ? .6 : 1),
                fontSize: n.single ? 9.5 : 11,
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

/// St.1–5 of a recipe: numbered pips, bright for each level ever owned.
class _Pips extends StatelessWidget {
  const _Pips({required this.levels});

  final Set<int> levels;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 1),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= Seal.maxLevel; i++)
          Container(
            key: levels.contains(i) ? Key('pip-lit-$i') : null,
            width: 13,
            height: 13,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: levels.contains(i) ? _brass : const Color(0xFF2E251E),
              border: Border.all(
                color: levels.contains(i)
                    ? _glowEmber
                    : const Color(0xFF5A4A3C),
                width: .8,
              ),
            ),
            child: Text(
              '$i',
              style: TextStyle(
                color: levels.contains(i)
                    ? const Color(0xFF2A1A0E)
                    : ForgeColors.muted.withValues(alpha: .7),
                fontSize: 8,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    ),
  );
}

/// The selected node: its recipe, who it suits, St.1–5 (forged levels,
/// the next one as a preview, the rest hidden) and the hint while dark.
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
      title = n.lit ? recipeName(l, r!).toUpperCase() : l.baumUndiscovered;
      final parts = r!.tier == 1
          ? l.sealComboName(sealStat(l, r.a), sealStat(l, r.b))
          : l.sealComboName(recipeName(l, r.base), sealStat(l, r.extra!));
      lines.add(Text(n.lit ? parts : '??? + ???', style: small));
      if (n.lit) {
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
      final first = compact ? math.max(1, n.tiers) : 1;
      final last = compact ? math.min(5, n.tiers + 1) : 5;
      for (var i = first; i <= last; i++) {
        final done = n.levels.contains(i);
        final next = i == n.tiers + 1 && (n.lit || n.ready);
        lines.add(
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    l.sealLevelShort(i),
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
      if (!n.lit) {
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
  _TreePainter(this.links, this.baseY);

  final List<(Path, bool, bool)> links;
  final double baseY;

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
    final sorted = [...links]..sort((x, y) => (x.$2 ? 1 : 0) - (y.$2 ? 1 : 0));
    for (final (path, lit, ready) in sorted) {
      if (lit) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _glowEmber.withValues(alpha: .35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = _brass
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFE6B0).withValues(alpha: .7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .8,
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

  @override
  bool shouldRepaint(_TreePainter old) => true;
}
