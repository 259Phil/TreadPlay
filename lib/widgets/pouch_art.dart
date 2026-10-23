import 'package:flutter/material.dart';

import '../domain/pouch.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../ui/skin.dart';
import 'format.dart';
import 'seal_art.dart';
import 'stock_art.dart';

String pouchName(AppLocalizations l, PouchColor c) => switch (c) {
  PouchColor.brown => l.pouchBrown,
  PouchColor.copper => l.pouchCopper,
  PouchColor.turquoise => l.pouchTurquoise,
  PouchColor.navy => l.pouchNavy,
};

String pouchShortName(AppLocalizations l, PouchColor c) => switch (c) {
  PouchColor.brown => l.pouchShortBrown,
  PouchColor.copper => l.pouchShortCopper,
  PouchColor.turquoise => l.pouchShortTurquoise,
  PouchColor.navy => l.pouchShortNavy,
};

String pouchContents(AppLocalizations l, PouchColor c) => switch (c) {
  PouchColor.brown => l.pouchContentsBrown,
  PouchColor.copper => l.pouchContentsCopper,
  PouchColor.turquoise => l.pouchContentsTurquoise,
  PouchColor.navy => l.pouchContentsNavy,
};

/// Metal accent of a pouch colour, for rims and labels.
Color pouchAccent(PouchColor c) => switch (c) {
  PouchColor.brown => const Color(0xFF9A7A4E),
  PouchColor.copper => const Color(0xFFC07842),
  PouchColor.turquoise => const Color(0xFF4FA39C),
  PouchColor.navy => const Color(0xFF6F86C4),
};

/// The painted knit pouch in its colour. A warmed-through pouch glows
/// brass.
class PouchArt extends StatelessWidget {
  const PouchArt({
    super.key,
    required this.color,
    required this.size,
    this.glow = false,
  });

  final PouchColor color;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final art = Image.asset(
      'assets/pouch/pouch_${color.name}.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => Icon(
        Icons.shopping_bag_outlined,
        size: size * .7,
        color: pouchAccent(color),
      ),
    );
    if (!glow) return SizedBox.square(dimension: size, child: art);
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0x66C4A36A), Color(0x00C4A36A)],
          ),
        ),
        child: art,
      ),
    );
  }
}

/// The painted leash: brass end brackets, a braided leather rope and four
/// brass rings. Pouches hang from the rings by their own carabiner. Rings
/// beyond [clips] are dimmed and carry a lock badge.
class LeashRail extends StatelessWidget {
  const LeashRail({
    super.key,
    required this.leash,
    required this.clips,
    required this.artSize,
    this.selected,
    this.onTap,
    this.labels = false,
    this.keyPrefix = 'leash',
    this.compact = false,
  });

  final List<Pouch> leash;
  final int clips;
  final double artSize;
  final int? selected;
  final ValueChanged<int>? onTap;

  /// Warm progress under each pouch.
  final bool labels;
  final String keyPrefix;

  /// Small rail for the Home chip: no labels, smaller lock badge.
  final bool compact;

  // Geometry of the art pieces (pixels in the 310 px tall source).
  static const _srcH = 310.0;
  static const _capW = 206.0;
  static const _ringW = 76.0;
  static const _hangY = 284.0;

  /// Height the rail needs at [width].
  static double heightFor(double width, double artSize, bool labels) {
    final g = _Geom(width, artSize);
    return g.pouchTop + g.art + (labels ? 18 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final g = _Geom(box.maxWidth, artSize);
        final h = g.pouchTop + g.art + (labels ? 18 : 0);
        final children = <Widget>[
          Positioned(
            left: g.capW * .5,
            right: g.capW * .5,
            top: 0,
            height: g.railH,
            child: Image.asset(
              'assets/leash/leash_rope.webp',
              repeat: ImageRepeat.repeatX,
              fit: BoxFit.fitHeight,
              alignment: Alignment.centerLeft,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: g.capW,
            height: g.railH,
            child: _piece('leash_cap_l'),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: g.capW,
            height: g.railH,
            child: _piece('leash_cap_r'),
          ),
        ];
        for (var i = 0; i < Pouches.maxClips; i++) {
          final cx = g.ringX(i);
          final p = i < leash.length && i < clips ? leash[i] : null;
          final locked = i >= clips;
          if (p != null) {
            final isSelected = i == selected;
            Widget art = PouchArt(color: p.color, size: g.art, glow: p.ready);
            if (isSelected) {
              art = DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ForgeColors.brass, width: 1.5),
                  color: const Color(0x22C4A36A),
                ),
                child: art,
              );
            }
            final tap = onTap;
            if (tap != null) {
              art = InkWell(
                key: Key('$keyPrefix-$i'),
                borderRadius: BorderRadius.circular(10),
                onTap: () => tap(i),
                child: art,
              );
            }
            children.add(
              Positioned(
                left: cx - g.art * .53,
                top: g.pouchTop,
                width: g.art,
                height: g.art,
                child: art,
              ),
            );
            if (labels) {
              children.add(
                Positioned(
                  left: cx - g.spacing * .45,
                  width: g.spacing * .9,
                  top: g.pouchTop + g.art + 1,
                  height: 16,
                  child: FittedBox(
                    child: Text(
                      p.ready
                          ? l.pouchReadyShort
                          : l.pouchWarmShort(
                              _km(context, p.warmedM),
                              _km(context, p.color.walkM),
                            ),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: p.ready ? ForgeColors.brass : ForgeColors.muted,
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          Widget ring = _piece('leash_ring');
          if (locked) {
            ring = Opacity(
              opacity: .55,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  .25, .25, .25, 0, 0, //
                  .22, .22, .22, 0, 0, //
                  .2, .2, .2, 0, 0, //
                  0, 0, 0, 1, 0,
                ]),
                child: ring,
              ),
            );
          }
          children.add(
            Positioned(
              left: cx - g.ringW / 2,
              top: 0,
              width: g.ringW,
              height: g.railH,
              child: ring,
            ),
          );
          if (locked) {
            final b = compact ? 13.0 : 20.0;
            children.add(
              Positioned(
                key: Key('$keyPrefix-locked-$i'),
                left: cx - b / 2,
                top: g.railH * (_hangY / _srcH) - b * .15,
                child: LockBadge(size: b),
              ),
            );
          }
        }
        return SizedBox(
          height: h,
          width: box.maxWidth,
          child: Stack(clipBehavior: Clip.none, children: children),
        );
      },
    );
  }

  static Widget _piece(String name) => Image.asset(
    'assets/leash/$name.webp',
    fit: BoxFit.fill,
    filterQuality: FilterQuality.medium,
  );
}

class _Geom {
  _Geom(this.width, double artSize) {
    railH = (width * .2).clamp(26.0, 88.0);
    capW = railH * LeashRail._capW / LeashRail._srcH;
    ringW = railH * LeashRail._ringW / LeashRail._srcH;
    final inner = width - capW * 1.7;
    spacing = inner / Pouches.maxClips;
    art = artSize.clamp(0.0, spacing * .98);
    pouchTop = railH * (LeashRail._hangY / LeashRail._srcH) - art * .07;
  }

  final double width;
  late final double railH;
  late final double capW;
  late final double ringW;
  late final double spacing;
  late final double art;
  late final double pouchTop;

  double ringX(int i) => capW * .85 + spacing * (i + .5);
}

String _km(BuildContext context, double m) =>
    formatNumber(context, m / 1000, pattern: '0.0');

/// One opened compartment: a seal, Glut or splinters.
class PouchRewardTile extends StatelessWidget {
  const PouchRewardTile({super.key, required this.reward, required this.size});

  final PouchReward reward;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (
      Widget art,
      String top,
      String bottom,
      Color tint,
    ) = switch (reward.kind) {
      PouchRewardKind.seal => (
        SealArt(seal: reward.seal!, size: size),
        l.sealLevelShort(reward.seal!.level),
        sealStats(l, reward.seal!),
        sealLevelMetal(reward.seal!.level),
      ),
      PouchRewardKind.glut => (
        GlutIcon(size: size),
        l.glutAmount(reward.amount),
        'Glut',
        ForgeColors.ember,
      ),
      PouchRewardKind.splinters => (
        SplitterIcon(size: size),
        l.pouchSplinters(reward.amount),
        '',
        ForgeColors.text,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ForgeColors.raised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: .55)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: size,
              child: Center(child: art),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                top,
                style: TextStyle(
                  color: tint,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            if (bottom.isNotEmpty)
              FittedBox(
                child: Text(
                  bottom,
                  style: const TextStyle(
                    color: ForgeColors.text,
                    fontSize: 11.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
