import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/game_data.dart';
import '../../domain/companion.dart';
import '../../domain/run_summary.dart';
import '../../l10n/app_localizations.dart';
import '../legal/movement_notice.dart';
import '../messenger/messenger_popup.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/companion_card.dart';
import '../../widgets/format.dart';
import '../../widgets/lp_pill.dart';
import '../wanderweg/trail_entry.dart';
import 'leash_drawer.dart';
import 'video_button.dart';
import 'world_scene.dart';
import '../../ui/skin.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final companion = game.activeCompanion;
    final topInset = MediaQuery.paddingOf(context).top;
    final skin = TreadSkin.of(context);

    return ColoredBox(
      color: skin.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 10, 16, 0),
            child: _Header(lp: game.lp, lastRun: game.lastRun),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: _BreathRow(
              breath: game.breath.points,
              tank: companion.tankSize,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: WorldScene(companion: companion)),
                const Positioned(
                  top: 6,
                  left: 14,
                  right: 14,
                  child: WaymarkReachedBubble(),
                ),
                if (game.unlocks.pouchColors.isNotEmpty)
                  Positioned.fill(child: LeashDrawer(game: game)),
              ],
            ),
          ),
          // Only while a messenger task is open; outside the scene so it
          // never covers the companion.
          if (game.messengers.task != null)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: MessengerNotice(),
            ),
          const MessengerWatcher(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SkinPanel(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: _NamePlate(companion: companion),
                  ),
                ),
                const SizedBox(width: 12),
                _StartButton(
                  label: l.startRun,
                  onPressed: () async {
                    await ensureMovementAccess(context, ref);
                    final access = ref.read(settingsProvider).movementAccess;
                    if (!context.mounted || access == MovementAccess.unasked) {
                      return;
                    }
                    if (!ref.read(runControllerProvider.notifier).start()) {
                      return;
                    }
                    if (context.mounted) context.push(AppRoutes.run);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Serif title, one line for the last run or "today 0 km", and LP.
class _Header extends StatelessWidget {
  const _Header({required this.lp, required this.lastRun});

  final double lp;
  final RunSummary? lastRun;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = lastRun;
    const small = TextStyle(color: TreadColors.muted, fontSize: 14);
    // Title row carries the small video button and the LP pill at the top
    // edge; the last-run line gets the full width below so it never clips.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l.appTitle,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TreadSkin.of(context).display(30),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: VideoButton(),
            ),
            LpPill(lp: lp),
          ],
        ),
        Row(
          children: [
            Expanded(child: _lastRunLine(context, l, r, small)),
            const SizedBox(width: 8),
            const TrailChip(),
          ],
        ),
      ],
    );
  }

  Widget _lastRunLine(
    BuildContext context,
    AppLocalizations l,
    RunSummary? r,
    TextStyle small,
  ) => Text.rich(
    r == null
        ? TextSpan(text: l.todayKm(l.kmValue(formatNumber(context, 0))))
        : TextSpan(
            text:
                '${l.lastRun}: ${l.kmValue(formatKm(context, r.distanceM))} · '
                '${formatDuration(r.duration)} · ',
            children: [
              TextSpan(
                text: r.valid
                    ? l.lpAmount(formatNumber(context, r.lp))
                    : l.invalidRun,
                style: TextStyle(
                  color: r.valid
                      ? TreadColors.brass
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: small,
  );
}

/// Name in serif, rarity and type, world and Spirit, sweet spot.
class _NamePlate extends StatelessWidget {
  const _NamePlate({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = companion;
    const small = TextStyle(color: TreadColors.muted, fontSize: 13.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TreadSkin.of(context).display(26),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: rarityLabel(l, c.rarity),
                          style: TextStyle(color: rarityMetal(c.rarity)),
                        ),
                        TextSpan(text: ' · ${l.levelShort(c.level)}'),
                      ],
                    ),
                    style: small,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(worldLabel(l, c.world), style: small),
                Text(
                  '${l.statSpirit} ${l.percentValue(formatNumber(context, c.spirit))}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.spirit < lowSpirit ? TreadColors.copper : null,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        // The gait in its coin colour, then its sweet spot.
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: typeLabel(l, c.type),
                style: TextStyle(
                  color: tempoColor(c.type),
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text:
                    ' · ${l.sweetSpotAt(formatNumber(context, c.type.sweetSpotKmh))}',
              ),
            ],
          ),
          style: small,
        ),
        if (c.spirit < lowSpirit)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.spiritLow(c.name, formatNumber(context, c.spirit)),
              key: const Key('home-spirit-low'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: TreadColors.copper, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// The shared Breath: label, `4/6` and one segment per point.
class _BreathRow extends StatelessWidget {
  const _BreathRow({required this.breath, required this.tank});

  final double breath;
  final int tank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final empty = breath < 1;
    return Semantics(
      label:
          '${l.breath} ${l.breathValue(formatNumber(context, breath), tank)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              skinIcon(
                context,
                Icons.air,
                SkinIcons.breath,
                size: 18,
                color: TreadColors.breath,
              ),
              const SizedBox(width: 6),
              Text(
                l.breath,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${breath.floor()}/$tank',
                style: TextStyle(
                  color: empty ? TreadColors.muted : TreadColors.brass,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < tank; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(child: _Segment(fill: (breath - i).clamp(0, 1))),
              ],
            ],
          ),
          if (empty) ...[
            const SizedBox(height: 6),
            Text(
              l.breathEmptyHint,
              style: const TextStyle(color: TreadColors.breath, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.fill});

  final double fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 12,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: TreadSkin.of(context).surface),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fill,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: brassGradient),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The round brass Start button, bottom right.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  static const _size = 92.0;

  @override
  Widget build(BuildContext context) {
    final s = TreadSkin.of(context);
    final ring = switch (s.style) {
      TreadStyle.forgeBrass => Border.all(
        color: const Color(0xFF4A3B24),
        width: 3,
      ),
      TreadStyle.ironPlain => Border.all(color: s.line, width: 2),
      TreadStyle.leather => Border.all(
        color: const Color(0xFF2E221A),
        width: 4,
      ),
      TreadStyle.runeEmber => Border.all(color: s.accent, width: 2),
    };
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: ring,
          boxShadow: [
            const BoxShadow(color: Color(0x99000000), blurRadius: 12),
            if (s.style == TreadStyle.runeEmber)
              BoxShadow(color: s.accent.withValues(alpha: .55), blurRadius: 18),
          ],
        ),
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: s.style == TreadStyle.ironPlain
                  ? LinearGradient(colors: [s.brass, s.brass])
                  : const RadialGradient(
                      center: Alignment(-.3, -.4),
                      radius: .95,
                      colors: [
                        Color(0xFFF0D598),
                        Color(0xFFC4A36A),
                        Color(0xFF8E7046),
                      ],
                    ),
            ),
            child: InkWell(
              onTap: onPressed,
              child: CustomPaint(
                foregroundPainter: _StartRing(s),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 36, color: s.base),
                    Text(
                      s.displayText(label),
                      style: s
                          .display(16, color: s.base)
                          .copyWith(height: 1, fontWeight: s.displayWeight),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartRing extends CustomPainter {
  _StartRing(this.s);
  final TreadSkin s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final p = Paint()..style = PaintingStyle.stroke;
    switch (s.style) {
      case TreadStyle.forgeBrass:
        canvas.drawCircle(
          c,
          r - 6,
          p
            ..strokeWidth = 1
            ..color = const Color(0xAA5A4628),
        );
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawCircle(
            c + Offset(math.cos(a), math.sin(a)) * (r - 9),
            1.8,
            Paint()..color = const Color(0xFF7A6238),
          );
        }
      case TreadStyle.ironPlain:
        break;
      case TreadStyle.leather:
        final path = Path()..addOval(Rect.fromCircle(center: c, radius: r - 7));
        for (final m in path.computeMetrics()) {
          for (var d = 0.0; d < m.length; d += 7) {
            canvas.drawPath(
              m.extractPath(d, d + 4),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2
                ..color = const Color(0xAA4A3420),
            );
          }
        }
      case TreadStyle.runeEmber:
        canvas.drawCircle(
          c,
          r - 6,
          p
            ..strokeWidth = 1.2
            ..color = const Color(0xAA6B3519),
        );
    }
  }

  @override
  bool shouldRepaint(_StartRing old) => old.s != s;
}
