import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/pouch.dart';
import '../../l10n/app_localizations.dart';
import '../history/history_screen.dart';
import '../wanderweg/trail_entry.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../../widgets/pouch_art.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final run = ref.watch(gameProvider.select((g) => g.lastRun));

    Widget row(String label, String value) => ListTile(
      title: Text(label),
      trailing: Text(value, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.summaryTitle),
        automaticallyImplyLeading: false,
      ),
      body: run == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!run.earnsLp)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l.summaryNoLp,
                        style: const TextStyle(color: TreadColors.copper),
                      ),
                    ),
                  ),
                if (!run.valid)
                  Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l.summaryInvalid,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                const WaymarkReachedBubble(dismissible: false),
                const SizedBox(height: 8),
                Text(
                  l.lpAmount(formatNumber(context, run.lp)),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: TreadColors.brass,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(l.summaryLp, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                if (run.pouch != null || run.leashFull || run.pouchesWarmed > 0)
                  _PouchCard(
                    pouch: run.pouch,
                    leashFull: run.leashFull,
                    warmed: run.pouchesWarmed,
                  ),
                row(l.distance, l.kmValue(formatKm(context, run.distanceM))),
                row(l.time, formatDuration(run.duration)),
                row(l.pace, l.paceValue(formatPace(run.pace))),
                row(l.sweetSpotShare, formatShare(context, run.sweetSpotShare)),
                if (run.glut > 0)
                  ListTile(
                    key: const Key('summary-glut'),
                    title: Text(l.summaryGlut),
                    trailing: Text(
                      l.glutAmount(run.glut),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: TreadColors.brass,
                      ),
                    ),
                  ),
                if ((run.breathLeft, run.tankSize) case (
                  final left?,
                  final tank?,
                ))
                  row(
                    l.summaryBreathLeft,
                    l.breathValue(formatNumber(context, left), tank),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(l.done),
                ),
              ],
            ),
    );
  }
}

/// The pouch the run found (or why none), and pouches it walked warm.
class _PouchCard extends StatelessWidget {
  const _PouchCard({
    required this.pouch,
    required this.leashFull,
    required this.warmed,
  });

  final PouchColor? pouch;
  final bool leashFull;
  final int warmed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = pouch;
    const muted = TextStyle(color: ForgeColors.muted, fontSize: 13.5);
    return Container(
      key: const Key('summary-pouch'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: ForgeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: p == null ? ForgeColors.line : pouchAccent(p),
        ),
      ),
      child: Row(
        children: [
          if (p != null) ...[
            PouchArt(color: p, size: 64),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p != null) ...[
                  Text(l.summaryPouchFound, style: muted),
                  Text(
                    pouchName(l, p),
                    style: TextStyle(
                      color: pouchAccent(p),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (leashFull)
                  Text(
                    l.summaryLeashFull,
                    style: muted.copyWith(color: ForgeColors.text),
                  ),
                if (warmed > 0)
                  Text(
                    l.summaryPouchesWarm(warmed),
                    style: muted.copyWith(color: ForgeColors.brass),
                  ),
              ],
            ),
          ),
          TextButton(
            key: const Key('summary-to-leash'),
            style: TextButton.styleFrom(foregroundColor: ForgeColors.brass),
            onPressed: () => context.push(AppRoutes.pouches),
            child: Text(l.summaryToLeash),
          ),
        ],
      ),
    );
  }
}
