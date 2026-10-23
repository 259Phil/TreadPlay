import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'skin.dart';

/// Painted brass/leather icons of style C (generated, cut out, 128 px).
abstract final class SkinIcons {
  static const coin = 'coin';
  static const lock = 'lock';
  static const stop = 'stop';
  static const breath = 'breath';
  static const waymark = 'waymark';
  static const logbook = 'logbook';
  static const play = 'play';
  static const video = 'video';
  static const delete = 'delete';
  static const export = 'export';
  static const import = 'import';
  static const buy = 'buy';
  static const sell = 'sell';

  static const all = [
    coin,
    lock,
    stop,
    breath,
    waymark,
    logbook,
    play,
    video,
    delete,
    export,
    import,
    buy,
    sell,
  ];

  static String asset(String name) => 'assets/icons/ui_$name.webp';
}

/// One painted icon. Decorative: the surrounding control carries the label.
class SkinIcon extends StatelessWidget {
  const SkinIcon(this.name, {super.key, this.size = 24, this.semanticLabel});

  final String name;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Image.asset(
    SkinIcons.asset(name),
    width: size,
    height: size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    semanticLabel: semanticLabel,
    excludeFromSemantics: semanticLabel == null,
    errorBuilder: (_, _, _) => SizedBox.square(dimension: size),
  );
}

/// The painted icon in style C, the Material [fallback] in the other styles.
Widget skinIcon(
  BuildContext context,
  IconData fallback,
  String painted, {
  double size = 24,
  Color? color,
}) => TreadSkin.of(context).style == TreadStyle.leather
    ? SkinIcon(painted, size: size * 1.12)
    : Icon(fallback, size: size, color: color);

/// Leather edge for dialogs, sheets, snackbars and cards: a dark cut edge,
/// a brass rim, a stitch line and (optionally) brass corner protectors.
class LeatherBorder extends OutlinedBorder {
  const LeatherBorder({
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.corners = true,
    this.rim = 1.8,
    this.stitchInset = 6,
    super.side = BorderSide.none,
  });

  final BorderRadiusGeometry borderRadius;
  final bool corners;
  final double rim;
  final double stitchInset;

  static const _thread = Color(0xFFC9A46A);
  static const _brassHi = Color(0xFFF0D59A);
  static const _brass = Color(0xFFD2B074);
  static const _brassDeep = Color(0xFF7A6238);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(rim);

  RRect _rrect(Rect rect, TextDirection? dir) =>
      borderRadius.resolve(dir).toRRect(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect, textDirection).deflate(rim));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect, textDirection));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final r = _rrect(rect, textDirection);
    canvas.drawRRect(
      r.deflate(rim / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rim
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_brassHi, _brass, _brassDeep, _brass],
          stops: [0, .35, .7, 1],
        ).createShader(rect),
    );
    canvas.drawRRect(
      r.deflate(rim + .5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x99140D09),
    );
    if (stitchInset > 0) {
      final path = Path()..addRRect(r.deflate(stitchInset));
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round
        ..color = _thread.withValues(alpha: .7);
      for (final m in path.computeMetrics()) {
        var d = 0.0;
        while (d < m.length) {
          canvas.drawPath(m.extractPath(d, math.min(d + 4, m.length)), p);
          d += 7;
        }
      }
    }
    if (corners) {
      if (r.tlRadiusX > 0) _corner(canvas, rect, 0);
      if (r.trRadiusX > 0) _corner(canvas, rect, 1);
      if (r.brRadiusX > 0) _corner(canvas, rect, 2);
      if (r.blRadiusX > 0) _corner(canvas, rect, 3);
    }
  }

  void _corner(Canvas canvas, Rect rect, int i) {
    const l = 18.0;
    canvas.save();
    final (o, rot) = switch (i) {
      0 => (rect.topLeft, 0.0),
      1 => (rect.topRight, math.pi / 2),
      2 => (rect.bottomRight, math.pi),
      _ => (rect.bottomLeft, -math.pi / 2),
    };
    canvas.translate(o.dx, o.dy);
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
        ..shader = const LinearGradient(
          colors: [_brassHi, _brass, _brassDeep],
        ).createShader(const Rect.fromLTWH(0, 0, l, l)),
    );
    canvas.drawCircle(const Offset(5, 5), 1.5, Paint()..color = _brassDeep);
    canvas.restore();
  }

  @override
  LeatherBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
  }) => LeatherBorder(
    borderRadius: borderRadius ?? this.borderRadius,
    corners: corners,
    rim: rim,
    stitchInset: stitchInset,
    side: side ?? this.side,
  );

  @override
  ShapeBorder scale(double t) => LeatherBorder(
    borderRadius: borderRadius * t,
    corners: corners,
    rim: rim * t,
    stitchInset: stitchInset * t,
  );

  @override
  bool operator ==(Object other) =>
      other is LeatherBorder &&
      other.borderRadius == borderRadius &&
      other.corners == corners &&
      other.rim == rim &&
      other.stitchInset == stitchInset;

  @override
  int get hashCode => Object.hash(borderRadius, corners, rim, stitchInset);
}

/// Style C for every remaining Material component: dialogs, bottom sheets,
/// snackbars, cards, list tiles, switches, sliders, progress bars, segmented
/// buttons, text fields, tabs, tooltips and icons.
ThemeData leatherComponents(ThemeData t, TreadSkin s) {
  const deep = Color(0xFF241A14);
  const hi = Color(0xFFF2DCA8);
  final body = TextStyle(fontFamily: TreadSkin.bodyFont, color: s.text);
  return t.copyWith(
    iconTheme: t.iconTheme.copyWith(color: s.brass),
    appBarTheme: t.appBarTheme.copyWith(
      foregroundColor: s.text,
      iconTheme: IconThemeData(color: s.brass),
      actionsIconTheme: IconThemeData(color: s.brass),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: s.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shadowColor: Colors.black,
      shape: const LeatherBorder(),
      iconColor: s.brass,
      titleTextStyle: s.display(21, color: hi),
      contentTextStyle: body.copyWith(fontSize: 15, height: 1.4),
      actionsPadding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
      barrierColor: const Color(0xA60A0604),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: s.surface,
      modalBackgroundColor: s.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      modalElevation: 16,
      shadowColor: Colors.black,
      modalBarrierColor: const Color(0x990A0604),
      dragHandleColor: s.brass.withValues(alpha: .75),
      dragHandleSize: const Size(44, 5),
      shape: const LeatherBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: s.raised,
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      shape: const LeatherBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        corners: false,
        stitchInset: 5,
      ),
      contentTextStyle: body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: hi,
      ),
      actionTextColor: s.brass,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xF2342519),
      surfaceTintColor: Colors.transparent,
      elevation: 5,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: const LeatherBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        corners: false,
        rim: 1.4,
        stitchInset: 5,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: s.brass,
      textColor: s.text,
      titleTextStyle: body.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: body.copyWith(fontSize: 13, color: s.muted),
      leadingAndTrailingTextStyle: body.copyWith(color: s.brass),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.disabled)
            ? s.line
            : st.contains(WidgetState.selected)
            ? const Color(0xFFF6E2AA)
            : const Color(0xFF9C8566),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (st) =>
            st.contains(WidgetState.selected) ? const Color(0xFF9C7840) : deep,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.selected) ? s.brass : s.line,
      ),
      trackOutlineWidth: const WidgetStatePropertyAll(1.6),
    ),
    sliderTheme: t.sliderTheme.copyWith(
      activeTrackColor: s.brass,
      inactiveTrackColor: deep,
      thumbColor: const Color(0xFFF0D59A),
      overlayColor: s.brass.withValues(alpha: .16),
      valueIndicatorColor: s.raised,
      trackHeight: 6,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: s.brass,
      linearTrackColor: deep,
      circularTrackColor: deep,
      linearMinHeight: 6,
      borderRadius: BorderRadius.circular(3),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? const Color(0xFFC9A464)
              : deep,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? const Color(0xFF2A1A0C)
              : s.text,
        ),
        iconColor: const WidgetStatePropertyAll(Color(0xFF2A1A0C)),
        side: WidgetStatePropertyAll(BorderSide(color: s.brass, width: 1.4)),
        textStyle: WidgetStatePropertyAll(s.display(14).copyWith(color: null)),
        elevation: const WidgetStatePropertyAll(2),
        shadowColor: const WidgetStatePropertyAll(Colors.black),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: s.line.withValues(alpha: .7),
      thickness: 1,
      space: 20,
      indent: 16,
      endIndent: 16,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: deep,
      labelStyle: TextStyle(color: s.muted),
      hintStyle: TextStyle(color: s.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: s.brassDeep),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: s.brassDeep, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: s.brass, width: 2),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: const Color(0xFFF6E2AA),
      unselectedLabelColor: s.muted,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: s.display(14).copyWith(color: null),
      unselectedLabelStyle: s.display(14).copyWith(color: null),
      indicator: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7A5A40), Color(0xFF4E3727)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: s.brass, width: 1.5),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: deep,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: s.brass),
        boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 6)],
      ),
      textStyle: body.copyWith(fontSize: 13, color: hi),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: s.surface,
      surfaceTintColor: Colors.transparent,
      shape: const LeatherBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        corners: false,
        rim: 1.4,
        stitchInset: 4,
      ),
      textStyle: body,
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(s.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStatePropertyAll(BorderSide(color: s.brass)),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: s.brass,
      selectionColor: s.brass.withValues(alpha: .35),
      selectionHandleColor: s.brass,
    ),
  );
}

/// Danger action (delete, erase): the oxblood plate in style C, copper text
/// in the other styles.
ButtonStyle dangerButtonStyle(BuildContext context, {double height = 44}) {
  final s = TreadSkin.of(context);
  return s.style == TreadStyle.leather
      ? skinButtonStyle(s, SkinButtonKind.danger, height: height)
      : TextButton.styleFrom(foregroundColor: const Color(0xFFB0703F));
}

/// Wraps a pushed full-screen route in the style's backdrop (style C); its
/// Scaffold then uses [TreadSkin.canvas] so the painted leather shows.
class SkinRoute extends StatelessWidget {
  const SkinRoute({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TreadSkin.of(context).backdrop == null
      ? child
      : SkinBackdrop(child: child);
}
