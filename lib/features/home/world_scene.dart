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

  /// Widest the creature may get, as a share of the scene width.
  static const double maxWidthShare = 0.76;

  /// Tallest the creature may get, as a share of the room above its feet.
  static const double maxHeightShare = 0.84;

  /// Visual size (√(body width × height) of the species' Common cutout) as a
  /// share of the scene width, so every species reads equally large.
  static const double presenceShare = 0.66;

  /// Pixel size shared by all world backgrounds.
  static const Size imageSize = Size(840, 1493);

  /// Where the ground line should sit, as a fraction of the scene height.
  static const double groundTarget = 0.86;

  /// Vertical shift of a cover-fitted background in a [w] × [h] box so its
  /// ground line ([ground], a fraction of the image height) lands as close
  /// to [groundTarget] as the image allows. Returns the alignment and the
  /// resulting ground line.
  static (Alignment, double) _fitGround(double w, double h, double ground) {
    final scale = max(w / imageSize.width, h / imageSize.height);
    final imageH = imageSize.height * scale;
    final slack = h - imageH;
    if (slack >= 0) return (Alignment.center, slack / 2 + imageH * ground);
    final offset = (h * groundTarget - imageH * ground).clamp(slack, 0.0);
    return (Alignment(0, 2 * offset / slack - 1), offset + imageH * ground);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => _scene(box.maxWidth, box.maxHeight),
    );
  }

  Widget _scene(double w, double h) {
    final world = companion.world;
    final (alignment, groundY) = world.background == null
        ? (Alignment.bottomCenter, h * world.ground)
        : _fitGround(w, h, world.ground);
    final feet = groundY + footSink;
    final room = max(h * 0.5, feet - topClear - 16);
    final place = companionPlacement(
      artKey: companion.artKey,
      centerX: w / 2,
      groundY: feet,
      maxWidth: w * maxWidthShare,
      maxHeight: room * maxHeightShare,
      presence: min(w * presenceShare, room * 0.68),
    );
    final shadowW = place.body.width * 0.85;
    final shadowH = max(12.0, place.body.height * 0.08);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: _Backdrop(
            world: world,
            groundY: groundY,
            alignment: alignment,
          ),
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
  const _Backdrop({
    required this.world,
    required this.groundY,
    required this.alignment,
  });

  final World world;
  final double groundY;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final background = world.background;
    if (background != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(background, fit: BoxFit.cover, alignment: alignment),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0E0D),
                  Color(0x330F0E0D),
                  Color(0x000F0E0D),
                  Color(0x660F0E0D),
                  Color(0xFF0F0E0D),
                ],
                stops: [0, 0.12, 0.5, 0.88, 1],
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
