import 'package:flutter/material.dart';

import '../../domain/shoe.dart';
import '../../domain/sweet_spot.dart';
import '../../theme.dart';

/// Horizontal speed scale with the boot's range, its core and a marker.
class SweetSpotGauge extends StatelessWidget {
  const SweetSpotGauge({super.key, required this.type, required this.speedKmh});

  static const double maxKmh = 20;

  final ShoeType type;
  final double speedKmh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: double.infinity,
      child: CustomPaint(painter: _GaugePainter(type, speedKmh)),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.type, this.speed);

  final ShoeType type;
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    double x(double kmh) =>
        (kmh.clamp(0, SweetSpotGauge.maxKmh) / SweetSpotGauge.maxKmh) *
        size.width;
    final barTop = size.height * 0.35;
    final barH = size.height * 0.3;
    RRect band(double from, double to) => RRect.fromLTRBR(
      x(from),
      barTop,
      x(to),
      barTop + barH,
      const Radius.circular(6),
    );

    final c = type.sweetSpotKmh;
    final r = type.rangeKmh;
    final core = r * sweetSpotCoreShare;
    canvas
      ..drawRRect(
        band(0, SweetSpotGauge.maxKmh),
        Paint()..color = TreadColors.panel,
      )
      ..drawRRect(
        band(c - r, c + r),
        Paint()..color = TreadColors.gold.withAlpha(90),
      )
      ..drawRRect(band(c - core, c + core), Paint()..color = TreadColors.gold);

    final mx = x(speed);
    canvas.drawLine(
      Offset(mx, 2),
      Offset(mx, size.height - 2),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.speed != speed || old.type != type;
}
