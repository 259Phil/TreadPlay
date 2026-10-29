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
import 'package:treadplay/features/forge/forge_screen.dart';
import 'package:treadplay/state/providers.dart';

void main() {
  setUpAll(() => forgeAmbientMotion = false);
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

  GameData withMates(int n, {double lp = 0}) {
    final g = GameData.initial(t0);
    return g.copyWith(
      lp: lp,
      companions: [
        ...g.companions,
        for (var i = 0; i < n; i++)
          Companion.fresh(id: 'c$i', speciesId: 'vine', rarity: Rarity.common),
      ],
    );
  }

  testWidgets('the den shows the bonus, the next step and buys a spot', (
    tester,
  ) async {
    final container = await pumpApp(tester, withMates(5, lp: 100));
    await tester.tap(find.widgetWithText(NavigationDestination, 'Den'));
    await tester.pumpAndSettle();
    expect(find.text('+1 Breath tank'), findsOneWidget);
    expect(
      find.text('Next step: from 10 companions +2 Breath tank (4 to go)'),
      findsOneWidget,
    );
    expect(find.text('Den 6/12 spots'), findsOneWidget);
    await tester.tap(find.byKey(const Key('shelf-buy-slot')));
    await tester.pumpAndSettle();
    expect(find.text('Buy a den spot?'), findsOneWidget);
    // Cancel keeps everything.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(gameProvider).shelfSlots, 12);
    await tester.tap(find.byKey(const Key('shelf-buy-slot')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shelf-buy-confirm')));
    await tester.pumpAndSettle();
    final game = container.read(gameProvider);
    expect(game.shelfSlots, 13);
    expect(game.lp, 40);
    expect(find.text('Den 6/13 spots'), findsOneWidget);
    expect(find.text('+1 spot · 90 LP'), findsOneWidget);
    expect(find.byKey(const Key('collector-explain')), findsNothing);
    await tester.tap(find.byKey(const Key('collector-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('collector-explain')), findsOneWidget);
    expect(find.text('6 companions with at least 50 % spirit'), findsOneWidget);
  });
}
