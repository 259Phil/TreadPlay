import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/companion.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/companion_card.dart';
import '../../widgets/companion_stats.dart';
import '../../widgets/format.dart';
import '../../widgets/lp_pill.dart';

/// Buy companions for LP and sell them back, on the same card grid as
/// Shelf. Offers drift every few hours; the moment is never shown.
class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final market = game.market;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.tabMarket),
          actions: lpActions(game.lp),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            splashBorderRadius: BorderRadius.circular(20),
            indicator: const BoxDecoration(
              gradient: brassGradient,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            labelColor: TreadColors.iron,
            unselectedLabelColor: TreadColors.text,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            tabs: [_PillTab(l.marketBuyTab), _PillTab(l.marketSellTab)],
          ),
        ),
        body: market == null
            ? const SizedBox.shrink()
            : TabBarView(
                children: [
                  _Grid(
                    game: game,
                    companions: market.offers,
                    price: market.priceOf,
                    buying: true,
                  ),
                  _Grid(
                    game: game,
                    companions: game.companions,
                    price: market.sellPriceOf,
                    buying: false,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Rounded pill tab for Offers and Yours.
class _PillTab extends StatelessWidget {
  const _PillTab(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(text),
      ),
    );
  }
}

String formatLpPrice(BuildContext context, double lp) => AppLocalizations.of(
  context,
).lpAmount(formatNumber(context, lp, pattern: '#,##0'));

class _Grid extends StatelessWidget {
  const _Grid({
    required this.game,
    required this.companions,
    required this.price,
    required this.buying,
  });

  final GameData game;
  final List<Companion> companions;
  final double Function(Companion) price;
  final bool buying;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CustomScrollView(
      key: PageStorageKey(buying),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.marketHint,
                    style: const TextStyle(color: TreadColors.muted),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l.shelfCount(game.companions.length, GameData.inventoryCap),
                  style: TextStyle(
                    color: game.shelfFull
                        ? TreadColors.copper
                        : TreadColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (companions.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                l.marketSoldOut,
                style: const TextStyle(color: TreadColors.muted),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          sliver: SliverGrid(
            gridDelegate: CompanionCard.grid(withAction: true),
            delegate: SliverChildListDelegate([
              for (final c in companions)
                CompanionCard(
                  key: ValueKey(c.id),
                  artKey: c.artKey,
                  world: c.world,
                  rarity: c.rarity,
                  name: c.name,
                  subtitle: rarityLabel(l, c.rarity),
                  stats: cardStats(context, c),
                  action:
                      '${typeLabel(l, c.type)} · ${formatLpPrice(context, price(c))}',
                  badge: !buying && c.id == game.activeCompanionId
                      ? l.takenAlong
                      : null,
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) =>
                        _TradeSheet(companionId: c.id, buying: buying),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _TradeSheet extends ConsumerWidget {
  const _TradeSheet({required this.companionId, required this.buying});

  final String companionId;
  final bool buying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);
    final market = game.market;
    final c = buying
        ? market?.offer(companionId)
        : game.companions.where((c) => c.id == companionId).firstOrNull;
    if (market == null || c == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Text(l.marketGone, textAlign: TextAlign.center),
        ),
      );
    }
    final block = buying
        ? game.buyBlock(companionId)
        : game.sellBlock(companionId);
    final price = buying ? market.priceOf(c) : market.sellPriceOf(c);
    final next = !buying && block == null && c.id == game.activeCompanionId
        ? game.companions.firstWhere((o) => o.id != c.id)
        : null;
    final notifier = ref.read(gameProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: AspectRatio(
                    aspectRatio: CompanionCard.aspectRatio,
                    child: CompanionCard(
                      artKey: c.artKey,
                      world: c.world,
                      rarity: c.rarity,
                      name: c.name,
                      subtitle: l.levelShort(c.level),
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
                      Text(
                        worldLabel(l, c.world),
                        style: const TextStyle(color: TreadColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.sweetSpotAt(
                          formatNumber(context, c.type.sweetSpotKmh),
                        ),
                      ),
                      Text(
                        l.breathMax(c.tankSize),
                        style: const TextStyle(color: TreadColors.breath),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CompanionStats(companion: c),
            const SizedBox(height: 12),
            if (block != null)
              Text(
                _blockText(l, block, c),
                key: const Key('trade-block'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: TreadColors.copper),
              ),
            if (next != null)
              Text(
                l.marketSellSwitches(next.name),
                textAlign: TextAlign.center,
                style: const TextStyle(color: TreadColors.muted),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                icon: Icon(buying ? Icons.shopping_bag : Icons.sell),
                label: Text(
                  buying
                      ? l.marketBuyFor(formatLpPrice(context, price))
                      : l.marketSellFor(formatLpPrice(context, price)),
                ),
                onPressed: block != null
                    ? null
                    : () {
                        final done = buying
                            ? notifier.buy(c.id)
                            : notifier.sell(c.id);
                        if (done) Navigator.of(context).pop();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _blockText(AppLocalizations l, TradeBlock block, Companion c) =>
    switch (block) {
      TradeBlock.gone => l.marketGone,
      TradeBlock.shelfFull => l.marketShelfFull(GameData.inventoryCap),
      TradeBlock.notEnoughLp => l.marketNotEnoughLp,
      TradeBlock.needsSpirit => l.marketNeedsSpirit,
      TradeBlock.lastCompanion => l.marketLastCompanion(c.name),
    };
