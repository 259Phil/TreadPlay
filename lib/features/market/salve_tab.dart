import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/market.dart';
import '../../domain/salve.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../../widgets/salve_art.dart';

/// The trader's Mutsalben: price with the Market's drift, the offer of
/// this drift struck through, the count in the Vorrat and a buy button.
class SalveTab extends ConsumerWidget {
  const SalveTab({super.key, required this.game, required this.market});

  final GameData game;
  final Market market;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListView(
      key: const Key('market-salves'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          l.marketSalvesIntro,
          style: const TextStyle(color: TreadColors.muted),
        ),
        const SizedBox(height: 12),
        for (final s in Salve.values) ...[
          _Offer(game: game, market: market, salve: s),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _Offer extends ConsumerWidget {
  const _Offer({required this.game, required this.market, required this.salve});

  final GameData game;
  final Market market;
  final Salve salve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final price = market.priceOfSalve(salve);
    final deal = market.salveDeal == salve;
    final block = game.buySalveBlock(salve);
    String lp(double v) => formatNumber(context, v, pattern: '0');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TreadColors.plate,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: deal ? salveHoney : TreadColors.brassDark,
          width: deal ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SalveArt(salve: salve, size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salveName(l, salve),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    salveEffect(l, salve),
                    style: TextStyle(color: salveTint(salve)),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (deal) ...[
                        Text(
                          l.lpAmount(lp(salve.price.toDouble())),
                          style: const TextStyle(
                            color: TreadColors.muted,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          l.marketSalveDeal,
                          style: const TextStyle(
                            color: salveHoney,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      Text(
                        l.salveOwned(game.salves.count(salve)),
                        style: const TextStyle(
                          color: TreadColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      key: ValueKey('buy-salve-${salve.name}'),
                      onPressed: block == null
                          ? () {
                              if (!ref
                                  .read(gameProvider.notifier)
                                  .buySalve(salve)) {
                                return;
                              }
                              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l.marketSalveBought(salveName(l, salve)),
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text(l.marketSalveBuy(lp(price))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
