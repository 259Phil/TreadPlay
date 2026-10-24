import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/salve.dart';
import '../l10n/app_localizations.dart';

/// Warm honey colour of the salve itself.
const Color salveHoney = Color(0xFFE7A93B);

/// Accent per salve size (tin brass, jar copper, rune pot ember).
Color salveTint(Salve s) => switch (s) {
  Salve.small => const Color(0xFFC9B07A),
  Salve.medium => const Color(0xFFC9814A),
  Salve.large => const Color(0xFFE07A3C),
};

String salveName(AppLocalizations l, Salve s) => switch (s) {
  Salve.small => l.salveSmall,
  Salve.medium => l.salveMedium,
  Salve.large => l.salveLarge,
};

/// "+15 % Mut" or "auf 100 % Mut".
String salveEffect(AppLocalizations l, Salve s) =>
    s == Salve.large ? l.salveEffectFull : l.salveEffect(s.points.round());

/// Drawn salve container: a flat tin, a jar, or a rune pot.
class SalveArt extends StatelessWidget {
  const SalveArt({super.key, required this.salve, required this.size});

  final Salve salve;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _SalvePainter(salve)),
  );
}

class _SalvePainter extends CustomPainter {
  const _SalvePainter(this.salve);

  final Salve salve;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * .9),
        width: w * .78,
        height: h * .12,
      ),
      shadow,
    );
    switch (salve) {
      case Salve.small:
        _tin(canvas, w, h);
      case Salve.medium:
        _jar(canvas, w, h);
      case Salve.large:
        _pot(canvas, w, h);
    }
  }

  void _tin(Canvas c, double w, double h) {
    const metal = Color(0xFFBFA46A);
    const dark = Color(0xFF7A6238);
    final body = Rect.fromLTRB(w * .14, h * .5, w * .86, h * .86);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [dark, metal, Color(0xFFE6D3A0), metal, dark],
        stops: [0, .25, .45, .7, 1],
      ).createShader(body);
    c.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(w * .08)),
      bodyPaint,
    );
    // Lid.
    final lid = Rect.fromCenter(
      center: Offset(w / 2, h * .5),
      width: w * .76,
      height: h * .26,
    );
    c.drawOval(
      lid,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.3, -.4),
          colors: [Color(0xFFF1E2B6), metal, dark],
          stops: [0, .6, 1],
        ).createShader(lid),
    );
    c.drawOval(
      lid.deflate(w * .07),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .02
        ..color = dark.withValues(alpha: .7),
    );
    _drop(c, Offset(w / 2, h * .5), w * .09, dark);
  }

  void _jar(Canvas c, double w, double h) {
    const clay = Color(0xFFB0703F);
    const clayDark = Color(0xFF6E3F22);
    final path = Path()
      ..moveTo(w * .3, h * .34)
      ..quadraticBezierTo(w * .12, h * .44, w * .16, h * .66)
      ..quadraticBezierTo(w * .2, h * .88, w * .5, h * .88)
      ..quadraticBezierTo(w * .8, h * .88, w * .84, h * .66)
      ..quadraticBezierTo(w * .88, h * .44, w * .7, h * .34)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [clayDark, clay, Color(0xFFDDA06C), clay, clayDark],
          stops: [0, .3, .45, .7, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    // Honey label band.
    final band = Rect.fromLTRB(w * .18, h * .55, w * .82, h * .7);
    c.save();
    c.clipPath(path);
    c.drawRect(band, Paint()..color = salveHoney.withValues(alpha: .9));
    c.restore();
    _drop(c, Offset(w / 2, h * .625), w * .07, clayDark);
    // Cloth lid tied with a cord.
    final cloth = Path()
      ..moveTo(w * .24, h * .36)
      ..quadraticBezierTo(w * .5, h * .12, w * .76, h * .36)
      ..lineTo(w * .7, h * .4)
      ..quadraticBezierTo(w * .5, h * .34, w * .3, h * .4)
      ..close();
    c.drawPath(cloth, Paint()..color = const Color(0xFFE9DCC0));
    c.drawLine(
      Offset(w * .28, h * .39),
      Offset(w * .72, h * .39),
      Paint()
        ..color = const Color(0xFF8B3A3A)
        ..strokeWidth = w * .035
        ..strokeCap = StrokeCap.round,
    );
  }

  void _pot(Canvas c, double w, double h) {
    const iron = Color(0xFF3A3027);
    const ironLight = Color(0xFF6B5A48);
    final glow = Paint()
      ..color = const Color(0xFFE07A3C).withValues(alpha: .35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .12);
    c.drawCircle(Offset(w / 2, h * .58), w * .36, glow);
    final body = Rect.fromCenter(
      center: Offset(w / 2, h * .62),
      width: w * .78,
      height: h * .56,
    );
    c.drawOval(
      body,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.35, -.4),
          colors: [ironLight, iron, Color(0xFF1C1612)],
          stops: [0, .6, 1],
        ).createShader(body),
    );
    // Copper band with runes.
    final bandY = h * .6;
    final bandPaint = Paint()
      ..color = const Color(0xFFC9814A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * .07;
    c.save();
    c.clipPath(Path()..addOval(body));
    c.drawLine(Offset(0, bandY), Offset(w, bandY), bandPaint);
    final rune = Paint()
      ..color = const Color(0xFFFFD08A)
      ..strokeWidth = w * .022
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final x = w * (.3 + i * .135);
      c.drawLine(
        Offset(x, bandY - h * .025),
        Offset(x, bandY + h * .025),
        rune,
      );
      c.drawLine(
        Offset(x, bandY - h * .025),
        Offset(x + w * (i.isEven ? .04 : -.04), bandY),
        rune,
      );
    }
    c.restore();
    // Rim with glowing honey.
    final rim = Rect.fromCenter(
      center: Offset(w / 2, h * .38),
      width: w * .56,
      height: h * .14,
    );
    c.drawOval(rim, Paint()..color = ironLight);
    c.drawOval(
      rim.deflate(w * .035),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFE2A0), salveHoney, Color(0xFFB8641E)],
        ).createShader(rim),
    );
    // Small sparks.
    final spark = Paint()..color = const Color(0xFFFFE2A0);
    for (var i = 0; i < 3; i++) {
      final a = -pi / 2 + (i - 1) * .55;
      c.drawCircle(
        Offset(w / 2 + cos(a) * w * .2, h * .3 + sin(a) * h * .1),
        w * .022,
        spark,
      );
    }
  }

  /// A small drop symbol for the honey salve.
  void _drop(Canvas c, Offset center, double r, Color outline) {
    final p = Path()
      ..moveTo(center.dx, center.dy - r * 1.5)
      ..quadraticBezierTo(
        center.dx + r * 1.1,
        center.dy,
        center.dx,
        center.dy + r,
      )
      ..quadraticBezierTo(
        center.dx - r * 1.1,
        center.dy,
        center.dx,
        center.dy - r * 1.5,
      )
      ..close();
    c.drawPath(p, Paint()..color = salveHoney);
    c.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .25
        ..color = outline,
    );
  }

  @override
  bool shouldRepaint(_SalvePainter old) => old.salve != salve;
}
