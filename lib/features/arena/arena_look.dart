import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/battle.dart';
import '../../domain/companion.dart';
import '../../widgets/companion_card.dart';
import '../../widgets/companion_figure.dart';
import 'arena_state.dart';

/// Colours of the arena: a night pit of dark stone lit by torches, set apart
/// from the warm leather of the rest of the app.
abstract final class ArenaColors {
  static const night = Color(0xFF0C0A16);
  static const dusk = Color(0xFF1B1428);
  static const stone = Color(0xFF4A3F4E);
  static const stoneDeep = Color(0xFF15111A);
  static const brass = Color(0xFFD2B074);
  static const brassLight = Color(0xFFF6E2AA);
  static const ember = Color(0xFFE8873A);
  static const heart = Color(0xFFD23B3F);
  static const mend = Color(0xFF7FD08A);
  static const text = Color(0xFFF2EADC);
  static const muted = Color(0xFFB4A9BF);
}

/// Where fighters stand on a field of [size]: the enemy on the far half,
/// the player on the near half, the front rows facing each other.
class ArenaGeometry {
  const ArenaGeometry(this.size);

  final Size size;

  double get figure => min(size.width * .27, size.height * .17);

  static double _feet(BattleSide side, BattleRow row) => switch ((side, row)) {
    (BattleSide.enemy, BattleRow.back) => .29,
    (BattleSide.enemy, BattleRow.front) => .44,
    (BattleSide.player, BattleRow.front) => .72,
    (BattleSide.player, BattleRow.back) => .89,
  };

  /// Depth scale: farther rows are drawn smaller.
  static double depth(BattleSide side, BattleRow row) => switch ((side, row)) {
    (BattleSide.enemy, BattleRow.back) => .74,
    (BattleSide.enemy, BattleRow.front) => .86,
    (BattleSide.player, BattleRow.front) => 1,
    (BattleSide.player, BattleRow.back) => .9,
  };

  /// Feet point of fighter [index] of [count] in a row.
  Offset feet(BattleSide side, BattleRow row, int index, int count) {
    final spacing = size.width * (row == BattleRow.front ? .3 : .34);
    final x = size.width / 2 + (index - (count - 1) / 2) * spacing;
    return Offset(x, size.height * _feet(side, row));
  }
}

/// The arena floor: night sky, stone pit with the gait circle as a rune ring,
/// a brass rim, a midline and two torches. [flicker] moves the torch light.
class ArenaPainter extends CustomPainter {
  const ArenaPainter({this.flicker = 0});

  final double flicker;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final all = Offset.zero & size;
    canvas.drawRect(
      all,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ArenaColors.night, ArenaColors.dusk, Color(0xFF0B0806)],
          stops: [0, .45, 1],
        ).createShader(all),
    );
    var seed = 4241;
    double rnd() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    final star = Paint();
    for (var i = 0; i < 60; i++) {
      star.color = Color.fromRGBO(240, 230, 255, .15 + rnd() * .45);
      canvas.drawCircle(Offset(rnd() * w, rnd() * h * .2), .4 + rnd(), star);
    }

    final c = Offset(w / 2, h * .58);
    final floor = Rect.fromCenter(center: c, width: w * 1.2, height: h * .78);
    canvas.drawOval(
      floor.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0xCC000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawOval(
      floor,
      Paint()
        ..shader = const RadialGradient(
          colors: [ArenaColors.stone, Color(0xFF2C2533), ArenaColors.stoneDeep],
          stops: [0, .6, 1],
        ).createShader(floor),
    );
    final seam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x55000000);
    for (final f in [.34, .67]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c,
          width: floor.width * f,
          height: floor.height * f,
        ),
        seam,
      );
    }
    for (var i = 0; i < 16; i++) {
      final a = i * pi / 8;
      final d = Offset(cos(a) * floor.width / 2, sin(a) * floor.height / 2);
      canvas.drawLine(c + d * .34, c + d, seam);
    }

    // The gait circle as a glowing rune ring: Stroll, Trot, Gallop.
    final ring = Rect.fromCenter(
      center: c,
      width: floor.width * .5,
      height: floor.height * .5,
    );
    const gaits = [CompanionType.moss, CompanionType.gale, CompanionType.brook];
    for (var i = 0; i < 3; i++) {
      final start = -pi / 2 + i * 2 * pi / 3 + .12;
      final col = tempoColor(gaits[i]);
      canvas.drawArc(
        ring,
        start,
        2 * pi / 3 - .24,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..color = col.withValues(alpha: .35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawArc(
        ring,
        start,
        2 * pi / 3 - .24,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = col.withValues(alpha: .85),
      );
    }

    final mid = Paint()
      ..strokeWidth = 2
      ..shader = const LinearGradient(
        colors: [
          Color(0x00D2B074),
          ArenaColors.brass,
          ArenaColors.brassLight,
          ArenaColors.brass,
          Color(0x00D2B074),
        ],
      ).createShader(Rect.fromLTWH(0, c.dy - 1, w, 2));
    canvas.drawLine(
      Offset(floor.left + 20, c.dy),
      Offset(floor.right - 20, c.dy),
      mid,
    );
    final diamond = Path()
      ..moveTo(c.dx, c.dy - 7)
      ..lineTo(c.dx + 7, c.dy)
      ..lineTo(c.dx, c.dy + 7)
      ..lineTo(c.dx - 7, c.dy)
      ..close();
    canvas.drawPath(diamond, Paint()..color = ArenaColors.brass);

    canvas.drawOval(
      floor,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ArenaColors.brassLight,
            ArenaColors.brass,
            Color(0xFF5E4523),
          ],
        ).createShader(floor),
    );
    canvas.drawOval(
      floor.deflate(4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF140D08),
    );

    for (final x in [w * .07, w * .93]) {
      _torch(canvas, Offset(x, h * .52), w, x < w / 2 ? 0 : 1.7);
    }

    canvas.drawRect(
      all,
      Paint()
        ..shader = const RadialGradient(
          radius: .85,
          colors: [Color(0x00000000), Color(0xB0000000)],
          stops: [.6, 1],
        ).createShader(all),
    );
  }

  void _torch(Canvas canvas, Offset at, double w, double phase) {
    final f = 1 + .06 * sin(flicker * 9 + phase) + .03 * sin(flicker * 23);
    final glow = Rect.fromCircle(center: at, radius: w * .24 * f);
    canvas.drawOval(
      glow,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x88E8873A), Color(0x22E8873A), Color(0x00E8873A)],
          stops: [0, .45, 1],
        ).createShader(glow),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: at + const Offset(0, 22), width: 7, height: 40),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF3A281C),
    );
    final top = at + const Offset(0, 2);
    final flame = Path()
      ..moveTo(top.dx - 7, top.dy)
      ..quadraticBezierTo(top.dx - 8, top.dy - 14 * f, top.dx, top.dy - 24 * f)
      ..quadraticBezierTo(top.dx + 8, top.dy - 14 * f, top.dx + 7, top.dy)
      ..close();
    canvas.drawPath(
      flame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFFE6A0), ArenaColors.ember, Color(0xFFB0301A)],
        ).createShader(flame.getBounds()),
    );
  }

  @override
  bool shouldRepaint(ArenaPainter old) => old.flicker != flicker;
}

/// Herz bar: a brass-framed red bar with the Herz number.
class HerzBar extends StatelessWidget {
  const HerzBar({
    super.key,
    required this.heart,
    required this.max,
    required this.width,
  });

  final int heart;
  final int max;
  final double width;

  @override
  Widget build(BuildContext context) {
    final f = max <= 0 ? 0.0 : (heart / max).clamp(0.0, 1.0);
    return Container(
      width: width,
      height: 13,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0E0E),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ArenaColors.brass, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 3)],
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: f,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF06A60),
                    ArenaColors.heart,
                    Color(0xFF7A1A1E),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              '$heart',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                height: 1,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 2)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stone pedestal under a fighter with a glow in its gait colour.
class _PedestalPainter extends CustomPainter {
  const _PedestalPainter(this.gait, {this.lit = false});

  final CompanionType? gait;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final col = gait == null ? ArenaColors.brass : tempoColor(gait!);
    canvas.drawOval(
      r.inflate(lit ? 8 : 4),
      Paint()
        ..color = col.withValues(alpha: lit ? .7 : .4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawOval(
      r.shift(const Offset(0, 4)),
      Paint()..color = const Color(0xFF0E0B10),
    );
    canvas.drawOval(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.4),
          colors: [Color(0xFF6A5E70), Color(0xFF3A3140), Color(0xFF1E1924)],
        ).createShader(r),
    );
    canvas.drawOval(
      r.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = col.withValues(alpha: .9),
    );
  }

  @override
  bool shouldRepaint(_PedestalPainter old) =>
      old.gait != gait || old.lit != lit;
}

const _grey = ColorFilter.matrix([
  .3, .59, .11, 0, 0, //
  .3, .59, .11, 0, 0, //
  .3, .59, .11, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// A fighter on the field: Herz bar, the creature on its pedestal, gait coin
/// and level. The box is [size] wide and [size] × 1.3 tall, feet at the
/// bottom centre.
class ArenaFigure extends StatelessWidget {
  const ArenaFigure({
    super.key,
    required this.entry,
    required this.side,
    required this.size,
    this.heart,
    this.knockedOut = false,
    this.lit = false,
  });

  final ArenaEntry entry;
  final BattleSide side;
  final double size;
  final int? heart;
  final bool knockedOut;
  final bool lit;

  static double heightFor(double size) => size * 1.3;

  @override
  Widget build(BuildContext context) {
    final gait = entry.fighter.tempo;
    Widget art = CompanionArt(entry.artKey);
    if (side == BattleSide.enemy) art = Transform.flip(flipX: true, child: art);
    if (knockedOut) {
      art = Opacity(
        opacity: .35,
        child: ColorFiltered(colorFilter: _grey, child: art),
      );
    }
    final pedestal = size * .22;
    return SizedBox(
      width: size,
      height: heightFor(size),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * .08,
            right: size * .08,
            bottom: 0,
            height: pedestal,
            child: CustomPaint(
              painter: _PedestalPainter(knockedOut ? null : gait, lit: lit),
            ),
          ),
          Positioned(
            left: size * .04,
            right: size * .04,
            bottom: pedestal * .45,
            height: size * .92,
            child: art,
          ),
          Positioned(
            top: 0,
            left: size * .06,
            child: HerzBar(
              heart: heart ?? entry.maxHeart,
              max: entry.maxHeart,
              width: size * .88,
            ),
          ),
          Positioned(
            top: 17,
            right: size * .02,
            child: _Coin(
              color: tempoColor(gait),
              child: Icon(elementIcon(gait), size: 11, color: Colors.white),
            ),
          ),
          Positioned(
            top: 17,
            left: size * .02,
            child: _Coin(
              color: const Color(0xFF3A281C),
              child: Text(
                '${entry.level}',
                style: const TextStyle(
                  color: ArenaColors.brassLight,
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: ArenaColors.brass, width: 1.2),
      boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 3)],
    ),
    child: child,
  );
}

/// A free slot: a dashed brass ring on the floor with a plus.
class EmptySlot extends StatelessWidget {
  const EmptySlot({super.key, required this.size, required this.label});

  final double size;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: ArenaFigure.heightFor(size),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(
          Icons.add_circle_outline,
          color: ArenaColors.brass,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: ArenaColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: size * .84,
          height: size * .22,
          child: const CustomPaint(painter: _DashedRing()),
        ),
      ],
    ),
  );
}

class _DashedRing extends CustomPainter {
  const _DashedRing();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawOval(r, Paint()..color = const Color(0x33000000));
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = ArenaColors.brass.withValues(alpha: .8);
    const n = 18;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(r, i * 2 * pi / n, pi / n, false, p);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => false;
}

/// Big ember button of the arena.
class ArenaButton extends StatelessWidget {
  const ArenaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final on = onPressed != null;
    return Opacity(
      opacity: on ? 1 : .45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0A050),
                  ArenaColors.ember,
                  Color(0xFF9A3E18),
                ],
              ),
              border: Border.all(color: ArenaColors.brassLight, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: ArenaColors.ember.withValues(alpha: on ? .55 : 0),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    fontSize: 15,
                    shadows: [Shadow(blurRadius: 3, color: Color(0xAA000000))],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
