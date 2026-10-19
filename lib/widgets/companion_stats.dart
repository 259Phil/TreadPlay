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
    final theme = Theme.of(context);
    final c = companion;

    Widget stat(String label, String value, {bool sealed = false}) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: sealed ? TreadColors.brass : null,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: TreadColors.muted, fontSize: 12),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
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
        ),
      ),
    );
  }
}
