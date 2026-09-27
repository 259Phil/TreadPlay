import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import 'boot_diorama.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final shoe = game.activeShoe;
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.appTitle,
                  style: theme.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.bolt, color: TreadColors.gold),
                label: Text(
                  l.lpAmount(formatNumber(context, game.lp, pattern: '0.0')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BootDiorama(
            shoe: shoe,
            action: _StartTread(
              label: l.startRun,
              onPressed: () {
                ref.read(runControllerProvider.notifier).start();
                context.push(AppRoutes.run);
              },
            ),
            corner: _LastRunNote(run: game.lastRun),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(shoe.name, style: theme.textTheme.headlineSmall),
              ),
              Text(
                l.levelShort(shoe.level),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          Text(
            '${rarityLabel(l, shoe.rarity)} · ${shoeTypeLabel(l, shoe.type)} · '
            '${l.sweetSpotAt(formatNumber(context, shoe.type.sweetSpotKmh))}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall,
            child: Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.air, size: 14, color: TreadColors.breath),
                Text(l.breath),
                Text(
                  l.breathValue(
                    formatNumber(context, shoe.breath),
                    shoe.tankSize,
                  ),
                ),
                Text(shoe.breath < 1 ? l.breathEmptyHint : l.breathRegenHint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartTread extends StatelessWidget {
  const _StartTread({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TreadColors.gold,
      shape: const CircleBorder(
        side: BorderSide(color: Color(0xFF6E4E2E), width: 3),
      ),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 84,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, size: 34, color: Colors.black),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastRunNote extends StatelessWidget {
  const _LastRunNote({required this.run});

  final RunSummary? run;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = run;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x9914110F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: DefaultTextStyle.merge(
          style: theme.textTheme.bodySmall,
          child: r == null
              ? Text(l.noRunsYet)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.lastRun, style: theme.textTheme.labelSmall),
                    Text.rich(
                      TextSpan(
                        text:
                            '${l.kmValue(formatKm(context, r.distanceM))} · '
                            '${formatDuration(r.duration)} · ',
                        children: [
                          TextSpan(
                            text: r.valid
                                ? l.lpAmount(formatNumber(context, r.lp))
                                : l.invalidRun,
                            style: TextStyle(
                              color: r.valid
                                  ? TreadColors.gold
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
