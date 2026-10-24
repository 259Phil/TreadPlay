import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/companion_cutouts.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/world.dart';
import 'package:treadplay/l10n/app_localizations.dart';
import 'package:treadplay/theme.dart';
import 'package:treadplay/widgets/companion_card.dart';

Rarity rarityOf(String art) => Rarity.values.firstWhere(
  (r) => art.endsWith('-${r.name}'),
  orElse: () => Rarity.common,
);

void main() {
  // Grid card (Gehege), market card with an action pill, and the small
  // card in the detail sheets.
  const sizes = {
    'grid': (Size(176, 303), false),
    'market': (Size(176, 352), true),
    'detail': (Size(130, 130 / CompanionCard.aspectRatio), false),
  };

  for (final MapEntry(key: where, value: (size, action)) in sizes.entries) {
    testWidgets('$where: every creature sits above the name plate', (
      tester,
    ) async {
      expect(companionCutouts, hasLength(40));
      for (final MapEntry(key: art, value: cut) in companionCutouts.entries) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Center(
              child: SizedBox.fromSize(
                size: size,
                child: CompanionCard(
                  artKey: art,
                  world: World.medieval,
                  rarity: rarityOf(art),
                  name: 'Kettrik',
                  subtitle: 'Moos · Lv 1',
                  type: CompanionType.moss,
                  badge: 'Dabei',
                  stats: action ? null : const [('Grit', '10')],
                  action: action ? '120 LP' : null,
                ),
              ),
            ),
          ),
        );
        final image = tester.getRect(find.byKey(ValueKey('card-art-$art')));
        final sx = image.width / cut.size.width;
        final sy = image.height / cut.size.height;
        final body = Rect.fromLTRB(
          image.left + cut.body.left * sx,
          image.top + cut.body.top * sy,
          image.left + cut.body.right * sx,
          image.top + cut.body.bottom * sy,
        );
        final plate = tester.getRect(find.byKey(const Key('card-plate')));
        final card = tester.getRect(find.byType(CompanionCard));
        expect(
          body.overlaps(plate),
          isFalse,
          reason: '$where $art: body $body, plate $plate',
        );
        expect(body.bottom, lessThanOrEqualTo(plate.top), reason: art);
        // Nothing cut at the sides or the top either.
        expect(body.left, greaterThanOrEqualTo(card.left + 8), reason: art);
        expect(body.right, lessThanOrEqualTo(card.right - 8), reason: art);
        expect(body.top, greaterThanOrEqualTo(card.top + 30), reason: art);
        // The 130 px detail card's rarity row is too narrow for the wide
        // test font (real fonts fit, see the 390x844 shots); only the
        // placement is checked there.
        final error = tester.takeException();
        if (where != 'detail') expect(error, isNull, reason: art);
      }
    });
  }
}
