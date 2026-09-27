import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/state/providers.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(() => DateTime(2026, 1, 1, 8)),
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

  testWidgets('home shows Cobble and switching to German works', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Cobble'), findsOneWidget);
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
      find.text('Noch keine Läufe. Zieh Cobble an und los!'),
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
    expect(find.text('Last run'), findsOneWidget);
    expect(container.read(gameProvider).lp, 2.5);
  });

  testWidgets('garage equips another boot and Home shows it', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Garage'));
    await tester.pumpAndSettle();
    expect(find.text('Gearbuckle'), findsOneWidget);
    expect(find.text('Orbithop'), findsOneWidget);

    await tester.tap(find.text('Gearbuckle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Put on'));
    await tester.pumpAndSettle();
    expect(find.text('Wearing'), findsWidgets);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
    await tester.pumpAndSettle();
    expect(find.text('Gearbuckle'), findsOneWidget);
    expect(find.text('Cobble'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(gameProvider).activeShoeId, 'gearbuckle-1');
    expect(
      container.read(gameRepositoryProvider).loadGame()!.activeShoeId,
      'gearbuckle-1',
    );
  });
}
