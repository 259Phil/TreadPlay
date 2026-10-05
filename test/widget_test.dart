import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/domain/breath.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/market.dart';
import 'package:treadplay/features/legal/legal_screen.dart';
import 'package:treadplay/state/providers.dart';
import 'package:treadplay/widgets/companion_card.dart';

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
    expect(find.text('Heute 0 km'), findsOneWidget);
    expect(find.text('Los'), findsOneWidget);
  });

  testWidgets('a run earns LP and shows the summary', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();
    expect(find.text('Movement and health'), findsOneWidget);
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(find.text('Movement and health'), findsNothing);

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
    expect(find.text('Not found yet'), findsNothing);
    expect(find.text('COMMON'), findsOneWidget);
    expect(find.text('RARE'), findsOneWidget);

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

  testWidgets('taking Gilt along with an empty bar does not refill it', (
    tester,
  ) async {
    final start = GameData.initial(t0);
    final gilt = Companion.fresh(
      id: 'gilt-1',
      speciesId: 'gilt',
      rarity: Rarity.legendary,
    );
    final game = start.copyWith(
      companions: [...start.companions, gilt],
      breath: Breath(points: 0, updatedAt: t0),
    );
    await pumpApp(
      tester,
      saved: {'flutter.game.v2': jsonEncode(game.toJson())},
    );
    expect(find.text('0/6'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    container.read(gameProvider.notifier).takeAlong('gilt-1');
    await tester.pumpAndSettle();
    expect(find.text('0/12'), findsOneWidget);
    expect(find.text('12/12'), findsNothing);
    expect(container.read(gameProvider).breath.points, 0);
    expect(container.read(gameRepositoryProvider).loadGame()!.breath.points, 0);
  });

  group('market', () {
    final offer = Companion.rolled(
      id: 'offer-1',
      speciesId: 'gilt',
      rarity: Rarity.rare,
      random: Random(3),
    );
    final market = Market(
      nextDriftAt: t0.add(const Duration(hours: 8)),
      drift: const {},
      offers: [offer],
    );
    final price = market.priceOf(offer);

    Future<void> openMarket(WidgetTester tester, GameData game) async {
      await pumpApp(
        tester,
        saved: {'flutter.game.v2': jsonEncode(game.toJson())},
      );
      await tester.tap(find.widgetWithText(NavigationDestination, 'Market'));
      await tester.pumpAndSettle();
    }

    ButtonStyleButton tradeButton(WidgetTester tester, String label) =>
        tester.widget<ButtonStyleButton>(
          find.ancestor(
            of: find.textContaining(label),
            matching: find.bySubtype<ButtonStyleButton>(),
          ),
        );

    void expectNoCountdown() {
      final clock = RegExp(
        r'\d\s*(h|min|Std|Stunden?|hours?)\b|\d:\d\d',
        caseSensitive: false,
      );
      final texts = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data ?? '')
          .where(clock.hasMatch);
      expect(texts, isEmpty);
    }

    testWidgets('fresh players see offers but cannot sell Pebble', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Market'));
      await tester.pumpAndSettle();
      expect(find.text('Shelf 1/12'), findsOneWidget);
      expect(find.byType(CompanionCard), findsNWidgets(Market.offerCount));
      expect(
        find.textContaining(RegExp(r'^(Moss|Brook|Gale) · [\d,]+ LP$')),
        findsWidgets,
      );
      expectNoCountdown();

      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();
      expect(find.text('Pebble'), findsOneWidget);
      await tester.tap(find.text('Pebble'));
      await tester.pumpAndSettle();
      expect(
        find.text('Pebble stays until a second companion joins your shelf.'),
        findsOneWidget,
      );
      expect(tradeButton(tester, 'Sell ·').onPressed, isNull);
      expectNoCountdown();
    });

    testWidgets('buying puts the offer on the shelf and spends LP', (
      tester,
    ) async {
      final game = GameData.initial(t0).copyWith(lp: price + 3, market: market);
      await openMarket(tester, game);
      await tester.tap(find.byKey(const ValueKey('offer-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Buy ·'));
      await tester.pumpAndSettle();
      expect(find.text('Shelf 2/12'), findsOneWidget);
      expect(
        find.text('All offers are gone. New ones arrive later.'),
        findsOneWidget,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      final saved = container.read(gameRepositoryProvider).loadGame()!;
      expect(saved.lp, 3);
      expect(saved.companions.map((c) => c.id), ['pebble-1', 'offer-1']);
      expect(saved.companions.last.stride, offer.stride);

      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pebble'));
      await tester.pumpAndSettle();
      expect(find.text('Afterwards Gilt goes along with you.'), findsOneWidget);
      expect(tradeButton(tester, 'Sell ·').onPressed, isNotNull);
    });

    testWidgets('a full shelf of 12 blocks buying', (tester) async {
      final start = GameData.initial(t0);
      final game = start.copyWith(
        lp: 1e6,
        market: market,
        companions: [
          ...start.companions,
          for (var i = 1; i < 12; i++)
            Companion.fresh(
              id: 'vine-$i',
              speciesId: 'vine',
              rarity: Rarity.common,
            ),
        ],
      );
      await openMarket(tester, game);
      expect(find.text('Shelf 12/12'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('offer-1')));
      await tester.pumpAndSettle();
      expect(
        find.text('Your shelf is full (12/12). Sell a companion first.'),
        findsOneWidget,
      );
      expect(tradeButton(tester, 'Buy ·').onPressed, isNull);
      expectNoCountdown();
    });

    testWidgets('a worn companion cannot be sold', (tester) async {
      final start = GameData.initial(t0);
      final worn = Companion.fresh(
        id: 'dune-1',
        speciesId: 'dune',
        rarity: Rarity.rare,
      ).copyWith(spirit: 80);
      await openMarket(
        tester,
        start.copyWith(market: market, companions: [...start.companions, worn]),
      );
      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dune'));
      await tester.pumpAndSettle();
      expect(find.text('Trading only at 100 % Spirit.'), findsOneWidget);
      expect(tradeButton(tester, 'Sell ·').onPressed, isNull);
    });
  });

  group('legal', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

    testWidgets('denying the movement notice starts no run and earns no LP', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(find.text('Read the privacy policy'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      final container = containerOf(tester);
      expect(
        container.read(settingsProvider).movementAccess,
        MovementAccess.denied,
      );
      expect(container.read(runControllerProvider), isNull);
      expect(container.read(runControllerProvider.notifier).start(), isFalse);
      expect(container.read(gameProvider).lp, 0);
      expect(find.text('Pebble'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Movement access is off. Runs earn no LP until you allow it.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the notice links to the full privacy policy', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read the privacy policy'));
      await tester.pumpAndSettle();
      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('3. Movement and health'), findsOneWidget);
    });

    testWidgets('settings open full privacy and terms in EN and DE', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
      await tester.pumpAndSettle();
      Future<void> tapRow(String text, {double delta = 200}) async {
        await tester.scrollUntilVisible(
          find.text(text),
          delta,
          scrollable: find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await Scrollable.ensureVisible(
          tester.element(find.text(text)),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      expect(find.text('Off: real movement earns no LP.'), findsOneWidget);

      await tapRow('Privacy');
      expect(find.text('1. Controller'), findsOneWidget);
      expect(
        find.textContaining(
          '[Contact person · address · e-mail — fill in before publishing]',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tapRow('Terms of use');
      expect(find.text('2. What the app is'), findsOneWidget);
      expect(find.textContaining('[address · e-mail]'), findsOneWidget);
      expect(
        find.textContaining(RegExp('crypto', caseSensitive: false)),
        findsNothing,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tapRow('Deutsch', delta: -200);
      await tapRow('Nutzungsbedingungen');
      expect(find.text('2. Was die App ist'), findsOneWidget);
      expect(find.textContaining('[Anschrift · E-Mail]'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tapRow('Datenschutz');
      expect(find.text('1. Verantwortlicher'), findsOneWidget);
    });

    testWidgets('movement access can be switched in settings', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Movement access'));
      await tester.pumpAndSettle();
      expect(
        find.text('Real movement earns LP. Readings stay on this device.'),
        findsOneWidget,
      );
      final saved = containerOf(
        tester,
      ).read(gameRepositoryProvider).loadSettings();
      expect(saved.movementAccess, MovementAccess.allowed);
    });
  });
}
