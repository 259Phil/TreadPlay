import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../ui/skin.dart';
import 'format.dart';
import 'seal_art.dart';

/// Stride, Grit, Fortune (seals included, brass when sealed) and Spirit.
class CompanionStats extends StatelessWidget {
  const CompanionStats({super.key, required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = companion;

    final anySeal = c.seals.isNotEmpty;

    /// Blank line on unsealed tiles keeps the row even.
    String? bonus(SealType t) {
      if (c.sealCount(t) == 0) return anySeal ? '' : null;
      final pct = pctText(context, c.sealBonus(t));
      return c.sealCapped(t) ? l.statCapped(pct) : l.statBonus(pct);
    }

    Widget stat(
      String label,
      String value, {
      bool sealed = false,
      String? extra,
    }) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: TreadColors.plate,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: sealed
                  ? TreadColors.brassDark
                  : kLeatherBuild
                  ? const Color(0xFF4A3628)
                  : const Color(0xFF332E27),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: const TextStyle(
                    color: TreadColors.muted,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: serifTitle.copyWith(
                    fontSize: 20,
                    color: sealed ? TreadColors.brass : null,
                  ),
                ),
                if (extra != null)
                  Text(
                    extra,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: const TextStyle(
                      color: TreadColors.brass,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Row(
      children: [
        stat(
          l.statStride,
          formatNumber(context, c.strideTotal),
          sealed: c.sealCount(SealType.stride) > 0,
          extra: bonus(SealType.stride),
        ),
        stat(
          l.statGrit,
          formatNumber(context, c.gritTotal),
          sealed: c.sealCount(SealType.grit) > 0,
          extra: bonus(SealType.grit),
        ),
        stat(
          l.statFortune,
          formatNumber(context, c.fortuneTotal),
          sealed: c.sealCount(SealType.fortune) > 0,
          extra: bonus(SealType.fortune),
        ),
        stat(
          l.statSpirit,
          l.percentValue(formatNumber(context, c.spirit)),
          extra: anySeal ? '' : null,
        ),
      ],
    );
  }
}

/// Stride, Grit and Fortune (seals included) for the card stat row.
List<(String, String)> cardStats(BuildContext context, Companion c) {
  final l = AppLocalizations.of(context);
  return [
    (l.statStride, formatNumber(context, c.strideTotal)),
    (l.statGrit, formatNumber(context, c.gritTotal)),
    (l.statFortune, formatNumber(context, c.fortuneTotal)),
  ];
}
