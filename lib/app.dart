import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'router.dart';
import 'state/providers.dart';
import 'theme.dart';

class TreadplayApp extends ConsumerWidget {
  const TreadplayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(settingsProvider.select((s) => s.localeCode));
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
