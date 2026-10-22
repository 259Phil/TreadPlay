import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import 'trail_layout.dart';
import 'wanderweg_text.dart';

/// Wanderweg palette on top of [TreadColors].
class TrailColors {
  static const slate = Color(0xFF1A1D22);
  static const slateLight = Color(0xFF2A3038);
  static const bone = Color(0xFFE8E0D0);
  static const brass = Color(0xFFC4A36A);
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
            topPad: topOverlay - 40,
            bottomPad: bottomOverlay - 60,
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
                  child: _TrailContent(geo: geo, game: game, companionS: s),
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

class _TrailContent extends StatelessWidget {
  const _TrailContent({
    required this.geo,
    required this.game,
    required this.companionS,
  });

  final TrailGeometry geo;
  final GameData game;
  final double companionS;

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
              painter: _EmberTrail(geo: geo, walkedS: companionS, nextS: nextS),
            ),
          ),
        ),
        for (var i = 0; i < trailSections.length; i++)
          for (final sign in trailSections[i].signs)
            _placedSign(context, geo.map(i, sign.at), sign, reached),
        for (final wm in waymarks)
          ..._cairn(context, wm, geo.cairnFoot(wm.number), cairnH),
        Positioned(
          left: at.dx - w * 0.09,
          top: at.dy - w * 0.17,
          width: w * 0.18,
          height: w * 0.18,
          child: _Companion(game: game),
        ),
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
    final lit = state == _CairnState.reached;
    final cw = h * (lit ? 239 / 360 : 246 / 360);
    final labelLeft = foot.dx > geo.width * 0.55;
    const labelW = 132.0;
    return [
      Positioned(
        left: foot.dx - cw / 2,
        top: foot.dy - h,
        width: cw,
        height: h,
        child: GestureDetector(
          key: Key('waymark-${wm.number}'),
          onTap: () => showWaymarkSheet(context, game, wm),
          child: _Cairn(number: wm.number, state: state),
        ),
      ),
      Positioned(
        left: labelLeft ? foot.dx - cw / 2 - labelW - 4 : foot.dx + cw / 2 + 4,
        top: foot.dy - h * 0.82,
        width: labelW,
        child: Align(
          alignment: labelLeft ? Alignment.topRight : Alignment.topLeft,
          child: GestureDetector(
            onTap: () => showWaymarkSheet(context, game, wm),
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
  Widget build(BuildContext context) => const IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x000F0E0D), Color(0x990F0E0D), Color(0x000F0E0D)],
        ),
      ),
    ),
  );
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
          colors: const [TreadColors.iron, Color(0x000F0E0D)],
        ),
      ),
    ),
  );
}

/// Glowing ember dots on the walked part, faint brass dots up to the next
/// waymark.
class _EmberTrail extends CustomPainter {
  _EmberTrail({required this.geo, required this.walkedS, required this.nextS});

  final TrailGeometry geo;
  final double walkedS;
  final double nextS;

  @override
  void paint(Canvas canvas, Size size) {
    final step = geo.width * 0.036;
    final glow = Paint()
      ..color = TrailColors.ember.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final core = Paint()..color = TrailColors.emberCore;
    for (var s = step * 0.5; s < walkedS - step * 0.6; s += step) {
      final p = geo.at(s);
      canvas.drawCircle(p, 4.2, glow);
      canvas.drawCircle(p, 2.1, core);
    }
    final ahead = Paint()..color = TrailColors.brass.withValues(alpha: 0.45);
    for (var s = walkedS + step; s < nextS; s += step * 1.2) {
      canvas.drawCircle(geo.at(s), 1.5, ahead);
    }
  }

  @override
  bool shouldRepaint(_EmberTrail old) =>
      old.walkedS != walkedS || old.nextS != nextS || old.geo != geo;
}

enum _CairnState { reached, next, open }

class _Cairn extends StatelessWidget {
  const _Cairn({required this.number, required this.state});

  final int number;
  final _CairnState state;

  @override
  Widget build(BuildContext context) {
    final lit = state == _CairnState.reached;
    final sprite = Image.asset(
      lit
          ? 'assets/wanderweg/cairn_lit.webp'
          : 'assets/wanderweg/cairn_cold.webp',
      fit: BoxFit.fill,
    );
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final plate = lit
            ? const Offset(0.482, 0.463)
            : const Offset(0.48, 0.459);
        final lantern = lit
            ? const Offset(0.817, 0.578)
            : const Offset(0.814, 0.567);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (state == _CairnState.next)
              Positioned(
                left: -w * 0.25,
                right: -w * 0.25,
                bottom: -h * 0.07,
                height: h * 0.18,
                child: const _GroundRing(),
              ),
            if (lit)
              Positioned(
                left: lantern.dx * w - w * 0.55,
                top: lantern.dy * h - w * 0.55,
                width: w * 1.1,
                height: w * 1.1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x88E08A3C), Color(0x00E08A3C)],
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: state == _CairnState.open
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.30, 0.30, 0.10, 0, 0, //
                        0.28, 0.30, 0.10, 0, 0, //
                        0.26, 0.28, 0.12, 0, 0, //
                        0, 0, 0, 1, 0,
                      ]),
                      child: sprite,
                    )
                  : sprite,
            ),
            Positioned(
              left: plate.dx * w - w * 0.2,
              top: plate.dy * h - h * 0.08,
              width: w * 0.4,
              height: h * 0.16,
              child: FittedBox(
                child: Text(
                  '$number',
                  style: serifTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: switch (state) {
                      _CairnState.reached => const Color(0xFF2A1C0C),
                      _CairnState.next => TrailColors.brass,
                      _CairnState.open => TreadColors.muted,
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GroundRing extends StatelessWidget {
  const _GroundRing();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: const BorderRadius.all(Radius.elliptical(100, 40)),
      border: Border.all(color: TrailColors.brass, width: 2),
      boxShadow: const [
        BoxShadow(color: Color(0x66C4A36A), blurRadius: 10, spreadRadius: 1),
      ],
    ),
  );
}

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
        const Color(0xFF3A3F47),
        TreadColors.muted,
        TreadColors.muted,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD91A1D22),
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
        color: const Color(0xCC1A1D22),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: open ? TrailColors.brass : const Color(0xFF3A3F47),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              open ? Icons.signpost_outlined : Icons.lock_outline,
              size: 13,
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
            Positioned(
              bottom: -22,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xE61A1D22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TrailColors.ember),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
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
            ),
          ],
        );
      },
    );
  }
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
          colors: [TreadColors.iron, Color(0xCC0F0E0D), Color(0x000F0E0D)],
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
                color: const Color(0xEB1A1D22),
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
    backgroundColor: TrailColors.slate,
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
