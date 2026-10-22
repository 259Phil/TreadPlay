import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/totals.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/features/wanderweg/wanderweg_screen.dart';
import 'package:treadplay/state/providers.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  Future<ProviderContainer> pumpApp(WidgetTester tester, GameData game) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'flutter.game.v2': jsonEncode(game.toJson()),
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(() => t0),
          randomProvider.overrideWithValue(Random(42)),
          movementSourceProvider.overrideWith(
            (ref) => SimulatedMovementSource(
              tick: const Duration(milliseconds: 100),
            ),
          ),
        ],
        child: const TreadplayApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(TreadplayApp)));
  }

  GameData at(double km, {int reached = 0, int seen = -1, int forged = 0}) =>
      GameData.initial(t0).copyWith(
        totals: Totals(distanceM: km * 1000, runs: 3, forgeUses: forged),
        wanderweg: WanderwegProgress(
          reachedAt: List.filled(reached, t0),
          seen: seen < 0 ? reached : seen,
        ),
      );

  testWidgets('home chip opens the trail of a new game', (tester) async {
    await pumpApp(tester, GameData.initial(t0));
    expect(find.text('0/19'), findsOneWidget);
    expect(find.byKey(const Key('waymark-bubble')), findsNothing);
    await tester.tap(find.byKey(const Key('trail-chip')));
    await tester.pumpAndSettle();
    expect(find.byType(WanderwegScreen), findsOneWidget);
    expect(find.text('THE TRAIL BEGINS'), findsOneWidget);
    expect(find.text('NEXT WAYMARK 1'), findsOneWidget);
    expect(find.text('0.0 / 0.7 km'), findsOneWidget);
    expect(find.byKey(const Key('trail-companion')), findsOneWidget);
  });

  testWidgets('trail around waymark 11 shows the next tasks', (tester) async {
    await pumpApp(tester, at(45.1, reached: 11, forged: 4));
    await tester.tap(find.byKey(const Key('trail-chip')));
    await tester.pumpAndSettle();
    expect(find.text('LAST AT WAYMARK 11'), findsOneWidget);
    expect(
      find.text('“Steam and cogs. Even machines only learn on the way.”'),
      findsNothing,
    );
    final panel = find.byKey(const Key('trail-panel'));
    expect(
      find.descendant(of: panel, matching: find.text('NEXT WAYMARK 12')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('Forging L4')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('4 / 5')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('later')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('waymark-12')), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Waymark 12 · 48.6 km'), findsOneWidget);
  });

  testWidgets('a reached waymark shows a quiet bubble on Home', (tester) async {
    final container = await pumpApp(tester, at(7, reached: 4, seen: 3));
    expect(find.text('Waymark 4 reached · Copper pouch'), findsOneWidget);
    expect(find.text('4/19'), findsOneWidget);
    await tester.tap(find.byKey(const Key('waymark-bubble-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('waymark-bubble')), findsNothing);
    expect(container.read(gameProvider).wanderweg.unseen, 0);
  });

  testWidgets('a run that reaches a waymark brings up the bubble', (
    tester,
  ) async {
    final container = await pumpApp(tester, at(0.5));
    container
        .read(gameProvider.notifier)
        .completeRun(
          RunSummary(
            companionId: Companion.pebble().id,
            startedAt: t0,
            duration: const Duration(minutes: 5),
            distanceM: 300,
            steps: 0,
            lp: 1,
            breathUsed: 1,
            valid: true,
          ),
          breathLeft: 5,
        );
    await tester.pumpAndSettle();
    expect(container.read(gameProvider).wanderweg.reached, 1);
    expect(find.text('Waymark 1 reached · Brown pouch'), findsOneWidget);
  });
}
