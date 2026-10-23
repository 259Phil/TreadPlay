import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/movement_source.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/features/pouches/pouch_screen.dart';
import 'package:treadplay/router.dart';
import 'package:treadplay/state/providers.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  GameData game({int reached = 7, double lp = 1000}) {
    var g = GameData.initial(t0).copyWith(
      lp: lp,
      wanderweg: WanderwegProgress(reachedAt: List.filled(reached, t0)),
    );
    for (final c in PouchColor.values) {
      g = g.hangingPouch(c, t0);
    }
    return g;
  }

  Future<ProviderContainer> pump(
    WidgetTester tester,
    GameData g,
    Size size,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'flutter.game.v2': jsonEncode(g.toJson()),
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
    return ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  void expectFits(WidgetTester tester, List<String> keys, String what) {
    final error = tester.takeException();
    expect(error, isNull, reason: '$what: $error');
    final screen = tester.getRect(find.byType(PouchScreen));
    for (final e
        in find
            .descendant(
              of: find.byType(PouchScreen),
              matching: find.byType(Scrollable),
            )
            .evaluate()) {
      final state = (e as StatefulElement).state as ScrollableState;
      if (state.position.axis == Axis.vertical) {
        expect(state.position.maxScrollExtent, 0, reason: '$what scrolls');
      }
    }
    for (final k in keys) {
      final r = tester.getRect(find.byKey(Key(k)));
      expect(
        r.top >= screen.top && r.bottom <= screen.bottom,
        isTrue,
        reason: '$what: $k at $r outside $screen',
      );
    }
  }

  for (final (name, size) in [
    ('390x844', const Size(390, 844)),
    ('360x780', const Size(360, 780)),
    ('desktop 1280x800', const Size(1280, 800)),
  ]) {
    testWidgets('pouches fit one screen and open every colour at $name', (
      tester,
    ) async {
      final c = await pump(tester, game(), size);
      await tapKey(tester, 'home-leash-handle');
      await tapKey(tester, 'home-leash');
      expect(find.byType(PouchScreen), findsOneWidget);
      expectFits(tester, [
        'pouch-leash',
        'pouch-detail',
        'pouch-contents',
        'pouch-status',
        'pouch-chance',
        'pouch-colors',
        'pouch-open',
      ], '$name leash');
      expect(
        tester.widget<Text>(find.byKey(const Key('pouch-colors'))).data,
        'Colours: Brown 71 % · Copper 29 %',
      );

      for (final color in PouchColor.values) {
        await tapKey(tester, 'pouch-clip-0');
        expect(
          tester.widget<Text>(find.byKey(const Key('pouch-name'))).data,
          contains(switch (color) {
            PouchColor.brown => 'Brown',
            PouchColor.copper => 'Copper',
            PouchColor.turquoise => 'Turquoise',
            PouchColor.navy => 'Navy',
          }),
        );
        await tapKey(tester, 'pouch-open');
        expect(find.byKey(const Key('pouch-reveal')), findsOneWidget);
        final tiles = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('pouch-reward-'),
        );
        expect(tiles, findsAtLeastNWidgets(2));
        expectFits(tester, [
          'pouch-reveal',
          'pouch-reward-0',
          'pouch-reward-1',
          'pouch-continue',
          'pouch-to-forge',
        ], '$name ${color.name} reveal');
        expect(c.read(gameProvider).pouches.openedOf(color), 1);
        await tapKey(tester, 'pouch-continue');
      }
      expect(c.read(gameProvider).pouches.leash, isEmpty);
      expect(find.byKey(const Key('pouch-note')), findsOneWidget);
      expectFits(tester, ['pouch-note', 'pouch-open'], '$name empty');
    });
  }

  testWidgets('a cold pouch without enough LP waits', (tester) async {
    await pump(tester, game(lp: 3), const Size(390, 844));
    await tapKey(tester, 'home-leash-handle');
    await tapKey(tester, 'home-leash');
    expect(find.byKey(const Key('pouch-no-lp')), findsOneWidget);
    await tapKey(tester, 'pouch-open');
    expect(find.byKey(const Key('pouch-reveal')), findsNothing);
  });

  testWidgets('no leash on home before waymark 1', (tester) async {
    await pump(tester, GameData.initial(t0), const Size(390, 844));
    expect(find.byKey(const Key('home-leash')), findsNothing);
    expect(find.byKey(const Key('home-leash-handle')), findsNothing);
  });

  testWidgets('the summary shows the found pouch and leads to the leash', (
    tester,
  ) async {
    final g = game(reached: 1).copyWith(
      runs: [
        RunSummary(
          companionId: 'pebble-1',
          startedAt: t0,
          duration: const Duration(minutes: 31),
          distanceM: 2370,
          steps: 3100,
          lp: 17.4,
          breathUsed: 6,
          valid: true,
          tankSize: 6,
        ).withRewards(glut: 0, pouch: PouchColor.copper),
      ],
    );
    final c = await pump(tester, g, const Size(390, 844));
    c.read(routerProvider).push(AppRoutes.summary);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('summary-pouch')), findsOneWidget);
    expect(find.text('Copper pouch'), findsOneWidget);
    expect(find.byKey(const Key('summary-glut')), findsNothing);
    await tapKey(tester, 'summary-to-leash');
    expect(find.byType(PouchScreen), findsOneWidget);
  });

  testWidgets('the fourth leash ring stays locked until waymark 7', (
    tester,
  ) async {
    await pump(tester, game(reached: 6), const Size(390, 844));
    expect(find.byKey(const Key('home-leash-clip-locked-3')), findsOneWidget);
    await tapKey(tester, 'home-leash-handle');
    await tapKey(tester, 'home-leash');
    expect(find.byKey(const Key('pouch-clip-locked-3')), findsOneWidget);
    expect(find.byKey(const Key('pouch-clip-3')), findsNothing);
    expect(find.byKey(const Key('pouch-clip-2')), findsOneWidget);
  });

  testWidgets('at waymark 7 all four rings carry a pouch', (tester) async {
    await pump(tester, game(), const Size(390, 844));
    await tapKey(tester, 'home-leash-handle');
    await tapKey(tester, 'home-leash');
    expect(find.byKey(const Key('pouch-clip-locked-3')), findsNothing);
    expect(find.byKey(const Key('pouch-clip-3')), findsOneWidget);
  });
}
