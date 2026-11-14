import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/features/forge/forge_screen.dart';
import 'package:treadplay/features/settings/settings_screen.dart';
import 'package:treadplay/state/providers.dart';

void main() {
  setUpAll(() => forgeAmbientMotion = false);
  final t0 = DateTime(2026, 1, 1, 8);

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
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
  }

  testWidgets('Settings offers Telegram feedback next to email in EN and DE', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    final scroll = find.byType(Scrollable);
    expect(scroll, findsWidgets);
    final state = tester.state<ScrollableState>(scroll.last);
    if (state.position.maxScrollExtent > 0) {
      state.position.jumpTo(state.position.maxScrollExtent.clamp(0, 600));
      await tester.pump();
    }
    expect(find.text('Send feedback'), findsOneWidget);
    expect(find.text('Send feedback on Telegram'), findsOneWidget);
    expect(find.text(feedbackEmail), findsOneWidget);
    expect(find.text(telegramHandle), findsOneWidget);

    state.position.jumpTo(0);
    await tester.pump();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    if (state.position.maxScrollExtent > 0) {
      state.position.jumpTo(state.position.maxScrollExtent.clamp(0, 600));
      await tester.pump();
    }
    expect(find.text('Feedback senden'), findsOneWidget);
    expect(find.text('Feedback per Telegram senden'), findsOneWidget);
    expect(find.text(telegramHandle), findsOneWidget);
  });
}
