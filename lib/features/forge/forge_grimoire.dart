part of 'forge_screen.dart';

// Kombinieren, "Verblasstes Grimoire": a dark aged page whose faded glyphs
// wake as seals are placed; the result lies under a wax seal until the
// reveal breaks it. Presentation only: every value comes from _recipe;
// costs and the fail chance stay in the plaque and the line below.

/// The combine reveal takes a little longer than the hammer's build-up.
const _combineStrikeTime = Duration(milliseconds: 1700);

/// Lets tests turn the drifting background off so they can settle.
@visibleForTesting
bool forgeAmbientMotion = true;

class _GrimoireCard extends StatefulWidget {
  const _GrimoireCard(this.r);

  final _RecipeParts r;

  @override
  State<_GrimoireCard> createState() => _GrimoireCardState();
}

class _GrimoireCardState extends State<_GrimoireCard>
    with SingleTickerProviderStateMixin {
  /// Slow ambient time: shimmering glyphs and drifting dust.
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
    value: .3,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _steer();
  }

  @override
  void didUpdateWidget(_GrimoireCard old) {
    super.didUpdateWidget(old);
    _steer();
  }

  /// The page only drifts while it is the visible, active tab: it stops
  /// when another app tab is shown (TickerMode), for the other forge tab
  /// and with reduced motion.
  void _steer() {
    final run =
        forgeAmbientMotion &&
        widget.r.active &&
        TickerMode.of(context) &&
        !MediaQuery.disableAnimationsOf(context);
    if (!run) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strike = widget.r.strike;
    return AnimatedBuilder(
      animation: Listenable.merge([_ambient, ?strike?.anim]),
      builder: (context, _) => _scene(
        context,
        _ambient.value,
        strike?.anim.value,
        strike?.outcome.success ?? true,
      ),
    );
  }

  Widget _scene(BuildContext context, double amb, double? t, bool success) {
    final r = widget.r;
    final l = AppLocalizations.of(context);
    final whisper = r.a == null
        ? l.forgeMysteryIdle
        : r.made == null
        ? l.forgeMysteryStir
        : l.forgeMysteryReady;
    final mood = _Mood(
      amb: amb,
      t: t,
      success: success,
      a: r.a != null,
      b: r.b != null,
      ready: r.made != null,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final c = Offset(w / 2, h / 2 - 7);
          final side = math.min(108.0, w / 2 - 50);
          Widget slot(Seal? s, double x) => Positioned(
            left: x - 26,
            top: c.dy - 26,
            child: _Slot(seal: s, palette: _arcane, size: 52),
          );
          return Stack(
            children: [
              Positioned.fill(child: const _GrimoireBackdrop()),
              Positioned.fill(
                child: CustomPaint(painter: _GrimoireBack(mood, c)),
              ),
              slot(r.a, c.dx - side),
              slot(r.b, c.dx + side),
              Positioned(
                left: c.dx - 32,
                top: c.dy - 32,
                width: 64,
                height: 64,
                child: _VeiledResult(seal: r.made, mood: mood),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _GrimoireFront(mood, c)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 3,
                child: Text(
                  whisper,
                  key: r.active ? const Key('forge-whisper') : null,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xCCD9C7A0),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    letterSpacing: .4,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Everything the painters need to know about the moment.
class _Mood {
  const _Mood({
    required this.amb,
    required this.t,
    required this.success,
    required this.a,
    required this.b,
    required this.ready,
  });

  /// Ambient time 0..1, looping.
  final double amb;

  /// Reveal time 0..1 while a combine runs.
  final double? t;
  final bool success;
  final bool a;
  final bool b;
  final bool ready;

  /// 0..1 how far the build-up before the reveal has come.
  double get build => t == null ? 0 : (t! / _reveal).clamp(0.0, 1.0);

  /// 0..1 after the reveal, or null before it.
  double? get after =>
      t == null || t! < _reveal ? null : (t! - _reveal) / (1 - _reveal);

  /// 0 (nothing placed) to 1 (both seals placed).
  double get wake => ready ? 1 : (a ? .5 : 0) + (b ? .5 : 0);

  bool get failed => after != null && !success;

  bool get revealed => after != null && success;
}

class _GrimoireBackdrop extends StatelessWidget {
  const _GrimoireBackdrop();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFF0E0A08),
      image: const DecorationImage(
        image: AssetImage('assets/forge/combine_grimoire.webp'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Color(0x40000000), BlendMode.darken),
      ),
      border: Border.all(color: const Color(0xFF3B2A18), width: 1.2),
    ),
  );
}

/// Seeded pseudo noise so particles keep their paths frame to frame.
double _hash(int i, int salt) {
  final x = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
  return x - x.floorToDouble();
}

/// Behind the seals: the glyph ring and drifting dust.
class _GrimoireBack extends CustomPainter {
  _GrimoireBack(this.m, this.c);

  final _Mood m;
  final Offset c;

  @override
  void paint(Canvas canvas, Size size) {
    _glyphs(canvas);
    _vignette(canvas, size);
  }

  void _vignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: .95,
          colors: [Color(0x00000000), Color(0x00000000), Color(0x99000000)],
          stops: [0, .6, 1],
        ).createShader(rect),
    );
  }

  void _glyphs(Canvas canvas) {
    const n = 14;
    const radius = 41.0;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = Color.lerp(
        const Color(0x553A2A18),
        const Color(0x996FE3D2),
        m.wake * .7,
      )!;
    canvas.drawCircle(c, radius - 9, ring);
    canvas.drawCircle(c, radius + 9, ring);
    final u = m.after;
    for (var i = 0; i < n; i++) {
      final ang = -math.pi / 2 + i * 2 * math.pi / n;
      final p = c + Offset(math.cos(ang), math.sin(ang)) * radius;
      final left = math.cos(ang) < -.01;
      final right = math.cos(ang) > .01;
      var lit = m.ready
          ? 1.0
          : (left && m.a) || (right && m.b)
          ? .75
          : 0.0;
      // A slow shimmer, and a chase around the ring while it builds up.
      lit *= .75 + .25 * math.sin(m.amb * 2 * math.pi * 6 + i * 1.7);
      if (m.t != null) {
        final chase = (i / n - m.build * 3) % 1;
        lit = math.max(lit, m.build * (1 - chase).clamp(0.0, 1.0));
      }
      if (u != null) lit = m.success ? 1 - .3 * u : lit * (1 - u);
      final ink = Color.lerp(
        const Color(0x663A2A18),
        m.failed ? const Color(0xFF8C8580) : const Color(0xFF7FF0DE),
        lit.clamp(0.0, 1.0),
      )!;
      if (lit > .05) {
        canvas.drawCircle(
          p,
          7,
          Paint()
            ..color = const Color(0xFF3FBFB0).withValues(alpha: .35 * lit)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      _glyph(canvas, p, i, ink);
    }
    _dust(canvas, const Color(0xFFE8D6A8), 16, .35);
  }

  /// A small made-up sigil, the same for the same [i].
  void _glyph(Canvas canvas, Offset p, int i, Color color) {
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p + const Offset(0, -5), p + const Offset(0, 5), pen);
    final k = (_hash(i, 3) * 4).floor();
    switch (k) {
      case 0:
        canvas.drawCircle(p + const Offset(0, -2), 2.4, pen);
      case 1:
        canvas.drawLine(p + const Offset(-4, -3), p + const Offset(4, 3), pen);
      case 2:
        canvas.drawLine(p + const Offset(-3, 1), p + const Offset(0, -3), pen);
        canvas.drawLine(p + const Offset(3, 1), p + const Offset(0, -3), pen);
      default:
        canvas.drawLine(p + const Offset(-4, 2), p + const Offset(4, 2), pen);
        canvas.drawCircle(p + const Offset(0, -3), 1.2, pen);
    }
  }

  void _dust(Canvas canvas, Color color, int n, double alpha) {
    final size = Size(c.dx * 2, c.dy * 2 + 14);
    for (var i = 0; i < n; i++) {
      final speed = .3 + _hash(i, 1) * .7;
      final x =
          _hash(i, 2) * size.width + math.sin(m.amb * 2 * math.pi * 3 + i) * 6;
      final y = (_hash(i, 4) - m.amb * speed * 4) % 1 * size.height;
      final tw = .5 + .5 * math.sin(m.amb * 2 * math.pi * 9 + i * 2.3);
      canvas.drawCircle(
        Offset(x, y),
        .7 + _hash(i, 5) * 1.1,
        Paint()..color = color.withValues(alpha: alpha * tw),
      );
    }
  }

  @override
  bool shouldRepaint(_GrimoireBack old) => true;
}

/// In front of the seals: the burst or the grey puff after the reveal.
class _GrimoireFront extends CustomPainter {
  _GrimoireFront(this.m, this.c);

  final _Mood m;
  final Offset c;

  @override
  void paint(Canvas canvas, Size size) {
    final u = m.after;
    if (u == null) return;
    if (m.success) {
      const color = Color(0xFF8FF0E2);
      final radius = 30 + 70 * u;
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: .85 * (1 - u)),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
      for (var i = 0; i < 16; i++) {
        final ang = i * 2 * math.pi / 16 + _hash(i, 7);
        final d = 20 + 55 * u * (.6 + .4 * _hash(i, 8));
        canvas.drawCircle(
          c + Offset(math.cos(ang), math.sin(ang)) * d,
          1.6 * (1 - u) + .4,
          Paint()..color = color.withValues(alpha: 1 - u),
        );
      }
    } else {
      final radius = 26 + 14 * u;
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..color = const Color(
            0xFF8C8580,
          ).withValues(alpha: .45 * (1 - u * .5))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
  }

  @override
  bool shouldRepaint(_GrimoireFront old) => true;
}

/// The result: an empty ring, then hidden (wax or a dark silhouette with
/// its level), revealed in colour only after a successful combine.
class _VeiledResult extends StatelessWidget {
  const _VeiledResult({required this.seal, required this.mood});

  final Seal? seal;
  final _Mood mood;

  @override
  Widget build(BuildContext context) {
    final s = seal;
    final m = mood;
    final accent = _arcane.accent;
    final ring = BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0x66000000),
      border: Border.all(color: accent.withValues(alpha: s == null ? .3 : .55)),
    );
    if (s == null) {
      return DecoratedBox(
        decoration: ring,
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              color: accent.withValues(alpha: .35),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    final u = m.after;
    final shake = m.t == null || u != null
        ? Offset.zero
        : Offset(
            math.sin(m.t! * 90) * 1.6 * m.build,
            math.cos(m.t! * 70) * .8 * m.build,
          );
    final shown = m.revealed ? Curves.easeOut.transform(u!) : 0.0;
    final hidden = Image.asset(
      'assets/forge/combine_wax.webp',
      width: 54,
      height: 54,
    );
    return Stack(
      key: const Key('forge-result'),
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        DecoratedBox(decoration: ring, child: const SizedBox.expand()),
        Transform.translate(
          offset: shake,
          child: Opacity(
            opacity: m.failed ? (1 - .6 * u!) : 1 - shown,
            child: Transform.scale(scale: 1 + .25 * shown, child: hidden),
          ),
        ),
        if (shown > 0)
          Opacity(
            opacity: shown,
            child: Transform.scale(
              scale: .7 + .3 * shown,
              child: SealArt(seal: s, size: 58, showLevel: true),
            ),
          ),
        if (shown == 0)
          Positioned(
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xDD0B0A12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: .7)),
              ),
              child: Text(
                AppLocalizations.of(context).sealLevelShort(s.level),
                style: TextStyle(
                  color: accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
