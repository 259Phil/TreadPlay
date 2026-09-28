import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

/// Small `6/6` plate showing a companion's Breath.
class BreathBadge extends StatelessWidget {
  const BreathBadge({super.key, required this.breath, required this.tank});

  final double breath;
  final int tank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final empty = breath < 1;
    final color = empty ? TreadColors.muted : TreadColors.breath;
    return Semantics(
      label:
          '${l.breath} ${l.breathValue(formatNumber(context, breath), tank)}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE612141A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            if (!empty)
              BoxShadow(
                color: TreadColors.breath.withValues(alpha: 0.35),
                blurRadius: 10,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.air, size: 15, color: color),
              const SizedBox(width: 4),
              Text(
                '${breath.floor()}/$tank',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
