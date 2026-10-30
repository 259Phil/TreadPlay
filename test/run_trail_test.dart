import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/features/run/run_trail.dart';
import 'package:treadplay/features/wanderweg/wanderweg_screen.dart';
import 'package:treadplay/l10n/app_localizations.dart';

void main() {
  final t0 = DateTime(2026, 1, 1);
  WanderwegProgress reached(int n) =>
      WanderwegProgress(reachedAt: List.filled(n, t0), seen: n);

  group('RunTrailSpot', () {
    test('walks from the last to the next waymark by distance', () {
      // Waymark 2 at 2.3 km, waymark 3 at 4.1 km.
      final spot = RunTrailSpot(reached(2), 3200);
      expect(spot.next!.number, 3);
      expect(spot.fromM, 2300);
      expect(spot.toM, 4100);
      expect(spot.fraction, closeTo(0.5, 1e-9));
      expect(spot.leftM, closeTo(900, 1e-9));
    });

    test('this run moves the companion on', () {
      final before = RunTrailSpot(reached(2), 3200);
      final after = RunTrailSpot(reached(2), 3200 + 450);
      expect(after.fraction - before.fraction, closeTo(450 / 1800, 1e-9));
    });

    test('waits at a waymark whose tasks are open', () {
      final spot = RunTrailSpot(reached(1), 5000);
      expect(spot.next!.number, 2);
      expect(spot.trailM, 2300);
      expect(spot.fraction, 1);
      expect(spot.leftM, 0);
    });

    test('a new player starts at 0 m', () {
      final spot = RunTrailSpot(const WanderwegProgress(), 350);
      expect(spot.fromM, 0);
      expect(spot.fraction, closeTo(0.5, 1e-9));
    });

    test('a finished trail stays complete', () {
      final spot = RunTrailSpot(reached(waymarks.length), 200000);
      expect(spot.complete, isTrue);
      expect(spot.next, isNull);
      expect(spot.fraction, 1);
    });
  });

  group('trail map', () {
    Widget host(Widget child) => MaterialApp(
      locale: const Locale('de'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: SizedBox.expand(child: child)),
    );

    final spot = RunTrailSpot(reached(2), 3200);
    final c = Companion.pebble();

    testWidgets('shows the real Wanderweg with the companion', (tester) async {
      final game = GameData.initial(t0).copyWith(wanderweg: reached(2));
      await tester.pumpWidget(
        host(
          Center(
            child: SizedBox(
              height: 300,
              child: RunTrailMap(
                game: game,
                spot: spot,
                companion: c,
                moving: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('run-trail-map')), findsOneWidget);
      // Same art, trail and waymarks as the Wanderweg screen.
      expect(find.byType(TrailMapContent), findsOneWidget);
      expect(find.byKey(const Key('trail-art-0')), findsOneWidget);
      expect(find.byKey(const Key('trail-companion')), findsNothing);
      expect(find.byKey(const Key('run-trail-figure')), findsOneWidget);
      expect(find.text('noch 0,9 km bis Wegmarke 3'), findsOneWidget);
      // The companion and its label stay inside the map's own box.
      final box = tester.getRect(find.byType(RunTrailMap)).inflate(0.5);
      for (final k in ['run-trail-figure', 'run-trail-label']) {
        final r = tester.getRect(find.byKey(Key(k)));
        expect(
          box.contains(r.topLeft) && box.contains(r.bottomRight),
          isTrue,
          reason: k,
        );
      }
    });

    testWidgets('the companion only steps while moving', (tester) async {
      Widget fig(bool moving) => host(
        Center(
          child: TrailFigure(companion: c, size: 80, moving: moving),
        ),
      );
      await tester.pumpWidget(fig(true));
      await tester.pump(const Duration(milliseconds: 140));
      final moved = tester.getTopLeft(
        find.byKey(const Key('run-trail-figure')),
      );
      await tester.pumpWidget(fig(false));
      await tester.pumpAndSettle();
      final still = tester.getTopLeft(
        find.byKey(const Key('run-trail-figure')),
      );
      expect(moved.dy, lessThan(still.dy));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
