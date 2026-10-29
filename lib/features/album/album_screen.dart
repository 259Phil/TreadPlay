import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/species.dart';
import '../../domain/album.dart';
import '../../domain/market.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/companion_card.dart';
import '../../widgets/companion_figure.dart';
import '../../widgets/format.dart';

/// Every species by world: collected ones in colour, the ones the Market
/// offers now as a light silhouette, the rest dark with the km they open
/// at. A gold ✦ marks species owned as a Schimmer.
class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final album = game.album;
    final offered = {
      for (final s in Market.poolFor(
        worlds: game.marketWorlds,
        distanceM: game.totals.distanceM,
      ))
        s.id,
    };
    final owned = speciesCatalog.where((s) => album.owned.contains(s.id));
    final shimmer = speciesCatalog.where((s) => album.shimmer.contains(s.id));

    return Scaffold(
      backgroundColor: TreadSkin.of(context).canvas,
      appBar: AppBar(title: Text(l.albumTitle)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.albumProgress(
                      owned.length,
                      speciesCatalog.length,
                      shimmer.length,
                    ),
                    key: const Key('album-progress'),
                    style: const TextStyle(
                      color: TreadColors.brass,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.albumShimmerHint,
                    style: const TextStyle(
                      color: TreadColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final world in Market.starterWorlds) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  worldLabel(l, world),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildListDelegate([
                  for (final s in speciesCatalog)
                    if (s.world == world)
                      _Tile(
                        species: s,
                        album: album,
                        offered: offered.contains(s.id),
                      ),
                ]),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// Black shape of the creature, for species not collected yet.
const ColorFilter _silhouette = ColorFilter.matrix([
  0, 0, 0, 0, 20, //
  0, 0, 0, 0, 16, //
  0, 0, 0, 0, 14, //
  0, 0, 0, 1, 0,
]);

class _Tile extends StatelessWidget {
  const _Tile({
    required this.species,
    required this.album,
    required this.offered,
  });

  final Species species;
  final AlbumState album;
  final bool offered;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = species;
    final have = album.owned.contains(s.id);
    final shimmer = album.shimmer.contains(s.id);
    final known = have || offered;
    final art = CompanionArt(s.id);
    final status = have
        ? l.albumFind(findRateLabel(l, s.findRate))
        : offered
        ? l.albumInMarket
        : l.albumFromKm(formatNumber(context, speciesOpenKm(s)));
    return DecoratedBox(
      key: ValueKey('album-${s.id}'),
      decoration: BoxDecoration(
        color: TreadColors.plate,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: shimmer
              ? const Color(0xFFF2C45A)
              : have
              ? TreadColors.brass
              : const Color(0xFF3A424C),
          width: shimmer ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: have
                        ? (shimmer ? ShimmerArt(child: art) : art)
                        : Opacity(
                            opacity: offered ? 0.75 : 0.45,
                            child: ColorFiltered(
                              colorFilter: _silhouette,
                              child: art,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Text(
                      shimmer ? '✦' : '✧',
                      key: ValueKey('album-star-${s.id}-$shimmer'),
                      style: TextStyle(
                        color: shimmer
                            ? const Color(0xFFF2C45A)
                            : const Color(0x553A424C),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              known ? s.name : '???',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: have ? TreadColors.text : TreadColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: TreadColors.muted, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}
