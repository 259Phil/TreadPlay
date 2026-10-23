import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../ui/skin.dart';
import 'format.dart';

/// The LP balance as a small brass-rimmed pill in a screen header.
class LpPill extends StatelessWidget {
  const LpPill({super.key, required this.lp});

  final double lp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ResourceCounter(
      icon: const LpCoin(),
      value: l.lpAmount(formatNumber(context, lp, pattern: '0.0')),
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
