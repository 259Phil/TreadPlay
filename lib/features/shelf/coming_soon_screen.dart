import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.teaser,
    required this.icon,
  });

  final String title;
  final String teaser;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: TreadColors.gold),
              const SizedBox(height: 16),
              Text(
                teaser,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(l.comingSoon, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
