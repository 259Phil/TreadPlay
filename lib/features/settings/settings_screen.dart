import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ui/skin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/game_data.dart';
import '../../domain/wanderweg.dart';

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
    final trail = ref.watch(gameProvider.select((g) => g.wanderweg));

    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TreadSkin.of(context).style == TreadStyle.leather
                ? TreadSkin.of(context).display(16, color: TreadColors.brass)
                : theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: TreadSkin.of(context).canvas,
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
            leading: skinIcon(
              context,
              Icons.history,
              SkinIcons.logbook,
              size: 28,
              color: TreadColors.brass,
            ),
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
          ListTile(
            title: Text(l.settingsFeedback),
            subtitle: const Text(feedbackEmail),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _sendFeedback(context, l.settingsFeedbackCopied),
          ),
          const Divider(),
          ListTile(
            key: const Key('settings-trail'),
            leading: skinIcon(
              context,
              Icons.signpost_outlined,
              SkinIcons.waymark,
              size: 28,
              color: TreadColors.brass,
            ),
            title: Text(l.wwTitle),
            subtitle: Text(switch (trail.next) {
              final next? => l.wwSettingsSub(
                trail.reached,
                waymarks.length,
                formatNumber(context, next.km, pattern: '0.0'),
              ),
              null => l.wwAllReached(waymarks.length),
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.wanderweg),
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

const String feedbackEmail = 'kontakt.bender.interactive@gmail.com';

Future<void> _sendFeedback(BuildContext context, String copiedMessage) async {
  final messenger = ScaffoldMessenger.of(context);
  final version = await PackageInfo.fromPlatform()
      .then((info) => ' – v${info.version}')
      .catchError((_) => '');
  final platform = kIsWeb
      ? 'Web'
      : defaultTargetPlatform == TargetPlatform.iOS
      ? 'iOS'
      : 'Android';
  final subject = 'TreadPlay Feedback – $platform$version';
  final opened = await launchUrl(
    Uri(
      scheme: 'mailto',
      path: feedbackEmail,
      query: 'subject=${Uri.encodeComponent(subject)}',
    ),
  ).catchError((_) => false);
  if (opened) return;
  await Clipboard.setData(const ClipboardData(text: feedbackEmail));
  messenger.showSnackBar(SnackBar(content: Text(copiedMessage)));
}
