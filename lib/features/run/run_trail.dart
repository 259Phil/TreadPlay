import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/companion.dart';
import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../wanderweg/trail_layout.dart';

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
  });

  final Companion companion;
  final double size;
  final bool moving;
  final bool glow;

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
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.elliptical(60, 20)),
                      gradient: RadialGradient(
                        colors: [Color(0x99E08A3C), Color(0x00E08A3C)],
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

/// Small pill with the distance to the next waymark.
class _TrailPill extends StatelessWidget {
  const _TrailPill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xCC120D0A),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x66D2B074)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        text,
        key: const Key('run-trail-label'),
        style: const TextStyle(
          color: TreadColors.brass,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

/// The painted Wanderweg, zoomed in and lightly dimmed behind the run; the
/// camera follows the companion, which sits low on the screen below the
/// controls.
class RunTrailMap extends StatelessWidget {
  const RunTrailMap({
    super.key,
    required this.spot,
    required this.companion,
    required this.moving,
  });

  /// Screen pixels per metre the companion should move at most zooms.
  static const double pxPerM = 0.3;
  static const double minZoom = 3;
  static const double maxZoom = 5.5;

  /// How far (px per metre) the dots ahead flow towards the companion, so
  /// walking pace reads even where the painted stretch is short.
  static const double flowPxPerM = 6;

  /// Zoom for the current stretch, so walking moves the companion visibly
  /// (about [pxPerM]) without blowing the art up too far.
  static double zoomFor(RunTrailSpot spot, double width) {
    final next = spot.next;
    if (next == null) return minZoom;
    final geo = TrailGeometry(width: width, topPad: 0, bottomPad: 0);
    final a = geo.companionS(spot.progress, spot.fromM);
    final b = geo.companionS(spot.progress, spot.toM);
    final perM = (b - a).abs() / (spot.toM - spot.fromM);
    if (perM <= 0) return minZoom;
    return (pxPerM / perM).clamp(minZoom, maxZoom).toDouble();
  }

  final RunTrailSpot spot;
  final Companion companion;
  final bool moving;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      final geo = TrailGeometry(
        width: w * zoomFor(spot, w),
        topPad: 0,
        bottomPad: 0,
      );
      return _Smooth(
        meters: spot.totalM,
        builder: (context, m) {
          final at = RunTrailSpot(spot.progress, m);
          final s = geo.companionS(spot.progress, m);
          final p = geo.at(s);
          final focal = Offset(w / 2, h * 0.84);
          final tx = (focal.dx - p.dx).clamp(w - geo.width, 0.0).toDouble();
          final ty = (focal.dy - p.dy)
              .clamp(h - geo.totalHeight, 0.0)
              .toDouble();
          final fig = w * 0.2;
          final nextS = at.next == null ? s : geo.waymarkS(at.next!.number);
          return ClipRect(
            key: const Key('run-trail-a'),
            child: Stack(
              children: [
                Positioned(
                  left: tx,
                  top: ty,
                  width: geo.width,
                  height: geo.totalHeight,
                  child: Stack(
                    children: [
                      for (var i = 0; i < trailSections.length; i++)
                        if (geo.sectionTop(i) + ty < h &&
                            geo.sectionTop(i) + geo.sectionHeight + ty > 0)
                          Positioned(
                            top: geo.sectionTop(i),
                            left: 0,
                            width: geo.width,
                            height: geo.sectionHeight + 1,
                            // The leather map is dark; lift it a little.
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                1.35, 0, 0, 0, 14, //
                                0, 1.35, 0, 0, 10, //
                                0, 0, 1.35, 0, 6, //
                                0, 0, 0, 1, 0, //
                              ]),
                              child: Image.asset(
                                trailSections[i].asset,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapPath(
                            geo: geo,
                            walkedS: s,
                            nextS: nextS,
                            flow: m * flowPxPerM,
                            reached: spot.progress.reached,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Light dim: a little more behind the LP at the top, clear
                // around the companion.
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, .3, .7, 1],
                        colors: [
                          Color(0x99120D0A),
                          Color(0x66120D0A),
                          Color(0x26120D0A),
                          Color(0x33120D0A),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: p.dx + tx - fig / 2,
                  top: p.dy + ty - fig * 0.92,
                  child: TrailFigure(
                    companion: companion,
                    size: fig,
                    moving: moving,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: p.dy + ty + 6,
                  child: Center(
                    child: _TrailPill(
                      at.label(context, AppLocalizations.of(context)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _MapPath extends CustomPainter {
  _MapPath({
    required this.geo,
    required this.walkedS,
    required this.nextS,
    required this.reached,
    this.flow = 0,
  });

  final TrailGeometry geo;
  final double walkedS;
  final double nextS;

  /// Grows with the distance walked; shifts the dots ahead towards the
  /// companion.
  final double flow;
  final int reached;

  void _dashes(Canvas c, double from, double to, Paint p) {
    for (var s = from; s < to; s += 18) {
      c.drawLine(geo.at(s), geo.at(math.min(s + 11, to)), p);
    }
  }

  Paint _stroke(Color color, double width, {double blur = 0}) {
    final p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (blur > 0) p.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Path still ahead: light dashes on a dark edge so they read on leather.
    _dashes(canvas, walkedS, geo.endS, _stroke(const Color(0x99000000), 7));
    _dashes(canvas, walkedS, geo.endS, _stroke(const Color(0xE6E8D9B8), 3.5));
    // Walked path: glowing gold.
    _dashes(
      canvas,
      geo.startS,
      walkedS,
      _stroke(const Color(0xB3E08A3C), 12, blur: 5),
    );
    _dashes(canvas, geo.startS, walkedS, _stroke(const Color(0xFFF6D488), 5));
    final ahead = Paint()..color = const Color(0xFFF6D488);
    for (var s = walkedS + 18 - flow % 18; s < nextS; s += 18) {
      if (s < walkedS + 6) continue;
      canvas.drawCircle(geo.at(s), 3, ahead);
    }
    for (final wm in waymarks) {
      final c = geo.at(geo.waymarkS(wm.number));
      final done = wm.number <= reached;
      final isNext = wm.number == reached + 1;
      final r = isNext ? 21.0 : 17.0;
      if (isNext) {
        canvas.drawCircle(
          c,
          r + 8,
          Paint()
            ..color = const Color(0x99F1C877)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
        );
      }
      canvas.drawCircle(
        c.translate(0, 2),
        r + 1,
        Paint()
          ..color = const Color(0x99000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = done ? const Color(0xFFE0BE7E) : const Color(0xF2241912),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isNext ? 3 : 2
          ..color = const Color(0xFFF1C877),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${wm.number}',
          style: TextStyle(
            color: done ? const Color(0xFF241912) : const Color(0xFFF6EEDC),
            fontSize: isNext ? 17 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_MapPath old) =>
      old.walkedS != walkedS ||
      old.flow != flow ||
      old.nextS != nextS ||
      old.reached != reached ||
      old.geo.width != geo.width;
}
