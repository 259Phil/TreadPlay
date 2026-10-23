import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The four style directions Philip picks from. Chosen at build time with
/// `--dart-define=TREADPLAY_STYLE=A|B|C|D`; C (Philip's pick) is the
/// default.
enum TreadStyle {
  /// A "Schmiede-Messing": engraved brass frames, rivets, serif display.
  forgeBrass,

  /// B "Dunkles Eisen, schlicht": flat dark iron, brass hairlines, sans.
  ironPlain,

  /// C "Leder & Pergament": dark leather, stitching, brass corners.
  leather,

  /// D "Runen-Glut": dark stone, ember glow, rune marks.
  runeEmber,
}

const _styleDefine = String.fromEnvironment(
  'TREADPLAY_STYLE',
  defaultValue: 'C',
);

TreadStyle get buildStyle => switch (_styleDefine.toUpperCase()) {
  'A' => TreadStyle.forgeBrass,
  'B' => TreadStyle.ironPlain,
  'D' => TreadStyle.runeEmber,
  _ => TreadStyle.leather,
};

/// Warm backdrop of style C, chosen with `--dart-define=TREADPLAY_BG=1|2|3`:
/// 1 deep brown leather (default), 2 dark aged parchment, 3 dark oak with a
/// forge glow from below.
const _bgDefine = String.fromEnvironment('TREADPLAY_BG', defaultValue: '1');

int get buildBackdrop => switch (_bgDefine) {
  '2' => 2,
  '3' => 3,
  _ => 1,
};

/// Design values and painters of one style, carried on the theme.
@immutable
class TreadSkin extends ThemeExtension<TreadSkin> {
  const TreadSkin({
    required this.style,
    required this.base,
    required this.surface,
    required this.raised,
    required this.line,
    required this.text,
    required this.muted,
    required this.brass,
    required this.brassDeep,
    required this.accent,
    required this.stop,
    required this.radius,
    required this.displayFont,
    required this.displayWeight,
    required this.displaySpacing,
    required this.displayUpper,
    this.backdrop,
  });

  final TreadStyle style;
  final Color base;
  final Color surface;
  final Color raised;
  final Color line;
  final Color text;
  final Color muted;
  final Color brass;
  final Color brassDeep;

  /// Second accent: brass for A/B, stitching thread for C, ember for D.
  final Color accent;
  final Color stop;
  final double radius;
  final String displayFont;
  final FontWeight displayWeight;
  final double displaySpacing;
  final bool displayUpper;

  /// Full-screen painted backdrop behind the key screens (style C only).
  final String? backdrop;

  /// Screen fill: transparent where the backdrop shows through.
  Color get canvas => backdrop == null ? base : Colors.transparent;

  static const bodyFont = 'Inter';

  static TreadSkin forStyle(TreadStyle s) => switch (s) {
    TreadStyle.forgeBrass => const TreadSkin(
      style: TreadStyle.forgeBrass,
      base: Color(0xFF1A1D22),
      surface: Color(0xFF2A3038),
      raised: Color(0xFF323944),
      line: Color(0xFF6E5A36),
      text: Color(0xFFE8E0D0),
      muted: Color(0xFFA39C90),
      brass: Color(0xFFC4A36A),
      brassDeep: Color(0xFF7A6238),
      accent: Color(0xFFE2C486),
      stop: Color(0xFF8B3A3A),
      radius: 6,
      displayFont: 'Cinzel',
      displayWeight: FontWeight.w700,
      displaySpacing: 0.6,
      displayUpper: false,
    ),
    TreadStyle.ironPlain => const TreadSkin(
      style: TreadStyle.ironPlain,
      base: Color(0xFF1A1D22),
      surface: Color(0xFF2A3038),
      raised: Color(0xFF323944),
      line: Color(0xFF3B434E),
      text: Color(0xFFE8E0D0),
      muted: Color(0xFF9AA1AA),
      brass: Color(0xFFC4A36A),
      brassDeep: Color(0xFF7A6238),
      accent: Color(0xFFC4A36A),
      stop: Color(0xFF8B3A3A),
      radius: 14,
      displayFont: 'BarlowSemiCondensed',
      displayWeight: FontWeight.w700,
      displaySpacing: 1.2,
      displayUpper: true,
    ),
    TreadStyle.leather => leather(buildBackdrop),
    TreadStyle.runeEmber => const TreadSkin(
      style: TreadStyle.runeEmber,
      base: Color(0xFF16181C),
      surface: Color(0xFF262A30),
      raised: Color(0xFF30353C),
      line: Color(0xFF3E3A36),
      text: Color(0xFFE8E0D0),
      muted: Color(0xFF9C9890),
      brass: Color(0xFFC4A36A),
      brassDeep: Color(0xFF7A6238),
      accent: Color(0xFFD9692F),
      stop: Color(0xFF8B3A3A),
      radius: 4,
      displayFont: 'Metamorphous',
      displayWeight: FontWeight.w400,
      displaySpacing: 0.5,
      displayUpper: false,
    ),
  };

  /// Style C on one of its three warm backdrops (see [buildBackdrop]).
  static TreadSkin leather(int bg) => TreadSkin(
    style: TreadStyle.leather,
    base: switch (bg) {
      2 => const Color(0xFF261C14),
      3 => const Color(0xFF1B120C),
      _ => const Color(0xFF1E140F),
    },
    surface: switch (bg) {
      2 => const Color(0xFF33241A),
      _ => const Color(0xFF3A2A20),
    },
    raised: const Color(0xFF47332A),
    line: const Color(0xFF5C4433),
    text: const Color(0xFFEDE4D3),
    muted: const Color(0xFFBBAC95),
    brass: const Color(0xFFD2B074),
    brassDeep: const Color(0xFF7A6238),
    accent: const Color(0xFFB9925A),
    stop: const Color(0xFF8B3A3A),
    radius: 10,
    displayFont: 'AlegreyaSC',
    displayWeight: FontWeight.w700,
    displaySpacing: 0.4,
    displayUpper: false,
    backdrop: 'assets/backdrop/bg$bg.jpg',
  );

  static TreadSkin of(BuildContext context) =>
      Theme.of(context).extension<TreadSkin>() ?? forStyle(buildStyle);

  /// Display text style (titles, names, button labels in A/C/D).
  TextStyle display(double size, {Color? color}) => TextStyle(
    fontFamily: displayFont,
    fontSize: size,
    fontWeight: displayWeight,
    letterSpacing: displaySpacing,
    color: color ?? text,
    height: 1.15,
  );

  /// Display strings stay as written (finders and screen readers see the
  /// same text); B gets its look from spacing instead of capitals.
  String displayText(String s) => s;

  @override
  TreadSkin copyWith() => this;

  @override
  TreadSkin lerp(TreadSkin? other, double t) => t < .5 ? this : (other ?? this);
}

/// Seeded noise so textures are stable between frames and screenshots.
class _Rng {
  _Rng(this._s);
  int _s;
  double next() {
    _s = (_s * 1103515245 + 12345) & 0x7fffffff;
    return _s / 0x7fffffff;
  }
}

/// The style's panel: card, frame and dialog body.
class SkinPanel extends StatelessWidget {
  const SkinPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.raised = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    return CustomPaint(
      painter: _PanelBack(s, raised),
      foregroundPainter: _PanelFront(s),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _PanelBack extends CustomPainter {
  _PanelBack(this.s, this.raised);
  final TreadSkin s;
  final bool raised;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(s.radius),
    );
    final fill = raised ? s.raised : s.surface;
    switch (s.style) {
      case TreadStyle.forgeBrass:
        canvas.drawShadow(Path()..addRRect(r), Colors.black, 4, false);
        canvas.drawRRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(fill, s.brass, .06)!, fill, s.base],
              stops: const [0, .55, 1],
            ).createShader(Offset.zero & size),
        );
      case TreadStyle.ironPlain:
        canvas.drawRRect(r, Paint()..color = fill);
      case TreadStyle.leather:
        canvas.drawShadow(Path()..addRRect(r), Colors.black, 5, false);
        canvas.drawRRect(
          r,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-.3, -.5),
              radius: 1.4,
              colors: [
                Color.lerp(fill, s.accent, .12)!,
                fill,
                const Color(0xFF241A14),
              ],
              stops: const [0, .5, 1],
            ).createShader(Offset.zero & size),
        );
        canvas.save();
        canvas.clipRRect(r);
        final rng = _Rng(size.width.toInt() * 31 + size.height.toInt());
        final dark = Paint()..color = const Color(0x22000000);
        final light = Paint()..color = const Color(0x10FFE6C0);
        final n = (size.width * size.height / 60).clamp(0, 6000).toInt();
        for (var i = 0; i < n; i++) {
          final o = Offset(rng.next() * size.width, rng.next() * size.height);
          canvas.drawCircle(o, .5 + rng.next() * 1.3, i.isEven ? dark : light);
        }
        canvas.restore();
      case TreadStyle.runeEmber:
        canvas.drawRRect(
          r.inflate(1.5),
          Paint()
            ..color = s.accent.withValues(alpha: .22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawRRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [fill, const Color(0xFF1C1F23)],
            ).createShader(Offset.zero & size),
        );
        canvas.save();
        canvas.clipRRect(r);
        final rng = _Rng(size.width.toInt() * 17 + size.height.toInt());
        final n = (size.width * size.height / 40).clamp(0, 8000).toInt();
        final p = Paint();
        for (var i = 0; i < n; i++) {
          final v = rng.next();
          p.color = v < .5
              ? Color.fromARGB((14 * v * 2).toInt() + 6, 0, 0, 0)
              : Color.fromARGB(((v - .5) * 20).toInt() + 4, 230, 220, 200);
          canvas.drawRect(
            Rect.fromLTWH(
              rng.next() * size.width,
              rng.next() * size.height,
              1 + rng.next() * 2,
              1 + rng.next() * 2,
            ),
            p,
          );
        }
        // Glowing seam at the bottom edge.
        canvas.drawRect(
          Rect.fromLTWH(0, size.height - 3, size.width, 3),
          Paint()
            ..shader = LinearGradient(
              colors: [
                s.accent.withValues(alpha: 0),
                s.accent.withValues(alpha: .55),
                s.accent.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromLTWH(0, 0, size.width, 3)),
        );
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PanelBack old) => old.s != s || old.raised != raised;
}

class _PanelFront extends CustomPainter {
  _PanelFront(this.s);
  final TreadSkin s;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = RRect.fromRectAndRadius(rect, Radius.circular(s.radius));
    switch (s.style) {
      case TreadStyle.forgeBrass:
        // Double engraved brass border with rivets in the corners.
        canvas.drawRRect(
          r.deflate(1),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [s.accent, s.brass, s.brassDeep, s.brass],
            ).createShader(rect),
        );
        canvas.drawRRect(
          r.deflate(4.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = .8
            ..color = s.brassDeep,
        );
        for (final c in [
          const Offset(9, 9),
          Offset(size.width - 9, 9),
          Offset(9, size.height - 9),
          Offset(size.width - 9, size.height - 9),
        ]) {
          _rivet(canvas, c, 3.2);
        }
        if (size.width > 200) {
          _rivet(canvas, Offset(size.width / 2, 2.5), 2.2);
          _rivet(canvas, Offset(size.width / 2, size.height - 2.5), 2.2);
        }
      case TreadStyle.ironPlain:
        canvas.drawRRect(
          r.deflate(.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = s.line,
        );
        // Thin brass hairline along the top.
        final inset = s.radius + 6;
        canvas.drawLine(
          Offset(inset, .5),
          Offset(size.width - inset, .5),
          Paint()
            ..strokeWidth = 1
            ..shader = LinearGradient(
              colors: [
                s.brass.withValues(alpha: 0),
                s.brass.withValues(alpha: .9),
                s.brass.withValues(alpha: 0),
              ],
            ).createShader(rect),
        );
      case TreadStyle.leather:
        canvas.drawRRect(
          r.deflate(.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFF1C140F),
        );
        _dashedRRect(
          canvas,
          r.deflate(5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3
            ..strokeCap = StrokeCap.round
            ..color = s.accent.withValues(alpha: .8),
        );
        for (var i = 0; i < 4; i++) {
          _corner(canvas, size, i);
        }
      case TreadStyle.runeEmber:
        canvas.drawRRect(
          r.deflate(.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = s.line,
        );
        final ember = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = s.accent;
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = s.accent.withValues(alpha: .35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
        _rune(canvas, const Offset(10, 8), 0, glow);
        _rune(canvas, const Offset(10, 8), 0, ember);
        _rune(canvas, Offset(size.width - 10, 8), 1, glow);
        _rune(canvas, Offset(size.width - 10, 8), 1, ember);
    }
  }

  void _rivet(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c + const Offset(.6, .8),
      r,
      Paint()..color = const Color(0xAA000000),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.4, -.4),
          colors: [s.accent, s.brass, s.brassDeep],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _corner(Canvas canvas, Size size, int i) {
    const l = 16.0;
    canvas.save();
    final (dx, dy, rot) = switch (i) {
      0 => (0.0, 0.0, 0.0),
      1 => (size.width, 0.0, math.pi / 2),
      2 => (size.width, size.height, math.pi),
      _ => (0.0, size.height, -math.pi / 2),
    };
    canvas.translate(dx, dy);
    canvas.rotate(rot);
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(l, 0)
      ..lineTo(l, 3)
      ..quadraticBezierTo(6, 4, 4, 6)
      ..quadraticBezierTo(3, 10, 3, l)
      ..lineTo(0, l)
      ..close();
    canvas.drawShadow(p, Colors.black, 2, false);
    canvas.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFE2C486), s.brass, s.brassDeep],
        ).createShader(const Rect.fromLTWH(0, 0, l, l)),
    );
    canvas.drawCircle(const Offset(5, 5), 1.4, Paint()..color = s.brassDeep);
    canvas.restore();
  }

  void _rune(Canvas canvas, Offset o, int kind, Paint p) {
    final path = Path();
    if (kind == 0) {
      // A small "fehu"-like branch mark.
      path
        ..moveTo(o.dx, o.dy)
        ..lineTo(o.dx, o.dy + 14)
        ..moveTo(o.dx, o.dy + 3)
        ..lineTo(o.dx + 6, o.dy)
        ..moveTo(o.dx, o.dy + 7)
        ..lineTo(o.dx + 6, o.dy + 4);
    } else {
      // A diamond "ingwaz" mark.
      path
        ..moveTo(o.dx, o.dy)
        ..lineTo(o.dx + 4, o.dy + 6)
        ..lineTo(o.dx, o.dy + 12)
        ..lineTo(o.dx - 4, o.dy + 6)
        ..close();
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_PanelFront old) => old.s != s;
}

void _dashedRRect(Canvas canvas, RRect r, Paint p) {
  final path = Path()..addRRect(r);
  for (final m in path.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      canvas.drawPath(m.extractPath(d, math.min(d + 4, m.length)), p);
      d += 7;
    }
  }
}

enum SkinButtonKind { primary, secondary, danger }

/// Primary, secondary and danger buttons in the style. Built on the
/// Material buttons so semantics and focus stay standard.
class SkinButton extends StatelessWidget {
  const SkinButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.kind = SkinButtonKind.primary,
    this.height = 48,
  });

  const SkinButton.secondary({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.height = 48,
  }) : kind = SkinButtonKind.secondary;

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final SkinButtonKind kind;
  final double height;

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    final style = skinButtonStyle(s, kind, height: height);
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    final child = icon == null
        ? text
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 6),
              Flexible(child: text),
            ],
          );
    return kind == SkinButtonKind.secondary
        ? OutlinedButton(onPressed: onPressed, style: style, child: child)
        : FilledButton(onPressed: onPressed, style: style, child: child);
  }
}

ButtonStyle skinButtonStyle(
  TreadSkin s,
  SkinButtonKind kind, {
  double height = 48,
}) {
  final primary = kind == SkinButtonKind.primary;
  final danger = kind == SkinButtonKind.danger;
  final leather = s.style == TreadStyle.leather;
  final fg = leather
      ? (primary ? const Color(0xFF2A1A0C) : const Color(0xFFF2DCA8))
      : primary
      ? s.base
      : (danger ? s.text : s.brass);
  final labelStyle = switch (s.style) {
    TreadStyle.ironPlain => const TextStyle(
      fontFamily: 'BarlowSemiCondensed',
      fontWeight: FontWeight.w700,
      fontSize: 16,
      letterSpacing: 1.4,
    ),
    TreadStyle.forgeBrass => const TextStyle(
      fontFamily: 'Cinzel',
      fontWeight: FontWeight.w700,
      fontSize: 15,
      letterSpacing: .6,
    ),
    TreadStyle.leather => TextStyle(
      fontFamily: 'AlegreyaSC',
      fontWeight: FontWeight.w700,
      fontSize: 17,
      shadows: [
        primary
            ? const Shadow(color: Color(0x88FFF3D0), offset: Offset(0, 1))
            : const Shadow(
                color: Color(0xCC000000),
                offset: Offset(0, 1),
                blurRadius: 1.5,
              ),
      ],
    ),
    TreadStyle.runeEmber => const TextStyle(
      fontFamily: 'Metamorphous',
      fontSize: 15,
      letterSpacing: .4,
    ),
  };
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(
      s.style == TreadStyle.ironPlain ? 10 : s.radius,
    ),
  );
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(0, height)),
    // Style C: the label sits on the raised plate, above its 3 px slab.
    padding: WidgetStatePropertyAll(
      leather
          ? const EdgeInsets.fromLTRB(16, 0, 16, 3)
          : const EdgeInsets.symmetric(horizontal: 16),
    ),
    textStyle: WidgetStatePropertyAll(labelStyle),
    shape: WidgetStatePropertyAll(shape),
    foregroundColor: WidgetStateProperty.resolveWith(
      (st) => st.contains(WidgetState.disabled) ? s.muted : fg,
    ),
    backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
    side: const WidgetStatePropertyAll(BorderSide.none),
    elevation: const WidgetStatePropertyAll(0),
    overlayColor: WidgetStatePropertyAll(
      leather ? Colors.transparent : s.text.withValues(alpha: .08),
    ),
    backgroundBuilder: (context, states, child) => CustomPaint(
      painter: _ButtonPainter(
        s,
        kind,
        states.contains(WidgetState.disabled),
        shape.borderRadius.resolve(TextDirection.ltr),
        pressed: states.contains(WidgetState.pressed),
        hovered: states.contains(WidgetState.hovered),
      ),
      child: child,
    ),
  );
}

class _ButtonPainter extends CustomPainter {
  _ButtonPainter(
    this.s,
    this.kind,
    this.disabled,
    this.radius, {
    this.pressed = false,
    this.hovered = false,
  });
  final TreadSkin s;
  final SkinButtonKind kind;
  final bool disabled;
  final BorderRadius radius;
  final bool pressed;
  final bool hovered;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = radius.toRRect(rect);
    final primary = kind == SkinButtonKind.primary;
    final danger = kind == SkinButtonKind.danger;
    if (s.style == TreadStyle.leather) {
      paintLeatherButton(
        canvas,
        size,
        s,
        radius,
        kind: kind,
        disabled: disabled,
        pressed: pressed,
        hovered: hovered,
      );
      return;
    }
    if (disabled) {
      canvas.drawRRect(r, Paint()..color = s.raised);
      canvas.drawRRect(
        r.deflate(.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = s.line,
      );
      return;
    }
    if (danger) {
      canvas.drawRRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFA04646), s.stop, const Color(0xFF5E2626)],
          ).createShader(rect),
      );
      canvas.drawRRect(
        r.deflate(.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = s.style == TreadStyle.ironPlain
              ? const Color(0xFF5E2626)
              : s.brassDeep,
      );
      return;
    }
    switch (s.style) {
      case TreadStyle.forgeBrass:
        if (primary) {
          canvas.drawShadow(Path()..addRRect(r), Colors.black, 3, false);
          canvas.drawRRect(
            r,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFEBD199),
                  s.brass,
                  const Color(0xFF8E7046),
                ],
                stops: const [0, .45, 1],
              ).createShader(rect),
          );
          canvas.drawRRect(
            r.deflate(3),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = .8
              ..color = const Color(0x995A4628),
          );
          canvas.drawRRect(
            r.deflate(.5),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = const Color(0xFF4A3B24),
          );
        } else {
          canvas.drawRRect(r, Paint()..color = s.base.withValues(alpha: .6));
          canvas.drawRRect(
            r.deflate(1),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..color = s.brass,
          );
          canvas.drawRRect(
            r.deflate(3.5),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = .6
              ..color = s.brassDeep,
          );
        }
      case TreadStyle.ironPlain:
        if (primary) {
          canvas.drawRRect(r, Paint()..color = s.brass);
        } else {
          canvas.drawRRect(r, Paint()..color = s.raised);
          canvas.drawRRect(
            r.deflate(.5),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = s.line,
          );
        }
      case TreadStyle.leather:
        canvas.drawShadow(Path()..addRRect(r), Colors.black, 3, false);
        canvas.drawRRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: primary
                  ? [const Color(0xFFD9BC82), s.brass, const Color(0xFF9A7A4E)]
                  : [
                      const Color(0xFF55402F),
                      s.raised,
                      const Color(0xFF2E221A),
                    ],
            ).createShader(rect),
        );
        _dashedRRect(
          canvas,
          r.deflate(4),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1
            ..color = primary ? const Color(0xAA4A3420) : s.accent,
        );
      case TreadStyle.runeEmber:
        canvas.drawRRect(
          r,
          Paint()
            ..color = s.accent.withValues(alpha: primary ? .45 : .2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
        );
        canvas.drawRRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: primary
                  ? [const Color(0xFFE2B878), s.brass, const Color(0xFFA0552A)]
                  : [s.raised, const Color(0xFF1E2125)],
            ).createShader(rect),
        );
        canvas.drawRRect(
          r.deflate(.75),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = primary ? const Color(0xFF6B3519) : s.accent,
        );
    }
  }

  @override
  bool shouldRepaint(_ButtonPainter old) =>
      old.s != s ||
      old.kind != kind ||
      old.disabled != disabled ||
      old.pressed != pressed ||
      old.hovered != hovered;
}

/// Style C buttons: a raised plate on a darker base slab, so they stand
/// off the leather. Primary is polished brass, secondary burnished leather
/// with a brass rim, danger oxblood with a brass rim. Pressed sinks the
/// plate onto its slab; disabled is flat, unlit leather.
void paintLeatherButton(
  Canvas canvas,
  Size size,
  TreadSkin s,
  BorderRadius radius, {
  SkinButtonKind kind = SkinButtonKind.primary,
  bool disabled = false,
  bool pressed = false,
  bool hovered = false,
}) {
  final rect = Offset.zero & size;
  final primary = kind == SkinButtonKind.primary;
  final danger = kind == SkinButtonKind.danger;
  if (disabled) {
    final r = radius.toRRect(rect.deflate(1));
    canvas.drawRRect(r, Paint()..color = const Color(0xFF2B1F17));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF4A372A),
    );
    _dashedRRect(
      canvas,
      r.deflate(4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x665C4433),
    );
    return;
  }
  const lift = 3.0;
  final sink = pressed ? lift - .5 : 0.0;
  final slab = radius.toRRect(Rect.fromLTRB(0, lift, size.width, size.height));
  final face = radius.toRRect(
    Rect.fromLTRB(0, sink, size.width, size.height - lift + sink),
  );
  // Drop shadow under the whole button.
  canvas.drawRRect(
    slab.shift(Offset(0, pressed ? 1 : 3)),
    Paint()
      ..color = const Color(0x99000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, pressed ? 2 : 5),
  );
  // Base slab (the edge the plate stands on).
  canvas.drawRRect(
    slab,
    Paint()
      ..color = primary
          ? const Color(0xFF5E4523)
          : (danger ? const Color(0xFF3A1414) : const Color(0xFF1A110B)),
  );
  final List<Color> colors = primary
      ? const [
          Color(0xFFF6E2AA),
          Color(0xFFDDBB7C),
          Color(0xFFB58E52),
          Color(0xFF8F6C3A),
        ]
      : danger
      ? const [
          Color(0xFFB45A4E),
          Color(0xFF8E3A32),
          Color(0xFF6E2A24),
          Color(0xFF521C18),
        ]
      : const [
          Color(0xFF7A5A40),
          Color(0xFF5C412E),
          Color(0xFF452F21),
          Color(0xFF34231A),
        ];
  final shade = pressed ? .16 : (hovered ? -.06 : 0.0);
  Color tone(Color c) => shade >= 0
      ? Color.lerp(c, Colors.black, shade)!
      : Color.lerp(c, Colors.white, -shade)!;
  canvas.drawRRect(
    face,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [for (final c in colors) tone(c)],
        stops: const [0, .38, .78, 1],
      ).createShader(face.outerRect),
  );
  // Brass rim around secondary and danger plates; dark rim on brass.
  final rimW = primary ? 1.2 : 2.0;
  canvas.drawRRect(
    face.deflate(rimW / 2),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = rimW
      ..shader = primary
          ? null
          : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF0D598),
                s.brass,
                const Color(0xFF7A6238),
              ],
            ).createShader(face.outerRect)
      ..color = const Color(0xFF4A3218),
  );
  // Top highlight line (the light catches the upper bevel).
  if (!pressed) {
    final y = face.top + rimW + 1.2;
    final inset = radius.topLeft.x + 3;
    canvas.drawLine(
      Offset(inset, y),
      Offset(size.width - inset, y),
      Paint()
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          colors: [
            const Color(0x00FFF6DC),
            Color(primary ? 0xCCFFF6DC : 0x66FFE6C0),
            const Color(0x00FFF6DC),
          ],
        ).createShader(face.outerRect),
    );
  }
  // Stitching inside the rim.
  _dashedRRect(
    canvas,
    face.deflate(primary ? 4 : 5),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = primary
          ? const Color(0x995A3E1E)
          : s.accent.withValues(alpha: .75),
  );
}

/// Small label chip (counts, filters, status).
class SkinChip extends StatelessWidget {
  const SkinChip({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    final radius = BorderRadius.circular(switch (s.style) {
      TreadStyle.forgeBrass => 4,
      TreadStyle.ironPlain => 8,
      TreadStyle.leather => 8,
      TreadStyle.runeEmber => 2,
    });
    final border = switch (s.style) {
      TreadStyle.forgeBrass => Border.all(color: s.brass, width: 1.2),
      TreadStyle.ironPlain => Border.all(color: selected ? s.brass : s.line),
      TreadStyle.leather => Border.all(
        color: onTap != null || selected
            ? s.brass.withValues(alpha: .9)
            : s.accent.withValues(alpha: .7),
        width: onTap != null ? 1.4 : 1,
      ),
      TreadStyle.runeEmber => Border.all(color: selected ? s.accent : s.line),
    };
    final fill = switch (s.style) {
      TreadStyle.leather => const Color(0xE62E221A),
      _ => s.base.withValues(alpha: .85),
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? Color.lerp(fill, s.brass, .18) : fill,
            borderRadius: radius,
            border: border,
            gradient: s.style == TreadStyle.leather
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: selected
                        ? const [Color(0xFF6E5236), Color(0xFF4A3424)]
                        : const [Color(0xF04A3527), Color(0xF02A1D15)],
                  )
                : null,
            boxShadow: s.style == TreadStyle.runeEmber && selected
                ? [
                    BoxShadow(
                      color: s.accent.withValues(alpha: .4),
                      blurRadius: 6,
                    ),
                  ]
                : s.style == TreadStyle.leather
                ? const [
                    BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: s.brass,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab bar in the style; drop-in for a [TabBar].
class SkinTabBar extends StatelessWidget implements PreferredSizeWidget {
  const SkinTabBar({super.key, required this.tabs, this.controller});

  final List<Widget> tabs;
  final TabController? controller;

  @override
  Size get preferredSize => const Size.fromHeight(46);

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    final label = switch (s.style) {
      TreadStyle.ironPlain => const TextStyle(
        fontFamily: 'BarlowSemiCondensed',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: 1,
      ),
      _ => s.display(14).copyWith(color: null, height: 1),
    };
    final Decoration indicator = switch (s.style) {
      TreadStyle.forgeBrass => _EngravedIndicator(s),
      TreadStyle.ironPlain => UnderlineTabIndicator(
        borderSide: BorderSide(color: s.brass, width: 2),
        insets: const EdgeInsets.symmetric(horizontal: 14),
      ),
      TreadStyle.leather => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7A5A40), Color(0xFF4E3727)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: s.brass, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      TreadStyle.runeEmber => BoxDecoration(
        border: Border(bottom: BorderSide(color: s.accent, width: 2)),
        boxShadow: [
          BoxShadow(
            color: s.accent.withValues(alpha: .45),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    };
    final bar = TabBar(
      controller: controller,
      tabs: tabs,
      labelStyle: label,
      unselectedLabelStyle: label,
      labelColor: switch (s.style) {
        TreadStyle.runeEmber => s.text,
        TreadStyle.leather => const Color(0xFFF6E2AA),
        _ => s.brass,
      },
      unselectedLabelColor: s.muted,
      indicator: indicator,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      overlayColor: WidgetStatePropertyAll(s.text.withValues(alpha: .05)),
      splashFactory: NoSplash.splashFactory,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
    return switch (s.style) {
      TreadStyle.leather => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF241A14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: s.line),
          ),
          child: Padding(padding: const EdgeInsets.all(3), child: bar),
        ),
      ),
      _ => DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: s.style == TreadStyle.forgeBrass ? s.brassDeep : s.line,
            ),
          ),
        ),
        child: bar,
      ),
    };
  }
}

class _EngravedIndicator extends Decoration {
  const _EngravedIndicator(this.s);
  final TreadSkin s;
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _EngravedPainter(s);
}

class _EngravedPainter extends BoxPainter {
  _EngravedPainter(this.s);
  final TreadSkin s;
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size!;
    final y = offset.dy + size.height - 2;
    final x0 = offset.dx + 10;
    final x1 = offset.dx + size.width - 10;
    final p = Paint()
      ..strokeWidth = 2
      ..color = s.brass;
    canvas.drawLine(Offset(x0, y), Offset(x1, y), p);
    final mid = (x0 + x1) / 2;
    final d = Path()
      ..moveTo(mid, y - 5)
      ..lineTo(mid + 5, y)
      ..lineTo(mid, y + 5)
      ..lineTo(mid - 5, y)
      ..close();
    canvas.drawPath(d, Paint()..color = s.accent);
    canvas.drawPath(
      d,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = s.brassDeep,
    );
  }
}

/// A resource counter: painted icon plus a value, framed in the style.
class ResourceCounter extends StatelessWidget {
  const ResourceCounter({
    super.key,
    required this.icon,
    required this.value,
    this.tooltip,
  });

  final Widget icon;
  final String value;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    final body = SkinChip(
      padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(dimension: 22, child: icon),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: s.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
    return tooltip == null ? body : Tooltip(message: tooltip, child: body);
  }
}

/// Flutter-drawn LP coin (until a painted one exists).
class LpCoin extends StatelessWidget {
  const LpCoin({super.key, this.size = 22});
  final double size;
  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    return CustomPaint(size: Size.square(size), painter: _CoinPainter(s));
  }
}

class _CoinPainter extends CustomPainter {
  _CoinPainter(this.s);
  final TreadSkin s;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - .5;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.4),
          colors: [const Color(0xFFEBD199), s.brass, s.brassDeep],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r * .74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .1
        ..color = const Color(0x997A6238),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: 'LP',
        style: TextStyle(
          fontSize: r * .82,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4A3B24),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_CoinPainter old) => old.s != s;
}

/// Flutter-drawn lock badge (locked leash ring, locked slots).
class LockBadge extends StatelessWidget {
  const LockBadge({super.key, this.size = 18});
  final double size;
  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s.base,
        border: Border.all(color: s.brass, width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 3)],
      ),
      child: Icon(Icons.lock, size: size * .6, color: s.brass),
    );
  }
}

/// Style C: every Filled/Outlined/Text button in the app gets the raised
/// plates, and screens get the warm base instead of the iron grey.
ThemeData _leatherButtons(ThemeData base, TreadSkin s) => base.copyWith(
  scaffoldBackgroundColor: s.base,
  canvasColor: s.base,
  colorScheme: base.colorScheme.copyWith(surface: s.base, onPrimary: s.base),
  appBarTheme: base.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
    titleTextStyle: s.display(26),
  ),
  bottomSheetTheme: base.bottomSheetTheme.copyWith(backgroundColor: s.base),
  snackBarTheme: base.snackBarTheme.copyWith(backgroundColor: s.surface),
  cardTheme: base.cardTheme.copyWith(color: s.surface),
  filledButtonTheme: FilledButtonThemeData(
    style: skinButtonStyle(s, SkinButtonKind.primary),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: skinButtonStyle(s, SkinButtonKind.secondary),
  ),
  textButtonTheme: TextButtonThemeData(
    style: skinButtonStyle(
      s,
      SkinButtonKind.secondary,
      height: 44,
    ).copyWith(minimumSize: const WidgetStatePropertyAll(Size(64, 44))),
  ),
);

/// The style's full-screen backdrop (style C: painted leather, parchment or
/// oak), with a soft vignette so panels and text keep their contrast.
class SkinBackdrop extends StatelessWidget {
  const SkinBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    final asset = s.backdrop;
    if (asset == null) return ColoredBox(color: s.base, child: child);
    return ColoredBox(
      color: s.base,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -.2),
                    radius: 1.15,
                    colors: [Color(0x00000000), Color(0x8C0A0604)],
                    stops: [.55, 1],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Shared ThemeData of a style. Screens outside the three key screens keep
/// their own colours until the style is chosen.
ThemeData applySkin(ThemeData base, TreadSkin s) {
  final leather = s.style == TreadStyle.leather;
  final themed = leather ? _leatherButtons(base, s) : base;
  return themed.copyWith(
    extensions: [s],
    textTheme: base.textTheme.apply(fontFamily: TreadSkin.bodyFont),
    primaryTextTheme: base.primaryTextTheme.apply(
      fontFamily: TreadSkin.bodyFont,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: s.brass,
      unselectedLabelColor: s.muted,
      dividerColor: Colors.transparent,
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: leather ? Colors.transparent : const Color(0xFF14161A),
      iconTheme: WidgetStateProperty.resolveWith(
        (st) => IconThemeData(
          color: st.contains(WidgetState.selected) ? s.brass : s.muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (st) => leather
            ? TextStyle(
                fontFamily: 'AlegreyaSC',
                fontSize: 11,
                height: 1,
                letterSpacing: -.25,
                fontWeight: FontWeight.w700,
                color: st.contains(WidgetState.selected)
                    ? const Color(0xFFF6E2AA)
                    : s.muted,
                shadows: const [
                  Shadow(color: Color(0xCC000000), offset: Offset(0, 1)),
                ],
              )
            : TextStyle(
                fontFamily: TreadSkin.bodyFont,
                fontSize: 10.5,
                letterSpacing: -.2,
                fontWeight: FontWeight.w600,
                color: st.contains(WidgetState.selected) ? s.brass : s.muted,
              ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: s.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(s.radius + 2),
        side: BorderSide(
          color: switch (s.style) {
            TreadStyle.forgeBrass => s.brass,
            TreadStyle.ironPlain => s.line,
            TreadStyle.leather => s.accent,
            TreadStyle.runeEmber => s.accent.withValues(alpha: .7),
          },
          width: s.style == TreadStyle.forgeBrass ? 2 : 1,
        ),
      ),
      titleTextStyle: s.display(20),
    ),
  );
}
