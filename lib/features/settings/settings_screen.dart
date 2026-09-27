import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
          section(l.settingsHealthTitle, l.settingsHealthBody),
          section(l.settingsPrivacyTitle, l.settingsPrivacyBody),
          section(l.settingsCredits, l.creditsArtwork),
        ],
      ),
    );
  }
}
