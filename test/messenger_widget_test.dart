import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treadplay/app.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/messenger.dart';
import 'package:treadplay/domain/pouch.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/features/home/world_scene.dart';
import 'package:treadplay/features/messenger/messenger_popup.dart';
import 'package:treadplay/l10n/app_localizations.dart';
import 'package:treadplay/state/providers.dart';

void main() {
  final t0 = DateTime(2026, 3, 2, 8);

  GameData base(MessengerState m) => GameData.initial(t0).copyWith(
    wanderweg: WanderwegProgress(reachedAt: List.filled(14, t0), seen: 14),
    pouches: const PouchState(found: {PouchColor.brown: 1}),
    messengers: m,
  );

  Future<ProviderContainer> pump(
    WidgetTester tester,
    GameData game, {
    String locale = 'de',
  }) async {
    // A 390×844 phone.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'game.v2': jsonEncode(game.toJson()),
      'settings.v1': jsonEncode({
        'localeCode': locale,
        'movementAccess': 'allowed',
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(() => t0),
          randomProvider.overrideWithValue(Random(1)),
        ],
        child: const TreadplayApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
  }

  /// The letter is on screen, whole, and nothing in it scrolls.
  void expectFits(WidgetTester tester) {
    final letter = find.byKey(const Key('messenger-letter'));
    expect(letter, findsOneWidget);
    final r = tester.getRect(letter);
    expect(r.top, greaterThanOrEqualTo(0));
    expect(r.bottom, lessThanOrEqualTo(844));
    expect(r.left, greaterThanOrEqualTo(0));
    expect(r.right, lessThanOrEqualTo(390));
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Scrollable),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  }

  MessengerTask taskOf(Messenger m, TaskType type) => MessengerTask(
    messenger: m,
    type: type,
    target: Messengers.targets[type]![m.index],
    progress: 1,
    line: 2,
  );

  for (final locale in ['de', 'en']) {
    for (final m in Messenger.values) {
      for (final kind in VisitKind.values) {
        testWidgets('$locale: ${m.name} ${kind.name} letter fits 390x844', (
          tester,
        ) async {
          final visit = MessengerVisit(
            messenger: m,
            kind: kind,
            at: t0,
            greet: 5,
            line: 4,
            glut: kind == VisitKind.gift ? m.giftGlut : 0,
            task: kind == VisitKind.task
                ? taskOf(m, TaskType.sweetSpotRuns)
                : null,
          );
          await pump(
            tester,
            base(MessengerState(met: 1, pending: visit)),
            locale: locale,
          );
          expectFits(tester);
          if (kind == VisitKind.leashFull) {
            expect(find.byKey(const Key('messenger-full')), findsOneWidget);
          }
        });
      }
    }
  }

  testWidgets('accepting a task shows the Aushang, below the scene', (
    tester,
  ) async {
    final visit = MessengerVisit(
      messenger: Messenger.flimm,
      kind: VisitKind.task,
      at: t0,
      task: taskOf(Messenger.flimm, TaskType.walk),
    );
    final c = await pump(tester, base(MessengerState(met: 1, pending: visit)));
    expect(find.byKey(const Key('messenger-notice')), findsNothing);
    await tester.tap(find.byKey(const Key('messenger-accept')));
    await tester.pumpAndSettle();
    expect(c.read(gameProvider).messengers.task, isNotNull);
    final notice = find.byKey(const Key('messenger-notice'));
    expect(notice, findsOneWidget);
    // Outside the scene, so it never covers the companion.
    final scene = tester.getRect(find.byType(WorldScene));
    expect(tester.getRect(notice).top, greaterThanOrEqualTo(scene.bottom));
    expect(
      find.descendant(of: notice, matching: find.textContaining('Glimmsel')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    // Its details open as the same no-scroll letter.
    await tester.tap(notice);
    await tester.pumpAndSettle();
    expectFits(tester);
  });

  testWidgets('turning a task down hangs the pouch, no Aushang', (
    tester,
  ) async {
    final visit = MessengerVisit(
      messenger: Messenger.kolk,
      kind: VisitKind.task,
      at: t0,
      task: taskOf(Messenger.kolk, TaskType.validRuns),
    );
    final c = await pump(tester, base(MessengerState(met: 1, pending: visit)));
    await tester.tap(find.byKey(const Key('messenger-decline')));
    await tester.pumpAndSettle();
    final g = c.read(gameProvider);
    expect(g.messengers.task, isNull);
    expect(g.pouches.leash.single.color, PouchColor.copper);
    expect(find.byKey(const Key('messenger-notice')), findsNothing);
  });

  testWidgets('a finished task shows its done note once', (tester) async {
    final c = await pump(
      tester,
      base(
        MessengerState(met: 1, done: taskOf(Messenger.vesper, TaskType.walk)),
      ),
    );
    expectFits(tester);
    await tester.tap(find.text('Danke'));
    await tester.pumpAndSettle();
    expect(c.read(gameProvider).messengers.done, isNull);
    expect(find.byKey(const Key('messenger-letter')), findsNothing);
  });

  test('messengers show their checked names, never the old ids', () {
    final old = RegExp(r'\b(kolk|flimm|vesper)\b', caseSensitive: false);
    for (final code in ['de', 'en']) {
      final l = lookupAppLocalizations(Locale(code));
      for (final m in Messenger.values) {
        final title = messengerTitle(l, m);
        expect(title, startsWith('${messengerName(m)} · '), reason: code);
        final texts = [
          title,
          for (var i = 0; i < 8; i++) ...[
            messengerGreet(l, m, i),
            messengerGiftLine(l, m, i),
            messengerTaskLine(l, m, i),
          ],
        ];
        for (final t in texts) {
          expect(old.hasMatch(t), isFalse, reason: '$code: $t');
        }
      }
    }
    expect(Messenger.values.map(messengerName), [
      'Ruhu',
      'Krahni',
      'Glimmsel',
      'Sternuh',
    ]);
  });
}
