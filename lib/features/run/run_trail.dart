import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/companion.dart';
import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
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

/// How the Wanderweg shows below the run controls (preview: `?lauf=1|2|3`).
enum RunTrailLook {
  /// Faint vector trail on the dimmed leather, companion in the middle.
  calm,

  /// The trail inked on a parchment map card.
  parchment,

  /// A narrow side-scrolling band from the last to the next waymark.
  horizon;

  /// Temporary preview switch while Philip picks a look.
  static RunTrailLook fromUrl() => switch (Uri.base.queryParameters['lauf']) {
    '2' => parchment,
    '3' => horizon,
    _ => calm,
  };

  /// Smallest height the free space below the controls gets; the run page
  /// scrolls instead of squeezing the map further.
  double get minHeight => this == horizon ? 150 : 200;
}

/// Label below the companion: the distance to the next waymark, on a soft
/// pill so the trail never runs through the text.
class _TrailLabel extends StatelessWidget {
  const _TrailLabel(
    this.text, {
    this.color = const Color(0xD9CDB892),
    this.fill = const Color(0x99120D0A),
    this.border = const Color(0x33C4A36A),
  });

  final String text;
  final Color color;
  final Color fill;
  final Color border;

  @override
  Widget build(BuildContext context) => Center(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          text,
          key: const Key('run-trail-label'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    ),
  );
}

/// The Wanderweg in the free space below the run controls. Everything is
/// drawn as vectors at screen resolution, so it stays sharp at any zoom.
class RunTrailMap extends StatelessWidget {
  const RunTrailMap({
    super.key,
    required this.spot,
    required this.companion,
    required this.moving,
    this.look = RunTrailLook.calm,
  });

  /// Screen pixels per metre the companion should move at most zooms.
  static const double pxPerM = 0.3;
  static const double minZoom = 3;
  static const double maxZoom = 5.5;

  /// How far (px per metre) the dots ahead flow towards the companion, so
  /// walking pace reads even where the trail is short.
  static const double flowPxPerM = 6;

  /// Zoom for the current stretch, so walking moves the companion visibly
  /// (about [pxPerM]) without the trail turning into one long line.
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
  final RunTrailLook look;

  @override
  Widget build(BuildContext context) => switch (look) {
    RunTrailLook.calm => _CalmMap(this),
    RunTrailLook.parchment => _ParchmentMap(this),
    RunTrailLook.horizon => _HorizonMap(this),
  };
}

/// Colours for one look's trail.
class _Ink {
  const _Ink({
    required this.ahead,
    required this.walked,
    required this.dots,
    required this.ring,
    required this.ringNext,
    required this.fill,
    required this.fillDone,
    required this.number,
    required this.numberDone,
    this.edge,
  });

  final Color ahead;
  final Color walked;
  final Color dots;
  final Color ring;
  final Color ringNext;
  final Color fill;
  final Color fillDone;
  final Color number;
  final Color numberDone;

  /// Thin dark edge under the dashes, so they read on busy ground.
  final Color? edge;
}

const _calmInk = _Ink(
  ahead: Color(0x66D8C4A0),
  walked: Color(0x99C4A36A),
  dots: Color(0x80D8C4A0),
  ring: Color(0x80C4A36A),
  ringNext: Color(0xCCC4A36A),
  fill: Color(0xD91A130E),
  fillDone: Color(0xB38A7148),
  number: Color(0xCCE8DCC4),
  numberDone: Color(0xFF1A130E),
  edge: Color(0x40000000),
);

const _parchmentInk = _Ink(
  ahead: Color(0x995A4632),
  walked: Color(0xCC7A4428),
  dots: Color(0xB35A4632),
  ring: Color(0xA65A4330),
  ringNext: Color(0xE65A3A24),
  fill: Color(0x1A5A4330),
  fillDone: Color(0xB35A4330),
  number: Color(0xE04A3626),
  numberDone: Color(0xFFD8C8A4),
);

/// The trail around the companion, in [size]; the companion's feet sit at
/// [focal].
class _TrailView extends StatelessWidget {
  const _TrailView({
    required this.map,
    required this.size,
    required this.focal,
    required this.ink,
    required this.fig,
    required this.labelColor,
    this.labelFill = const Color(0x99120D0A),
    this.labelBorder = const Color(0x33C4A36A),
    this.shadow = const Color(0x8C000000),
  });

  final RunTrailMap map;
  final Size size;
  final Offset focal;
  final _Ink ink;
  final double fig;
  final Color labelColor;
  final Color labelFill;
  final Color labelBorder;
  final Color shadow;

  /// Wider view than the old full-screen map, so the next waymark is in
  /// sight more often; the flowing dots carry the walking pace.
  static const double zoomShare = 0.6;

  @override
  Widget build(BuildContext context) {
    final spot = map.spot;
    final geo = TrailGeometry(
      width: size.width * RunTrailMap.zoomFor(spot, size.width) * zoomShare,
      topPad: 0,
      bottomPad: 0,
    );
    return _Smooth(
      meters: spot.totalM,
      builder: (context, m) {
        final at = RunTrailSpot(spot.progress, m);
        final s = geo.companionS(spot.progress, m);
        final shift = focal - geo.at(s);
        final nextS = at.next == null ? s : geo.waymarkS(at.next!.number);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .16, .86, 1],
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ).createShader(r),
                child: CustomPaint(
                  painter: _MapPath(
                    geo: geo,
                    shift: shift,
                    ink: ink,
                    walkedS: s,
                    nextS: nextS,
                    flow: m * RunTrailMap.flowPxPerM,
                    reached: spot.progress.reached,
                  ),
                ),
              ),
            ),
            Positioned(
              left: focal.dx - fig / 2,
              top: focal.dy - fig * 0.92,
              child: TrailFigure(
                companion: map.companion,
                size: fig,
                moving: map.moving,
                shadow: shadow,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: focal.dy + 8,
              child: _TrailLabel(
                at.label(context, AppLocalizations.of(context)),
                color: labelColor,
                fill: labelFill,
                border: labelBorder,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Look 1: a faint trail on the leather, which darkens a little towards the
/// companion; the companion stays in the middle and the trail moves past.
class _CalmMap extends StatelessWidget {
  const _CalmMap(this.map);

  final RunTrailMap map;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final size = box.biggest;
      final fig = math.min(size.width * 0.18, size.height * 0.3);
      return ClipRect(
        key: const Key('run-trail-calm'),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00120D0A), Color(0x59120D0A)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _TrailView(
                map: map,
                size: size,
                focal: Offset(size.width / 2, size.height * 0.6),
                ink: _calmInk,
                fig: fig,
                labelColor: const Color(0xD9CDB892),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Look 2: the trail inked on a parchment map card with a fine double
/// border.
class _ParchmentMap extends StatelessWidget {
  const _ParchmentMap(this.map);

  final RunTrailMap map;

  static const _ink = Color(0xFF5A4330);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
    child: DecoratedBox(
      key: const Key('run-trail-parchment'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A2A1C), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        gradient: const RadialGradient(
          radius: 0.95,
          colors: [Color(0xFFBFA982), Color(0xFF9E8763)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: LayoutBuilder(
          builder: (context, box) {
            final size = box.biggest;
            final fig = math.min(size.width * 0.18, size.height * 0.3);
            return Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _PaperGrain()),
                ),
                Positioned.fill(
                  child: _TrailView(
                    map: map,
                    size: size,
                    focal: Offset(size.width / 2, size.height * 0.6),
                    ink: _parchmentInk,
                    fig: fig,
                    labelColor: const Color(0xFF4A3626),
                    labelFill: const Color(0xD9C4AE88),
                    labelBorder: const Color(0x665A4330),
                    shadow: const Color(0x665A4330),
                  ),
                ),
                // Fine inner frame line.
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _ink.withAlpha(0x59),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 12,
                  right: 12,
                  width: 26,
                  height: 26,
                  child: CustomPaint(painter: _Compass(_ink)),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

/// Sparse fibres and specks on the parchment, drawn at screen resolution.
class _PaperGrain extends CustomPainter {
  const _PaperGrain();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final dark = Paint()..color = const Color(0x145A4330);
    final light = Paint()..color = const Color(0x1AFFF4DC);
    final n = (size.width * size.height / 260).round();
    for (var i = 0; i < n; i++) {
      final o = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      );
      canvas.drawCircle(
        o,
        0.5 + rng.nextDouble() * 1.4,
        i.isEven ? dark : light,
      );
    }
    final fibre = Paint()
      ..color = const Color(0x125A4330)
      ..strokeWidth = 0.8;
    for (var i = 0; i < n ~/ 12; i++) {
      final o = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      );
      final a = rng.nextDouble() * math.pi;
      final l = 4 + rng.nextDouble() * 10;
      canvas.drawLine(o, o + Offset(math.cos(a), math.sin(a)) * l, fibre);
    }
  }

  @override
  bool shouldRepaint(_PaperGrain old) => false;
}

/// A small four-pointed compass star in ink.
class _Compass extends CustomPainter {
  const _Compass(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final fill = Paint()..color = color.withAlpha(0x99);
    final star = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final d = i.isEven ? r : r * 0.22;
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    canvas.drawPath(star, fill);
    canvas.drawCircle(
      c,
      r * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = color.withAlpha(0x73),
    );
  }

  @override
  bool shouldRepaint(_Compass old) => old.color != color;
}

/// Look 3: a narrow band from the last waymark (left) to the next (right);
/// the companion walks along it by distance while the ground flows past.
class _HorizonMap extends StatelessWidget {
  const _HorizonMap(this.map);

  final RunTrailMap map;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final bandH = (box.maxHeight * 0.42)
          .clamp(96.0, 140.0)
          .toDouble()
          .clamp(0.0, box.maxHeight - 44)
          .toDouble();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _Smooth(
            meters: map.spot.totalM,
            builder: (context, m) {
              final at = RunTrailSpot(map.spot.progress, m);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    key: const Key('run-trail-horizon'),
                    height: bandH,
                    child: LayoutBuilder(
                      builder: (context, band) {
                        final w = band.maxWidth;
                        final ground = bandH * 0.74;
                        final fig = bandH * 0.56;
                        final left = _HorizonBand.edge + 10;
                        final right = w - _HorizonBand.edge - 10;
                        final x = left + (right - left) * at.fraction;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _HorizonBand(
                                  fraction: at.fraction,
                                  flow: m * RunTrailMap.flowPxPerM,
                                  ground: ground,
                                  from: at.progress.reached,
                                  to: at.next?.number,
                                ),
                              ),
                            ),
                            Positioned(
                              left: x - fig / 2,
                              top: ground - fig * 0.92,
                              child: TrailFigure(
                                companion: map.companion,
                                size: fig,
                                moving: map.moving,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TrailLabel(at.label(context, AppLocalizations.of(context))),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

class _HorizonBand extends CustomPainter {
  _HorizonBand({
    required this.fraction,
    required this.flow,
    required this.ground,
    required this.from,
    required this.to,
  });

  /// Room at each end for the waymark flags.
  static const double edge = 30;

  final double fraction;
  final double flow;
  final double ground;
  final int from;
  final int? to;

  static const _beige = Color(0xFFD8C4A0);
  static const _brass = Color(0xFFC4A36A);

  double _wave(double x) => ground + math.sin((x + flow) / 37) * 1.6;

  void _flag(
    Canvas canvas,
    double x,
    int number, {
    required bool done,
    bool mirror = false,
  }) {
    final d = mirror ? -1.0 : 1.0;
    final foot = Offset(x, ground + 1);
    // Cairn: three flat stones.
    final stone = Paint()..color = const Color(0x998A7A66);
    canvas.drawOval(
      Rect.fromCenter(center: foot.translate(0, -2), width: 18, height: 7),
      stone,
    );
    canvas.drawOval(
      Rect.fromCenter(center: foot.translate(0, -7), width: 13, height: 6),
      stone,
    );
    canvas.drawOval(
      Rect.fromCenter(center: foot.translate(0, -11), width: 8, height: 5),
      stone,
    );
    // Pole and pennant with the number.
    final top = foot.translate(0, -ground * 0.78);
    canvas.drawLine(
      foot.translate(0, -12),
      top,
      Paint()
        ..color = const Color(0x99A08C70)
        ..strokeWidth = 1.4,
    );
    final pennant = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(top.dx + 28 * d, top.dy + 10)
      ..lineTo(top.dx, top.dy + 20)
      ..close();
    canvas.drawPath(
      pennant,
      Paint()..color = done ? _brass.withAlpha(0x99) : const Color(0xCC1A130E),
    );
    canvas.drawPath(
      pennant,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _brass.withAlpha(done ? 0x99 : 0xB3),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: done ? const Color(0xFF1A130E) : const Color(0xD9E8DCC4),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(top.dx + 9 * d - tp.width / 2, top.dy + 10 - tp.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0x59120D0A));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _brass.withAlpha(0x40),
    );
    canvas.save();
    canvas.clipRRect(r);
    final left = edge + 10;
    final right = size.width - edge - 10;
    final x = left + (right - left) * fraction;
    // Pebbles and tufts flow past while walking.
    final pebble = Paint()..color = _beige.withAlpha(0x26);
    final tuft = Paint()
      ..color = const Color(0x40A3A070)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const step = 29.0;
    for (var i = -1; i * step < size.width + step; i++) {
      final px = i * step - flow % step;
      final k = ((i + (flow ~/ step)) * 7919) % 13;
      final py = ground + 6 + (k % 4) * 4.0;
      if (k.isEven) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(px, py),
            width: 3.0 + k % 3,
            height: 2,
          ),
          pebble,
        );
      } else {
        final b = Offset(px, py + 1);
        canvas.drawLine(b, b.translate(-2, -4), tuft);
        canvas.drawLine(b, b.translate(0, -5), tuft);
        canvas.drawLine(b, b.translate(2, -4), tuft);
      }
    }
    // Walked: a soft solid line; ahead: faint dashes.
    final walked = Path()..moveTo(0, _wave(0));
    for (var px = 4.0; px <= x; px += 4) {
      walked.lineTo(px, _wave(px));
    }
    walked.lineTo(x, _wave(x));
    canvas.drawPath(
      walked,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = _brass.withAlpha(0x99),
    );
    final dash = Paint()
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = _beige.withAlpha(0x66);
    for (var px = x + 10 - flow % 14; px < size.width; px += 14) {
      if (px < x + 6) continue;
      canvas.drawLine(
        Offset(px, _wave(px)),
        Offset(px + 7, _wave(px + 7)),
        dash,
      );
    }
    if (from > 0) _flag(canvas, edge, from, done: true);
    if (to case final n?) {
      _flag(canvas, size.width - edge, n, done: false, mirror: true);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HorizonBand old) =>
      old.fraction != fraction ||
      old.flow != flow ||
      old.ground != ground ||
      old.from != from ||
      old.to != to;
}

class _MapPath extends CustomPainter {
  _MapPath({
    required this.geo,
    required this.shift,
    required this.ink,
    required this.walkedS,
    required this.nextS,
    required this.reached,
    this.flow = 0,
  });

  final TrailGeometry geo;

  /// Moves trail coordinates onto the screen.
  final Offset shift;
  final _Ink ink;
  final double walkedS;
  final double nextS;

  /// Grows with the distance walked; shifts the dots ahead towards the
  /// companion.
  final double flow;
  final int reached;

  late Rect _view;

  bool _visible(Offset p) => _view.contains(p);

  void _dashes(Canvas c, double from, double to, Paint p) {
    for (var s = from; s < to; s += 16) {
      final a = geo.at(s) + shift;
      final b = geo.at(math.min(s + 9, to)) + shift;
      if (!_visible(a) && !_visible(b)) continue;
      c.drawLine(a, b, p);
    }
  }

  void _line(Canvas c, double from, double to, Paint p) {
    final path = Path();
    var open = false;
    for (var s = from; s <= to; s += 6) {
      final a = geo.at(s) + shift;
      if (!_visible(a)) {
        open = false;
        continue;
      }
      open ? path.lineTo(a.dx, a.dy) : path.moveTo(a.dx, a.dy);
      open = true;
    }
    final end = geo.at(to) + shift;
    if (open) path.lineTo(end.dx, end.dy);
    c.drawPath(path, p);
  }

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..strokeWidth = width
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    _view = (Offset.zero & size).inflate(40);
    if (ink.edge case final edge?) {
      _dashes(canvas, walkedS, geo.endS, _stroke(edge, 4.5));
    }
    _dashes(canvas, walkedS, geo.endS, _stroke(ink.ahead, 2.4));
    _line(canvas, geo.startS, walkedS, _stroke(ink.walked, 3.2));
    final dots = Paint()..color = ink.dots;
    for (var s = walkedS + 16 - flow % 16; s < nextS; s += 16) {
      if (s < walkedS + 6) continue;
      final p = geo.at(s) + shift;
      if (_visible(p)) canvas.drawCircle(p, 1.8, dots);
    }
    for (final wm in waymarks) {
      final c = geo.at(geo.waymarkS(wm.number)) + shift;
      if (!_visible(c)) continue;
      final done = wm.number <= reached;
      final isNext = wm.number == reached + 1;
      final r = isNext ? 12.0 : 10.0;
      canvas.drawCircle(c, r, Paint()..color = done ? ink.fillDone : ink.fill);
      canvas.drawCircle(
        c,
        r,
        _stroke(isNext ? ink.ringNext : ink.ring, isNext ? 1.6 : 1.1),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${wm.number}',
          style: TextStyle(
            color: done ? ink.numberDone : ink.number,
            fontSize: isNext ? 12 : 10,
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
      old.shift != shift ||
      old.nextS != nextS ||
      old.reached != reached ||
      old.ink != ink ||
      old.geo.width != geo.width;
}
