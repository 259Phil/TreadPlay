import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/game_data.dart';

import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import 'save_game_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final totals = ref.watch(gameProvider.select((g) => g.totals));

    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ListTile(
            title: Text(l.settingsLanguage),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'de', label: Text('Deutsch')),
              ],
              selected: {settings.localeCode},
              onSelectionChanged: (s) => notifier.setLocale(s.first),
            ),
          ),
          SwitchListTile(
            title: Text(l.settingsKaching),
            value: settings.kaching,
            onChanged: notifier.setKaching,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history, color: TreadColors.brass),
            title: Text(l.settingsHistory),
            subtitle: Text(
              l.historyTotals(
                formatKm(context, totals.distanceM),
                totals.runs,
                formatNumber(context, totals.lp),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.history),
          ),
          const Divider(),
          section(l.settingsHealthTitle, l.settingsHealthBody),
          SwitchListTile(
            title: Text(l.settingsMovement),
            subtitle: Text(
              settings.movementAccess == MovementAccess.allowed
                  ? l.settingsMovementOn
                  : l.settingsMovementOff,
            ),
            value: settings.movementAccess == MovementAccess.allowed,
            onChanged: (on) => notifier.setMovementAccess(
              on ? MovementAccess.allowed : MovementAccess.denied,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l.settingsPrivacyTitle),
            subtitle: Text(l.settingsPrivacyBody),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.privacy),
          ),
          ListTile(
            title: Text(l.settingsTerms),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.terms),
          ),
          const Divider(),
          const SaveGameSection(),
          const Divider(),
          section(l.settingsCredits, l.creditsArtwork),
        ],
      ),
    );
  }
}
