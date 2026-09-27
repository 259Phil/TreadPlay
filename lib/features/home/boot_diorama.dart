import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/shoe.dart';

/// Active boot standing on a cobblestone pedestal in its world scene.
class BootDiorama extends StatelessWidget {
  const BootDiorama({super.key, required this.shoe});

  final Shoe shoe;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3E4A6B), Color(0xFF8A6A58), Color(0xFF2B211B)],
              stops: [0, 0.62, 1],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _SkylinePainter()),
                  ),
                  Positioned(
                    left: w * 0.1,
                    right: w * 0.1,
                    bottom: w * 0.06,
                    height: w * 0.3,
                    child: CustomPaint(painter: _PedestalPainter()),
                  ),
                  Positioned(
                    left: w * 0.14,
                    right: w * 0.14,
                    bottom: w * 0.2,
                    height: w * 0.72,
                    child: Image.asset(shoe.imageAsset, fit: BoxFit.contain),
                  ),
                ],
              );
            },
          ),
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
    final base = size.height * 0.62;
    final path = Path()..moveTo(0, base);
    final towers = [0.0, 0.08, 0.16, 0.3, 0.42, 0.58, 0.7, 0.84, 0.92, 1.0];
    final heights = [0.1, 0.22, 0.14, 0.3, 0.12, 0.18, 0.34, 0.16, 0.24, 0.1];
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

class _PedestalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topH = h * 0.55;
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
