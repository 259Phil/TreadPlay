part of 'forge_screen.dart';

// Sets "Aufwerten" (riveted iron, ember, copper) apart from "Kombinieren"
// (the faded grimoire in forge_grimoire.dart, teal, verdigris).
// Presentation only: every value shown comes from _recipe.

class _Palette {
  const _Palette({
    required this.glow,
    required this.accent,
    required this.deep,
    required this.light,
    required this.face,
    required this.slab,
    required this.fg,
    required this.icon,
  });

  final Color glow;
  final Color accent;
  final Color deep;
  final Color light;
  final List<Color> face;
  final Color slab;
  final Color fg;
  final String icon;
}

const _ember = _Palette(
  glow: Color(0xFFE0782F),
  accent: Color(0xFFE39255),
  deep: Color(0xFF6E2E12),
  light: Color(0xFFF6C58E),
  face: [
    Color(0xFFF4BC84),
    Color(0xFFDB8645),
    Color(0xFFB05A28),
    Color(0xFF7E3A16),
  ],
  slab: Color(0xFF451D0A),
  fg: Color(0xFF2A1206),
  icon: 'assets/nav/nav_schmiede.webp',
);

const _arcane = _Palette(
  glow: Color(0xFF3FBFB0),
  accent: Color(0xFF6FD6C8),
  deep: Color(0xFF16423E),
  light: Color(0xFFBFF2EA),
  face: [
    Color(0xFFA6E6DA),
    Color(0xFF5DBAAC),
    Color(0xFF34887D),
    Color(0xFF1F5C55),
  ],
  slab: Color(0xFF0D2A27),
  fg: Color(0xFF05201C),
  icon: 'assets/forge/icon_fuse.webp',
);

_Palette _paletteOf(_Mode m) => m == _Mode.up ? _ember : _arcane;

/// Everything the recipe panel shows, already worked out by _recipe.
class _RecipeParts {
  const _RecipeParts({
    required this.mode,
    required this.active,
    required this.a,
    required this.b,
    required this.made,
    required this.title,
    required this.costs,
    required this.slider,
    required this.fail,
    required this.hint,
    this.strike,
  });

  final _Mode mode;
  final bool active;
  final Seal? a;
  final Seal? b;
  final Seal? made;
  final String title;
  final Widget? costs;
  final Widget slider;
  final Widget fail;
  final Widget hint;

  /// The running reveal of a forge in this tab, if any.
  final _Strike? strike;
}

Widget _modeBackdrop(_Mode mode, Widget child) {
  final p = _paletteOf(mode);
  const alpha = .12;
  return Stack(
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.45),
                radius: .95,
                colors: [
                  p.glow.withValues(alpha: alpha),
                  p.glow.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
      child,
    ],
  );
}

Widget _recipePanel(BuildContext context, _RecipeParts r) {
  final p = _paletteOf(r.mode);
  final up = r.mode == _Mode.up;
  final Widget card = SizedBox(
    height: 124,
    child: up ? _IronCard(r) : _GrimoireCard(r),
  );
  final body = Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Plaque(palette: p, title: r.title, costs: r.costs),
      const SizedBox(height: 6),
      card,
      const SizedBox(height: 2),
      r.slider,
      r.fail,
      const SizedBox(height: 2),
      r.hint,
    ],
  );
  const pad = EdgeInsets.fromLTRB(12, 9, 12, 8);
  final key = r.active ? const Key('forge-panel') : null;
  return SkinPanel(key: key, padding: pad, child: body);
}

/// Tab label with the mode's painted icon.
class _TabWithIcon extends StatelessWidget {
  const _TabWithIcon({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(icon, width: 20, height: 20),
      const SizedBox(width: 4),
      Text(text),
    ],
  );
}

/// "+ 2 Glut / + 79 LP" as a compact block.
class _CostLine extends StatelessWidget {
  const _CostLine({required this.glut, required this.lp});

  final int glut;
  final String lp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l.forgeGlutCost(glut),
          style: const TextStyle(
            color: ForgeColors.brass,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            height: 1.1,
          ),
        ),
        Text(
          l.forgeLpCost(lp),
          style: const TextStyle(
            color: ForgeColors.muted,
            fontSize: 12,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// Header plate of the recipe: painted icon, mode name, rule, costs.
class _Plaque extends StatelessWidget {
  const _Plaque({required this.palette, required this.title, this.costs});

  final _Palette palette;
  final String title;
  final Widget? costs;

  @override
  Widget build(BuildContext context) {
    final skin = TreadSkin.of(context);
    final i = title.indexOf(':');
    final head = i < 0 ? title : title.substring(0, i);
    final rule = i < 0 ? '' : title.substring(i + 1).trim();
    return Container(
      height: 42,
      padding: const EdgeInsets.fromLTRB(4, 2, 8, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            palette.deep.withValues(alpha: .95),
            palette.deep.withValues(alpha: .35),
          ],
        ),
        border: Border.all(color: palette.accent.withValues(alpha: .55)),
      ),
      child: Row(
        children: [
          Image.asset(palette.icon, width: 36, height: 36),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin.displayText(head),
                  maxLines: 1,
                  style: skin
                      .display(16)
                      .copyWith(color: palette.light, height: 1.05),
                ),
                Text(
                  rule,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ForgeColors.muted,
                    fontSize: 11,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          ?costs,
        ],
      ),
    );
  }
}

/// A recipe slot: a ring in the mode's metal, the seal inside.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.seal,
    required this.palette,
    this.size = 58,
    this.badge,
  });

  final Seal? seal;
  final _Palette palette;
  final double size;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final s = seal;
    final ring = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xCC1A120D),
        border: Border.all(color: palette.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: palette.glow.withValues(alpha: s == null ? .15 : .45),
            blurRadius: s == null ? 4 : 10,
          ),
        ],
      ),
      child: s == null
          ? Icon(Icons.add, color: palette.accent.withValues(alpha: .6))
          : Center(
              child: SealArt(seal: s, size: size - 4),
            ),
    );
    if (badge == null || s == null) return ring;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ring,
        Positioned(
          right: -6,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: palette.deep,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.accent),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                color: palette.light,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Where the result appears: a glowing ring, the new seal with its level.
class _ResultRing extends StatelessWidget {
  const _ResultRing({
    required this.seal,
    required this.palette,
    this.size = 70,
  });

  final Seal? seal;
  final _Palette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = seal;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: s == null
              ? [const Color(0xAA1A120D), const Color(0x661A120D)]
              : [
                  palette.glow.withValues(alpha: .5),
                  palette.glow.withValues(alpha: 0),
                ],
        ),
        border: Border.all(
          color: palette.accent.withValues(alpha: s == null ? .35 : .9),
          width: 1.5,
        ),
      ),
      child: s == null
          ? Icon(
              Icons.question_mark_rounded,
              size: size * .32,
              color: palette.accent.withValues(alpha: .4),
            )
          : Center(
              child: SealArt(
                key: const Key('forge-result'),
                seal: s,
                size: size - 6,
                showLevel: true,
              ),
            ),
    );
  }
}

// ----------------------------------------------------------------- cards

/// V3 Aufwerten: a riveted iron plate with the level track 1–5.
class _IronCard extends StatelessWidget {
  const _IronCard(this.r);

  final _RecipeParts r;

  @override
  Widget build(BuildContext context) {
    final from = r.a?.level;
    final strike = r.strike;
    Widget ladder(double flash) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var lv = 1; lv <= 5; lv++) ...[
          if (lv > 1)
            Container(
              width: 8,
              height: 2,
              color: from != null && lv <= from + 1 && flash >= 0
                  ? _ember.accent
                  : const Color(0xFF4A403A),
            ),
          _LevelPip(
            level: lv,
            state: from == null
                ? 0
                : lv <= from
                ? 1
                : lv == from + 1
                ? (flash < 0 ? 0 : 2)
                : 0,
            flash: from != null && lv == from + 1 ? math.max(0, flash) : 0,
          ),
        ],
      ],
    );
    return CustomPaint(
      painter: _IronPlate(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Row(
          children: [
            _CrackOverlay(
              strike: strike,
              child: _Slot(seal: r.a, palette: _ember, size: 64, badge: '×2'),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AnvilStrike(strike: strike),
                  const SizedBox(height: 2),
                  if (from == null || strike == null)
                    ladder(0)
                  else
                    AnimatedBuilder(
                      animation: strike.anim,
                      builder: (context, _) {
                        final t = strike.anim.value;
                        if (t < _reveal) return ladder(0);
                        final u = ((t - _reveal) / (1 - _reveal)).clamp(
                          0.0,
                          1.0,
                        );
                        // Success: the target level flares golden.
                        // Fail: it goes dark.
                        return ladder(
                          strike.outcome.success ? math.sin(u * math.pi) : -1,
                        );
                      },
                    ),
                ],
              ),
            ),
            _ResultRing(seal: r.made, palette: _ember, size: 74),
          ],
        ),
      ),
    );
  }
}

class _LevelPip extends StatelessWidget {
  const _LevelPip({required this.level, required this.state, this.flash = 0});

  final int level;

  /// 0..1: the golden flare when a forge on this level succeeds.
  final double flash;

  /// 0 not reached, 1 reached, 2 the level this forge makes.
  final int state;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: switch (state) {
        1 => const Color(0xFF8E4A22),
        2 => Color.lerp(_ember.glow, const Color(0xFFFFD86B), flash),
        _ => const Color(0xFF2A2522),
      },
      border: Border.all(
        color: state == 0 ? const Color(0xFF5A504A) : _ember.light,
        width: 1,
      ),
      boxShadow: state == 2
          ? [
              BoxShadow(
                color: Color.lerp(
                  _ember.glow,
                  const Color(0xFFFFD86B),
                  flash,
                )!.withValues(alpha: .8),
                blurRadius: 8 + 10 * flash,
                spreadRadius: 3 * flash,
              ),
            ]
          : null,
    ),
    child: Text(
      '$level',
      style: TextStyle(
        color: state == 0 ? const Color(0xFF8A8078) : const Color(0xFFFFF1DC),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _IronPlate extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawShadow(Path()..addRRect(r), Colors.black, 4, false);
    canvas.drawRRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A4440), Color(0xFF2C2724), Color(0xFF1C1816)],
          stops: [0, .5, 1],
        ).createShader(Offset.zero & size),
    );
    // Hammered texture.
    final rng = math.Random(7);
    for (var i = 0; i < 260; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        1 + rng.nextDouble() * 2.5,
        Paint()
          ..color = (i.isEven ? Colors.black : Colors.white).withValues(
            alpha: .05,
          ),
      );
    }
    // Ember seam along the bottom edge.
    canvas.drawRect(
      Rect.fromLTWH(10, size.height - 3, size.width - 20, 2.5),
      Paint()
        ..shader = LinearGradient(
          colors: [
            _ember.glow.withValues(alpha: 0),
            _ember.glow.withValues(alpha: .9),
            _ember.glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.drawRRect(
      r.deflate(.75),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF0F0C0A),
    );
    for (final c in [
      const Offset(7, 7),
      Offset(size.width - 7, 7),
      Offset(7, size.height - 7),
      Offset(size.width - 7, size.height - 7),
    ]) {
      canvas.drawCircle(
        c + const Offset(.6, .8),
        3,
        Paint()..color = Colors.black54,
      );
      canvas.drawCircle(
        c,
        3,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.4, -.4),
            colors: [_ember.light, _ember.accent, _ember.deep],
          ).createShader(Rect.fromCircle(center: c, radius: 3)),
      );
    }
  }

  @override
  bool shouldRepaint(_IronPlate old) => false;
}

// ---------------------------------------------------------------- button

/// The action plate in the mode's metal (copper or verdigris) with its icon.
class _TintButton extends StatelessWidget {
  const _TintButton({
    super.key,
    required this.palette,
    required this.label,
    required this.onPressed,
    this.height = 50,
  });

  final _Palette palette;
  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    final base = skinButtonStyle(s, SkinButtonKind.primary, height: height);
    final radius = BorderRadius.circular(s.radius);
    final disabled = onPressed == null;
    return FilledButton(
      onPressed: onPressed,
      style: base.copyWith(
        padding: const WidgetStatePropertyAll(EdgeInsets.fromLTRB(8, 0, 12, 3)),
        foregroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.disabled) ? s.muted : palette.fg,
        ),
        backgroundBuilder: (context, states, child) => CustomPaint(
          painter: _TintButtonPainter(
            palette,
            s,
            radius,
            disabled: states.contains(WidgetState.disabled),
            pressed: states.contains(WidgetState.pressed),
          ),
          child: child,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: disabled ? .55 : 1,
            child: Image.asset(palette.icon, width: 30, height: 30),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _TintButtonPainter extends CustomPainter {
  _TintButtonPainter(
    this.p,
    this.s,
    this.radius, {
    required this.disabled,
    required this.pressed,
  });

  final _Palette p;
  final TreadSkin s;
  final BorderRadius radius;
  final bool disabled;
  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    if (disabled) {
      paintLeatherButton(canvas, size, s, radius, disabled: true);
      // A thin line in the mode's metal so the plate keeps its colour.
      canvas.drawRRect(
        radius.toRRect((Offset.zero & size).deflate(1)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = p.accent.withValues(alpha: .45),
      );
      return;
    }
    const lift = 3.0;
    final sink = pressed ? lift - .5 : 0.0;
    final slab = radius.toRRect(
      Rect.fromLTRB(0, lift, size.width, size.height),
    );
    final face = radius.toRRect(
      Rect.fromLTRB(0, sink, size.width, size.height - lift + sink),
    );
    canvas.drawRRect(
      slab.shift(Offset(0, pressed ? 1 : 3)),
      Paint()
        ..color = const Color(0x99000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, pressed ? 2 : 5),
    );
    canvas.drawRRect(
      slab.inflate(2),
      Paint()
        ..color = p.glow.withValues(alpha: .35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(slab, Paint()..color = p.slab);
    canvas.drawRRect(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            for (final c in p.face)
              pressed ? Color.lerp(c, Colors.black, .16)! : c,
          ],
          stops: const [0, .38, .78, 1],
        ).createShader(face.outerRect),
    );
    canvas.drawRRect(
      face.deflate(.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = p.slab,
    );
    final path = Path()..addRRect(face.deflate(4));
    final stitch = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = p.slab.withValues(alpha: .6);
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 4, m.length)), stitch);
        d += 7;
      }
    }
  }

  @override
  bool shouldRepaint(_TintButtonPainter old) =>
      old.p != p || old.disabled != disabled || old.pressed != pressed;
}
