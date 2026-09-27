import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shoe.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/boot_placement.dart';
import '../../widgets/breath_ring.dart';
import '../../widgets/format.dart';

/// The boot shelf: every owned boot stands in its own cubby.
class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key});

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  String? _selectedId;

  static const _minCubbies = 4;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final selected = game.shoes.firstWhere(
      (s) => s.id == _selectedId,
      orElse: () => game.activeShoe,
    );
    final empty = (_minCubbies - game.shoes.length).clamp(0, 2).toInt();

    return Scaffold(
      appBar: AppBar(title: Text(l.tabGarage)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF5A3F2A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF3B2918), width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
                children: [
                  for (final shoe in game.shoes)
                    _Cubby(
                      shoe: shoe,
                      selected: shoe.id == selected.id,
                      equipped: shoe.id == game.activeShoeId,
                      onTap: () => setState(() => _selectedId = shoe.id),
                    ),
                  for (var i = 0; i < empty; i++) const _EmptyCubby(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Details(
            shoe: selected,
            equipped: selected.id == game.activeShoeId,
            onEquip: () => ref.read(gameProvider.notifier).equip(selected.id),
          ),
        ],
      ),
    );
  }
}

class _ShelfBack extends StatelessWidget {
  const _ShelfBack({required this.child, this.highlight = false});

  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? TreadColors.gold : const Color(0xFF2A1D12),
          width: highlight ? 3 : 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF231911), Color(0xFF3A2A1E)],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Plank geometry shared by filled and empty cubbies.
class _Plank {
  _Plank(double h) : top = h * 0.8, face = h * 0.05;

  final double top;
  final double face;

  List<Widget> widgets(double w, double h) => [
    Positioned(
      left: 0,
      right: 0,
      top: top,
      height: face,
      child: const ColoredBox(color: Color(0xFF9A7650)),
    ),
    Positioned(
      left: 0,
      right: 0,
      top: top + face,
      bottom: 0,
      child: const ColoredBox(color: Color(0xFF6B4E34)),
    ),
  ];
}

class _Cubby extends StatelessWidget {
  const _Cubby({
    required this.shoe,
    required this.selected,
    required this.equipped,
    required this.onTap,
  });

  final Shoe shoe;
  final bool selected;
  final bool equipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: _ShelfBack(
        highlight: selected,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            final plank = _Plank(h);
            final seat = BootPlacement.seat(
              modelId: shoe.modelId,
              centerX: w / 2,
              soleY: plank.top + plank.face * 0.7,
              maxImageSize: w * 1.05,
              maxBootHeight: h * 0.5,
            );
            return Stack(
              children: [
                ...plank.widgets(w, h),
                Positioned(
                  left: seat.boot.left + seat.boot.width * 0.08,
                  width: seat.boot.width * 0.84,
                  top: plank.top - 3,
                  height: plank.face + 4,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0x88000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: seat.image,
                  child: Image.asset(shoe.imageAsset, fit: BoxFit.contain),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  width: 34,
                  height: 34,
                  child: BreathRing(breath: shoe.breath, tank: shoe.tankSize),
                ),
                if (equipped)
                  Positioned(
                    left: 6,
                    top: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: TreadColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          l.equipped,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 8,
                  right: 8,
                  top: plank.top + plank.face,
                  bottom: 0,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A45C),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF7A5A26)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          shoe.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF2A1D12),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyCubby extends StatelessWidget {
  const _EmptyCubby();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ShelfBack(
      child: LayoutBuilder(
        builder: (context, box) {
          final plank = _Plank(box.maxHeight);
          return Stack(
            children: [
              ...plank.widgets(box.maxWidth, box.maxHeight),
              Positioned(
                left: 12,
                right: 12,
                top: 0,
                height: plank.top,
                child: Center(
                  child: Text(
                    l.garageMoreToFind,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0x88E8DCCB)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.shoe,
    required this.equipped,
    required this.onEquip,
  });

  final Shoe shoe;
  final bool equipped;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shoe.name, style: theme.textTheme.headlineSmall),
            Text(
              '${rarityLabel(l, shoe.rarity)} · ${shoeTypeLabel(l, shoe.type)}'
              ' · ${l.sweetSpotAt(formatNumber(context, shoe.type.sweetSpotKmh))}',
            ),
            const SizedBox(height: 4),
            Text(
              '${l.breath} ${l.breathValue(formatNumber(context, shoe.breath), shoe.tankSize)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: equipped
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: Text(l.equipped),
                    )
                  : FilledButton.icon(
                      onPressed: onEquip,
                      icon: const Icon(Icons.hiking),
                      label: Text(l.equip),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
