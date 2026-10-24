import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/ads/rewarded_ad_service.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/domain/breath.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/forge.dart';
import 'package:treadplay/domain/market.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/features/forge/forge_screen.dart';
import 'package:treadplay/features/legal/legal_screen.dart';
import 'package:treadplay/platform/save_file_io.dart';
import 'package:treadplay/domain/totals.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/state/providers.dart';
import 'package:treadplay/widgets/companion_card.dart';

void main() {
  setUpAll(() => forgeAmbientMotion = false);
  final t0 = DateTime(2026, 1, 1, 8);

  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> saved = const {},
    RewardedAdService? ads,
    SaveFileIo? files,
    Random? random,
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
          randomProvider.overrideWithValue(random ?? Random(42)),
          if (ads != null) rewardedAdServiceProvider.overrideWithValue(ads),
          if (files != null) saveFileIoProvider.overrideWithValue(files),
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

  testWidgets('home shows Mossik and switching to German works', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Mossik'), findsOneWidget);
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

  testWidgets('no video button without a video service (Web, tests)', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byKey(const Key('video-button')), findsNothing);
  });

  testWidgets('video button pays 3 shrinking rewards, then dims', (
    tester,
  ) async {
    await pumpApp(tester, ads: FakeRewardedAdService(delay: Duration.zero));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(find.text('3'), findsOneWidget);
    for (final lp in [2.5, 4.0, 5.0]) {
      await tester.tap(find.byKey(const Key('video-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch'));
      await tester.pumpAndSettle();
      expect(container.read(gameProvider).lp, lp);
    }
    expect(find.text('3'), findsNothing);
    await tester.tap(find.byKey(const Key('video-button')));
    await tester.pumpAndSettle();
    expect(find.text('Watch'), findsNothing);
    expect(
      find.text("Today's videos are used up. New ones tomorrow."),
      findsOneWidget,
    );
    expect(container.read(gameProvider).lp, 5);
  });

  Future<void> openSaveTile(WidgetTester tester, String key) async {
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    final tile = find.byKey(Key(key));
    await tester.scrollUntilVisible(tile, 200);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('save game export and import roundtrip in settings', (
    tester,
  ) async {
    final files = _FakeSaveFiles();
    final rich = GameData.initial(
      t0,
    ).copyWith(lp: 77, totals: const Totals(distanceM: 5000, lp: 77, runs: 3));
    await pumpApp(
      tester,
      saved: {'game.v2': jsonEncode(rich.toJson())},
      files: files,
    );

    await openSaveTile(tester, 'save-export');
    expect(files.delivered, isNotNull);
    expect(files.name, endsWith('.json'));
    expect(find.text('Save game exported.'), findsOneWidget);
    expect(find.textContaining('Last export:'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    container.read(gameProvider.notifier).wipe();
    await tester.pumpAndSettle();
    expect(container.read(gameProvider).lp, 0);

    files.toPick = files.delivered;
    await tester.tap(find.byKey(const Key('save-import')));
    await tester.pumpAndSettle();
    expect(find.text('Import save game?'), findsOneWidget);
    expect(find.textContaining('1 companions, 77 LP'), findsOneWidget);
    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(find.text('Save game imported.'), findsOneWidget);
    expect(container.read(gameProvider).lp, 77);
    expect(container.read(gameProvider).totals.runs, 3);
  });

  testWidgets('an invalid save file is rejected and nothing changes', (
    tester,
  ) async {
    final files = _FakeSaveFiles()
      ..toPick = Uint8List.fromList(utf8.encode('{"format":"other"}'));
    final rich = GameData.initial(t0).copyWith(lp: 42);
    await pumpApp(
      tester,
      saved: {'game.v2': jsonEncode(rich.toJson())},
      files: files,
    );
    await openSaveTile(tester, 'save-import');
    expect(
      find.text('This file is not a Treadplay save game.'),
      findsOneWidget,
    );
    expect(find.text('Import save game?'), findsNothing);

    files.toPick = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'format': 'treadplay-save',
          'version': 99,
          'game': rich.toJson(),
        }),
      ),
    );
    await tester.tap(find.byKey(const Key('save-import')));
    await tester.pumpAndSettle();
    expect(find.textContaining('newer Treadplay version'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(gameProvider).lp, 42);
  });

  testWidgets('delete save game asks twice and resets to Mossik', (
    tester,
  ) async {
    final rich = GameData.initial(t0).copyWith(
      lp: 500,
      totals: const Totals(distanceM: 9000, lp: 500, runs: 9),
      runs: [
        RunSummary(
          companionId: 'pebble-1',
          startedAt: t0,
          duration: const Duration(minutes: 20),
          distanceM: 2000,
          steps: 2600,
          lp: 15,
          breathUsed: 6,
          valid: true,
        ),
      ],
    );
    final files = _FakeSaveFiles(copies: 2);
    await pumpApp(
      tester,
      saved: {'game.v2': jsonEncode(rich.toJson())},
      files: files,
    );
    await openSaveTile(tester, 'save-delete');
    expect(find.text('Delete save game?'), findsOneWidget);
    expect(find.textContaining('export copies the app kept'), findsOneWidget);
    expect(files.deleteCalls, 0);
    await tester.tap(find.text('Delete save game').last);
    await tester.pumpAndSettle();
    expect(find.text('Really delete everything?'), findsOneWidget);
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();
    expect(
      find.text('Save game deleted. Fresh start with Mossik.'),
      findsOneWidget,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final g = container.read(gameProvider);
    expect(g.lp, 0);
    expect(g.runs, isEmpty);
    expect(g.totals.runs, 0);
    expect(g.totals.distanceM, 0);
    expect(g.companions.single.speciesId, 'pebble');
    expect(g.videos.watched, 0);
    final stored = container.read(gameRepositoryProvider).loadGame();
    expect(stored?.totals.runs, 0);
    expect(files.deleteCalls, 1);
    expect(files.copies, 0);
  });

  testWidgets('delete save game works when the app holds no copy', (
    tester,
  ) async {
    final files = _FakeSaveFiles();
    final rich = GameData.initial(t0).copyWith(lp: 500);
    await pumpApp(
      tester,
      saved: {'game.v2': jsonEncode(rich.toJson())},
      files: files,
    );
    await openSaveTile(tester, 'save-delete');
    await tester.tap(find.text('Delete save game').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();
    expect(
      find.text('Save game deleted. Fresh start with Mossik.'),
      findsOneWidget,
    );
    expect(files.deleteCalls, 1);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(gameProvider).lp, 0);
  });

  testWidgets('cancelling the first delete question keeps everything', (
    tester,
  ) async {
    final rich = GameData.initial(t0).copyWith(lp: 500);
    await pumpApp(tester, saved: {'game.v2': jsonEncode(rich.toJson())});
    await openSaveTile(tester, 'save-delete');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(gameProvider).lp, 500);
  });

  testWidgets('run history lists runs, shows details and can be erased', (
    tester,
  ) async {
    final runs = [
      RunSummary(
        companionId: 'pebble-1',
        startedAt: t0,
        duration: const Duration(minutes: 20),
        distanceM: 2000,
        steps: 2600,
        lp: 15,
        breathUsed: 6,
        valid: true,
        sweetSpotShare: 0.8,
      ),
      RunSummary(
        companionId: 'pebble-1',
        startedAt: t0.subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 5),
        distanceM: 500,
        steps: 650,
        lp: 5,
        breathUsed: 2,
        valid: true,
      ),
    ];
    final json = GameData.initial(t0).copyWith(runs: runs).toJson()
      ..remove('totals');
    await pumpApp(tester, saved: {'game.v2': jsonEncode(json)});

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run history'));
    await tester.pumpAndSettle();
    expect(find.text('2.50 km · 2 runs · 20 LP in total'), findsOneWidget);
    expect(find.text('15 LP'), findsOneWidget);

    await tester.tap(find.text('15 LP'));
    await tester.pumpAndSettle();
    expect(find.text('In sweet spot'), findsOneWidget);
    expect(find.text('80 %'), findsOneWidget);
    expect(find.text('Breath used'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('5 LP'));
    await tester.pumpAndSettle();
    expect(find.text('–'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Erase local record'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Erase local record').last);
    await tester.pumpAndSettle();
    expect(find.text('15 LP'), findsNothing);
    expect(find.text('2.50 km · 2 runs · 20 LP in total'), findsOneWidget);
  });

  testWidgets('a run earns LP and shows the summary', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();
    expect(find.text('Movement and location'), findsOneWidget);
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(find.text('Movement and location'), findsNothing);

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
    expect(find.text('Pace'), findsOneWidget);
    expect(find.textContaining(' /km'), findsOneWidget);
    expect(find.text('Breath left'), findsOneWidget);
    expect(find.text('5 / 6'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last run: '), findsOneWidget);
    expect(container.read(gameProvider).lp, 2.5);
  });

  testWidgets('den cards are drawn by Flutter and take along works', (
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
    await tester.tap(find.widgetWithText(NavigationDestination, 'Den'));
    await tester.pumpAndSettle();
    expect(find.text('Mossik'), findsOneWidget);
    expect(find.text('Sahri'), findsOneWidget);
    expect(find.text('GALLOP 11 km/h'), findsOneWidget);
    // Next to the Along badge the tag shows only the speed.
    expect(find.text('4.5 km/h'), findsOneWidget);
    expect(find.text('Along'), findsOneWidget);
    expect(find.text('Not found yet'), findsNothing);
    expect(find.text('COMMON'), findsOneWidget);
    expect(find.text('RARE'), findsOneWidget);

    await tester.tap(find.text('Sahri'));
    await tester.pumpAndSettle();
    expect(
      find.text('Sand in its ears, wanderlust in its eyes.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Take along'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take along'));
    await tester.pumpAndSettle();
    expect(find.text('Along'), findsWidgets);
    await tester.tapAt(const Offset(20, 100));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
    await tester.pumpAndSettle();
    expect(find.text('Sahri'), findsOneWidget);
    expect(find.text('Mossik'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(gameProvider).activeCompanionId, 'dune-1');
    expect(
      container.read(gameRepositoryProvider).loadGame()!.activeCompanionId,
      'dune-1',
    );
  });

  testWidgets('taking Frilla along with an empty bar does not refill it', (
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

  testWidgets('switching companion mid-run does not refill shared Breath', (
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
      breath: Breath(points: 2, updatedAt: t0),
    );
    await pumpApp(
      tester,
      saved: {'flutter.game.v2': jsonEncode(game.toJson())},
    );
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final notifier = container.read(gameProvider.notifier);
    container.read(runControllerProvider.notifier)
      ..setDemoSpeed(4.5)
      ..setTimeLapse(true);
    for (var i = 0; i < 220; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    notifier.takeAlong('gilt-1');
    expect(container.read(gameProvider).activeCompanionId, 'pebble-1');
    final engine = container.read(runControllerProvider)!.engine;
    expect(engine.breathLeft, 1);
    expect(engine.companion.tankSize, 6);

    await tester.scrollUntilVisible(find.text('Stop'), 200);
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 6'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    notifier.takeAlong('gilt-1');
    expect(container.read(gameProvider).activeCompanionId, 'gilt-1');
    expect(container.read(gameProvider).breath.points, 1);
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

    testWidgets('fresh players see offers but cannot sell Mossik', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Market'));
      await tester.pumpAndSettle();
      expect(find.text('Den 1/12'), findsOneWidget);
      final seen = <Key>{};
      void collect() => seen.addAll(
        tester
            .widgetList<CompanionCard>(find.byType(CompanionCard))
            .map((c) => c.key!),
      );
      collect();
      for (var i = 0; i < 20 && seen.length < Market.offerCount; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();
        collect();
      }
      expect(seen, hasLength(Market.offerCount));
      expect(find.textContaining(RegExp(r'^[\d,]+ LP$')), findsWidgets);
      expectNoCountdown();

      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();
      expect(find.text('Mossik'), findsOneWidget);
      await tester.tap(find.text('Mossik'));
      await tester.pumpAndSettle();
      expect(
        find.text('Mossik stays until a second companion joins your den.'),
        findsOneWidget,
      );
      expect(tradeButton(tester, 'Sell ·').onPressed, isNull);
      expectNoCountdown();
    });

    testWidgets('buying puts the offer in the den and spends LP', (
      tester,
    ) async {
      final game = GameData.initial(t0).copyWith(lp: price + 3, market: market);
      await openMarket(tester, game);
      await tester.tap(find.byKey(const ValueKey('offer-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Buy ·'));
      await tester.pumpAndSettle();
      expect(find.text('Den 2/12'), findsOneWidget);
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
      await tester.tap(find.text('Mossik'));
      await tester.pumpAndSettle();
      expect(
        find.text('Afterwards Frilla goes along with you.'),
        findsOneWidget,
      );
      expect(tradeButton(tester, 'Sell ·').onPressed, isNotNull);
    });

    testWidgets('a full den of 12 blocks buying', (tester) async {
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
      expect(find.text('Den 12/12'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('offer-1')));
      await tester.pumpAndSettle();
      expect(
        find.text('Your den is full (12/12). Sell a companion first.'),
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
      await tester.tap(find.text('Sahri'));
      await tester.pumpAndSettle();
      expect(find.text('Trading only at 100 % Spirit.'), findsOneWidget);
      expect(tradeButton(tester, 'Sell ·').onPressed, isNull);
    });
  });

  group('legal', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

    testWidgets('denying the movement notice opens the run but earns no LP', (
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
      expect(find.byKey(const Key('run-no-lp')), findsOneWidget);
      final engine = container.read(runControllerProvider)!.engine;
      expect(engine.earnsLp, isFalse);

      container.read(runControllerProvider.notifier)
        ..setDemoSpeed(4.5)
        ..setTimeLapse(true);
      for (var i = 0; i < 220; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(engine.distanceM, greaterThan(250));
      expect(engine.blocks, 0);
      expect(engine.breathLeft, 6);

      await tester.scrollUntilVisible(find.text('Stop'), 200);
      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();
      expect(
        find.text('Movement access was off, so this run earned no LP.'),
        findsOneWidget,
      );
      expect(find.text('6 / 6'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(container.read(gameProvider).lp, 0);
      expect(container.read(gameProvider).breath.points, 6);
      expect(find.text('Mossik'), findsOneWidget);

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
      expect(find.text('3. Movement, steps and GPS'), findsOneWidget);
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

  group('forge', () {
    Future<void> openForge(
      WidgetTester tester,
      GameData game, {
      bool open = true,
      Random? random,
      Size? size,
    }) async {
      final seeded = open
          ? game.copyWith(wanderweg: const WanderwegProgress(legacyForge: true))
          : game;
      await pumpApp(
        tester,
        saved: {'flutter.game.v2': jsonEncode(seeded.toJson())},
        random: random,
      );
      if (size != null) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
      }
      await tester.tap(find.widgetWithText(NavigationDestination, 'Forge'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgeScreen), findsOneWidget);
    }

    // The Forge page does not scroll; only the seal strips scroll sideways.
    Future<void> tapKey(WidgetTester tester, String key) async {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }

    ButtonStyleButton button(WidgetTester tester, String key) =>
        tester.widget<ButtonStyleButton>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.bySubtype<ButtonStyleButton>(),
            matchRoot: true,
          ),
        );

    String textOf(WidgetTester tester, String key) =>
        tester.widget<Text>(find.byKey(Key(key))).data!;

    /// The stores line as one text: "Splinters 1/5 · Glut 0".
    String storesOf(WidgetTester tester, String key) =>
        '${textOf(tester, '$key-splinters')} · ${textOf(tester, '$key-glut')}';

    /// All waymarks reached, so every forge level is open.
    GameData openAll(GameData g) => g.copyWith(
      wanderweg: WanderwegProgress(reachedAt: List.filled(waymarks.length, t0)),
    );

    testWidgets('the hammer reveals the outcome only after the last blow', (
      tester,
    ) async {
      final start = openAll(
        GameData.initial(t0).copyWith(
          lp: 100,
          forge: const ForgeState(glut: 5, stock: {'stride@1': 2}),
        ),
      );
      await openForge(tester, start, open: false, random: _FixedRandom(0.99));
      await tapKey(tester, 'case-stride@1');
      // At rest the hammer lies still: nothing is waiting for a frame.
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(storesOf(tester, 'forge-stores'), 'Splinters 0/5 · Glut 5');
      await tester.tap(find.byKey(const Key('forge-go')));
      await tester.pump(const Duration(milliseconds: 600));
      // Mid-swing: the Glut is paid, no result yet and a second tap does
      // nothing.
      expect(find.byKey(const Key('forge-success')), findsNothing);
      expect(storesOf(tester, 'forge-stores'), 'Splinters 0/5 · Glut 4');
      await tester.tap(find.byKey(const Key('forge-go')), warnIfMissed: false);
      // Still winding up for the heavy last blow at about 3.75 s.
      await tester.pump(const Duration(milliseconds: 2900));
      expect(find.byKey(const Key('forge-success')), findsNothing);
      // The result follows the last blow, about 4 s after Schmieden.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('forge-success')), findsOneWidget);
      await tester.tap(find.byKey(const Key('forge-result-ok')));
      await tester.pumpAndSettle();
      expect(storesOf(tester, 'forge-stores'), 'Splinters 0/5 · Glut 4');
      expect(find.byKey(const Key('case-stride@2')), findsOneWidget);
    });

    testWidgets('a failed blow ends in the fail result', (tester) async {
      final start = openAll(
        GameData.initial(t0).copyWith(
          lp: 100,
          forge: const ForgeState(glut: 5, stock: {'stride@1': 2}),
        ),
      );
      await openForge(tester, start, open: false, random: _FixedRandom(0));
      await tapKey(tester, 'case-stride@1');
      await tester.tap(find.byKey(const Key('forge-go')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('forge-failed')), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('forge-failed')), findsOneWidget);
    });

    testWidgets('reduced motion skips the hammer', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final start = openAll(
        GameData.initial(t0).copyWith(
          lp: 100,
          forge: const ForgeState(glut: 5, stock: {'stride@1': 2}),
        ),
      );
      await openForge(tester, start, open: false, random: _FixedRandom(0.99));
      await tapKey(tester, 'case-stride@1');
      await tester.tap(find.byKey(const Key('forge-go')));
      await tester.pump();
      expect(find.byKey(const Key('forge-success')), findsOneWidget);
      await tester.pumpAndSettle();
    });

    group('grimoire combine view', () {
      // The page drifts here; elsewhere it stays still so tests settle.
      setUp(() => forgeAmbientMotion = true);
      tearDown(() => forgeAmbientMotion = false);

      GameData pair() => openAll(
        GameData.initial(t0).copyWith(
          lp: 500,
          forge: const ForgeState(stock: {'grit@3': 1, 'stride@3': 1}, glut: 5),
        ),
      );

      // The look keeps moving (mist, runes, candles), so settle by time.
      Future<void> tapAndWait(WidgetTester tester, String key) async {
        await tester.tap(find.byKey(Key(key)));
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      testWidgets('whispers, hides the result and fits 360x780', (
        tester,
      ) async {
        await openForge(
          tester,
          pair(),
          open: false,
          size: const Size(360, 780),
          random: _FixedRandom(0.99),
        );
        await tapAndWait(tester, 'tab-combine');
        expect(textOf(tester, 'forge-whisper'), 'The signs are asleep …');
        await tapAndWait(tester, 'case-stride@3');
        expect(textOf(tester, 'forge-whisper'), 'Something stirs …');
        await tapAndWait(tester, 'case-grit@3');
        expect(
          textOf(tester, 'forge-whisper'),
          'Two essences call to each other …',
        );
        expect(textOf(tester, 'forge-fail'), startsWith('Fail chance 17 %'));
        expect(find.byKey(const Key('forge-result')), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byKey(const Key('forge-go')));
        await tester.pump(const Duration(milliseconds: 900));
        expect(find.byKey(const Key('forge-success')), findsNothing);
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.byKey(const Key('forge-success')), findsOneWidget);
        await tapAndWait(tester, 'forge-result-ok');
        expect(find.byKey(const Key('case-stride+grit@3')), findsOneWidget);
        // Back on Aufwerten the page stops drifting, so the screen settles.
        await tester.tap(find.byKey(const Key('tab-up')));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('buys seals, forges one up and sets it on the companion', (
      tester,
    ) async {
      final start = openAll(
        GameData.initial(
          t0,
        ).copyWith(lp: 100, forge: const ForgeState(glut: 5)),
      );
      await openForge(tester, start, open: false, random: _FixedRandom(0.99));
      expect(
        textOf(tester, 'forge-hint'),
        'No loose seals yet. Buy a seal L1 in the Case tab.',
      );
      expect(storesOf(tester, 'forge-stores'), 'Splinters 0/5 · Glut 5');

      await tapKey(tester, 'tab-case');
      await tapKey(tester, 'buy-stride');
      await tapKey(tester, 'buy-stride');
      expect(find.text('26.0 LP'), findsOneWidget);
      expect(find.text('L1 ×2'), findsOneWidget);

      await tapKey(tester, 'tab-up');
      await tapKey(tester, 'case-stride@1');
      expect(textOf(tester, 'forge-fail'), startsWith('Fail chance 12 %'));
      await tapKey(tester, 'glut-plus');
      await tapKey(tester, 'glut-plus');
      expect(textOf(tester, 'forge-fail'), startsWith('Fail chance 7.5 %'));
      expect(find.text('+ 3 Glut'), findsOneWidget);
      expect(find.text('+ 13 LP'), findsOneWidget);
      expect(textOf(tester, 'glut-value'), '3 / 5');
      expect(find.byKey(const Key('forge-result')), findsOneWidget);

      await tapKey(tester, 'forge-go');
      expect(find.byKey(const Key('forge-success')), findsOneWidget);
      await tester.tap(find.byKey(const Key('forge-result-ok')));
      await tester.pumpAndSettle();
      expect(find.text('13.0 LP'), findsOneWidget);
      expect(storesOf(tester, 'forge-stores'), 'Splinters 0/5 · Glut 2');
      expect(find.byKey(const Key('case-stride@2')), findsOneWidget);

      // The new L2 stays picked; set it into Mossik.
      await tapKey(tester, 'forge-set');
      expect(find.byKey(const Key('case-stride@2')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('charm-slot-0')),
          matching: find.text('Stride +9 %'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(NavigationDestination, 'Den'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mossik'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('charm-slot-0')),
          matching: find.text('Level 2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the Glut slider sets the Glut for the try', (tester) async {
      final start = openAll(
        GameData.initial(t0).copyWith(
          lp: 500,
          forge: const ForgeState(stock: {'grit@3': 2}, glut: 9),
        ),
      );
      await openForge(tester, start, open: false);
      await tapKey(tester, 'case-grit@3');
      expect(textOf(tester, 'glut-value'), '2 / 9');
      final slider = find.byKey(const Key('glut-slider'));
      await tester.tapAt(tester.getTopRight(slider) + const Offset(-14, 20));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'glut-value'), '5 / 9');
      expect(textOf(tester, 'forge-fail'), startsWith('Fail chance 14 %'));
    });

    testWidgets('a failed forge leaves one seal and 3 splinters', (
      tester,
    ) async {
      final start = openAll(
        GameData.initial(t0).copyWith(
          lp: 100,
          forge: const ForgeState(stock: {'grit@1': 2}, glut: 1),
        ),
      );
      await openForge(tester, start, open: false, random: _FixedRandom(0.01));
      await tapKey(tester, 'case-grit@1');
      await tapKey(tester, 'forge-go');
      expect(find.byKey(const Key('forge-failed')), findsOneWidget);
      await tester.tap(find.byKey(const Key('forge-result-ok')));
      await tester.pumpAndSettle();
      expect(storesOf(tester, 'forge-stores'), 'Splinters 3/5 · Glut 0');
      expect(find.text('L1 ×1'), findsOneWidget);
      expect(find.text('87.0 LP'), findsOneWidget);
    });

    testWidgets('combines two L3 seals of different stats', (tester) async {
      final start = openAll(
        GameData.initial(t0).copyWith(
          lp: 500,
          forge: const ForgeState(stock: {'grit@3': 1, 'stride@3': 1}, glut: 5),
        ),
      );
      await openForge(tester, start, open: false, random: _FixedRandom(0.99));
      await tapKey(tester, 'tab-combine');
      await tapKey(tester, 'case-stride@3');
      expect(
        textOf(tester, 'forge-hint'),
        'Now pick a seal of another stat at the same level.',
      );
      await tapKey(tester, 'case-grit@3');
      expect(textOf(tester, 'forge-fail'), startsWith('Fail chance 17 %'));
      await tapKey(tester, 'forge-go');
      expect(find.byKey(const Key('forge-success')), findsOneWidget);
      await tester.tap(find.byKey(const Key('forge-result-ok')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('case-stride+grit@3')), findsOneWidget);
      expect(find.text('403.0 LP'), findsOneWidget);
    });

    testWidgets('combining waits for waymark 13', (tester) async {
      await openForge(tester, GameData.initial(t0));
      await tapKey(tester, 'tab-combine');
      expect(textOf(tester, 'forge-hint'), 'Combining L3 opens at waymark 13.');
    });

    testWidgets('a level not yet reached on the trail is locked', (
      tester,
    ) async {
      final start = GameData.initial(t0).copyWith(
        lp: 500,
        forge: const ForgeState(stock: {'stride@1': 2}, glut: 5),
      );
      await openForge(tester, start);
      await tapKey(tester, 'case-stride@1');
      expect(textOf(tester, 'forge-hint'), 'Forging L2 opens at waymark 5.');
      expect(button(tester, 'forge-go').onPressed, isNull);
    });

    testWidgets('Spirit below 100 % keeps seals in the case', (tester) async {
      final start = GameData.initial(
        t0,
      ).copyWith(lp: 1000, forge: const ForgeState(stock: {'stride@1': 1}));
      await openForge(
        tester,
        start.replaceCompanion(start.activeCompanion.copyWith(spirit: 80)),
      );
      await tapKey(tester, 'case-stride@1');
      expect(button(tester, 'forge-set').onPressed, isNull);
      expect(find.text('Seals are set only at 100 % Spirit.'), findsOneWidget);
    });

    testWidgets('the Case tab buys, melts and sets seals', (tester) async {
      await openForge(
        tester,
        GameData.initial(
          t0,
        ).copyWith(lp: 36, forge: const ForgeState(splinters: 6)),
      );
      await tapKey(tester, 'tab-case');
      for (final t in SealType.values) {
        expect(button(tester, 'buy-${t.name}').onPressed, isNull);
      }
      expect(find.text('Not enough LP yet.'), findsOneWidget);
      expect(find.text('No loose seals yet.'), findsOneWidget);
      await tapKey(tester, 'melt-grit');
      expect(storesOf(tester, 'case-stores'), 'Splinters 1/5 · Glut 0');
      expect(button(tester, 'melt-grit').onPressed, isNull);
      await tapKey(tester, 'case-grit@1');
      await tapKey(tester, 'case-set');
      expect(
        find.descendant(
          of: find.byKey(const Key('charm-slot-0')),
          matching: find.text('Grit +4 %'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a set seal goes back into the case when taken out', (
      tester,
    ) async {
      final pebble = Companion.pebble().withSeal(
        0,
        const Seal(SealType.grit, 4),
      );
      await openForge(
        tester,
        GameData.initial(t0).copyWith(companions: [pebble]),
      );
      expect(find.text('Grit +22 %'), findsOneWidget);
      await tester.tap(find.byKey(const Key('charm-slot-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('forge-clear-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('case-grit@4')), findsOneWidget);
    });

    testWidgets('the Levels tab shows every level', (tester) async {
      await openForge(tester, GameData.initial(t0));
      await tapKey(tester, 'tab-ladder');
      final tab = find.byKey(const Key('forge-ladder-tab'));
      expect(tab, findsOneWidget);
      for (final pct in ['+4 %', '+9 %', '+15 %', '+22 %', '+31 %']) {
        expect(
          find.descendant(of: tab, matching: find.text(pct)),
          findsNWidgets(3),
          reason: pct,
        );
      }
      expect(
        find.descendant(of: tab, matching: find.text('+19 % / +19 %')),
        findsOneWidget,
      );
    });

    testWidgets('a new game finds the forge closed until waymark 2', (
      tester,
    ) async {
      await openForge(
        tester,
        GameData.initial(t0).copyWith(lp: 1000),
        open: false,
      );
      expect(find.byKey(const Key('forge-block')), findsOneWidget);
      expect(find.textContaining('waymark 2'), findsOneWidget);
      await tapKey(tester, 'tab-case');
      for (final t in SealType.values) {
        expect(button(tester, 'buy-${t.name}').onPressed, isNull);
      }
    });

    group('fits one screen', () {
      final gilt =
          Companion.fresh(
                id: 'm-gilt-1',
                speciesId: 'gilt',
                rarity: Rarity.legendary,
              )
              .withSeal(0, const Seal(SealType.stride, 5))
              .withSeal(1, Seal.combined(SealType.stride, SealType.grit, 5))
              .withSeal(2, const Seal(SealType.fortune, 1));
      final rich = openAll(
        GameData.initial(t0).copyWith(
          lp: 1284.6,
          companions: [Companion.pebble(), gilt],
          activeCompanionId: 'm-gilt-1',
          forge: const ForgeState(
            stock: {
              'stride@1': 3,
              'grit@1': 1,
              'fortune@2': 1,
              'grit@4': 1,
              'stride@3': 2,
              'grit@3': 1,
              'fortune@3': 1,
              'stride+grit@3': 1,
              'stride@5': 1,
            },
            glut: 7,
            splinters: 6,
          ),
        ),
      );

      /// The page itself never scrolls: no vertical scrollable inside the
      /// Forge, and the action buttons sit inside the Forge's own area.
      void expectNoPageScroll(WidgetTester tester, String what) {
        final forge = tester.getRect(find.byType(ForgeScreen));
        for (final e
            in find
                .descendant(
                  of: find.byType(ForgeScreen),
                  matching: find.byType(Scrollable),
                )
                .evaluate()) {
          final state = (e as StatefulElement).state as ScrollableState;
          if (state.position.axis == Axis.vertical) {
            expect(
              state.position.maxScrollExtent,
              0,
              reason: '$what scrolls vertically',
            );
          }
        }
        final error = tester.takeException();
        expect(
          error,
          isNull,
          reason:
              '$what: ${error is FlutterError ? error.diagnostics.join('\n') : error}',
        );
        for (final key in ['forge-header', 'forge-tabs']) {
          final r = tester.getRect(find.byKey(Key(key)));
          expect(
            r.top >= forge.top && r.bottom <= forge.bottom,
            isTrue,
            reason: '$what: $key off screen',
          );
        }
      }

      void expectInside(WidgetTester tester, String key, String what) {
        final forge = tester.getRect(find.byType(ForgeScreen));
        final r = tester.getRect(find.byKey(Key(key)));
        expect(
          r.top >= forge.top && r.bottom <= forge.bottom,
          isTrue,
          reason: '$what: $key at $r outside $forge',
        );
      }

      for (final (name, size) in [
        ('390x844', const Size(390, 844)),
        ('360x780', const Size(360, 780)),
        ('desktop 1280x800', const Size(1280, 800)),
      ]) {
        testWidgets('every tab at $name', (tester) async {
          await openForge(tester, rich, open: false, size: size);
          expectNoPageScroll(tester, '$name main');

          await tapKey(tester, 'case-stride@3');
          for (final k in [
            'forge-result',
            'glut-slider',
            'forge-fail',
            'forge-hint',
            'forge-stores',
            'forge-go',
            'forge-set',
          ]) {
            expectInside(tester, k, '$name forge up');
          }
          expectNoPageScroll(tester, '$name forge up');

          await tapKey(tester, 'tab-combine');
          await tapKey(tester, 'case-stride@3');
          await tapKey(tester, 'case-grit@3');
          for (final k in ['forge-result', 'forge-fail', 'forge-go']) {
            expectInside(tester, k, '$name combine');
          }
          expectNoPageScroll(tester, '$name combine');

          await tapKey(tester, 'tab-case');
          for (final k in [
            'case-stores',
            'case-set',
            'buy-fortune',
            'melt-fortune',
          ]) {
            expectInside(tester, k, '$name case');
          }
          expectNoPageScroll(tester, '$name case');

          await tapKey(tester, 'tab-ladder');
          expectInside(tester, 'forge-ladder-tab', '$name levels');
          expectNoPageScroll(tester, '$name levels');
        });
      }

      testWidgets('a closed forge at 360x780 fits too', (tester) async {
        await openForge(
          tester,
          GameData.initial(
            t0,
          ).copyWith(forge: const ForgeState(stock: {'stride@1': 1})),
          open: false,
          size: const Size(360, 780),
        );
        expect(find.byKey(const Key('forge-block')), findsOneWidget);
        await tapKey(tester, 'case-stride@1');
        expectInside(tester, 'forge-go', 'closed');
        expectNoPageScroll(tester, 'closed');
        await tapKey(tester, 'tab-case');
        expectInside(tester, 'melt-fortune', 'closed case');
        expectNoPageScroll(tester, 'closed case');
      });
    });
  });
}

/// nextDouble always gives [roll]; nextBool is true.
class _FixedRandom implements Random {
  _FixedRandom(this.roll);

  final double roll;

  @override
  double nextDouble() => roll;

  @override
  bool nextBool() => true;

  @override
  int nextInt(int max) => 0;
}

class _FakeSaveFiles extends SaveFileIo {
  _FakeSaveFiles({this.copies = 0});

  /// App-internal copies the fake pretends to hold.
  int copies;
  int deleteCalls = 0;
  Uint8List? delivered;
  String? name;
  Uint8List? toPick;

  @override
  Future<Uint8List?> pick() async => toPick;

  @override
  Future<void> deliver(
    String name,
    Uint8List bytes, {
    required String subject,
  }) async {
    this.name = name;
    delivered = bytes;
  }

  @override
  Future<int> deleteLocalCopies() async {
    deleteCalls++;
    final n = copies;
    copies = 0;
    return n;
  }

  @override
  bool get downloads => false;
}
