import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/forge/forge_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/legal/legal_screen.dart';
import 'features/legal/legal_texts.dart';
import 'features/market/market_screen.dart';
import 'features/run/run_screen.dart';
import 'features/pouches/pouch_screen.dart';
import 'features/run/summary_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shelf/shelf_screen.dart';
import 'features/wanderweg/wanderweg_screen.dart';
import 'l10n/app_localizations.dart';
import 'ui/skin.dart';
import 'widgets/app_shell.dart';

class AppRoutes {
  static const home = '/home';
  static const shelf = '/shelf';
  static const forge = '/forge';
  static const market = '/market';
  static const settings = '/settings';
  static const run = '/run';
  static const summary = '/summary';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const history = '/history';
  static const wanderweg = '/wanderweg';
  static const pouches = '/pouches';
  static String historyDetail(int index) => '$history/$index';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _branch(AppRoutes.home, (_) => const HomeScreen()),
          _branch(AppRoutes.shelf, (_) => const ShelfScreen()),
          _branch(AppRoutes.forge, (_) => const ForgeScreen()),
          _branch(AppRoutes.market, (_) => const MarketScreen()),
          _branch(AppRoutes.settings, (_) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.run,
        builder: (_, _) => const SkinRoute(child: RunScreen()),
      ),
      GoRoute(
        path: AppRoutes.summary,
        builder: (_, _) => const SkinRoute(child: SummaryScreen()),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, _) => const SkinRoute(child: HistoryScreen()),
        routes: [
          GoRoute(
            path: ':index',
            builder: (_, state) => SkinRoute(
              child: RunDetailScreen(
                index: int.tryParse(state.pathParameters['index'] ?? '') ?? -1,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.wanderweg,
        builder: (_, _) => const WanderwegScreen(),
      ),
      GoRoute(path: AppRoutes.pouches, builder: (_, _) => const PouchScreen()),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (_, _) =>
            const SkinRoute(child: LegalScreen(doc: LegalDoc.privacy)),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (_, _) =>
            const SkinRoute(child: LegalScreen(doc: LegalDoc.terms)),
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
