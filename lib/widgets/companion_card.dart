import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../domain/world.dart';
import '../theme.dart';

/// Collectible card. The frame, name and stats are drawn here; the image is
/// only the creature on transparency.
class CompanionCard extends StatelessWidget {
  const CompanionCard({
    super.key,
    required this.artKey,
    required this.world,
    required this.rarity,
    required this.name,
    required this.subtitle,
    this.badge,
    this.locked = false,
    this.onTap,
  });

  final String artKey;
  final World world;
  final Rarity rarity;
  final String name;
  final String subtitle;

  /// Small brass tag in the top left corner, e.g. "Along".
  final String? badge;
  final bool locked;
  final VoidCallback? onTap;

  static const double aspectRatio = 0.72;

  @override
  Widget build(BuildContext context) {
    final metal = locked ? const Color(0xFF4A5058) : rarityMetal(rarity);
    final glow = rarity == Rarity.legendary && !locked;
    Widget art = Image.asset(
      'assets/companions/$artKey.png',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
    if (locked) {
      art = Opacity(
        opacity: 0.35,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.3, 0.5, 0.1, 0, 0, //
            0.3, 0.5, 0.1, 0, 0, //
            0.3, 0.5, 0.1, 0, 0, //
            0, 0, 0, 1, 0,
          ]),
          child: art,
        ),
      );
    }

    return Semantics(
      button: onTap != null,
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(metal, Colors.white, 0.35)!,
                metal,
                Color.lerp(metal, Colors.black, 0.45)!,
              ],
            ),
            boxShadow: [
              const BoxShadow(color: Color(0x88000000), blurRadius: 6),
              if (glow)
                BoxShadow(
                  color: metal.withValues(alpha: 0.55),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.lerp(
                                  world.placeholder,
                                  TreadColors.iron,
                                  0.35,
                                )!,
                                TreadColors.iron,
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 22, 10, 8),
                          child: art,
                        ),
                        if (locked)
                          const Center(
                            child: Icon(
                              Icons.lock_outline,
                              color: TreadColors.muted,
                            ),
                          ),
                        if (badge != null)
                          Positioned(left: 6, top: 6, child: _Tag(badge!)),
                        Positioned(
                          right: 7,
                          top: 7,
                          child: _RarityPips(rarity: rarity, color: metal),
                        ),
                      ],
                    ),
                  ),
                  _Plate(
                    name: name,
                    subtitle: subtitle,
                    metal: metal,
                    locked: locked,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({
    required this.name,
    required this.subtitle,
    required this.metal,
    required this.locked,
  });

  final String name;
  final String subtitle;
  final Color metal;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    const rivet = SizedBox.square(
      dimension: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF5C636B),
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TreadColors.rail,
        border: Border(top: BorderSide(color: metal, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 7),
        child: Row(
          children: [
            rivet,
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: locked ? TreadColors.muted : TreadColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TreadColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            rivet,
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TreadColors.brass,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 12, color: TreadColors.iron),
            const SizedBox(width: 2),
            Text(
              text,
              style: const TextStyle(
                color: TreadColors.iron,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One to four small rivets for the rarity tier.
class _RarityPips extends StatelessWidget {
  const _RarityPips({required this.rarity, required this.color});

  final Rarity rarity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i <= rarity.index; i++)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: SizedBox.square(
              dimension: 7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: const Color(0xFF12141A)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
