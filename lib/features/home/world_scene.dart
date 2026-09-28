import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/companion.dart';
import '../../domain/world.dart';
import '../../widgets/breath_badge.dart';
import '../../widgets/companion_figure.dart';

/// The taken-along companion standing on the ground of its world, under the
/// iron rail with three empty pins.
class WorldScene extends StatelessWidget {
  const WorldScene({super.key, required this.companion, this.railTop = 0});

  final Companion companion;

  /// Where the pouch rail hangs (below the top bar).
  final double railTop;

  /// How far the feet sink below the ground line, so they cover it.
  static const double footSink = 10;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => _scene(box.maxWidth, box.maxHeight),
    );
  }

  Widget _scene(double w, double h) {
    final world = companion.world;
    final groundY = h * world.ground;
    final railHeight = max(64.0, h * 0.1);
    final top = railTop + railHeight + 24;
    final figure = companionStandingRect(
      artKey: companion.artKey,
      centerX: w / 2,
      groundY: groundY + footSink,
      maxWidth: w * 0.7,
      maxHeight: max(h * 0.2, min(h * 0.36, groundY + footSink - top)),
    );
    final shadowW = figure.width * 0.8;
    final shadowH = max(10.0, figure.height * 0.1);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: _Backdrop(world: world, groundY: groundY),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: railTop,
          height: railHeight,
          child: CustomPaint(painter: _RailPainter()),
        ),
        Positioned(
          left: w / 2 - shadowW / 2,
          width: shadowW,
          top: groundY + footSink - shadowH * 0.6,
          height: shadowH,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x88000000), Color(0x00000000)],
              ),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: figure,
          child: Image.asset(
            companion.imageAsset,
            key: const Key('home-companion'),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          ),
        ),
        Positioned(
          left: min(figure.right - 36, w - 84),
          top: max(top - 8, figure.top - 6),
          child: BreathBadge(
            breath: companion.breath,
            tank: companion.tankSize,
          ),
        ),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.world, required this.groundY});

  final World world;
  final double groundY;

  @override
  Widget build(BuildContext context) {
    final background = world.background;
    if (background != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            background,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x88000000),
                ],
                stops: [0, 0.22, 0.8, 1],
              ),
            ),
          ),
        ],
      );
    }
    return CustomPaint(
      painter: _PlaceholderPainter(world.placeholder, groundY),
    );
  }
}

/// Flat colour world with a darker ground band.
class _PlaceholderPainter extends CustomPainter {
  _PlaceholderPainter(this.color, this.groundY);

  final Color color;
  final double groundY;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = Color.lerp(color, const Color(0xFF000000), 0.4)!;
    canvas
      ..drawRect(Offset.zero & size, Paint()..color = color)
      ..drawRect(
        Rect.fromLTRB(0, groundY, size.width, size.height),
        Paint()..color = ground,
      );
  }

  @override
  bool shouldRepaint(_PlaceholderPainter old) =>
      old.color != color || old.groundY != groundY;
}

/// Iron rod across the top with three empty wooden pins for treat pouches.
class _RailPainter extends CustomPainter {
  static const pins = [0.28, 0.5, 0.72];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    const y = 14.0;
    const r = 3.5;
    final rod = Rect.fromLTRB(10, y - r, w - 10, y + r);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rod, const Radius.circular(r)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB5BCC4), Color(0xFF5C636B), Color(0xFF2E3338)],
        ).createShader(rod),
    );
    final bracket = Paint()..color = const Color(0xFF3A4047);
    final rim = Paint()
      ..color = const Color(0xFFC4A36A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final x in [12.0, w - 12]) {
      canvas
        ..drawCircle(Offset(x, y), 7, bracket)
        ..drawCircle(Offset(x, y), 7, rim);
    }

    final wood = Paint()..color = const Color(0xFF9C7A50);
    final edge = Paint()
      ..color = const Color(0xFF4A3622)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final spring = Paint()..color = const Color(0xFF9AA3A8);
    final pinW = max(6.0, w * 0.017);
    final pinH = pinW * 4;
    for (final t in pins) {
      final x = w * t;
      for (final dx in [-pinW * 0.55, pinW * 0.55]) {
        final p = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + dx, y + pinH * 0.35),
            width: pinW,
            height: pinH,
          ),
          Radius.circular(pinW / 2),
        );
        canvas
          ..drawRRect(p, wood)
          ..drawRRect(p, edge);
      }
      canvas.drawCircle(Offset(x, y + pinH * 0.2), pinW * 0.45, spring);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
