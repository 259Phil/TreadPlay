import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

class BreathBar extends StatelessWidget {
  const BreathBar({super.key, required this.breath, required this.tank});

  final double breath;
  final int tank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.air, size: 18, color: TreadColors.breath),
            const SizedBox(width: 6),
            Text(l.breath),
            const Spacer(),
            Text(l.breathValue(formatNumber(context, breath), tank)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (breath / tank).clamp(0, 1),
            minHeight: 10,
            color: TreadColors.breath,
            backgroundColor: TreadColors.panel,
          ),
        ),
      ],
    );
  }
}
