part of 'forge_screen.dart';

// The suspense moment of a forge: the outcome is already decided by the
// game logic, the screen only reveals it after the hammer falls.
// Aufwerten: the hammer lifts off the small anvil and strikes three times,
// the last blow heavier. Success: a golden burst and the target level lights
// up. Failure: a dull blow, a grey puff and the seal cracks into splinters.

/// A running reveal: [anim] runs 0..1, [outcome] is what it will show.
class _Strike {
  const _Strike(this.anim, this.outcome);

  final Animation<double> anim;
  final ForgeOutcome outcome;
}

const _upStrikeTime = Duration(milliseconds: 1400);

/// The three blows, as points of the 0..1 timeline.
const _hits = [0.20, 0.44, 0.80];

/// From the last blow on, the result shows.
const _reveal = 0.80;

double _easeOut(double x) => 1 - (1 - x) * (1 - x);
double _easeIn(double x) => x * x * x;

/// How far the hammer is lifted (radians) at [t]; 0 rests on the anvil.
double _hammerLift(double t, bool success) {
  double swing(double s, double e, double peak, double upShare) {
    final u = ((t - s) / (e - s)).clamp(0.0, 1.0);
    if (u < upShare) return peak * _easeOut(u / upShare);
    // A short hold at the top, then a fast fall.
    final d = ((u - upShare) / (1 - upShare)).clamp(0.0, 1.0);
    return peak * (1 - _easeIn(d));
  }

  if (t < _hits[0]) return swing(0, _hits[0], .75, .6);
  if (t < _hits[1]) return swing(_hits[0], _hits[1], .75, .6);
  if (t < _hits[2]) return swing(_hits[1], _hits[2], 1.15, .72);
  // A light bounce after a good blow; a dull one just lies there.
  if (!success) return 0;
  final u = (t - _hits[2]) / .12;
  return u >= 1 ? 0 : .14 * math.sin(u * math.pi);
}

/// How far the resting hammer floats above the anvil face (logical px);
/// it drops onto the face for each blow and settles back afterwards.
const _restRaise = 3.0;

/// 1 while the hammer rests, 0 during the blows.
double _restShare(double t) {
  double smooth(double x) => x * x * (3 - 2 * x);
  if (t < _hits[0]) return 1 - smooth((t / _hits[0]).clamp(0.0, 1.0));
  if (t <= _hits[2]) return 0;
  return smooth(((t - _hits[2]) / (1 - _hits[2])).clamp(0.0, 1.0));
}

/// The small anvil with its hammer, sparks, flash and smoke.
class _AnvilStrike extends StatelessWidget {
  const _AnvilStrike({this.strike});

  final _Strike? strike;

  static const width = 78.0;
  static const height = 50.0;

  /// Where the hammer meets the anvil face.
  static const impact = Offset(37, 23);

  @override
  Widget build(BuildContext context) {
    final s = strike;
    if (s == null) return _frame(context, 0, null);
    return AnimatedBuilder(
      animation: s.anim,
      builder: (context, _) => _frame(context, s.anim.value, s.outcome),
    );
  }

  Widget _frame(BuildContext context, double t, ForgeOutcome? outcome) {
    final success = outcome?.success ?? true;
    final lift = _hammerLift(t, success);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 11,
            top: 18,
            width: 54,
            child: Image.asset('assets/forge/anvil_plain.webp'),
          ),
          if (outcome != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _SparkPainter(t: t, success: success),
              ),
            ),
          // Pivot at the handle end; the head sits on the anvil face.
          Positioned(
            left: 30,
            top: -6,
            width: 36,
            height: 20,
            child: Transform.translate(
              offset: Offset(0, -_restRaise * _restShare(t)),
              child: Transform.rotate(
                angle: -.35 + lift,
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/forge/hammer.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.t, required this.success});

  final double t;
  final bool success;

  @override
  void paint(Canvas canvas, Size size) {
    const p = _AnvilStrike.impact;
    for (var i = 0; i < _hits.length; i++) {
      final last = i == _hits.length - 1;
      final life = last ? (success ? .2 : .1) : .11;
      final age = (t - _hits[i]) / life;
      if (age < 0 || age > 1) continue;
      if (last && success) {
        // Golden flash behind the burst.
        canvas.drawCircle(
          p,
          8 + 22 * age,
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFFFFE7A3).withValues(alpha: .75 * (1 - age)),
                const Color(0x00FFB040),
              ],
            ).createShader(Rect.fromCircle(center: p, radius: 8 + 22 * age)),
        );
      }
      final rnd = math.Random(7 + i * 31);
      final n = last ? (success ? 22 : 4) : 7;
      final reach = last ? (success ? 40.0 : 10.0) : 18.0;
      final hot = last && success
          ? const Color(0xFFFFD86B)
          : last
          ? const Color(0xFF9A6A4A)
          : const Color(0xFFFF9A3C);
      for (var k = 0; k < n; k++) {
        final a = -math.pi * (.08 + .84 * rnd.nextDouble());
        final v = reach * (.55 + .45 * rnd.nextDouble());
        final d = Offset(math.cos(a), math.sin(a));
        final head = p + d * v * age + Offset(0, 14 * age * age);
        final tail = p + d * v * math.max(0, age - .25);
        canvas.drawLine(
          tail,
          head,
          Paint()
            ..color = hot.withValues(alpha: 1 - age)
            ..strokeWidth = last && success ? 1.6 : 1.2
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    // Failure: a grey puff rising from the anvil face.
    if (!success && t >= _reveal) {
      final u = ((t - _reveal) / (1 - _reveal)).clamp(0.0, 1.0);
      final rnd = math.Random(3);
      for (var k = 0; k < 5; k++) {
        final dx = (rnd.nextDouble() - .5) * 26;
        final c =
            p +
            Offset(dx * (.4 + u), -4 - 14 * u * (.6 + .4 * rnd.nextDouble()));
        canvas.drawCircle(
          c,
          4 + 7 * u,
          Paint()
            ..color = const Color(0xFF8C8580).withValues(alpha: .55 * (1 - u))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.t != t || old.success != success;
}

/// The seal in the input slot cracks, then falls apart into splinters.
class _CrackOverlay extends StatelessWidget {
  const _CrackOverlay({required this.strike, required this.child});

  final _Strike? strike;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = strike;
    if (s == null || s.outcome.success) return child;
    return AnimatedBuilder(
      animation: s.anim,
      child: child,
      builder: (context, child) {
        final t = s.anim.value;
        if (t < _reveal) return child!;
        final u = ((t - _reveal) / (1 - _reveal)).clamp(0.0, 1.0);
        return CustomPaint(
          foregroundPainter: _CrackPainter(u),
          child: Opacity(opacity: 1 - .65 * u, child: child),
        );
      },
    );
  }
}

class _CrackPainter extends CustomPainter {
  _CrackPainter(this.u);

  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final grow = (u / .45).clamp(0.0, 1.0);
    final ink = Paint()
      ..color = const Color(0xFF1A120D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final glow = Paint()
      ..color = const Color(0xFFE39255).withValues(alpha: .8 * (1 - u))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final rnd = math.Random(11);
    for (var k = 0; k < 5; k++) {
      final a = k * 2 * math.pi / 5 + rnd.nextDouble() * .6;
      final path = Path()..moveTo(c.dx, c.dy);
      var pos = c;
      for (var j = 1; j <= 3; j++) {
        final aj = a + (rnd.nextDouble() - .5) * .7;
        pos = c + Offset(math.cos(aj), math.sin(aj)) * r * .8 * grow * (j / 3);
        path.lineTo(pos.dx, pos.dy);
      }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, ink);
    }
    // Splinters fly off once the cracks are through.
    if (u <= .45) return;
    final f = (u - .45) / .55;
    for (var k = 0; k < 7; k++) {
      final a = k * 2 * math.pi / 7 + rnd.nextDouble() * .5;
      final d = Offset(math.cos(a), math.sin(a));
      final at = c + d * r * (.35 + .75 * f) + Offset(0, 10 * f * f);
      final s = 3.5 + rnd.nextDouble() * 2.5;
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(a + f * 3);
      canvas.drawPath(
        Path()
          ..moveTo(-s, -s * .5)
          ..lineTo(s, 0)
          ..lineTo(-s * .4, s * .7)
          ..close(),
        Paint()..color = const Color(0xFFB7A48A).withValues(alpha: 1 - f * .8),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CrackPainter old) => old.u != u;
}
