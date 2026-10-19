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
import '../../widgets/lp_pill.dart';

/// Sets seals into the charm sockets of the companion taken along.
class ForgeScreen extends ConsumerWidget {
  const ForgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final c = game.activeCompanion;
    final free = c.charms.where((s) => s == null).length;
    final banner = c.spirit < 100
        ? l.forgeNeedsSpirit
        : free == 0
        ? l.forgeNoSocket
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l.tabForge), actions: lpActions(game.lp)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.forgeAlong,
              style: const TextStyle(color: TreadColors.muted),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.15,
              child: CompanionCard(
                artKey: c.artKey,
                world: c.world,
                rarity: c.rarity,
                name: c.name,
                subtitle:
                    '${rarityLabel(l, c.rarity)} · ${typeLabel(l, c.type)}',
                badge: l.takenAlong,
              ),
            ),
            const SizedBox(height: 12),
            CompanionStats(companion: c),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.charms,
                    style: serifTitle.copyWith(fontSize: 20),
                  ),
                ),
                Text(
                  l.forgeFreeSockets(free, c.charms.length),
                  key: const Key('forge-free'),
                  style: const TextStyle(color: TreadColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: TreadColors.rail,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2B2722)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: CharmSockets(
                  companion: c,
                  onClear: (slot, seal) =>
                      _confirmClear(context, ref, c, slot, seal),
                ),
              ),
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
            Text(
              l.forgeRule,
              style: const TextStyle(color: TreadColors.muted, fontSize: 13),
            ),
            if (banner != null) ...[
              const SizedBox(height: 8),
              Text(
                banner,
                key: const Key('forge-block'),
                style: const TextStyle(color: TreadColors.copper),
              ),
            ],
            const SizedBox(height: 10),
            for (final type in SealType.values) ...[
              _SealRow(game: game, companion: c, type: type),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
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
    return DecoratedBox(
      key: Key('seal-${type.name}'),
      decoration: BoxDecoration(
        color: TreadColors.plate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF332E27)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Icon(sealIcon(type), color: TreadColors.brass, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.sealName(sealStat(l, type)),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    block == ForgeBlock.notEnoughLp
                        ? '${l.forgeStatCount(companion.sealCount(type))} · ${l.forgeNotEnoughLp}'
                        : l.forgeStatCount(companion.sealCount(type)),
                    style: const TextStyle(
                      color: TreadColors.muted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: block == null
                  ? () => ref
                        .read(gameProvider.notifier)
                        .forge(companion.id, type)
                  : null,
              child: Text(
                cost == null ? costText : '${l.forgeSet} · $costText',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
