import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/domain/salve.dart';
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

  ButtonStyleButton button(WidgetTester tester, String key) =>
      tester.widget<ButtonStyleButton>(find.byKey(ValueKey(key)));

  Future<void> openDetail(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Den'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mossik').first);
    await tester.pumpAndSettle();
  }

  testWidgets('the detail shows XP and levels up once XP and LP are there', (
    tester,
  ) async {
    final g0 = GameData.initial(t0).copyWith(lp: 20);
    await pumpApp(
      tester,
      g0.replaceCompanion(g0.activeCompanion.copyWith(xp: 4)),
    );
    await openDetail(tester);
    expect(find.text('XP 4 / 6'), findsOneWidget);
    expect(find.text('2 XP to walk'), findsOneWidget);
    expect(button(tester, 'level-up').onPressed, isNull);
    await tester.pumpWidget(const SizedBox());

    await pumpApp(
      tester,
      g0.replaceCompanion(g0.activeCompanion.copyWith(xp: 7)),
    );
    await openDetail(tester);
    expect(find.text('Level up · 5 LP'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('level-up')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('level-up')));
    await tester.pumpAndSettle();
    expect(find.text('Mossik is level 2 now!'), findsOneWidget);
    expect(find.text('XP 1 / 12'), findsOneWidget);
  });

  testWidgets('the detail lists the recipe effects of the set seals', (
    tester,
  ) async {
    final g0 = GameData.initial(t0);
    await pumpApp(
      tester,
      g0.replaceCompanion(g0.activeCompanion.withCharm(0, 'grit+fortune@3')),
    );
    await openDetail(tester);
    expect(find.byKey(const ValueKey('recipe-effects')), findsOneWidget);
    expect(find.byKey(const ValueKey('recipe-effect-schutz')), findsOneWidget);
    expect(find.textContaining('Ward Amulet'), findsWidgets);
    await tester.pumpWidget(const SizedBox());

    await pumpApp(tester, g0);
    await openDetail(tester);
    expect(find.byKey(const ValueKey('recipe-effects')), findsNothing);
  });

  testWidgets('a salve from the Vorrat brings the Mut back', (tester) async {
    final g0 = GameData.initial(
      t0,
    ).copyWith(salves: const SalveStock({Salve.small: 2}));
    final c = await pumpApp(
      tester,
      g0.replaceCompanion(g0.activeCompanion.copyWith(spirit: 60)),
    );
    await openDetail(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('salve-open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('salve-open')));
    await tester.pumpAndSettle();
    expect(find.text('Spirit salve for Mossik'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('salve-use-small')),
        matching: find.text('Apply'),
      ),
    );
    await tester.pumpAndSettle();
    final game = c.read(gameProvider);
    expect(game.activeCompanion.spirit, 75);
    expect(game.salves.count(Salve.small), 1);
  });

  testWidgets('the Market sells salves into the Vorrat', (tester) async {
    final c = await pumpApp(
      tester,
      GameData.initial(t0).withMarket(t0, Random(1)).copyWith(lp: 100),
    );
    await tester.tap(find.widgetWithText(NavigationDestination, 'Market'));
    await tester.pumpAndSettle();
    expect(find.text('Salves'), findsOneWidget);
    await tester.tap(find.text('Salves'));
    await tester.pumpAndSettle();
    final price = c.read(gameProvider).market!.priceOfSalve(Salve.large);
    final buy = find.byKey(const ValueKey('buy-salve-large'));
    await tester.scrollUntilVisible(
      buy,
      120,
      scrollable: find.descendant(
        of: find.byKey(const Key('market-salves')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(buy);
    await tester.pumpAndSettle();
    final game = c.read(gameProvider);
    expect(game.salves.count(Salve.large), 1);
    expect(game.lp, 100 - price);
  });
}
