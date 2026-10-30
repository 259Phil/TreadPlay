import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/features/run/run_trail.dart';
import 'package:treadplay/features/wanderweg/trail_layout.dart';
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

    for (final (look, key) in [
      (RunTrailLook.calm, 'run-trail-calm'),
      (RunTrailLook.parchment, 'run-trail-parchment'),
      (RunTrailLook.horizon, 'run-trail-horizon'),
    ]) {
      testWidgets('${look.name} shows the trail with the companion', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            SizedBox(
              height: 300,
              child: RunTrailMap(
                spot: spot,
                companion: c,
                moving: false,
                look: look,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(Key(key)), findsOneWidget);
        expect(find.byKey(const Key('run-trail-figure')), findsOneWidget);
        expect(find.text('noch 0,9 km bis Wegmarke 3'), findsOneWidget);
        // Everything stays inside the map's own box.
        final box = tester.getRect(find.byType(RunTrailMap)).inflate(0.5);
        final fig = tester.getRect(find.byKey(const Key('run-trail-figure')));
        final label = tester.getRect(find.byKey(const Key('run-trail-label')));
        expect(
          box.contains(fig.topLeft) && box.contains(fig.bottomRight),
          isTrue,
        );
        expect(
          box.contains(label.topLeft) && box.contains(label.bottomRight),
          isTrue,
        );
      });
    }

    test('preview switch defaults to the calm look', () {
      expect(RunTrailLook.fromUrl(), RunTrailLook.calm);
    });

    test('zooms in so walking pace moves the companion visibly', () {
      const w = 412.0;
      for (var n = 0; n < waymarks.length; n++) {
        final at = RunTrailSpot(reached(n), waymarks[n].meters - 100);
        final z = RunTrailMap.zoomFor(at, w);
        expect(z, inInclusiveRange(RunTrailMap.minZoom, RunTrailMap.maxZoom));
      }
      // Waymark 2 -> 3: 30 s at 6 km/h (50 m) moves the companion visibly.
      final z = RunTrailMap.zoomFor(spot, w);
      final geo = TrailGeometry(width: w * z, topPad: 0, bottomPad: 0);
      final a = geo.at(geo.companionS(spot.progress, 3200));
      final b = geo.at(geo.companionS(spot.progress, 3250));
      expect((b - a).distance, greaterThan(10));
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
