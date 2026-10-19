import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

/// Stride, Grit, Fortune (seals included, brass when sealed) and Spirit.
class CompanionStats extends StatelessWidget {
  const CompanionStats({super.key, required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = companion;

    Widget stat(String label, String value, {bool sealed = false}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: TreadColors.plate,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: sealed ? TreadColors.brassDark : const Color(0xFF332E27),
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
        ),
        stat(
          l.statGrit,
          formatNumber(context, c.gritTotal),
          sealed: c.sealCount(SealType.grit) > 0,
        ),
        stat(
          l.statFortune,
          formatNumber(context, c.fortuneTotal),
          sealed: c.sealCount(SealType.fortune) > 0,
        ),
        stat(l.statSpirit, l.percentValue(formatNumber(context, c.spirit))),
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
