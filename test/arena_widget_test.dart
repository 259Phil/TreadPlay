import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/features/arena/arena_look.dart';
import 'package:treadplay/features/forge/forge_screen.dart';
import 'package:treadplay/state/providers.dart';

/// Taps a slot high up: in perspective the nearer row overlaps the feet of
/// the row in front of it.
Future<void> tapSlot(WidgetTester tester, int slot) {
  final f = find.byKey(Key('arena-slot-$slot'));
  return tester.tapAt(
    tester.getTopLeft(f) + Offset(tester.getSize(f).width / 2, 30),
  );
}

void main() {
  setUpAll(() => forgeAmbientMotion = false);

  Future<void> openArena(WidgetTester tester) async {
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
          randomProvider.overrideWithValue(Random(7)),
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
    await tester.tap(find.widgetWithText(NavigationDestination, 'Arena'));
    await tester.pumpAndSettle();
  }

  testWidgets('the starter stands in front against a practice opponent', (
    tester,
  ) async {
    await openArena(tester);
    expect(find.textContaining('PRACTICE OPPONENT'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('arena-slot-0')),
        matching: find.byType(ArenaFigure),
      ),
      findsOneWidget,
    );
    expect(find.byType(EmptySlot), findsNWidgets(4));
    // Mirrored shape: one rival.
    expect(find.byType(ArenaFigure), findsNWidgets(2));
  });

  testWidgets('without anyone in front the battle cannot start', (
    tester,
  ) async {
    await openArena(tester);
    await tapSlot(tester, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('arena-remove')));
    await tester.pumpAndSettle();
    expect(find.byType(EmptySlot), findsNWidgets(5));
    expect(find.text('Put at least one companion in front.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('arena-start')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('arena-skip')), findsNothing);

    await tapSlot(tester, 3);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('arena-pick-pebble-1')).first);
    await tester.pumpAndSettle();
    expect(find.byType(EmptySlot), findsNWidgets(4));
    expect(find.text('Put at least one companion in front.'), findsOneWidget);
  });

  testWidgets('a battle plays out with rounds and ends with a result', (
    tester,
  ) async {
    await openArena(tester);
    await tester.tap(find.byKey(const Key('arena-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ROUND 1'), findsOneWidget);
    // Let the page transition finish.
    await tester.pump(const Duration(seconds: 1));
    var popups = 0;
    for (var i = 0; i < 60 && popups == 0; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      popups = find.byKey(const Key('arena-popup')).evaluate().length;
    }
    expect(popups, greaterThan(0));

    await tester.tap(find.byKey(const Key('arena-skip')));
    await tester.pump();
    expect(find.byKey(const Key('arena-result')), findsOneWidget);
    expect(
      find.text('Victory!').evaluate().length +
          find.text('Defeat').evaluate().length,
      1,
    );

    await tester.tap(find.byKey(const Key('arena-again')));
    await tester.pump();
    expect(find.byKey(const Key('arena-result')), findsNothing);
    await tester.tap(find.byKey(const Key('arena-skip')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('arena-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('arena-start')), findsOneWidget);
  });
}
