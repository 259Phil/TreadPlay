import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/species.dart';
import '../../domain/companion.dart';
import '../../domain/world.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/companion_card.dart';
import '../../widgets/format.dart';

/// Card grid of owned companions, followed by species not found yet.
class ShelfScreen extends ConsumerStatefulWidget {
  const ShelfScreen({super.key});

  @override
  ConsumerState<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends ConsumerState<ShelfScreen> {
  World? _world;
  CompanionType? _type;
  Rarity? _rarity;

  bool _matches(World world, CompanionType type, Rarity rarity) =>
      (_world == null || _world == world) &&
      (_type == null || _type == type) &&
      (_rarity == null || _rarity == rarity);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final owned = {for (final c in game.companions) c.speciesId};
    final companions = [
      for (final c in game.companions)
        if (_matches(c.world, c.type, c.rarity)) c,
    ];
    final missing = [
      for (final s in speciesCatalog)
        if (!owned.contains(s.id) && _matches(s.world, s.type, Rarity.common))
          s,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.tabShelf)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  _Filter<World>(
                    label: l.filterWorld,
                    value: _world,
                    values: World.values,
                    name: (w) => worldLabel(l, w),
                    onChanged: (v) => setState(() => _world = v),
                  ),
                  _Filter<CompanionType>(
                    label: l.filterType,
                    value: _type,
                    values: CompanionType.values,
                    name: (t) => typeLabel(l, t),
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  _Filter<Rarity>(
                    label: l.filterRarity,
                    value: _rarity,
                    values: Rarity.values,
                    name: (r) => rarityLabel(l, r),
                    onChanged: (v) => setState(() => _rarity = v),
                  ),
                ],
              ),
            ),
          ),
          if (companions.isEmpty && missing.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  l.shelfNothingHere,
                  style: const TextStyle(color: TreadColors.muted),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: CompanionCard.aspectRatio,
              ),
              delegate: SliverChildListDelegate([
                for (final c in companions)
                  CompanionCard(
                    key: ValueKey(c.id),
                    artKey: c.artKey,
                    world: c.world,
                    rarity: c.rarity,
                    name: c.name,
                    subtitle:
                        '${typeLabel(l, c.type)} · ${l.levelShort(c.level)}',
                    badge: c.id == game.activeCompanionId ? l.takenAlong : null,
                    onTap: () => _showDetail(context, c.id),
                  ),
                for (final s in missing)
                  CompanionCard(
                    key: ValueKey(s.id),
                    artKey: artKeyFor(s.id, Rarity.common),
                    world: s.world,
                    rarity: Rarity.common,
                    name: s.name,
                    subtitle: l.notFoundYet,
                    locked: true,
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, String companionId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _Detail(companionId: companionId),
    );
  }
}

class _Filter<T> extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.values,
    required this.name,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T) name;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = value;
    final active = v != null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<int>(
        color: TreadColors.plate,
        onSelected: (i) => onChanged(i < 0 ? null : values[i]),
        itemBuilder: (_) => [
          PopupMenuItem(value: -1, child: Text(l.filterAll)),
          for (var i = 0; i < values.length; i++)
            PopupMenuItem(value: i, child: Text(name(values[i]))),
        ],
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active
                ? TreadColors.brass.withValues(alpha: 0.2)
                : TreadColors.plate,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? TreadColors.brass : const Color(0xFF3A424C),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 7, 6, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$label: ${v == null ? l.filterAll : name(v)}',
                  style: TextStyle(
                    color: active ? TreadColors.brass : TreadColors.text,
                    fontSize: 13,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: TreadColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.companionId});

  final String companionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);
    final c = game.companions.firstWhere((c) => c.id == companionId);
    final along = c.id == game.activeCompanionId;

    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          Text(
            label,
            style: const TextStyle(color: TreadColors.muted, fontSize: 12),
          ),
        ],
      ),
    );

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
                        '${l.breath} '
                        '${l.breathValue(formatNumber(context, c.breath.floorToDouble()), c.tankSize)}',
                        style: const TextStyle(color: TreadColors.breath),
                      ),
                      Text(
                        l.breathRegenHint,
                        style: const TextStyle(
                          color: TreadColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    stat(l.statStride, formatNumber(context, c.stride)),
                    stat(l.statGrit, formatNumber(context, c.grit)),
                    stat(l.statFortune, formatNumber(context, c.fortune)),
                    stat(
                      l.statSpirit,
                      l.percentValue(formatNumber(context, c.spirit)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(l.charms, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 0 ? 8 : 0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3A424C)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l.charmSlotEmpty,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: TreadColors.muted),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text(l.levelUp),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(onPressed: null, child: Text(l.repair)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                icon: Icon(along ? Icons.check : Icons.directions_walk),
                label: Text(along ? l.takenAlong : l.takeAlong),
                onPressed: along
                    ? null
                    : () => ref.read(gameProvider.notifier).takeAlong(c.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
