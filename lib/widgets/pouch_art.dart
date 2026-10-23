import 'package:flutter/material.dart';

import '../domain/pouch.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';
import 'seal_art.dart';

String pouchName(AppLocalizations l, PouchColor c) => switch (c) {
  PouchColor.brown => l.pouchBrown,
  PouchColor.copper => l.pouchCopper,
  PouchColor.turquoise => l.pouchTurquoise,
  PouchColor.navy => l.pouchNavy,
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

/// The iron leash rod with its clips; pouches hang below the clips.
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
  });

  final List<Pouch> leash;
  final int clips;
  final double artSize;
  final int? selected;
  final ValueChanged<int>? onTap;

  /// Warm progress under each pouch.
  final bool labels;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Stack(
      children: [
        // The rod.
        Positioned(
          left: 0,
          right: 0,
          top: 4,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8A9099),
                  Color(0xFF3B434E),
                  Color(0xFF1A1D22),
                ],
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x99000000), blurRadius: 3),
              ],
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < clips; i++)
              Expanded(child: _clip(context, l, i)),
          ],
        ),
      ],
    );
  }

  Widget _clip(BuildContext context, AppLocalizations l, int i) {
    final p = i < leash.length ? leash[i] : null;
    final isSelected = p != null && i == selected;
    final clip = Container(
      width: 8,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFF4A3B24)),
        gradient: const LinearGradient(
          colors: [Color(0xFFC4A36A), Color(0xFF7A6238)],
        ),
      ),
    );
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        clip,
        if (p == null)
          SizedBox(
            height: artSize,
            child: Center(
              child: Container(
                width: artSize * .42,
                height: artSize * .42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ForgeColors.line, width: 1.5),
                ),
              ),
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? ForgeColors.brass : Colors.transparent,
                width: 1.5,
              ),
              color: isSelected ? const Color(0x22C4A36A) : null,
            ),
            child: PouchArt(color: p.color, size: artSize, glow: p.ready),
          ),
        if (labels)
          SizedBox(
            height: 16,
            child: p == null
                ? null
                : FittedBox(
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
      ],
    );
    final tap = onTap;
    if (p == null || tap == null) {
      return Center(child: body);
    }
    return Center(
      child: InkWell(
        key: Key('$keyPrefix-$i'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => tap(i),
        child: body,
      ),
    );
  }
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
        Icon(
          Icons.local_fire_department,
          size: size * .8,
          color: ForgeColors.ember,
        ),
        l.glutAmount(reward.amount),
        'Glut',
        ForgeColors.ember,
      ),
      PouchRewardKind.splinters => (
        Icon(Icons.scatter_plot, size: size * .8, color: ForgeColors.muted),
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
