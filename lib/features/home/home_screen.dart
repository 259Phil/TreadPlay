import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/breath_bar.dart';
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
          BootDiorama(shoe: shoe),
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
          const SizedBox(height: 16),
          BreathBar(breath: shoe.breath, tank: shoe.tankSize),
          const SizedBox(height: 4),
          Text(
            shoe.breath < 1 ? l.breathEmptyHint : l.breathRegenHint,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow, size: 32),
              label: Text(l.startRun, style: const TextStyle(fontSize: 22)),
              onPressed: () {
                ref.read(runControllerProvider.notifier).start();
                context.push(AppRoutes.run);
              },
            ),
          ),
          const SizedBox(height: 24),
          _LastRunCard(run: game.lastRun),
        ],
      ),
    );
  }
}

class _LastRunCard extends StatelessWidget {
  const _LastRunCard({required this.run});

  final RunSummary? run;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = run;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: r == null
            ? Text(l.noRunsYet)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.lastRun, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.kmValue(formatKm(context, r.distanceM))),
                      Text(formatDuration(r.duration)),
                      Text(
                        r.valid
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
                ],
              ),
      ),
    );
  }
}
