import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/features/home/world_scene.dart';
import 'package:treadplay/features/pouches/pouch_screen.dart';
import 'package:treadplay/state/providers.dart';
import 'package:treadplay/widgets/pouch_art.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  GameData game({int pouches = 3}) {
    var g = GameData.initial(t0).copyWith(
      lp: 500,
      wanderweg: WanderwegProgress(reachedAt: List.filled(7, t0), seen: 7),
    );
    for (var i = 0; i < pouches; i++) {
      g = g.hangingPouch(PouchColor.values[i % 4], t0);
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
        ],
        child: const TreadplayApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
  }

  final handle = find.byKey(const Key('home-leash-handle'));
  final panel = find.byKey(const Key('home-leash'));
  final companion = find.byKey(const Key('home-companion'));

  bool open() => panel.hitTestable().evaluate().isNotEmpty;

  for (final (name, size) in [
    ('390x844', const Size(390, 844)),
    ('360x780', const Size(360, 780)),
    ('desktop 1280x800', const Size(1280, 800)),
  ]) {
    testWidgets('$name: closed, the handle keeps clear of the companion', (
      tester,
    ) async {
      await pump(tester, game(), size);
      expect(handle, findsOneWidget);
      expect(open(), isFalse);
      final h = tester.getRect(handle);
      final c = tester.getRect(companion);
      expect(h.overlaps(c), isFalse, reason: 'handle $h, companion $c');
      // Inside the world, at its edge.
      final scene = tester.getRect(find.byType(WorldScene));
      expect(h.right, moreOrLessEquals(scene.right));
      expect(h.bottom, lessThanOrEqualTo(scene.bottom));
      expect(find.byType(Scrollable), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name: tap opens the whole leash, outside closes it', (
      tester,
    ) async {
      await pump(tester, game(), size);
      await tester.tap(handle);
      await tester.pumpAndSettle();
      expect(open(), isTrue);
      final p = tester.getRect(panel);
      final scene = tester.getRect(find.byType(WorldScene));
      expect(p.left, greaterThanOrEqualTo(scene.left));
      expect(p.right, lessThanOrEqualTo(scene.right));
      expect(p.bottom, lessThanOrEqualTo(scene.bottom));
      expect(
        find.descendant(of: panel, matching: find.byType(PouchArt)),
        findsNWidgets(3),
      );
      // A tap outside slides it back.
      await tester.tapAt(scene.topLeft + const Offset(20, 40));
      await tester.pumpAndSettle();
      expect(open(), isFalse);
      // The handle toggles too.
      await tester.tap(handle);
      await tester.pumpAndSettle();
      expect(open(), isTrue);
      await tester.tap(handle);
      await tester.pumpAndSettle();
      expect(open(), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('swipe left opens, swipe right closes', (tester) async {
    await pump(tester, game(), const Size(390, 844));
    await tester.drag(handle, const Offset(-160, 0));
    await tester.pumpAndSettle();
    expect(open(), isTrue);
    await tester.drag(handle, const Offset(160, 0));
    await tester.pumpAndSettle();
    expect(open(), isFalse);
  });

  testWidgets('the open leash leads to the pouches', (tester) async {
    await pump(tester, game(), const Size(390, 844));
    await tester.tap(handle);
    await tester.pumpAndSettle();
    await tester.tap(panel);
    await tester.pumpAndSettle();
    expect(find.byType(PouchScreen), findsOneWidget);
  });

  for (final n in [0, 1, 3, 4]) {
    testWidgets('the badge counts $n pouches', (tester) async {
      await pump(tester, game(pouches: n), const Size(390, 844));
      expect(
        tester.widget<Text>(find.byKey(const Key('home-leash-count'))).data,
        '$n',
      );
    });
  }

  testWidgets('a new pouch peeks out once, then the leash slides back', (
    tester,
  ) async {
    final c = await pump(tester, game(pouches: 1), const Size(390, 844));
    expect(open(), isFalse);
    c.read(gameProvider.notifier).importGame(game(pouches: 2));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(open(), isTrue);
    expect(
      tester.widget<Text>(find.byKey(const Key('home-leash-count'))).data,
      '2',
    );
    await tester.pumpAndSettle();
    expect(open(), isFalse);
    // Still marked as new until looked at: the handle glows.
    BoxDecoration deco() =>
        tester
                .widget<Container>(
                  find
                      .descendant(of: handle, matching: find.byType(Container))
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(deco().boxShadow, hasLength(2));
    await tester.tap(handle);
    await tester.pumpAndSettle();
    await tester.tap(handle);
    await tester.pumpAndSettle();
    expect(deco().boxShadow, hasLength(1));
    // Nothing new, no second peek.
    c.read(gameProvider.notifier).importGame(game(pouches: 2));
    await tester.pumpAndSettle();
    expect(open(), isFalse);
  });
}
