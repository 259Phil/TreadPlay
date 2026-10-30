import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/run_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/format.dart';

String formatRunDate(BuildContext context, DateTime d) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).add_Hm().format(d.toLocal());
}

/// Sweet-spot share as a whole percentage, or a dash for older runs.
String formatShare(BuildContext context, double? share) {
  if (share == null) return '–';
  return AppLocalizations.of(
    context,
  ).percentValue(formatNumber(context, share * 100, pattern: '0'));
}

/// Local run list (newest first) with lifetime totals and "Erase local record".
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final runs = ref.watch(gameProvider.select((g) => g.runs));
    final totals = ref.watch(gameProvider.select((g) => g.totals));

    return Scaffold(
      backgroundColor: TreadSkin.of(context).canvas,
      appBar: AppBar(title: Text(l.historyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            l.historyTotals(
              formatKm(context, totals.distanceM),
              totals.runs,
              formatNumber(context, totals.lp),
            ),
            style: const TextStyle(
              color: TreadColors.brass,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.historyLocalNote,
            style: const TextStyle(color: TreadColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          if (runs.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l.historyEmpty,
                  style: const TextStyle(color: TreadColors.muted),
                ),
              ),
            )
          else
            for (var i = 0; i < runs.length; i++)
              _RunTile(
                run: runs[i],
                onTap: () => context.push(AppRoutes.historyDetail(i)),
              ),
          const SizedBox(height: 20),
          if (runs.isNotEmpty)
            OutlinedButton.icon(
              style: TreadSkin.of(context).style == TreadStyle.leather
                  ? skinButtonStyle(
                      TreadSkin.of(context),
                      SkinButtonKind.secondary,
                    ).copyWith(
                      minimumSize: const WidgetStatePropertyAll(
                        Size.fromHeight(48),
                      ),
                    )
                  : OutlinedButton.styleFrom(
                      foregroundColor: TreadColors.muted,
                      side: const BorderSide(color: TreadColors.brassDark),
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
              icon: skinIcon(
                context,
                Icons.delete_outline,
                SkinIcons.delete,
                size: 20,
              ),
              label: Text(l.historyErase),
              onPressed: () => _confirmErase(context, ref),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmErase(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.historyEraseTitle),
        content: Text(l.historyEraseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            style: dangerButtonStyle(context),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.historyErase),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(gameProvider.notifier).eraseRuns();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.historyErased)));
  }
}

/// One run as a plate card: date on top, km · time · LP below.
class _RunTile extends StatelessWidget {
  const _RunTile({required this.run, required this.onTap});

  final RunSummary run;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const small = TextStyle(color: TreadColors.muted, fontSize: 13.5);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatRunDate(context, run.startedAt),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${l.kmValue(formatKm(context, run.distanceM))} · '
                      '${formatDuration(run.duration)}',
                      style: small,
                    ),
                  ],
                ),
              ),
              Text(
                run.valid
                    ? l.lpAmount(formatNumber(context, run.lp))
                    : l.invalidRun,
                style: TextStyle(
                  color: run.valid ? TreadColors.brass : TreadColors.muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: TreadColors.brass),
            ],
          ),
        ),
      ),
    );
  }
}

/// All stored values of one run. No route, no map.
class RunDetailScreen extends ConsumerWidget {
  const RunDetailScreen({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final runs = ref.watch(gameProvider.select((g) => g.runs));
    final run = index >= 0 && index < runs.length ? runs[index] : null;

    return Scaffold(
      backgroundColor: TreadSkin.of(context).canvas,
      appBar: AppBar(title: Text(l.runDetailTitle)),
      body: run == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                const SizedBox(height: 6),
                Text(
                  run.valid
                      ? l.lpAmount(formatNumber(context, run.lp))
                      : l.invalidRun,
                  style: TreadSkin.of(context).display(
                    40,
                    color: run.valid ? TreadColors.brass : TreadColors.muted,
                  ),
                ),
                Text(
                  l.summaryLp,
                  style: const TextStyle(color: TreadColors.muted),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        _Row(l.date, formatRunDate(context, run.startedAt)),
                        _Row(
                          l.distance,
                          l.kmValue(formatKm(context, run.distanceM)),
                        ),
                        _Row(l.time, formatDuration(run.duration)),
                        _Row(l.paceAverage, l.paceValue(formatPace(run.pace))),
                        _Row(
                          l.breathUsed,
                          formatNumber(context, run.breathUsed),
                        ),
                        _Row(
                          l.sweetSpotShare,
                          formatShare(context, run.sweetSpotShare),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                  color: TreadSkin.of(context).line.withValues(alpha: .6),
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: TreadColors.muted, fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
