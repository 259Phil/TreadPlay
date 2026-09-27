import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/run/run_screen.dart';
import 'features/run/summary_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shelf/coming_soon_screen.dart';
import 'l10n/app_localizations.dart';
import 'widgets/app_shell.dart';

class AppRoutes {
  static const home = '/home';
  static const garage = '/garage';
  static const forge = '/forge';
  static const market = '/market';
  static const settings = '/settings';
  static const run = '/run';
  static const summary = '/summary';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _branch(AppRoutes.home, (_) => const HomeScreen()),
          _branch(
            AppRoutes.garage,
            (l) => ComingSoonScreen(
              title: l.tabGarage,
              teaser: l.garageTeaser,
              icon: Icons.shelves,
            ),
          ),
          _branch(
            AppRoutes.forge,
            (l) => ComingSoonScreen(
              title: l.tabForge,
              teaser: l.forgeTeaser,
              icon: Icons.local_fire_department,
            ),
          ),
          _branch(
            AppRoutes.market,
            (l) => ComingSoonScreen(
              title: l.tabMarket,
              teaser: l.marketTeaser,
              icon: Icons.storefront,
            ),
          ),
          _branch(AppRoutes.settings, (_) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: AppRoutes.run, builder: (_, _) => const RunScreen()),
      GoRoute(
        path: AppRoutes.summary,
        builder: (_, _) => const SummaryScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(
  String path,
  Widget Function(AppLocalizations l) screen,
) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, _) => screen(AppLocalizations.of(context)),
    ),
  ],
);
