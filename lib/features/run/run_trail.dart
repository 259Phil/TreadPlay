import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/game_data.dart';
import '../../domain/companion.dart';
import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/format.dart';
import '../wanderweg/trail_layout.dart';
import '../wanderweg/wanderweg_screen.dart';

/// Where the companion stands on the Wanderweg during a run: lifetime
/// distance plus this run, between the last reached and the next waymark.
class RunTrailSpot {
  const RunTrailSpot(this.progress, this.totalM);

  final WanderwegProgress progress;

  /// Lifetime distance of valid runs plus the run so far, in metres.
  final double totalM;

  bool get complete => progress.complete;
  Waymark? get next => complete ? null : waymarks[progress.reached];
  double get fromM =>
      progress.reached == 0 ? 0 : waymarks[progress.reached - 1].meters;
  double get toM => next?.meters ?? fromM;

  /// Distance walked on the trail; it waits at a waymark whose tasks are
  /// still open.
  double get trailM => complete ? totalM : math.min(totalM, toM);

  double get leftM => math.max(0, toM - totalM);

  /// Share (0–1) of the way from the last to the next waymark.
  double get fraction => complete
      ? 1
      : ((trailM - fromM) / (toM - fromM)).clamp(0.0, 1.0).toDouble();

  String label(BuildContext context, AppLocalizations l) {
    final n = next;
    if (n == null) return l.runTrailComplete;
    if (leftM <= 0) return l.runTrailAtWaymark(n.number);
    return l.runTrailToNext(
      formatNumber(context, leftM / 1000, pattern: '0.0'),
      n.number,
    );
  }
}

/// The companion on the trail, stepping (a small hop and sway) only while
/// [moving].
class TrailFigure extends StatefulWidget {
  const TrailFigure({
    super.key,
    required this.companion,
    required this.size,
    required this.moving,
    this.glow = true,
    this.shadow = const Color(0x8C000000),
  });

  final Companion companion;
  final double size;
  final bool moving;
  final bool glow;

  /// Soft ground shadow under the feet.
  final Color shadow;

  @override
  State<TrailFigure> createState() => _TrailFigureState();
}

class _TrailFigureState extends State<TrailFigure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _step = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TrailFigure old) {
    super.didUpdateWidget(old);
    if (old.moving != widget.moving) _sync();
  }

  void _sync() {
    if (widget.moving) {
      _step.repeat();
    } else if (_step.isAnimating) {
      // Finish the step, then stand.
      _step.animateTo(1).whenComplete(() {
        if (mounted && !widget.moving) _step.value = 0;
      });
    }
  }

  @override
  void dispose() {
    _step.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox.square(
      dimension: s,
      child: AnimatedBuilder(
        animation: _step,
        builder: (context, child) {
          final t = _step.value;
          final hop = math.sin(t * math.pi);
          final sway = math.sin(t * 2 * math.pi) * 0.05;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              if (widget.glow)
                Positioned(
                  bottom: -s * 0.05,
                  width: s * (0.8 - hop * 0.12),
                  height: s * 0.2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(60, 20),
                      ),
                      gradient: RadialGradient(
                        colors: [widget.shadow, widget.shadow.withAlpha(0)],
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, -hop * s * 0.07),
                  child: Transform.rotate(
                    angle: sway,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
        child: Image.asset(
          widget.companion.imageAsset,
          key: const Key('run-trail-figure'),
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

/// Eases the trail distance between the 1 s movement samples.
class _Smooth extends StatelessWidget {
  const _Smooth({required this.meters, required this.builder});

  final double meters;
  final Widget Function(BuildContext context, double meters) builder;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: meters),
    duration: const Duration(milliseconds: 1000),
    builder: (context, m, _) => builder(context, m),
  );
}

/// Label below the companion: the distance to the next waymark, on a soft
/// pill so the trail never runs through the text.
class _TrailLabel extends StatelessWidget {
  const _TrailLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xEB1A130E),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x40C4A36A), width: 0.8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      child: Text(
        text,
        key: const Key('run-trail-label'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xD9CDB892),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
  );
}

/// The real Wanderweg (same art, stitched trail, signs and medallions as the
/// Wanderweg screen) in the free space below the run controls: shown at the
/// Wanderweg screen's own scale so the painted art is never blown up,
/// dimmed a little and faded out at the top and bottom. The camera keeps
/// the companion in the middle of the space.
class RunTrailMap extends StatelessWidget {
  const RunTrailMap({
    super.key,
    required this.game,
    required this.spot,
    required this.companion,
    required this.moving,
  });

  /// Smallest height the free space below the controls gets; the run page
  /// scrolls instead of squeezing the map further.
  static const double minHeight = 200;

  /// Where the companion's feet sit, as a share of the map's height.
  static const double focalY = 0.56;

  final GameData game;
  final RunTrailSpot spot;
  final Companion companion;
  final bool moving;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      final geo = TrailGeometry(width: w, topPad: 0, bottomPad: 0);
      final fig = w * 0.18;
      return ClipRect(
        key: const Key('run-trail-map'),
        child: _Smooth(
          meters: spot.totalM,
          builder: (context, m) {
            final at = RunTrailSpot(spot.progress, m);
            final s = geo.companionS(spot.progress, m);
            final p = geo.at(s);
            final ty = (h * focalY - p.dy)
                .clamp(h - geo.totalHeight, 0.0)
                .toDouble();
            return Stack(
              children: [
                Positioned.fill(
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, .18, .76, .97],
                      colors: [
                        Color(0x00FFFFFF),
                        Color(0xFFFFFFFF),
                        Color(0xFFFFFFFF),
                        Color(0x00FFFFFF),
                      ],
                    ).createShader(r),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: ty,
                          width: w,
                          height: geo.totalHeight,
                          child: TrailMapContent(
                            geo: geo,
                            game: game,
                            companionS: s,
                            showCompanion: false,
                            interactive: false,
                          ),
                        ),
                        // Muted: the map stays in the background.
                        const Positioned.fill(
                          child: ColoredBox(color: Color(0x66120D0A)),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: p.dx - fig / 2,
                  top: p.dy + ty - fig * 0.94,
                  child: TrailFigure(
                    companion: companion,
                    size: fig,
                    moving: moving,
                  ),
                ),
                // Fixed at the bottom, in the faded strip, so it never
                // covers a waymark or its label.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Center(
                    child: _TrailLabel(
                      at.label(context, AppLocalizations.of(context)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
