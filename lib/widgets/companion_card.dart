import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../domain/world.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'card_designs.dart';
import 'companion_figure.dart';
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
    this.stats,
    this.action,
    this.type,
  });

  final String artKey;
  final World world;
  final Rarity rarity;
  final String name;
  final String subtitle;

  /// Small brass tag in the top left corner, e.g. "Along". On narrow cards
  /// the rarity tag wraps below it instead of overlapping.
  final String? badge;
  final VoidCallback? onTap;

  /// Label and value pairs shown in a row under the subtitle.
  final List<(String, String)>? stats;

  /// Text on the brass pill at the bottom of the card, e.g. the price.
  final String? action;

  /// Element of the companion; shown by the trial card designs.
  final CompanionType? type;

  static const double aspectRatio = 0.72;

  /// Two-column card grid used by Shelf and Market; taller cards when they
  /// carry an [action] pill.
  static SliverGridDelegate grid({bool withAction = false}) =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: withAction ? 0.5 : 0.58,
      );

  @override
  Widget build(BuildContext context) {
    if (kCardDesign != 0) return cardDesign(this);
    final metal = rarityMetal(rarity);
    final glow = rarity == Rarity.legendary;

    return Semantics(
      button: onTap != null,
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(metal, Colors.white, 0.25)!,
                metal,
                Color.lerp(metal, Colors.black, 0.45)!,
              ],
            ),
            boxShadow: [
              const BoxShadow(color: Color(0xAA000000), blurRadius: 8),
              if (glow)
                BoxShadow(
                  color: metal.withValues(alpha: 0.5),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
                          color: Color.lerp(
                            world.placeholder,
                            TreadColors.iron,
                            0.4,
                          )!,
                        ),
                        if (world.background case final bg?)
                          Image.asset(
                            bg,
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                            color: const Color(0x40000000),
                            colorBlendMode: BlendMode.darken,
                          ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00000000), Color(0x88000000)],
                              stops: [0.6, 1],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 28, 8, 4),
                          child: CompanionArt(artKey),
                        ),
                        Positioned(
                          left: 8,
                          right: 8,
                          top: 8,
                          child: switch (badge) {
                            final b? => Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                _Tag(b),
                                _RarityTag(rarity: rarity, color: metal),
                              ],
                            ),
                            null => Align(
                              alignment: Alignment.topRight,
                              child: _RarityTag(rarity: rarity, color: metal),
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                  _Plate(
                    name: name,
                    subtitle: subtitle,
                    metal: metal,
                    stats: stats,
                    action: action,
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
    this.stats,
    this.action,
  });

  final String name;
  final String subtitle;
  final Color metal;
  final List<(String, String)>? stats;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final a = action;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TreadColors.plate,
        border: Border(top: BorderSide(color: metal.withValues(alpha: 0.5))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: serifTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: TreadColors.muted, fontSize: 12.5),
            ),
            if (s != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final (label, value) in s)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              color: TreadColors.muted,
                              fontSize: 10.5,
                            ),
                          ),
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            if (a != null) ...[
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: brassGradient,
                ),
                child: SizedBox(
                  height: 38,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        a,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TreadColors.iron,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          text,
          style: const TextStyle(
            color: TreadColors.iron,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Rarity word on a small dark plate in the frame's metal.
class _RarityTag extends StatelessWidget {
  const _RarityTag({required this.rarity, required this.color});

  final Rarity rarity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC0F0E0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
