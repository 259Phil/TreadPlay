import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/collector.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';

/// Den header: the Sammlerbonus with its next step (explained on tap), and
/// the shelf slots with the button to buy one more.
class CollectorPanel extends ConsumerStatefulWidget {
  const CollectorPanel({super.key});

  @override
  ConsumerState<CollectorPanel> createState() => _CollectorPanelState();
}

class _CollectorPanelState extends ConsumerState<CollectorPanel> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final count = game.collectorCount;
    final bonus = game.collectorBonus;
    final next = Collector.nextTierFor(count);
    final price = game.nextSlotPrice;
    return Container(
      key: const Key('collector-panel'),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: TreadColors.plate,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TreadColors.brassDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('collector-toggle'),
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                const Icon(Icons.air, size: 18, color: TreadColors.breath),
                const SizedBox(width: 6),
                Text(
                  l.collectorTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bonus > 0 ? l.collectorBonus(bonus) : l.collectorNone,
                    key: const Key('collector-bonus'),
                    style: TextStyle(
                      color: bonus > 0 ? TreadColors.breath : TreadColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  _open ? Icons.expand_less : Icons.info_outline,
                  size: 20,
                  color: TreadColors.muted,
                  semanticLabel: l.collectorMore,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _Steps(count: count),
          const SizedBox(height: 4),
          Text(
            next == null
                ? l.collectorMaxed
                : l.collectorNext(next, Collector.bonusFor(next), next - count),
            key: const Key('collector-next'),
            style: const TextStyle(color: TreadColors.brass, fontSize: 13),
          ),
          if (_open) ...[
            const SizedBox(height: 4),
            Text(l.collectorCount(count), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              l.collectorExplain,
              key: const Key('collector-explain'),
              style: const TextStyle(color: TreadColors.muted, fontSize: 12),
            ),
          ],
          const Divider(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.shelfSlotsLine(game.companions.length, game.shelfSlots),
                  key: const Key('shelf-slots'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (price == null)
                Flexible(
                  child: Text(
                    l.shelfSlotsMax,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: TreadColors.muted,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                FilledButton(
                  key: const Key('shelf-buy-slot'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _confirmBuy(context),
                  child: Text(l.shelfBuySlot(price)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBuy(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final game = ref.read(gameProvider);
    final price = game.nextSlotPrice;
    if (price == null) return;
    final slot = game.shelfSlots + 1;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (game.slotBlock == SlotBlock.notEnoughLp) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l.shelfSlotNoLp(slot, price))),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('shelf-buy-dialog'),
        title: Text(l.shelfBuyTitle),
        content: Text(l.shelfBuyBody(slot, price)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const Key('shelf-buy-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.shelfBuyConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!ref.read(gameProvider.notifier).buySlot()) return;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(l.shelfBuyDone(ref.read(gameProvider).shelfSlots)),
      ),
    );
  }
}

/// Three bars for the 5 / 10 / 20 steps.
class _Steps extends StatelessWidget {
  const _Steps({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final t in Collector.tiers)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (count / t).clamp(0, 1).toDouble(),
                      minHeight: 5,
                      color: count >= t
                          ? TreadColors.breath
                          : TreadColors.brass,
                      backgroundColor: TreadColors.rail,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$t · +${Collector.bonusFor(t)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: count >= t
                          ? TreadColors.breath
                          : TreadColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
