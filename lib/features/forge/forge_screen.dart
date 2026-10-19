import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/companion.dart';
import '../../domain/forge.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/charm_sockets.dart';
import '../../widgets/companion_card.dart';
import '../../widgets/companion_stats.dart';
import '../../widgets/format.dart';

/// Sets seals into the charm sockets of the companion taken along.
class ForgeScreen extends ConsumerWidget {
  const ForgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);
    final c = game.activeCompanion;
    final free = c.charms.where((s) => s == null).length;
    final banner = c.spirit < 100
        ? l.forgeNeedsSpirit
        : free == 0
        ? l.forgeNoSocket
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabForge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                l.lpAmount(formatNumber(context, game.lp, pattern: '0.0')),
                style: const TextStyle(
                  color: TreadColors.brass,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: AspectRatio(
                    aspectRatio: CompanionCard.aspectRatio,
                    child: CompanionCard(
                      artKey: c.artKey,
                      world: c.world,
                      rarity: c.rarity,
                      name: c.name,
                      subtitle: typeLabel(l, c.type),
                      badge: l.takenAlong,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: theme.textTheme.headlineSmall),
                      Text(
                        '${rarityLabel(l, c.rarity)} · ${typeLabel(l, c.type)}',
                        style: TextStyle(color: rarityMetal(c.rarity)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.forgeAlong,
                        style: const TextStyle(color: TreadColors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.forgeFreeSockets(free, c.charms.length),
                        key: const Key('forge-free'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CompanionStats(companion: c),
            const SizedBox(height: 12),
            Text(l.charms, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            CharmSockets(
              companion: c,
              onClear: (slot, seal) =>
                  _confirmClear(context, ref, c, slot, seal),
            ),
            if (c.charms.any((s) => s != null)) ...[
              const SizedBox(height: 6),
              Text(
                l.forgeClearHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: TreadColors.muted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Text(l.forgeRule, style: const TextStyle(color: TreadColors.muted)),
            if (banner != null) ...[
              const SizedBox(height: 8),
              Text(
                banner,
                key: const Key('forge-block'),
                style: const TextStyle(color: TreadColors.copper),
              ),
            ],
            const SizedBox(height: 8),
            for (final type in SealType.values)
              _SealRow(game: game, companion: c, type: type),
            const SizedBox(height: 12),
            Text(
              l.forgeSellNote,
              style: const TextStyle(color: TreadColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmClear(
  BuildContext context,
  WidgetRef ref,
  Companion companion,
  int slot,
  SealType seal,
) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.forgeClearTitle(l.sealName(sealStat(l, seal)))),
      content: Text(l.forgeClearBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.forgeClearKeep),
        ),
        FilledButton(
          key: const Key('forge-clear-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.forgeClearAction),
        ),
      ],
    ),
  );
  if (ok == true) {
    ref.read(gameProvider.notifier).clearSeal(companion.id, slot);
  }
}

class _SealRow extends ConsumerWidget {
  const _SealRow({
    required this.game,
    required this.companion,
    required this.type,
  });

  final GameData game;
  final Companion companion;
  final SealType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cost = Forge.nextCost(companion, type);
    final block = game.forgeBlock(companion.id, type);
    final costText = cost == null
        ? l.forgeMaxed
        : l.lpAmount(formatNumber(context, cost));
    return Card(
      key: Key('seal-${type.name}'),
      child: ListTile(
        leading: Icon(sealIcon(type), color: TreadColors.brass),
        title: Text(l.sealName(sealStat(l, type))),
        subtitle: Text(
          block == ForgeBlock.notEnoughLp
              ? '${l.forgeStatCount(companion.sealCount(type))} · ${l.forgeNotEnoughLp}'
              : l.forgeStatCount(companion.sealCount(type)),
        ),
        trailing: FilledButton(
          onPressed: block == null
              ? () => ref.read(gameProvider.notifier).forge(companion.id, type)
              : null,
          child: Text(cost == null ? costText : '${l.forgeSet} · $costText'),
        ),
      ),
    );
  }
}
