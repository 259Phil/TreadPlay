import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

/// Stride, Grit, Fortune and Spirit of one companion in a row.
class CompanionStats extends StatelessWidget {
  const CompanionStats({super.key, required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = companion;

    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleMedium),
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
            stat(l.statStride, formatNumber(context, c.stride)),
            stat(l.statGrit, formatNumber(context, c.grit)),
            stat(l.statFortune, formatNumber(context, c.fortune)),
            stat(l.statSpirit, l.percentValue(formatNumber(context, c.spirit))),
          ],
        ),
      ),
    );
  }
}
