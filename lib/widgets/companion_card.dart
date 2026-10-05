import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../domain/world.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

/// Collectible card. The frame (rarity metal), rarity word, name and
/// subtitle are drawn here; the image is only the creature on transparency.
class CompanionCard extends StatelessWidget {
  const CompanionCard({
    super.key,
    required this.artKey,
    required this.world,
    required this.rarity,
    required this.name,
    required this.subtitle,
    this.badge,
    this.onTap,
  });

  final String artKey;
  final World world;
  final Rarity rarity;
  final String name;
  final String subtitle;

  /// Small brass tag in the top left corner, e.g. "Along".
  final String? badge;
  final VoidCallback? onTap;

  static const double aspectRatio = 0.72;

  /// Two-column card grid used by Shelf and Market.
  static const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: aspectRatio,
  );

  @override
  Widget build(BuildContext context) {
    final metal = rarityMetal(rarity);
    final glow = rarity == Rarity.legendary;
    final art = Image.asset(
      'assets/companions/$artKey.png',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );

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
                        if (badge != null)
                          Positioned(left: 6, top: 6, child: _Tag(badge!)),
                        Positioned(
                          right: 7,
                          top: 7,
                          child: _RarityTag(rarity: rarity, color: metal),
                        ),
                      ],
                    ),
                  ),
                  _Plate(name: name, subtitle: subtitle, metal: metal),
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
  });

  final String name;
  final String subtitle;
  final Color metal;

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
                    style: const TextStyle(
                      color: TreadColors.text,
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

/// Rarity word on a small plate in the frame's metal.
class _RarityTag extends StatelessWidget {
  const _RarityTag({required this.rarity, required this.color});

  final Rarity rarity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE612141A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          rarityLabel(l, rarity).toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
