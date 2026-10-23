import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

IconData sealIcon(SealType type) => switch (type) {
  SealType.stride => Icons.directions_walk,
  SealType.grit => Icons.shield_outlined,
  SealType.fortune => Icons.auto_awesome,
};

String sealStat(AppLocalizations l, SealType type) => switch (type) {
  SealType.stride => l.statStride,
  SealType.grit => l.statGrit,
  SealType.fortune => l.statFortune,
};

/// "Stride" or "Grit + Stride".
String sealStats(AppLocalizations l, Seal s) => s.combined
    ? l.sealComboName(sealStat(l, s.type), sealStat(l, s.partner!))
    : sealStat(l, s.type);

/// "Stride seal L3" style name used in dialogs.
String sealTitle(AppLocalizations l, Seal s) =>
    '${l.sealName(sealStats(l, s))} ${l.sealLevelShort(s.level)}';

/// A bonus fraction as a percent number: 0.15 → "15".
String pctText(BuildContext context, double fraction) =>
    formatNumber(context, fraction * 100);

/// "+15 %" or "+9 % / +9 %".
String sealBonusText(BuildContext context, Seal s) {
  final l = AppLocalizations.of(context);
  final pct = pctText(context, s.bonus);
  return s.combined ? l.sealComboBonus(pct) : l.statBonus(pct);
}

/// The painted seal for [seal] at [size]. The art itself grows with the
/// level (L1 is a small stone, L5 a winged crest); Flutter adds the warm
/// glow of L4/L5 and, with [showLevel], a small level plate.
class SealArt extends StatelessWidget {
  const SealArt({
    super.key,
    required this.seal,
    required this.size,
    this.showLevel = false,
    this.dimmed = false,
  });

  final Seal seal;
  final double size;
  final bool showLevel;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final glow = switch (seal.level) {
      >= 5 => const Color(0x66D9692F),
      4 => const Color(0x40D9692F),
      _ => null,
    };
    Widget art = Image.asset(
      seal.asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: sealTitle(l, seal),
    );
    if (dimmed) art = Opacity(opacity: 0.45, child: art);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (glow != null)
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [glow, glow.withValues(alpha: 0)],
                ),
              ),
            ),
          art,
          if (showLevel)
            Positioned(
              right: -2,
              bottom: -2,
              child: SealLevelPlate(level: seal.level, compact: size < 56),
            ),
        ],
      ),
    );
  }
}

/// Small metal plate with the level ("St.3" / "L3").
class SealLevelPlate extends StatelessWidget {
  const SealLevelPlate({super.key, required this.level, this.compact = false});

  final int level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final metal = sealLevelMetal(level);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ForgeColors.base,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: metal, width: 1.2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 3 : 5,
          vertical: compact ? 0 : 1,
        ),
        child: Text(
          l.sealLevelShort(level),
          style: TextStyle(
            color: metal,
            fontSize: compact ? 9.5 : 11,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}
