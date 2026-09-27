import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/boot_footprint.dart';
import '../../domain/shoe.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/format.dart';

/// Active boot standing on a cobblestone pedestal in its world scene,
/// under the empty clothesline, with Breath shown at the shaft.
class BootDiorama extends StatelessWidget {
  const BootDiorama({super.key, required this.shoe, this.action, this.corner});

  final Shoe shoe;

  /// Round control placed at the lower right edge of the pedestal.
  final Widget? action;

  /// Small note placed in the lower left corner, below the pedestal.
  final Widget? corner;

  static const double _aspect = 0.9;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3E4A6B), Color(0xFF8A6A58), Color(0xFF2B211B)],
              stops: [0, 0.6, 1],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, box) => _scene(box.maxWidth, box.maxHeight),
          ),
        ),
      ),
    );
  }

  Widget _scene(double w, double h) {
    final pedLeft = w * 0.08;
    final pedWidth = w * 0.84;
    final pedHeight = w * 0.3;
    final pedBottom = h * 0.83;
    final pedTop = pedBottom - pedHeight;
    final ovalHalf = pedHeight * _PedestalPainter.topShare / 2;
    // Sole lands in the lower half of the top oval so it sits on the stones.
    final soleY = pedTop + ovalHalf * 1.35;

    final fp = bootFootprints[shoe.modelId] ?? defaultBootFootprint;
    final size = min(w * 0.74, w * 0.5 / fp.height);
    final imgLeft = w / 2 - fp.center.dx * size;
    final imgTop = soleY - fp.bottom * size;
    final bootRight = imgLeft + fp.right * size;
    final bootTop = imgTop + fp.top * size;
    final bootWidth = fp.width * size;

    const ring = 48.0;
    final ringLeft = min(bootRight - ring * 0.2, w - ring - 12);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: CustomPaint(painter: _SkylinePainter())),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: h * 0.2,
          child: CustomPaint(painter: _ClotheslinePainter()),
        ),
        Positioned(
          left: pedLeft,
          width: pedWidth,
          top: pedTop,
          height: pedHeight,
          child: CustomPaint(painter: _PedestalPainter()),
        ),
        Positioned(
          left: w / 2 - bootWidth * 0.45,
          width: bootWidth * 0.9,
          top: soleY - ovalHalf * 0.35,
          height: ovalHalf * 0.6,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x99000000), Color(0x00000000)],
              ),
            ),
          ),
        ),
        Positioned(
          left: imgLeft,
          top: imgTop,
          width: size,
          height: size,
          child: Image.asset(shoe.imageAsset, fit: BoxFit.contain),
        ),
        Positioned(
          left: ringLeft,
          top: bootTop + 4,
          width: ring,
          height: ring,
          child: BreathRing(breath: shoe.breath, tank: shoe.tankSize),
        ),
        if (corner != null)
          Positioned(left: 14, bottom: 12, width: w * 0.58, child: corner!),
        if (action != null)
          Positioned(
            right: pedLeft - 4,
            top: pedBottom - pedHeight * 0.45,
            child: action!,
          ),
      ],
    );
  }
}

/// Small glowing ring showing a boot's Breath.
class BreathRing extends StatelessWidget {
  const BreathRing({super.key, required this.breath, required this.tank});

  final double breath;
  final int tank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final share = (breath / tank).clamp(0.0, 1.0);
    return Semantics(
      label:
          '${l.breath} ${l.breathValue(formatNumber(context, breath), tank)}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xCC14110F),
          boxShadow: [
            BoxShadow(
              color: TreadColors.breath.withValues(alpha: 0.55 * share),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: CircularProgressIndicator(
                value: share,
                strokeWidth: 4,
                color: TreadColors.breath,
                backgroundColor: TreadColors.panel,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.air, size: 14, color: TreadColors.breath),
                  Text(
                    formatNumber(context, breath.floorToDouble()),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x552B2438);
    final w = size.width;
    final base = size.height * 0.6;
    final path = Path()..moveTo(0, base);
    final towers = [0.0, 0.08, 0.16, 0.3, 0.42, 0.58, 0.7, 0.84, 0.92, 1.0];
    final heights = [0.1, 0.22, 0.14, 0.28, 0.12, 0.18, 0.3, 0.16, 0.24, 0.1];
    for (var i = 0; i < towers.length - 1; i++) {
      final top = base - size.height * heights[i];
      path
        ..lineTo(w * towers[i], top)
        ..lineTo(w * towers[i + 1], top);
    }
    path
      ..lineTo(w, base)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A sagging line with three empty pins, waiting for sacks.
class _ClotheslinePainter extends CustomPainter {
  static const pins = [0.28, 0.5, 0.72];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final y0 = size.height * 0.28;
    final sag = size.height * 0.22;
    double lineY(double t) => y0 + sag * 4 * t * (1 - t);

    final line = Path()
      ..moveTo(-4, y0)
      ..quadraticBezierTo(w / 2, y0 + sag * 2, w + 4, y0);
    canvas.drawPath(
      line,
      Paint()
        ..color = const Color(0xFFD9CBB4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final wood = Paint()..color = const Color(0xFFB78B5A);
    final edge = Paint()
      ..color = const Color(0xFF6E4E2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final spring = Paint()..color = const Color(0xFF9AA3A8);
    final pinW = max(6.0, w * 0.018);
    final pinH = pinW * 4.2;
    for (final t in pins) {
      final x = w * t;
      final y = lineY(t);
      for (final dx in [-pinW * 0.55, pinW * 0.55]) {
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + dx, y + pinH * 0.3),
            width: pinW,
            height: pinH,
          ),
          Radius.circular(pinW / 2),
        );
        canvas
          ..drawRRect(r, wood)
          ..drawRRect(r, edge);
      }
      canvas.drawCircle(Offset(x, y + pinH * 0.18), pinW * 0.45, spring);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PedestalPainter extends CustomPainter {
  /// Share of the pedestal height taken by the top oval.
  static const topShare = 0.55;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topH = h * topShare;
    final top = Rect.fromLTWH(0, 0, w, topH);
    final side = Path()
      ..moveTo(0, topH / 2)
      ..lineTo(0, h - topH / 2)
      ..arcTo(Rect.fromLTWH(0, h - topH, w, topH), pi, -pi, false)
      ..lineTo(w, topH / 2)
      ..close();
    canvas.drawPath(side, Paint()..color = const Color(0xFF4A3F37));
    canvas.drawOval(top, Paint()..color = const Color(0xFF7D7064));

    final stone = Paint()..color = const Color(0xFF93867A);
    final gap = Paint()
      ..color = const Color(0xFF5E534A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rnd = Random(7);
    for (var row = 0; row < 4; row++) {
      final y = topH * (0.2 + row * 0.2);
      final half =
          sqrt(max(0, 1 - pow((y - topH / 2) / (topH / 2), 2))) * w / 2;
      var x = w / 2 - half + 6;
      while (x < w / 2 + half - 16) {
        final sw = 16 + rnd.nextDouble() * 14;
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y - 5, sw, 10),
          const Radius.circular(4),
        );
        canvas
          ..drawRRect(r, stone)
          ..drawRRect(r, gap);
        x += sw + 3;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
