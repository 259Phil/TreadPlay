import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/companion.dart';
import '../../domain/run_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import 'world_scene.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _barHeight = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final companion = game.activeCompanion;
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        WorldScene(companion: companion, railTop: topInset + _barHeight + 4),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: _MetalBar(
            topInset: topInset,
            height: _barHeight,
            lp: game.lp,
            companion: companion,
          ),
        ),
        Positioned(
          left: 12,
          right: 112,
          bottom: 14,
          child: _NamePlate(companion: companion, lastRun: game.lastRun),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: _StartButton(
            label: l.startRun,
            onPressed: () {
              ref.read(runControllerProvider.notifier).start();
              context.push(AppRoutes.run);
            },
          ),
        ),
      ],
    );
  }
}

/// Thin iron strip at the top: LP and a mini status.
class _MetalBar extends StatelessWidget {
  const _MetalBar({
    required this.topInset,
    required this.height,
    required this.lp,
    required this.companion,
  });

  final double topInset;
  final double height;
  final double lp;
  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF212141A), Color(0xE62A3038)],
        ),
        border: Border(
          bottom: BorderSide(color: TreadColors.brassDark, width: 1.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, topInset, 12, 0),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.appTitle.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: const TextStyle(
                    color: TreadColors.brass,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
              _Rivet(
                icon: Icons.bolt,
                text: l.lpAmount(formatNumber(context, lp, pattern: '0.0')),
                color: TreadColors.brass,
              ),
              const SizedBox(width: 8),
              _Rivet(
                icon: Icons.favorite_outline,
                text: l.percentValue(formatNumber(context, companion.spirit)),
                color: TreadColors.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rivet extends StatelessWidget {
  const _Rivet({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TreadColors.iron,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3A424C)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Name, type and the last session on one small iron plate.
class _NamePlate extends StatelessWidget {
  const _NamePlate({required this.companion, required this.lastRun});

  final Companion companion;
  final RunSummary? lastRun;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = lastRun;
    final small = theme.textTheme.bodySmall?.copyWith(color: TreadColors.muted);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE01A1D22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TreadColors.brassDark),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    companion.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  l.levelShort(companion.level),
                  style: const TextStyle(color: TreadColors.brass),
                ),
              ],
            ),
            Text(
              '${typeLabel(l, companion.type)} · '
              '${l.sweetSpotAt(formatNumber(context, companion.type.sweetSpotKmh))}',
              style: small,
            ),
            if (companion.breath < 1) ...[
              const SizedBox(height: 4),
              Text(
                l.breathEmptyHint,
                style: small?.copyWith(color: TreadColors.breath),
              ),
            ],
            const Divider(height: 12),
            if (r == null)
              Text(l.noRunsYet(companion.name), style: small)
            else
              Text.rich(
                TextSpan(
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
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                style: small,
              ),
          ],
        ),
      ),
    );
  }
}

/// Round brass Start knob.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 12)],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8C939B), Color(0xFF2E3338)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [
                  Color(0xFFE2C98F),
                  TreadColors.brass,
                  Color(0xFF8A6D3E),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      size: 34,
                      color: TreadColors.iron,
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        color: TreadColors.iron,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
