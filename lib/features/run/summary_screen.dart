import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/companion.dart';
import '../../domain/pouch.dart';
import '../../l10n/app_localizations.dart';
import '../history/history_screen.dart';
import '../messenger/messenger_popup.dart';
import '../wanderweg/trail_entry.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/format.dart';
import '../../widgets/pouch_art.dart';
import '../../widgets/stock_art.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final run = ref.watch(gameProvider.select((g) => g.lastRun));
    final companion = ref.watch(
      gameProvider.select(
        (g) => g.companions.where((c) => c.id == run?.companionId).firstOrNull,
      ),
    );

    Widget row(String label, String value) => ListTile(
      title: Text(label),
      trailing: Text(value, style: theme.textTheme.titleMedium),
    );

    final skin = TreadSkin.of(context);
    final leather = skin.style == TreadStyle.leather;
    return Scaffold(
      backgroundColor: skin.canvas,
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
                const MessengerWatcher(),
                const WaymarkReachedBubble(dismissible: false),
                const SizedBox(height: 8),
                Text(
                  l.lpAmount(formatNumber(context, run.lp)),
                  textAlign: TextAlign.center,
                  style: leather
                      ? skin
                            .display(52, color: TreadColors.brass)
                            .copyWith(
                              shadows: const [
                                Shadow(
                                  color: Color(0xCC000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            )
                      : theme.textTheme.displayMedium?.copyWith(
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        row(
                          l.distance,
                          l.kmValue(formatKm(context, run.distanceM)),
                        ),
                        row(l.time, formatDuration(run.duration)),
                        row(l.paceAverage, l.paceValue(formatPace(run.pace))),
                        row(
                          l.sweetSpotShare,
                          formatShare(context, run.sweetSpotShare),
                        ),
                        if ((run.breathLeft, run.tankSize) case (
                          final left?,
                          final tank?,
                        ))
                          row(
                            l.summaryBreathLeft,
                            l.breathValue(formatNumber(context, left), tank),
                          ),
                        if (run.spiritAfter case final after?)
                          ListTile(
                            key: const Key('summary-spirit'),
                            title: Text(l.summarySpirit),
                            trailing: Text(
                              l.summarySpiritValue(
                                formatNumber(context, after + run.spiritLost),
                                formatNumber(context, after),
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: after < lowSpirit
                                    ? TreadColors.copper
                                    : null,
                              ),
                            ),
                          ),
                        if (run.xpGained > 0)
                          ListTile(
                            key: const Key('summary-xp'),
                            title: Text(l.summaryXp),
                            trailing: Text(
                              l.summaryXpValue(run.xpGained),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: TreadColors.brass,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (run.levelReady && companion != null)
                  Card(
                    key: const Key('summary-level-ready'),
                    child: ListTile(
                      leading: const Icon(
                        Icons.trending_up,
                        color: TreadColors.brass,
                      ),
                      title: Text(l.summaryLevelReady(companion.name)),
                      onTap: () => context.go(AppRoutes.shelf),
                    ),
                  ),
                if (run.glut > 0)
                  ListTile(
                    key: const Key('summary-glut'),
                    leading: const GlutIcon(size: 36),
                    title: Text(l.summaryGlut),
                    trailing: Text(
                      l.glutAmount(run.glut),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: TreadColors.brass,
                      ),
                    ),
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
    final leather = TreadSkin.of(context).style == TreadStyle.leather;
    return Container(
      key: const Key('summary-pouch'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: leather
          ? const EdgeInsets.fromLTRB(14, 12, 10, 12)
          : const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: leather
          ? const ShapeDecoration(
              color: Color(0xF2342519),
              shape: LeatherBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              shadows: [BoxShadow(color: Color(0xAA000000), blurRadius: 8)],
            )
          : BoxDecoration(
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
            style: leather
                ? null
                : TextButton.styleFrom(foregroundColor: ForgeColors.brass),
            onPressed: () => context.push(AppRoutes.pouches),
            child: Text(l.summaryToLeash),
          ),
        ],
      ),
    );
  }
}
