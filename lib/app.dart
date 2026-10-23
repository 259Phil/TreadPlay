import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'router.dart';
import 'state/providers.dart';
import 'theme.dart';
import 'ui/skin.dart';

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
      builder: kIsWeb ? (context, child) => _PhoneFrame(child: child) : null,
    );
  }
}

/// In a wide browser window the app keeps its phone layout, centred.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  static const maxWidth = 430.0;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= maxWidth) return child ?? const SizedBox();
    final skin = TreadSkin.of(context);
    final column = Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: skin.backdrop == null
              ? null
              : const [
                  BoxShadow(
                    color: Color(0xCC000000),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: SizedBox(
          width: maxWidth,
          child: MediaQuery(
            data: media.copyWith(size: Size(maxWidth, media.size.height)),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
    if (skin.backdrop == null) {
      return ColoredBox(color: skin.base, child: column);
    }
    // Style C: the painted leather shows around the phone column, dimmed so
    // the column stays the focus.
    return SkinBackdrop(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0x660A0604)),
          column,
        ],
      ),
    );
  }
}
