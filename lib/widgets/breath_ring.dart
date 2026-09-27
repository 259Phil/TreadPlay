import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

/// Small glowing ring showing a boot's Breath.
class BreathRing extends StatelessWidget {
  const BreathRing({super.key, required this.breath, required this.tank});

  final double breath;
  final int tank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final share = (breath / tank).clamp(0.0, 1.0);
    return Semantics(
      label:
          '${l.breath} ${l.breathValue(formatNumber(context, breath), tank)}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xCC14110F),
          boxShadow: [
            BoxShadow(
              color: TreadColors.breath.withValues(alpha: 0.55 * share),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: CircularProgressIndicator(
                value: share,
                strokeWidth: 4,
                color: TreadColors.breath,
                backgroundColor: TreadColors.panel,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.air, size: 14, color: TreadColors.breath),
                  Text(
                    formatNumber(context, breath.floorToDouble()),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
