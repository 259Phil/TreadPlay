import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/game_data.dart';
import '../../domain/companion.dart';
import '../../domain/run_summary.dart';
import '../../l10n/app_localizations.dart';
import '../legal/movement_notice.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../../widgets/lp_pill.dart';
import 'video_button.dart';
import 'world_scene.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final companion = game.activeCompanion;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: TreadColors.iron,
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
          Expanded(child: WorldScene(companion: companion)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _NamePlate(companion: companion),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: _StartButton(
              label: l.startRun,
              onPressed: () async {
                await ensureMovementAccess(context, ref);
                final access = ref.read(settingsProvider).movementAccess;
                if (!context.mounted || access == MovementAccess.unasked) {
                  return;
                }
                if (!ref.read(runControllerProvider.notifier).start()) return;
                if (context.mounted) context.push(AppRoutes.run);
              },
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
                style: serifTitle.copyWith(fontSize: 30),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: VideoButton(),
            ),
            LpPill(lp: lp),
          ],
        ),
        Text.rich(
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
        ),
      ],
    );
  }
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
                    style: serifTitle.copyWith(fontSize: 30, height: 1.1),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: rarityLabel(l, c.rarity),
                          style: TextStyle(color: rarityMetal(c.rarity)),
                        ),
                        TextSpan(
                          text:
                              ' · ${typeLabel(l, c.type)} · ${l.levelShort(c.level)}',
                        ),
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
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l.sweetSpotAt(formatNumber(context, c.type.sweetSpotKmh)),
          style: small,
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
              const Icon(Icons.air, size: 18, color: TreadColors.breath),
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
            const ColoredBox(color: TreadColors.plate),
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

/// The single wide brass Start button.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 12)],
      ),
      child: Material(
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(gradient: brassGradient),
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              height: 62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    size: 30,
                    color: TreadColors.iron,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: TreadColors.iron,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
