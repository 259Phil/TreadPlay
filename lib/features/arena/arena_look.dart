import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/battle.dart';
import '../../domain/companion.dart';
import '../../domain/world.dart';
import '../../widgets/companion_card.dart';
import '../../widgets/companion_figure.dart';
import 'arena_state.dart';

/// Colours of the arena, taken from the TreadPlay palette.
abstract final class ArenaColors {
  static const leather = Color(0xFF241912);
  static const leatherLight = Color(0xFF3A2A20);
  static const brass = Color(0xFFD2B074);
  static const brassLight = Color(0xFFF6E2AA);
  static const brassDeep = Color(0xFF7A6238);
  static const ember = Color(0xFFD9692F);
  static const heart = Color(0xFFD23B3F);
  static const mend = Color(0xFF7FD08A);
  static const text = Color(0xFFEDE4D3);
  static const muted = Color(0xFFBBAC95);
}

/// The field in perspective, seen by the TreadPlayer from behind their own
/// companions: the rivals stand far up on the ground of the world, small;
/// your line-up stands near, large, its back turned to you.
class ArenaGeometry {
  const ArenaGeometry(this.size);

  final Size size;

  /// Width of a near fighter.
  double get figure => min(size.width * .34, size.height * .22);

  static double _feet(BattleSide side, BattleRow row) => switch ((side, row)) {
    (BattleSide.enemy, BattleRow.back) => .50,
    (BattleSide.enemy, BattleRow.front) => .58,
    (BattleSide.player, BattleRow.front) => .80,
    (BattleSide.player, BattleRow.back) => .95,
  };

  /// Depth scale: farther rows are drawn smaller.
  static double depth(BattleSide side, BattleRow row) => switch ((side, row)) {
    (BattleSide.enemy, BattleRow.back) => .5,
    (BattleSide.enemy, BattleRow.front) => .62,
    (BattleSide.player, BattleRow.front) => 1,
    (BattleSide.player, BattleRow.back) => 1.1,
  };

  /// Feet point of fighter [index] of [count] in a row; rows close in
  /// towards the horizon.
  Offset feet(BattleSide side, BattleRow row, int index, int count) {
    final d = depth(side, row);
    final spacing =
        size.width * (row == BattleRow.front ? .31 : .38) * min(1, d * 1.1);
    final x = size.width / 2 + (index - (count - 1) / 2) * spacing;
    return Offset(x, size.height * _feet(side, row));
  }

  /// Centre of the trodden ring on the ground.
  Offset get ringCenter => Offset(size.width / 2, size.height * .70);
}

/// The ground of the [world] as the battlefield: its backdrop, a trodden
/// ring in perspective and a soft vignette.
class ArenaBackdrop extends StatelessWidget {
  const ArenaBackdrop({super.key, required this.world});

  final World world;

  @override
  Widget build(BuildContext context) {
    final bg = world.background;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (bg != null)
          Image.asset(bg, fit: BoxFit.cover, alignment: Alignment.bottomCenter)
        else
          ColoredBox(color: world.placeholder),
        const CustomPaint(painter: _FieldPainter()),
      ],
    );
  }
}

class _FieldPainter extends CustomPainter {
  const _FieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final all = Offset.zero & size;
    final geo = ArenaGeometry(size);
    final c = geo.ringCenter;
    final ring = Rect.fromCenter(center: c, width: w * 1.05, height: h * .46);

    // Trodden earth inside the ring.
    canvas.drawOval(
      ring,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x40000000), Color(0x22000000), Color(0x00000000)],
          stops: [0, .7, 1],
        ).createShader(ring),
    );
    // Faint chalk lines: the ring and the line between the two sides.
    final chalk = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x55F6E2AA);
    const n = 40;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(
        ring.deflate(6),
        i * 2 * pi / n,
        pi / n * 1.2,
        false,
        chalk,
      );
    }
    final midY = h * .68;
    final half =
        w *
        .5 *
        sqrt(max(0, 1 - pow((midY - c.dy) / (ring.height / 2 - 6), 2)));
    canvas.drawLine(
      Offset(c.dx - half + 8, midY),
      Offset(c.dx + half - 8, midY),
      chalk..strokeWidth = 1.6,
    );

    // Darken the edges so the field draws the eye; top for the bar.
    canvas.drawRect(
      all,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x99241912),
            Color(0x00241912),
            Color(0x00241912),
            Color(0x66241912),
          ],
          stops: [0, .18, .82, 1],
        ).createShader(all),
    );
    canvas.drawRect(
      all,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, .3),
          radius: 1.1,
          colors: [Color(0x00000000), Color(0x88000000)],
          stops: [.55, 1],
        ).createShader(all),
    );
  }

  @override
  bool shouldRepaint(_FieldPainter old) => false;
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
        color: ArenaColors.leather,
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

/// Shadow on the ground under a fighter, rimmed in its gait colour.
class _GroundPainter extends CustomPainter {
  const _GroundPainter(this.gait, {this.lit = false});

  final CompanionType? gait;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawOval(
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x99000000), Color(0x00000000)],
        ).createShader(r),
    );
    if (gait == null) return;
    final col = tempoColor(gait!);
    canvas.drawOval(
      r.deflate(size.width * .08),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lit ? 3 : 1.6
        ..color = col.withValues(alpha: lit ? .95 : .55)
        ..maskFilter = lit ? const MaskFilter.blur(BlurStyle.normal, 2) : null,
    );
  }

  @override
  bool shouldRepaint(_GroundPainter old) => old.gait != gait || old.lit != lit;
}

const _grey = ColorFilter.matrix([
  .3, .59, .11, 0, 0, //
  .3, .59, .11, 0, 0, //
  .3, .59, .11, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// A fighter on the field: Herz bar, gait and level coins, the creature on
/// its shadow. Rivals face you; your own companions show their back. The
/// box is [size] wide and [heightFor] tall, feet at the bottom centre.
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

  static double heightFor(double size) => size * 1.25;

  @override
  Widget build(BuildContext context) {
    final gait = entry.fighter.tempo;
    final back = side == BattleSide.player ? entry.backAsset : null;
    Widget art = back == null
        ? CompanionArt(entry.artKey)
        : Image.asset(
            back,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          );
    if (knockedOut) {
      art = Opacity(
        opacity: .35,
        child: ColorFiltered(colorFilter: _grey, child: art),
      );
    }
    final shadow = size * .24;
    final coin = (size * .2).clamp(14.0, 20.0);
    return SizedBox(
      width: size,
      height: heightFor(size),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: -shadow * .3,
            height: shadow,
            child: CustomPaint(
              painter: _GroundPainter(knockedOut ? null : gait, lit: lit),
            ),
          ),
          Positioned(
            left: size * .02,
            right: size * .02,
            bottom: 0,
            height: size * .98,
            child: art,
          ),
          Positioned(
            top: 0,
            left: size * .1,
            child: HerzBar(
              heart: heart ?? entry.maxHeart,
              max: entry.maxHeart,
              width: size * .8,
            ),
          ),
          Positioned(
            top: 16,
            right: size * .04,
            child: _Coin(
              size: coin,
              color: tempoColor(gait),
              child: Icon(
                elementIcon(gait),
                size: coin * .55,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: size * .04,
            child: _Coin(
              size: coin,
              color: ArenaColors.leatherLight,
              child: Text(
                '${entry.level}',
                style: TextStyle(
                  color: ArenaColors.brassLight,
                  fontSize: coin * .5,
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
  const _Coin({required this.size, required this.color, required this.child});

  final double size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
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

/// A free slot: a dashed chalk ring on the ground with a plus.
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
          color: ArenaColors.brassLight,
          size: 28,
          shadows: [Shadow(blurRadius: 6)],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: ArenaColors.text,
            fontSize: 11,
            shadows: [Shadow(blurRadius: 4)],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: size * .9,
          height: size * .26,
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
    canvas.drawOval(r, Paint()..color = const Color(0x44000000));
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = ArenaColors.brassLight.withValues(alpha: .85);
    const n = 18;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(r, i * 2 * pi / n, pi / n, false, p);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => false;
}

/// Big brass button of the arena, like the Start button on Home.
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
    const ink = Color(0xFF2A1D15);
    return Opacity(
      opacity: on ? 1 : .45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ArenaColors.brassLight,
                  ArenaColors.brass,
                  ArenaColors.brassDeep,
                ],
              ),
              border: Border.all(color: const Color(0xFF4A3520), width: 1.6),
              boxShadow: const [
                BoxShadow(color: Color(0x99000000), blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: ink, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    color: ink,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontSize: 16,
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
