import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/state/providers.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> saved = const {},
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(saved);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(() => t0),
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
  }

  testWidgets('home shows Pebble and switching to German works', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Pebble'), findsOneWidget);
    expect(find.text('6/6'), findsOneWidget);
    expect(find.text('Start'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(find.text('Einstellungen'), findsWidgets);
    expect(find.text('Puste'), findsNothing);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(
      find.text('Noch keine Läufe. Nimm Pebble mit und los!'),
      findsOneWidget,
    );
    expect(find.text('Los'), findsOneWidget);
  });

  testWidgets('a run earns LP and shows the summary', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    container.read(runControllerProvider.notifier)
      ..setDemoSpeed(4.5)
      ..setTimeLapse(true);
    // 100 ms ticks × 10 = 1 s simulated per tick, ~1.25 m each → 250 m ≈ 200 ticks.
    for (var i = 0; i < 220; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(container.read(runControllerProvider)!.engine.blocks, 1);

    await tester.scrollUntilVisible(find.text('Stop'), 200);
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect(find.text('Run complete'), findsOneWidget);
    expect(find.text('2.5 LP'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last run: '), findsOneWidget);
    expect(container.read(gameProvider).lp, 2.5);
  });

  testWidgets('shelf cards are drawn by Flutter and take along works', (
    tester,
  ) async {
    final start = GameData.initial(t0);
    final dune = Companion.fresh(
      t0,
      id: 'dune-1',
      speciesId: 'dune',
      rarity: Rarity.rare,
    );
    final game = start.copyWith(companions: [...start.companions, dune]);
    await pumpApp(
      tester,
      saved: {'flutter.game.v2': jsonEncode(game.toJson())},
    );
    await tester.tap(find.widgetWithText(NavigationDestination, 'Shelf'));
    await tester.pumpAndSettle();
    expect(find.text('Pebble'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Gale · Lv 1'), findsOneWidget);
    expect(find.text('Along'), findsOneWidget);
    expect(find.text('Not found yet'), findsWidgets);

    await tester.tap(find.text('Dune'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take along'));
    await tester.pumpAndSettle();
    expect(find.text('Along'), findsWidgets);
    await tester.tapAt(const Offset(20, 100));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
    await tester.pumpAndSettle();
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Pebble'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(gameProvider).activeCompanionId, 'dune-1');
    expect(
      container.read(gameRepositoryProvider).loadGame()!.activeCompanionId,
      'dune-1',
    );
  });
}
