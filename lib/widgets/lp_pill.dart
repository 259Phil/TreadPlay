import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'format.dart';

/// The LP balance as a small brass-rimmed pill in a screen header.
class LpPill extends StatelessWidget {
  const LpPill({super.key, required this.lp});

  final double lp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TreadColors.plate,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A3328)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(
          l.lpAmount(formatNumber(context, lp, pattern: '0.0')),
          style: const TextStyle(
            color: TreadColors.brass,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// Header actions with the LP pill, right-aligned in an app bar.
List<Widget> lpActions(double lp) => [
  Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Center(child: LpPill(lp: lp)),
  ),
];
