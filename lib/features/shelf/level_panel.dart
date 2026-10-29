import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/companion.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../../widgets/salve_sheet.dart';

/// Level, XP, Mut loss and the two actions on a companion's detail:
/// level up for LP once the XP is walked, and apply a Mutsalbe.
class LevelPanel extends ConsumerWidget {
  const LevelPanel({super.key, required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final c = companion;
    final need = c.xpToNext;
    final block = game.levelUpBlock(c.id);
    final cost = c.levelUpCost;
    final gritSaves = ((1 - c.spiritLossFactor) * 100).round();
    final nextPct = need == null
        ? 0
        : ((levelFactor(c.level + 1) - levelFactor(c.level)) * 100).round();
    final tankNext = nextTankLevel(c.level) == c.level + 1;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TreadColors.plate,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TreadColors.brassDark),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  l.levelShort(c.level),
                  style: const TextStyle(
                    color: TreadColors.brass,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: need == null
                      ? Text(
                          l.levelMax,
                          style: const TextStyle(color: TreadColors.muted),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            key: const ValueKey('xp-bar'),
                            value: (c.xp / need).clamp(0, 1).toDouble(),
                            minHeight: 8,
                            color: TreadColors.brass,
                            backgroundColor: TreadColors.rail,
                          ),
                        ),
                ),
                if (need != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    l.levelXp(c.xp.clamp(0, need), need),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            if (need != null)
              Text(
                tankNext ? l.levelNextTank(nextPct) : l.levelNextLp(nextPct),
                style: TextStyle(
                  color: tankNext ? TreadColors.breath : TreadColors.text,
                  fontSize: 13,
                ),
              ),
            Text(
              l.levelXpHint,
              style: const TextStyle(color: TreadColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              [
                l.spiritLossLine(
                  formatNumber(context, c.spiritPerBreath, pattern: '0.0#'),
                ),
                if (gritSaves > 0) l.spiritGritSaves(gritSaves),
              ].join(' · '),
              style: const TextStyle(color: TreadColors.copper, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('level-up'),
                    onPressed: block == null
                        ? () {
                            final ok = ref
                                .read(gameProvider.notifier)
                                .levelUp(c.id);
                            if (!ok) return;
                            final up = ref
                                .read(gameProvider)
                                .companions
                                .firstWhere((o) => o.id == c.id);
                            final msg = up.tankSize > c.tankSize
                                ? l.levelUpDoneTank(
                                    c.name,
                                    up.level,
                                    up.tankSize +
                                        ref.read(gameProvider).collectorBonus,
                                  )
                                : l.levelUpDone(c.name, up.level);
                            ScaffoldMessenger.maybeOf(
                              context,
                            )?.showSnackBar(SnackBar(content: Text(msg)));
                          }
                        : null,
                    child: FittedBox(
                      child: Text(
                        cost == null
                            ? l.levelMax
                            : l.levelUpFor(
                                formatNumber(context, cost, pattern: '0'),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('salve-open'),
                    icon: const Icon(Icons.healing, size: 18),
                    onPressed: () => showSalveSheet(context, c.id),
                    label: FittedBox(
                      child: Text(
                        game.salves.isEmpty
                            ? l.salveButton
                            : '${l.salveButton} (${game.salves.total})',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (switch (block) {
                  LevelBlock.needsXp => l.levelNeedsXp(need! - c.xp),
                  LevelBlock.notEnoughLp => l.levelNeedsLp(
                    formatNumber(context, cost! - game.lp, pattern: '0'),
                  ),
                  _ => null,
                }
                case final hint?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: TreadColors.muted,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
