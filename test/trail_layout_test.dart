import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/wanderweg.dart';
import 'package:treadplay/features/wanderweg/trail_layout.dart';

WanderwegProgress _reached(int n) =>
    WanderwegProgress(reachedAt: List.filled(n, DateTime(2026, 10, 1)));

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    group('width $width', () {
      final geo = TrailGeometry(width: width, topPad: 170, bottomPad: 40);
      final sectionBottom = geo.sectionTop(0) + geo.sectionHeight;

      test('a fresh player stands on the painted path in section 1', () {
        final s = geo.companionS(const WanderwegProgress(), 0);
        expect(s, closeTo(geo.startS, 0.001));
        final p = geo.at(s);
        expect(p.dy, lessThan(sectionBottom - width * 0.25));
        expect(p.dy, greaterThan(geo.sectionTop(0)));
      });

      test('the companion stays on screen for every km and at the end', () {
        for (var n = 0; n <= waymarks.length; n++) {
          final from = n == 0 ? 0.0 : waymarks[n - 1].km;
          final to = n == waymarks.length ? from + 20 : waymarks[n].km;
          for (var f = 0.0; f <= 1.0; f += 0.25) {
            final km = from + (to - from) * f;
            final s = geo.companionS(_reached(n), km * 1000);
            final p = geo.at(s);
            expect(p.dx, inInclusiveRange(width * 0.12, width * 0.88));
            // Head below the 150 px top overlay, feet above the art's end.
            expect(p.dy - width * 0.17, greaterThanOrEqualTo(150));
            expect(p.dy, lessThanOrEqualTo(sectionBottom));
          }
        }
      });

      test('at the end the companion is past the last waymark', () {
        final s = geo.companionS(_reached(waymarks.length), 140000);
        expect(s, greaterThan(geo.waymarkS(waymarks.length)));
        final foot = geo.cairnFoot(waymarks.length);
        expect(geo.at(s).dy, lessThan(foot.dy - width * 0.2));
      });
    });
  }
}
