part of 'forge_screen.dart';

// The Schmiede-Baum as a star map grown from the player's own history.
// The first seal ever owned sits in the middle; every other single seal
// St.1 docks onto it, each higher level onto the level below of its stat,
// and every forged recipe level onto the exact seals it was forged from.
//
// To stay calm with many seals every kind keeps its own slice of the sky:
// six sectors round the middle, a stat, the recipe of it and the next
// stat, and so on (Schwung, Ausdauer, Zähigkeit, Schutz, Glück, Fährte),
// so a level-1 recipe always sits between its two seals. Each level is one
// ring further out. Level-2 recipes sit just outside their level-1 recipe;
// the thread to their third seal runs round the outside of the ring, never
// across the middle. Seals never owned hang on as dark ghosts; recipe
// levels not forged yet drift in their place with no line.

/// A node of the grown tree.
class _GN {
  _GN(this.id, this.key, {required this.owned, this.parent});

  final String id;

  /// [ForgeState.seenKey] of the node.
  final String key;

  /// Ever owned (lit); otherwise a dark ghost of a single seal.
  final bool owned;

  /// Node it docks onto; null for the root.
  final String? parent;

  /// Further sources drawn into it (the other seal of a recipe).
  final List<String> extra = [];
}

/// The grown tree of a [ForgeState].
class _Grown {
  _Grown(this.nodes, this.root);

  final Map<String, _GN> nodes;
  final String root;

  /// Root while nothing is owned yet: the forge itself.
  static const hub = 'hub';

  factory _Grown.of(ForgeState f) {
    final owned = [
      for (final k in f.order)
        if (_nodeOfKey(k) != null) k,
    ];
    final rank = {for (final (i, k) in owned.indexed) k: i};
    final root = owned.isEmpty ? hub : _nodeOfKey(owned.first)!;
    final nodes = <String, _GN>{
      root: _GN(root, owned.isEmpty ? hub : owned.first, owned: true),
    };
    // Single seals: owned ones dock onto the highest owned level below
    // (else the root), ghosts onto the level below.
    for (final t in SealType.values) {
      for (var lv = 1; lv <= Seal.maxLevel; lv++) {
        final id = _singleId(t, lv);
        if (id == root) continue;
        final key = '${t.name}@$lv';
        final own = rank.containsKey(key);
        var parent = root;
        if (own) {
          for (var below = lv - 1; below >= 1; below--) {
            if (rank.containsKey('${t.name}@$below')) {
              parent = _singleId(t, below);
              break;
            }
          }
        } else if (lv > 1) {
          parent = _singleId(t, lv - 1);
        }
        nodes[id] = _GN(id, key, owned: own, parent: parent);
      }
    }
    // Recipe levels, in unlock order, dock onto the seals they came from:
    // a level-2 recipe onto its level-1 recipe (right next to it), a
    // level-1 recipe onto the newer of its two seals.
    for (final k in owned) {
      final [name, lv] = k.split('@');
      final r = Recipe.values.asNameMap()[name];
      final id = _nodeOfKey(k)!;
      if (r == null || id == root) continue;
      final srcs = [
        for (final s in f.forged[k] ?? _sourcesOf(r, int.parse(lv)))
          if (nodes.containsKey(_nodeOfKey(s))) s,
      ];
      int score(String s) =>
          (s.startsWith('${r.base.name}@') && r.tier == 2 ? 1000 : 0) +
          (rank[s] ?? -1);
      srcs.sort((a, b) => score(b).compareTo(score(a)));
      nodes[id] = _GN(
        id,
        k,
        owned: true,
        parent: srcs.isEmpty ? root : _nodeOfKey(srcs.first),
      )..extra.addAll(srcs.skip(1).map((s) => _nodeOfKey(s)!));
    }
    return _Grown(nodes, root);
  }

  /// What [r] at [level] is forged from when the save does not say.
  static List<String> _sourcesOf(Recipe r, int level) => r.tier == 1
      ? ['${r.a.name}@$level', '${r.b.name}@$level']
      : ['${r.base.name}@$level', '${r.extra!.name}@$level'];
}

/// Where every node sits, plus the drifting ??? levels.
class _Layout {
  _Layout(this.at, this.drift, this.bounds);

  /// Node positions round the root at (0, 0).
  final Map<String, Offset> at;
  final Map<String, Offset> drift;
  final Rect bounds;
}

/// Radius of the ring of [level].
double _ringOf(int level) => 150 + (level - 1) * 125.0;

/// How far out of its ring a level-2 recipe sits.
const double _tier2Out = 58;

/// How far out of its ring a recipe sits, so it hangs between its seals.
const double _recipeOut = 42;

/// Sector (0–5) of each kind: stat, recipe of it and the next stat, …
int _sectorOf(String name) => switch (name) {
  'stride' => 0,
  'ausdauer' => 1,
  'wanderstern' => 1,
  'grit' => 2,
  'schutz' => 3,
  'glutherz' => 3,
  'fortune' => 4,
  _ => 5, // faehrte, spurenleser
};

/// A small deterministic wobble per id, so the map looks grown.
double _jit(String id, int salt) {
  var h = 17 + salt;
  for (final c in id.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return (h % 1000) / 1000 - .5;
}

_Layout _layout(_Grown g, List<String> drifting) {
  // The root's own sector points up.
  final rootName = g.nodes[g.root]!.key.split('@').first;
  final turn = g.root == _Grown.hub ? 0 : _sectorOf(rootName);
  Offset slot(String key) {
    final [name, lv] = key.split('@');
    final level = int.parse(lv);
    final tier2 = Recipe.values.asNameMap()[name]?.tier == 2;
    final id = _nodeOfKey(key)!;
    // Level-2 recipes lean a little to the side of their third seal's
    // thread, level-1 recipes a little the other way.
    final lean = Recipe.values.asNameMap().containsKey(name)
        ? (tier2 ? .1 : -.05)
        : 0.0;
    final a =
        -math.pi / 2 +
        (_sectorOf(name) - turn) * math.pi / 3 +
        lean +
        _jit(id, 1) * .05;
    final r =
        _ringOf(level) +
        (tier2 ? _tier2Out : 0) +
        (Recipe.values.asNameMap().containsKey(name) ? _recipeOut : 0) +
        _jit(id, 2) * 10;
    return Offset.fromDirection(a, r);
  }

  final at = <String, Offset>{
    for (final n in g.nodes.values)
      n.id: n.id == g.root ? Offset.zero : slot(n.key),
  };
  final drift = <String, Offset>{
    for (final id in drifting)
      id: slot(
        '${id.substring(0, id.lastIndexOf('-'))}@'
        '${id.substring(id.lastIndexOf('-') + 1)}',
      ),
  };
  final box = _boundsOf([...at.values, ...drift.values]).inflate(110);
  return _Layout(at, drift, box);
}

Rect _boundsOf(Iterable<Offset> ps) {
  var l = 0.0, t = 0.0, r = 0.0, b = 0.0;
  for (final p in ps) {
    l = math.min(l, p.dx);
    t = math.min(t, p.dy);
    r = math.max(r, p.dx);
    b = math.max(b, p.dy);
  }
  return Rect.fromLTRB(l, t, r, b);
}

/// One connection: [from] → [to], lit when both ends are owned; [grow] is
/// the key whose first look grows it in. [extra] lines are the faint
/// thread to a recipe's other seal.
typedef _Edge = ({String from, String to, bool lit, String? grow, bool extra});

List<_Edge> _edgesOf(_Grown g) => [
  for (final n in g.nodes.values)
    if (n.parent case final p?) ...[
      (
        from: p,
        to: n.id,
        lit: n.owned && g.nodes[p]!.owned,
        grow: n.owned ? n.key : null,
        extra: false,
      ),
      for (final x in n.extra)
        (from: x, to: n.id, lit: g.nodes[x]!.owned, grow: n.key, extra: true),
    ],
];

/// Line from [a] to [b] round the root at [c]: straight along a ray,
/// bowed along the ring between neighbours, and round the outside of the
/// ring when the two ends lie far apart ([lane] keeps such threads apart).
Path _starPath(Offset c, Offset a, Offset b, int lane) {
  final pa = a - c;
  final pb = b - c;
  final path = Path()..moveTo(a.dx, a.dy);
  if (pa.distance < 1 || pb.distance < 1) {
    return path..lineTo(b.dx, b.dy);
  }
  var turn = pb.direction - pa.direction;
  while (turn > math.pi) {
    turn -= 2 * math.pi;
  }
  while (turn <= -math.pi) {
    turn += 2 * math.pi;
  }
  if (turn.abs() < .05) return path..lineTo(b.dx, b.dy);
  if (turn.abs() <= math.pi * .45) {
    // Neighbours: bow outwards, along the ring.
    final m = (pa + pb) / 2;
    final r = math.max(pa.distance, pb.distance) * 1.02;
    final k = c + Offset.fromDirection(m.direction, r);
    return path..quadraticBezierTo(k.dx, k.dy, b.dx, b.dy);
  }
  // Far apart: out to an orbit in the free band past the nearer end (the
  // seal's ring), round it, out to the other end. A turn of half the
  // circle always goes the same way round.
  if ((turn.abs() - math.pi).abs() < .2) turn = turn.abs();
  final r = math.min(pa.distance, pb.distance) + 70 + lane * 8;
  final from = c + Offset.fromDirection(pa.direction, r);
  final to = c + Offset.fromDirection(pb.direction, r);
  path.lineTo(from.dx, from.dy);
  path.arcTo(Rect.fromCircle(center: c, radius: r), pa.direction, turn, false);
  path.lineTo(to.dx, to.dy);
  return path..lineTo(b.dx, b.dy);
}

/// Paints the sky and the connections, growing new ones in one after
/// another.
class _GrownPainter extends CustomPainter {
  _GrownPainter({
    required this.layout,
    required this.edges,
    required this.shift,
    required this.grow,
    required this.growing,
    required this.root,
  }) : super(repaint: grow);

  final _Layout layout;
  final List<_Edge> edges;
  final Offset shift;
  final Animation<double> grow;

  /// Keys growing now, in unlock order.
  final List<String> Function() growing;

  /// Id of the root node.
  final String root;

  static const _tint = Color(0xFF9FE6FF);

  /// Share 0–1 of the line into [key] drawn at grow value [v].
  static double share(List<String> order, String? key, double v) {
    if (key == null) return 1;
    final i = order.indexOf(key);
    if (i < 0) return 1;
    final n = order.length;
    final start = n == 1 ? 0.0 : i / n * .75;
    final len = n == 1 ? 1.0 : .25 + .75 / n;
    return ((v - start) / len).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = (layout.at[root] ?? Offset.zero) + shift;
    _sky(canvas, size, c);
    final order = growing();
    // Ghosts first, then threads, then the lit branches on top.
    int rankOf(_Edge e) => !e.lit ? 0 : (e.extra ? 1 : 2);
    for (final e in [
      ...edges,
    ]..sort((a, b) => rankOf(a).compareTo(rankOf(b)))) {
      final p = layout.at[e.from];
      final q = layout.at[e.to];
      if (p == null || q == null) continue;
      final lane = switch (Recipe.values.asNameMap()[e.to.split('-').first]) {
        final r? when r.tier == 2 => r.index - 3,
        _ => 0,
      };
      var path = _starPath(c, p + shift, q + shift, lane);
      final t = share(order, e.grow, grow.value);
      if (t <= 0) continue;
      if (t < 1) path = _TreeLines.part(path, t);
      if (!e.lit) {
        _TreeLines.dotted(canvas, path, const Color(0x55A8B4C8));
      } else if (e.extra) {
        // The other seal of a recipe: a faint thread, the branch itself
        // comes from the first.
        _TreeLines.dashed(canvas, path, _tint.withValues(alpha: .32));
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..color = const Color(0xFF6FC8FF).withValues(alpha: .26)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0xFFE6F6FF),
        );
      }
      if (t < 1 && e.lit) _TreeLines.spark(canvas, path, _tint);
    }
  }

  /// Night sky round the root, with one faint ring per level.
  void _sky(Canvas canvas, Size box, Offset c) {
    // Painted well past the canvas, so zooming out never shows its edge.
    final rect = (Offset.zero & box).inflate(1400);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (c.dx - rect.left) / rect.width * 2 - 1,
            (c.dy - rect.top) / rect.height * 2 - 1,
          ),
          radius: .35,
          colors: const [
            Color(0xFF1A2440),
            Color(0xFF0C1020),
            Color(0xFF07080F),
          ],
        ).createShader(rect),
    );
    final rnd = math.Random(7);
    final dot = Paint();
    for (var i = 0; i < 2600; i++) {
      final p =
          rect.topLeft +
          Offset(rnd.nextDouble() * rect.width, rnd.nextDouble() * rect.height);
      dot.color = Colors.white.withValues(alpha: .08 + rnd.nextDouble() * .3);
      canvas.drawCircle(p, rnd.nextDouble() * 1.1 + .3, dot);
    }
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0xFF9FC8FF).withValues(alpha: .08);
    for (var lv = 1; lv <= Seal.maxLevel; lv++) {
      canvas.drawCircle(c, _ringOf(lv), ring);
      // Which ring is which level, between two sectors.
      final tp = TextPainter(
        text: TextSpan(
          text: 'St.$lv',
          style: TextStyle(
            color: const Color(0xFF9FC8FF).withValues(alpha: .35),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = c + Offset.fromDirection(-math.pi / 3, _ringOf(lv) - 18);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_GrownPainter old) => true;
}

/// Path helpers.
abstract final class _TreeLines {
  /// The first [t] of [path].
  static Path part(Path path, double t) {
    final out = Path();
    var total = 0.0;
    final metrics = path.computeMetrics().toList();
    for (final m in metrics) {
      total += m.length;
    }
    var left = total * t;
    for (final m in metrics) {
      if (left <= 0) break;
      out.addPath(m.extractPath(0, math.min(m.length, left)), Offset.zero);
      left -= m.length;
    }
    return out;
  }

  /// A spark at the growing tip.
  static void spark(Canvas canvas, Path path, Color tint) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty || metrics.last.length == 0) return;
    final m = metrics.last;
    final tip = m.getTangentForOffset(m.length)!.position;
    canvas.drawCircle(
      tip,
      7,
      Paint()
        ..color = tint.withValues(alpha: .75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(tip, 2.4, Paint()..color = const Color(0xFFFFF6DC));
  }

  /// A faint dotted line (to a seal never owned).
  static void dotted(Canvas canvas, Path path, Color color) {
    final dot = Paint()..color = color;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawCircle(m.getTangentForOffset(d)!.position, 1.1, dot);
      }
    }
  }

  /// A thin dashed line.
  static void dashed(Canvas canvas, Path path, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = color;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, math.min(m.length, d + 5)), paint);
      }
    }
  }
}
