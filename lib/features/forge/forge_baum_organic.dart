part of 'forge_screen.dart';

// The Schmiede-Baum as a living tree in three looks to choose from. It is
// grown from the player's own history: the first seal ever owned is the
// root, every other single seal St.1 docks onto it, each higher level onto
// the level below of its stat, and every forged recipe level onto the
// exact seals it was forged from. Seals never owned hang on as dark
// ghosts; recipe levels not forged yet drift free as ??? with no line.

/// The three looks Philip chooses from.
enum _Look { stars, branch, net }

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

  /// Further sources drawn into it (the second seal of a recipe).
  final List<String> extra = [];
  final List<String> children = [];
  int depth = 0;
  int weight = 1;
}

/// The grown tree of [game]: nodes in unlock order (ghosts last).
class _Grown {
  _Grown(this.nodes, this.root, this.rank);

  final Map<String, _GN> nodes;
  final String root;

  /// Unlock rank of each owned key (0 = first).
  final Map<String, int> rank;

  static const hub = 'hub';

  factory _Grown.of(ForgeState f) {
    final nodes = <String, _GN>{};
    final rank = <String, int>{};
    final owned = [
      for (final k in f.order)
        if (_nodeOfKey(k) != null) k,
    ];
    for (final (i, k) in owned.indexed) {
      rank[k] = i;
    }
    String? idOf(String k) => _nodeOfKey(k);
    // With nothing owned yet the forge itself is the root.
    final root = owned.isEmpty ? hub : idOf(owned.first)!;
    if (owned.isEmpty) nodes[hub] = _GN(hub, hub, owned: true);
    bool placed(String k) => nodes.containsKey(idOf(k));
    for (final (i, k) in owned.indexed) {
      final id = idOf(k)!;
      if (i == 0) {
        nodes[id] = _GN(id, k, owned: true);
        continue;
      }
      final [name, lv] = k.split('@');
      final level = int.parse(lv);
      String parent = root;
      final extra = <String>[];
      if (SealType.values.asNameMap()[name] case final t?) {
        // The level below of the same stat, else the root.
        for (var below = level - 1; below >= 1; below--) {
          if (placed('${t.name}@$below')) {
            parent = _singleId(t, below);
            break;
          }
        }
      } else {
        final srcs = [
          for (final s in f.forged[k] ?? const <String>[])
            if (placed(s)) s,
        ]..sort((a, b) => (rank[b] ?? 0).compareTo(rank[a] ?? 0));
        if (srcs.isNotEmpty) {
          parent = idOf(srcs.first)!;
          extra.addAll(srcs.skip(1).map((s) => idOf(s)!));
        } else if (i > 0) {
          parent = idOf(owned[i - 1])!;
        }
      }
      nodes[id] = _GN(id, k, owned: true, parent: parent)..extra.addAll(extra);
    }
    // Seals never owned hang on as ghosts: St.1 at the root, the rest
    // under the level below.
    for (var lv = 1; lv <= Seal.maxLevel; lv++) {
      for (final t in SealType.values) {
        final id = _singleId(t, lv);
        if (nodes.containsKey(id)) continue;
        final parent = lv == 1 ? root : _singleId(t, lv - 1);
        nodes[id] = _GN(id, '${t.name}@$lv', owned: false, parent: parent);
      }
    }
    for (final n in nodes.values) {
      if (n.parent case final p?) nodes[p]!.children.add(n.id);
    }
    void walk(_GN n, int depth) {
      n.depth = depth;
      n.weight = 0;
      for (final c in n.children) {
        walk(nodes[c]!, depth + 1);
        n.weight += nodes[c]!.weight;
      }
      n.weight = math.max(1, n.weight);
    }

    walk(nodes[root]!, 0);
    return _Grown(nodes, root, rank);
  }
}

/// Where every node sits in one look, plus the drifting ??? levels.
class _Layout {
  _Layout(this.at, this.drift, this.bounds, this.hexes, this.hex);

  final Map<String, Offset> at;
  final Map<String, Offset> drift;
  final Rect bounds;

  /// [_Look.net]: centres of the cells taken.
  final List<Offset> hexes;
  final double hex;
}

/// A small deterministic wobble per id, so the tree looks grown.
double _jit(String id, int salt) {
  var h = 17 + salt;
  for (final c in id.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return (h % 1000) / 1000 - .5;
}

_Layout _layout(_Look look, _Grown g, List<String> drifting) {
  final at = <String, Offset>{};
  final hexes = <Offset>[];
  const hexR = 46.0;
  switch (look) {
    case _Look.stars:
      // Radial: each branch owns a slice of the circle by its size.
      const ring = 92.0;
      void place(_GN n, double a0, double a1) {
        final a = (a0 + a1) / 2 + _jit(n.id, 1) * .12;
        final r = n.depth * ring + _jit(n.id, 2) * 18;
        at[n.id] = Offset(math.cos(a) * r, math.sin(a) * r);
        var start = a0;
        final kids = n.children.map((c) => g.nodes[c]!).toList();
        final total = kids.fold(0, (s, k) => s + k.weight);
        for (final k in kids) {
          final span = (a1 - a0) * k.weight / total;
          place(k, start, start + span);
          start += span;
        }
      }

      place(g.nodes[g.root]!, -math.pi / 2, 3 * math.pi / 2);
    case _Look.branch:
      // Upwards: leaves side by side, each fork above its twigs' middle.
      var slot = 0.0;
      double place(_GN n) {
        final kids = n.children.map((c) => g.nodes[c]!).toList();
        double x;
        if (kids.isEmpty) {
          x = slot;
          slot += 1;
        } else {
          final xs = [for (final k in kids) place(k)];
          x = (xs.first + xs.last) / 2;
        }
        at[n.id] = Offset(
          x * 74 + _jit(n.id, 3) * 14,
          -n.depth * 98 + _jit(n.id, 4) * 22,
        );
        return x;
      }

      place(g.nodes[g.root]!);
      final rootX = at[g.root]!.dx;
      at.updateAll((_, p) => p - Offset(rootX, 0));
    case _Look.net:
      // A path over hex cells: each node takes the free cell next to its
      // parent that leads furthest out.
      final taken = <(int, int)>{};
      Offset centre((int, int) c) =>
          Offset(hexR * math.sqrt(3) * (c.$1 + c.$2 / 2), hexR * 1.5 * c.$2);
      const dirs = [(1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)];
      final cellOf = <String, (int, int)>{};
      void put(String id, (int, int) c) {
        taken.add(c);
        cellOf[id] = c;
        at[id] = centre(c);
      }

      put(g.root, (0, 0));
      final queue = [g.root];
      while (queue.isNotEmpty) {
        final n = g.nodes[queue.removeAt(0)]!;
        final pc = cellOf[n.id]!;
        final from = centre(pc);
        for (final (i, c) in n.children.indexed) {
          final kid = g.nodes[c]!;
          (int, int)? best;
          var score = -1e9;
          for (var ring = 1; ring <= 3 && best == null; ring++) {
            for (final d in dirs) {
              for (var s = 0; s < ring; s++) {
                final side = dirs[(dirs.indexOf(d) + 2) % 6];
                final cell = (
                  pc.$1 + d.$1 * ring + side.$1 * s,
                  pc.$2 + d.$2 * ring + side.$2 * s,
                );
                if (taken.contains(cell)) continue;
                final p = centre(cell);
                // Outwards from the root, the root's children spread round.
                final out = n.id == g.root
                    ? -(p - Offset.fromDirection(i * math.pi / 3 + .3, hexR))
                          .distance
                    : p.distance - from.distance * .9;
                final v = out + _jit(kid.id, 5) * 8;
                if (v > score) {
                  score = v;
                  best = cell;
                }
              }
            }
          }
          put(c, best!);
          queue.add(c);
        }
      }
      hexes.addAll(taken.map(centre));
  }
  // The ??? levels drift in six groups round (stars, net) or above
  // (branch) the tree, each recipe's St.1–5 close together.
  var box = _boundsOf(at.values);
  final drift = <String, Offset>{};
  final groups = <String, List<String>>{};
  for (final id in drifting) {
    groups.putIfAbsent(id.split('-').first, () => []).add(id);
  }
  for (final (gi, r) in Recipe.values.indexed) {
    final ids = groups[r.name] ?? const [];
    late Offset c;
    late double spread;
    if (look == _Look.branch) {
      final w = math.max(box.width, 520.0);
      c = Offset(
        box.center.dx - w / 2 + w * (gi + .5) / 6,
        box.top - 120 - (r.tier == 2 ? 150 : 0),
      );
      spread = 0;
    } else {
      final rad = math.max(box.width, box.height) / 2 + 150;
      final a = -math.pi / 2 + gi * math.pi / 3 + math.pi / 6;
      c = box.center + Offset(math.cos(a) * rad, math.sin(a) * rad);
      spread = a;
    }
    for (final id in ids) {
      final lv = int.parse(id.split('-').last);
      final t = (lv - 3).toDouble();
      // Branch: a little flower; round looks: a short arc along the rim.
      drift[id] = look == _Look.branch
          ? c + _petal(lv, 46)
          : c +
                Offset.fromDirection(spread + math.pi / 2, t * 52) +
                Offset.fromDirection(spread, t.abs() * -12);
    }
  }
  box = _boundsOf([...at.values, ...drift.values]).inflate(90);
  return _Layout(at, drift, box, hexes, hexR);
}

/// St.1–5 of one recipe as a little flower above the branch.
Offset _petal(int lv, double r) {
  if (lv == 1) return Offset.zero;
  final a = -math.pi / 2 + (lv - 2) * math.pi / 2 + math.pi / 4;
  return Offset(math.cos(a) * r * 1.15, math.sin(a) * r);
}

Rect _boundsOf(Iterable<Offset> ps) {
  if (ps.isEmpty) return Rect.zero;
  var l = double.infinity, t = double.infinity;
  var r = -double.infinity, b = -double.infinity;
  for (final p in ps) {
    l = math.min(l, p.dx);
    t = math.min(t, p.dy);
    r = math.max(r, p.dx);
    b = math.max(b, p.dy);
  }
  return Rect.fromLTRB(l, t, r, b);
}

/// One connection: [from] → [to], lit when both ends are owned; [grow] is
/// the key whose first look grows it in.
typedef _Edge = ({
  String from,
  String to,
  bool lit,
  String? grow,
  int weight,
  bool extra,
});

List<_Edge> _edgesOf(_Grown g) => [
  for (final n in g.nodes.values)
    if (n.parent case final p?) ...[
      (
        from: p,
        to: n.id,
        lit: n.owned && g.nodes[p]!.owned,
        grow: n.owned ? n.key : null,
        weight: n.weight,
        extra: false,
      ),
      for (final x in n.extra)
        (from: x, to: n.id, lit: true, grow: n.key, weight: 1, extra: true),
    ],
];

/// Paints the background of a look and its connections, growing new ones
/// in one after another.
class _GrownPainter extends CustomPainter {
  _GrownPainter({
    required this.look,
    required this.layout,
    required this.edges,
    required this.shift,
    required this.grow,
    required this.growing,
    required this.maxWeight,
    required this.root,
  }) : super(repaint: grow);

  /// Id of the root node.
  final String root;

  final _Look look;
  final _Layout layout;
  final List<_Edge> edges;
  final Offset shift;
  final Animation<double> grow;

  /// Keys growing now, in unlock order.
  final List<String> Function() growing;
  final int maxWeight;

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
    _background(canvas, size);
    final order = growing();
    for (final e in [
      ...edges,
    ]..sort((a, b) => (a.lit ? 1 : 0) - (b.lit ? 1 : 0))) {
      final p = layout.at[e.from];
      final q = layout.at[e.to];
      if (p == null || q == null) continue;
      final a = p + shift;
      final b = q + shift;
      var path = _curve(a, b, e.to);
      final t = share(order, e.grow, grow.value);
      if (t <= 0) continue;
      if (t < 1) path = _TreeLines.part(path, t);
      if (!e.lit) {
        _TreeLines.dotted(canvas, path, const Color(0x55A89A88));
        continue;
      }
      if (e.extra) {
        // The second seal of a recipe: a faint thread, the branch itself
        // comes from the newer one.
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = _tint.withValues(alpha: .35),
        );
      } else {
        _stroke(canvas, path, e.weight);
      }
      if (t < 1) _TreeLines.spark(canvas, path, _tint);
    }
  }

  Color get _tint => switch (look) {
    _Look.stars => const Color(0xFF9FE6FF),
    _Look.branch => _glowEmber,
    _Look.net => const Color(0xFFFFB347),
  };

  Path _curve(Offset a, Offset b, String id) {
    final path = Path()..moveTo(a.dx, a.dy);
    switch (look) {
      case _Look.stars:
        final m = (a + b) / 2;
        final d = b - a;
        final n = Offset(-d.dy, d.dx) * (.18 * (_jit(id, 7) > 0 ? 1 : -1));
        final c = m + n;
        path.quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
      case _Look.branch:
        final dy = (b.dy - a.dy) * .55;
        path.cubicTo(a.dx, a.dy + dy, b.dx, b.dy - dy, b.dx, b.dy);
      case _Look.net:
        path.lineTo(b.dx, b.dy);
    }
    return path;
  }

  void _stroke(Canvas canvas, Path path, int weight) {
    switch (look) {
      case _Look.stars:
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..color = const Color(0xFF6FC8FF).withValues(alpha: .28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = const Color(0xFFE6F6FF),
        );
      case _Look.branch:
        final w = 2.2 + 6 * math.sqrt(weight / math.max(1, maxWeight));
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = w + 6
            ..color = _glowEmber.withValues(alpha: .25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = w
            ..color = const Color(0xFF7A5230),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = math.max(1, w * .35)
            ..color = const Color(0xFFFFC874).withValues(alpha: .85),
        );
      case _Look.net:
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..color = const Color(0xFFFF8A2A).withValues(alpha: .3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFE0A050),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFFFFF0C8),
        );
    }
  }

  void _background(Canvas canvas, Size box) {
    // Painted well past the canvas, so zooming out never shows its edge.
    final rect = (Offset.zero & box).inflate(1400);
    final size = rect.size;
    canvas.save();
    canvas.translate(rect.left, rect.top);
    _backdrop(canvas, size, -rect.topLeft);
    canvas.restore();
  }

  void _backdrop(Canvas canvas, Size size, Offset at) {
    final rect = Offset.zero & size;
    final root = (layout.at[this.root] ?? Offset.zero) + shift + at;
    switch (look) {
      case _Look.stars:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = RadialGradient(
              center: Alignment(
                root.dx / size.width * 2 - 1,
                root.dy / size.height * 2 - 1,
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
        for (
          var i = 0;
          i < math.min(2600, size.width * size.height / 2600);
          i++
        ) {
          final p = Offset(
            rnd.nextDouble() * size.width,
            rnd.nextDouble() * size.height,
          );
          dot.color = Colors.white.withValues(
            alpha: .1 + rnd.nextDouble() * .35,
          );
          canvas.drawCircle(p, rnd.nextDouble() * 1.2 + .3, dot);
        }
        for (var r = 92.0; r < 92 * 12; r += 92) {
          canvas.drawCircle(
            root,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = .6
              ..color = const Color(0xFF9FC8FF).withValues(alpha: .07),
          );
        }
      case _Look.branch:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF120D0A), Color(0xFF241810), Color(0xFF2E1C10)],
            ).createShader(rect),
        );
        // Roots under the first seal.
        final roots = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF5A3C22);
        for (final (dx, w) in [
          (-70.0, 5.0),
          (-25.0, 6.0),
          (30.0, 6.0),
          (80.0, 4.0),
        ]) {
          canvas.drawPath(
            Path()
              ..moveTo(root.dx, root.dy + 14)
              ..cubicTo(
                root.dx,
                root.dy + 50,
                root.dx + dx * .6,
                root.dy + 40,
                root.dx + dx,
                root.dy + 80,
              ),
            roots..strokeWidth = w,
          );
        }
      case _Look.net:
        canvas.drawRect(rect, Paint()..color = const Color(0xFF111316));
        final h = layout.hex;
        final rows = (size.height / (h * 1.5)).ceil() + 2;
        final cols = (size.width / (h * math.sqrt(3))).ceil() + 2;
        final faint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7
          ..color = const Color(0xFFB08A50).withValues(alpha: .07);
        final o = root;
        final r0 = (-o.dy / (h * 1.5)).floor() - 1;
        for (var r = r0; r < r0 + rows; r++) {
          final c0 = (-(o.dx) / (h * math.sqrt(3)) - r / 2).floor() - 1;
          for (var c = c0; c < c0 + cols; c++) {
            final p = o + Offset(h * math.sqrt(3) * (c + r / 2), h * 1.5 * r);
            canvas.drawPath(_hexPath(p, h * .96), faint);
          }
        }
        for (final p in layout.hexes) {
          final hp = _hexPath(p + shift + at, h * .96);
          canvas.drawPath(
            hp,
            Paint()..color = const Color(0xFFFF9A3C).withValues(alpha: .06),
          );
          canvas.drawPath(
            hp,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = const Color(0xFFD9A060).withValues(alpha: .28),
          );
        }
    }
  }

  static Path _hexPath(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = math.pi / 6 + i * math.pi / 3;
      final v = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? p.moveTo(v.dx, v.dy) : p.lineTo(v.dx, v.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(_GrownPainter old) => true;
}

/// Path helpers shared by the looks.
abstract final class _TreeLines {
  /// The first [t] of [path].
  static Path part(Path path, double t) {
    final out = Path();
    for (final m in path.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * t), Offset.zero);
    }
    return out;
  }

  /// A spark at the growing tip.
  static void spark(Canvas canvas, Path path, Color tint) {
    for (final m in path.computeMetrics()) {
      if (m.length == 0) continue;
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
}
