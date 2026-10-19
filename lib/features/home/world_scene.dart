import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/companion.dart';
import '../../domain/world.dart';
import '../../widgets/companion_figure.dart';

/// The taken-along companion standing large on the ground of its world.
class WorldScene extends StatelessWidget {
  const WorldScene({super.key, required this.companion, this.topClear = 0});

  final Companion companion;

  /// Height covered by the top bar; the figure stays below it.
  final double topClear;

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
    final top = topClear + 24;
    final place = companionPlacement(
      artKey: companion.artKey,
      centerX: w / 2,
      groundY: groundY + footSink,
      maxWidth: w * 0.86,
      maxHeight: max(h * 0.34, min(h * 0.5, groundY + footSink - top)),
    );
    final shadowW = place.body.width * 0.85;
    final shadowH = max(12.0, place.body.height * 0.08);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: _Backdrop(world: world, groundY: groundY),
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
          rect: place.image,
          child: Image.asset(
            companion.imageAsset,
            key: const Key('home-companion'),
            fit: BoxFit.fill,
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
