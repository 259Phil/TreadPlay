import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';

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
                row(l.distance, l.kmValue(formatKm(context, run.distanceM))),
                row(l.time, formatDuration(run.duration)),
                row(l.steps, '${run.steps}'),
                row(l.summaryBreathUsed, formatNumber(context, run.breathUsed)),
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
