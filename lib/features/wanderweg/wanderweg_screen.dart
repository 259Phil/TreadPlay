import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/format.dart';
import 'trail_layout.dart';
import 'wanderweg_text.dart';

/// Wanderweg palette on top of [TreadColors].
class TrailColors {
  static const slate = kLeatherBuild ? Color(0xFF241912) : Color(0xFF1A1D22);
  static const slateLight = kLeatherBuild
      ? Color(0xFF3A2A20)
      : Color(0xFF2A3038);
  static const bone = Color(0xFFE8E0D0);
  static const brass = kLeatherBuild ? Color(0xFFD2B074) : Color(0xFFC4A36A);
  static const ember = Color(0xFFE08A3C);
  static const emberCore = Color(0xFFFFC27A);
}

String kmText(BuildContext context, double km) =>
    formatNumber(context, km, pattern: '0.0');

/// The painted trail: 19 waymarks over four world sections, the companion
/// taken along at its current spot, the last messenger line on top and the
/// next waymark's tasks at the bottom.
class WanderwegScreen extends ConsumerStatefulWidget {
  const WanderwegScreen({super.key});

  @override
  ConsumerState<WanderwegScreen> createState() => _WanderwegScreenState();
}

class _WanderwegScreenState extends ConsumerState<WanderwegScreen> {
  final _scroll = ScrollController();
  bool _placed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(gameProvider.notifier).markWanderwegSeen();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final insets = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: TreadColors.iron,
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final topOverlay = insets.top + 150;
          final bottomOverlay = 214 + insets.bottom;
          final geo = TrailGeometry(
            width: w,
            topPad: topOverlay + 20,
            bottomPad: 40 + insets.bottom,
          );
          final progress = game.wanderweg;
          final s = geo.companionS(progress, game.totals.distanceM);
          final at = geo.at(s);
          if (!_placed) {
            _placed = true;
            final visible = box.maxHeight - topOverlay - bottomOverlay;
            final target = at.dy - topOverlay - visible * 0.55;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_scroll.hasClients) return;
              _scroll.jumpTo(
                target.clamp(0.0, _scroll.position.maxScrollExtent),
              );
            });
          }
          return Stack(
            children: [
              SingleChildScrollView(
                key: const Key('trail-scroll'),
                controller: _scroll,
                child: SizedBox(
                  width: w,
                  height: geo.totalHeight,
                  child: TrailMapContent(geo: geo, game: game, companionS: s),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBar(game: game, topInset: insets.top),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _NextPanel(game: game, bottomInset: insets.bottom),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The painted Wanderweg with its stitched trail, world signs and waymark
/// medallions; shared by the Wanderweg screen and the run screen.
class TrailMapContent extends StatelessWidget {
  const TrailMapContent({
    super.key,
    required this.geo,
    required this.game,
    required this.companionS,
    this.showCompanion = true,
    this.interactive = true,
  });

  final TrailGeometry geo;
  final GameData game;
  final double companionS;

  /// Off on the run screen, which walks its own stepping companion.
  final bool showCompanion;

  /// Waymarks open their sheet on tap.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final w = geo.width;
    final sh = geo.sectionHeight;
    final progress = game.wanderweg;
    final reached = progress.reached;
    final nextS = progress.complete
        ? companionS
        : geo.waymarkS(waymarks[reached].number);
    final cairnH = w * 0.16;
    final at = geo.at(companionS);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < trailSections.length; i++)
          Positioned(
            top: geo.sectionTop(i),
            left: 0,
            width: w,
            height: sh + 1,
            child: Image.asset(
              trailSections[i].asset,
              key: Key('trail-art-$i'),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        // Soft seams between the painted sections, and fades into iron.
        for (var i = 1; i < trailSections.length; i++)
          Positioned(
            top: geo.sectionTop(i - 1) - 36,
            left: 0,
            right: 0,
            height: 72,
            child: const _Seam(),
          ),
        Positioned(
          top: geo.sectionTop(trailSections.length - 1),
          left: 0,
          right: 0,
          height: 90,
          child: const _Fade(down: true),
        ),
        Positioned(
          top: geo.sectionTop(0) + sh - 90,
          left: 0,
          right: 0,
          height: 90,
          child: const _Fade(down: false),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _StitchTrail(
                geo: geo,
                walkedS: companionS,
                nextS: nextS,
              ),
            ),
          ),
        ),
        for (var i = 0; i < trailSections.length; i++)
          for (final sign in trailSections[i].signs)
            _placedSign(context, geo.map(i, sign.at), sign, reached),
        for (final wm in waymarks)
          ..._cairn(context, wm, geo.cairnFoot(wm.number), cairnH),
        if (showCompanion) ...[
          Positioned(
            left: at.dx - w * 0.09,
            top: at.dy - w * 0.17,
            width: w * 0.18,
            height: w * 0.18,
            child: _Companion(game: game),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: at.dy + w * 0.01 + 4,
            height: 22,
            child: _CompanionTag(game: game, centerX: at.dx),
          ),
        ],
      ],
    );
  }

  Widget _placedSign(
    BuildContext context,
    Offset p,
    TrailSign sign,
    int reached,
  ) {
    final open = reached >= sign.fromWaymark;
    final chip = _WorldSign(sign: sign, open: open);
    return sign.right
        ? Positioned(right: geo.width - p.dx, top: p.dy - 14, child: chip)
        : Positioned(left: p.dx, top: p.dy - 14, child: chip);
  }

  List<Widget> _cairn(BuildContext context, Waymark wm, Offset foot, double h) {
    final progress = game.wanderweg;
    final state = wm.number <= progress.reached
        ? _CairnState.reached
        : wm.number == progress.reached + 1
        ? _CairnState.next
        : _CairnState.open;
    final cw = h * 0.64;
    final labelLeft = foot.dx > geo.width * 0.55;
    const labelW = 132.0;
    return [
      Positioned(
        left: foot.dx - cw / 2,
        top: foot.dy - h,
        width: cw,
        height: h,
        child: GestureDetector(
          key: interactive ? Key('waymark-${wm.number}') : null,
          onTap: interactive ? () => showWaymarkSheet(context, game, wm) : null,
          child: _Medallion(number: wm.number, state: state),
        ),
      ),
      Positioned(
        left: labelLeft ? foot.dx - cw / 2 - labelW - 4 : foot.dx + cw / 2 + 4,
        top: foot.dy - h * 0.82,
        width: labelW,
        child: Align(
          alignment: labelLeft ? Alignment.topRight : Alignment.topLeft,
          child: GestureDetector(
            onTap: interactive
                ? () => showWaymarkSheet(context, game, wm)
                : null,
            child: _CairnLabel(waymark: wm, state: state),
          ),
        ),
      ),
    ];
  }
}

class _Seam extends StatelessWidget {
  const _Seam();

  @override
  Widget build(BuildContext context) {
    const c = kLeatherBuild ? Color(0xFF1E140F) : Color(0xFF0F0E0D);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              c.withValues(alpha: 0),
              c.withValues(alpha: .6),
              c.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fade extends StatelessWidget {
  const _Fade({required this.down});

  final bool down;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: down ? Alignment.topCenter : Alignment.bottomCenter,
          end: down ? Alignment.bottomCenter : Alignment.topCenter,
          colors: const [
            TreadColors.iron,
            (kLeatherBuild ? Color(0x001E140F) : Color(0x000F0E0D)),
          ],
        ),
      ),
    ),
  );
}

/// Arc-length samples of the trail between [from] and [to].
Iterable<Offset> _along(
  TrailGeometry geo,
  double from,
  double to,
  double d,
) sync* {
  for (var s = from; s < to; s += d) {
    yield geo.at(s);
  }
  yield geo.at(to);
}

Path _pathAlong(TrailGeometry geo, double from, double to) {
  final path = Path();
  var first = true;
  for (final p in _along(geo, from, to, 6)) {
    first ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    first = false;
  }
  return path;
}

void _dashes(
  Canvas canvas,
  TrailGeometry geo,
  double from,
  double to,
  double dash,
  double gap,
  Paint paint,
) {
  for (var s = from; s < to; s += dash + gap) {
    final a = geo.at(s);
    final b = geo.at(math.min(s + dash, to));
    canvas.drawLine(a, b, paint);
  }
}

/// Dark leather map: a tooled groove with a stitch line; the walked part
/// is sewn in glowing brass thread.
class _StitchTrail extends CustomPainter {
  _StitchTrail({required this.geo, required this.walkedS, required this.nextS});

  final TrailGeometry geo;
  final double walkedS;
  final double nextS;

  @override
  void paint(Canvas canvas, Size size) {
    final all = _pathAlong(geo, geo.startS, geo.endS);
    canvas.drawPath(
      all,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x66000000)
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      all,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x22F0D9A8)
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round,
    );
    final thread = Paint()
      ..color = const Color(0xB39C8462)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    _dashes(canvas, geo, walkedS, geo.endS, 8, 6, thread);
    if (walkedS > geo.startS) {
      final glow = Paint()
        ..color = TrailColors.ember.withValues(alpha: .55)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _dashes(canvas, geo, geo.startS, walkedS, 8, 6, glow);
      final gold = Paint()
        ..color = const Color(0xFFF1C877)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      _dashes(canvas, geo, geo.startS, walkedS, 8, 6, gold);
    }
    final ahead = Paint()..color = TrailColors.brass.withValues(alpha: .7);
    final step = geo.width * 0.045;
    for (var s = walkedS + step; s < nextS; s += step) {
      canvas.drawCircle(geo.at(s), 1.6, ahead);
    }
  }

  @override
  bool shouldRepaint(_StitchTrail old) =>
      old.walkedS != walkedS || old.nextS != nextS || old.geo != geo;
}

/// Dark leather map waymark: a riveted brass medallion on the stitch line,
/// glowing once reached.
class _Medallion extends StatelessWidget {
  const _Medallion({required this.number, required this.state});

  final int number;
  final _CairnState state;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final d = math.min(box.maxWidth * 1.05, box.maxHeight * 0.66);
      final reached = state == _CairnState.reached;
      final open = state == _CairnState.open;
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: -d * 0.12,
            width: d,
            height: d,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: reached
                      ? const [Color(0xFFF6D08A), Color(0xFFB0813E)]
                      : open
                      ? const [Color(0xFF3A2A1E), Color(0xFF241812)]
                      : const [Color(0xFF4A3322), Color(0xFF2A1C12)],
                ),
                border: Border.all(
                  color: open ? const Color(0xFF6A5038) : TrailColors.brass,
                  width: open ? 2 : 3,
                ),
                boxShadow: [
                  const BoxShadow(color: Color(0xAA000000), blurRadius: 6),
                  if (reached)
                    BoxShadow(
                      color: TrailColors.ember.withValues(alpha: .75),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  if (state == _CairnState.next)
                    BoxShadow(
                      color: TrailColors.brass.withValues(alpha: .6),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Container(
                margin: EdgeInsets.all(d * 0.08),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: reached
                        ? const Color(0x995A3A12)
                        : const Color(0x55D2B074),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(d * 0.14),
                child: FittedBox(
                  child: Text(
                    '$number',
                    style: serifTitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: reached
                          ? const Color(0xFF2A1C0C)
                          : open
                          ? TreadColors.muted
                          : TrailColors.brass,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

enum _CairnState { reached, next, open }

class _CairnLabel extends StatelessWidget {
  const _CairnLabel({required this.waymark, required this.state});

  final Waymark waymark;
  final _CairnState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final km = l.kmValue(kmText(context, waymark.km));
    final unlock = unlockLabel(l, waymark.unlock);
    final (border, head, body) = switch (state) {
      _CairnState.reached => (
        TreadColors.brassDark,
        TrailColors.brass,
        TrailColors.bone,
      ),
      _CairnState.next => (
        TrailColors.brass,
        TrailColors.brass,
        TrailColors.bone,
      ),
      _CairnState.open => (
        (kLeatherBuild ? const Color(0xFF6A5038) : const Color(0xFF3A3F47)),
        TreadColors.muted,
        TreadColors.muted,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: (kLeatherBuild
            ? const Color(0xD9241912)
            : const Color(0xD91A1D22)),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: border,
          width: state == _CairnState.next ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state == _CairnState.reached ? '✓ $km' : km,
              style: TextStyle(
                color: head,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              unlock,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: body, fontSize: 11, height: 1.2),
            ),
            if (state == _CairnState.reached)
              Text(
                l.wwUnlocked,
                style: const TextStyle(
                  color: TrailColors.ember,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorldSign extends StatelessWidget {
  const _WorldSign({required this.sign, required this.open});

  final TrailSign sign;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = [for (final w in sign.worlds) worldLabel(l, w)].join(' · ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: (kLeatherBuild
            ? const Color(0xCC241912)
            : const Color(0xCC1A1D22)),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: open
              ? TrailColors.brass
              : (kLeatherBuild
                    ? const Color(0xFF6A5038)
                    : const Color(0xFF3A3F47)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            skinIcon(
              context,
              open ? Icons.signpost_outlined : Icons.lock_outline,
              open ? SkinIcons.waymark : SkinIcons.lock,
              size: 14,
              color: open ? TrailColors.brass : TreadColors.muted,
            ),
            const SizedBox(width: 5),
            Text(
              open
                  ? name.toUpperCase()
                  : '${name.toUpperCase()} · ${l.wwFromWaymark(sign.fromWaymark)}',
              style: TextStyle(
                color: open ? TrailColors.bone : TreadColors.muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The companion taken along, in its own colours, with a small ember glow
/// at its feet and the distance left to the next waymark.
class _Companion extends StatelessWidget {
  const _Companion({required this.game});

  final GameData game;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final s = box.maxWidth;
        return Stack(
          key: const Key('trail-companion'),
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: -s * 0.06,
              width: s * 0.9,
              height: s * 0.24,
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
              child: Image.asset(
                game.activeCompanion.imageAsset,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The "you · X km to go" tag under the companion, centred on it but kept
/// inside the screen at both edges.
class _CompanionTag extends StatelessWidget {
  const _CompanionTag({required this.game, required this.centerX});

  final GameData game;
  final double centerX;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = game.wanderweg;
    final next = progress.next;
    final String tag;
    if (next == null) {
      tag = l.wwYou;
    } else {
      final left = next.km - game.totals.distanceM / 1000;
      tag = left > 0
          ? '${l.wwYou} · ${l.wwYouLeft(kmText(context, math.max(left, 0.1)))}'
          : '${l.wwYou} · ${l.wwYouTask}';
    }
    return CustomSingleChildLayout(
      delegate: _CenterClamp(centerX),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (kLeatherBuild
              ? const Color(0xE6241912)
              : const Color(0xE61A1D22)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TrailColors.ember),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          child: Text(
            tag,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              color: TrailColors.bone,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterClamp extends SingleChildLayoutDelegate {
  _CenterClamp(this.centerX);

  final double centerX;
  static const margin = 6.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().deflate(
        const EdgeInsets.symmetric(horizontal: margin),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = math.max(margin, size.width - childSize.width - margin);
    return Offset((centerX - childSize.width / 2).clamp(margin, maxX), 0);
  }

  @override
  bool shouldRelayout(_CenterClamp old) => old.centerX != centerX;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.game, required this.topInset});

  final GameData game;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final last = game.wanderweg.last;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TreadColors.iron,
            (kLeatherBuild ? Color(0xCC1E140F) : Color(0xCC0F0E0D)),
            (kLeatherBuild ? Color(0x001E140F) : Color(0x000F0E0D)),
          ],
          stops: [0, 0.7, 1],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, topInset + 4, 12, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: TrailColors.bone),
                ),
                Expanded(
                  child: Text(
                    l.wwTitle,
                    style: serifTitle.copyWith(fontSize: 24),
                  ),
                ),
                Text(
                  '${game.wanderweg.reached}/${waymarks.length}',
                  style: const TextStyle(
                    color: TreadColors.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TreadColors.brassDark),
                    color: TrailColors.slate,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      l.kmValue(kmText(context, game.totals.distanceM / 1000)),
                      style: const TextStyle(
                        color: TrailColors.brass,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            DecoratedBox(
              key: const Key('trail-messenger'),
              decoration: BoxDecoration(
                color: (kLeatherBuild
                    ? const Color(0xEB241912)
                    : const Color(0xEB1A1D22)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TreadColors.brassDark),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.local_fire_department_outlined,
                        color: TrailColors.ember,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (last == null
                                    ? l.wwStartTitle
                                    : l.wwLastAt(last.number))
                                .toUpperCase(),
                            style: const TextStyle(
                              color: TrailColors.brass,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            last == null
                                ? l.wwStartLine(
                                    kmText(context, waymarks.first.km),
                                  )
                                : '„${waymarkLine(l, last.number)}“',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: serifTitle.copyWith(
                              fontSize: 14.5,
                              height: 1.3,
                              fontStyle: last == null
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: TrailColors.bone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact panel for the next waymark: km and its tasks.
class _NextPanel extends StatelessWidget {
  const _NextPanel({required this.game, required this.bottomInset});

  final GameData game;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final next = game.wanderweg.next;
    final counters = game.waymarkCounters;
    return DecoratedBox(
      key: const Key('trail-panel'),
      decoration: const BoxDecoration(
        color: Color(0xF21A1D22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(top: BorderSide(color: TreadColors.brassDark)),
        boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 16)],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
        child: next == null
            ? Text(
                l.wwAllReached(waymarks.length),
                style: serifTitle.copyWith(fontSize: 16),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.wwNext(next.number).toUpperCase(),
                        style: const TextStyle(
                          color: TrailColors.brass,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          unlockLabel(l, next.unlock),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: TrailColors.bone,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...taskRows(context, next, counters),
                  if (next.tasks.any((t) => !t.counter.built)) ...[
                    const SizedBox(height: 2),
                    Text(
                      l.wwLaterNote,
                      style: const TextStyle(
                        color: TreadColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Km row first, then one row per task.
List<Widget> taskRows(
  BuildContext context,
  Waymark wm,
  WaymarkCounters counters,
) {
  final l = AppLocalizations.of(context);
  final km = counters.distanceM / 1000;
  return [
    _TaskRow(
      done: km >= wm.km,
      label: l.wwKmTask(kmText(context, wm.km)),
      value: l.wwKmValue(
        kmText(context, math.min(km, wm.km)),
        kmText(context, wm.km),
      ),
      share: (km / wm.km).clamp(0.0, 1.0),
    ),
    for (final t in wm.tasks)
      // "1 seal at L3" asks for one seal, not for a count up to 3.
      if (t.counter == WaymarkCounter.bestSealLevel)
        _TaskRow(
          done: counters.met(t),
          label: taskLabel(l, t),
          value: counters.met(t) ? '1 / 1' : '0 / 1',
        )
      else
        _TaskRow(
          done: counters.met(t),
          waived: !t.counter.built,
          label: taskLabel(l, t),
          value: t.counter.built
              ? '${math.min(counters[t.counter], t.target)} / ${t.target}'
              : l.wwLater,
          share: t.counter.built && t.target > 1
              ? (counters[t.counter] / t.target).clamp(0.0, 1.0)
              : null,
        ),
  ];
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.done,
    required this.label,
    required this.value,
    this.waived = false,
    this.share,
  });

  final bool done;
  final bool waived;
  final String label;
  final String value;
  final double? share;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                waived
                    ? Icons.schedule
                    : done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 18,
                color: waived
                    ? TreadColors.muted
                    : done
                    ? TrailColors.brass
                    : TreadColors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: waived ? TreadColors.muted : TrailColors.bone,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: done && !waived
                      ? TrailColors.brass
                      : TreadColors.muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  fontStyle: waived ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
          if (share != null) ...[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 5,
                  color: TrailColors.ember,
                  backgroundColor: TrailColors.slateLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Details of one waymark: unlock, line (once reached) and tasks.
Future<void> showWaymarkSheet(BuildContext context, GameData game, Waymark wm) {
  final l = AppLocalizations.of(context);
  final reached = wm.number <= game.wanderweg.reached;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: kLeatherBuild ? null : TrailColors.slate,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l.wwWaymark(wm.number)} · ${l.kmValue(kmText(context, wm.km))}',
              style: serifTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              unlockLabel(l, wm.unlock),
              style: const TextStyle(
                color: TrailColors.brass,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (reached)
              Text(
                wm.unlock.wired
                    ? l.wwUnlocked
                    : '${l.wwUnlocked} · ${l.wwComingSoon}',
                style: const TextStyle(
                  color: TrailColors.ember,
                  fontStyle: FontStyle.italic,
                  fontSize: 12.5,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              reached ? '„${waymarkLine(l, wm.number)}“' : l.wwLineLocked,
              style: serifTitle.copyWith(
                fontSize: 15,
                height: 1.35,
                fontStyle: reached ? FontStyle.italic : FontStyle.normal,
                color: reached ? TrailColors.bone : TreadColors.muted,
              ),
            ),
            const SizedBox(height: 14),
            if (!reached) ...taskRows(context, wm, game.waymarkCounters),
            if (reached && wm.tasks.isEmpty)
              Text(
                l.wwNoTask,
                style: const TextStyle(color: TreadColors.muted, fontSize: 12),
              ),
          ],
        ),
      ),
    ),
  );
}
