import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/species.dart';
import 'package:treadplay/l10n/app_localizations.dart';
import 'package:treadplay/widgets/format.dart';

void main() {
  test('species keep their save ids and carry the style C names', () {
    expect(
      {for (final s in speciesCatalog) s.id: s.name},
      {
        'pebble': 'Mossik',
        'lumen': 'Astrillo',
        'coil': 'Krullo',
        'gilt': 'Frilla',
        'hookfin': 'Finzack',
        'valve': 'Kettrik',
        'dune': 'Sahri',
        'brine': 'Blubbo',
        'vine': 'Rankix',
        'glaze': 'Zuckli',
        'zinnbuck': 'Zinnbuck',
        'ringelpanz': 'Ringelpanz',
        'nebulo': 'Nebulo',
        'kraterix': 'Kraterix',
        'drahtel': 'Drahtel',
        'muttrix': 'Muttrix',
        'porzella': 'Porzella',
        'puderling': 'Puderling',
        'teerbock': 'Teerbock',
        'segelkamm': 'Segelkamm',
        'messingor': 'Messingor',
        'emaillo': 'Emaillo',
        'papyrix': 'Papyrix',
        'lapisor': 'Lapisor',
        'muschlo': 'Muschlo',
        'tangwell': 'Tangwell',
        'farnix': 'Farnix',
        'schwammo': 'Schwammo',
        'karamello': 'Karamello',
        'lakrillo': 'Lakrillo',
      },
    );
  });

  test('every species has a flavour line in German and English', () {
    for (final code in ['de', 'en']) {
      final l = lookupAppLocalizations(Locale(code));
      final lines = [for (final s in speciesCatalog) speciesFlavour(l, s.id)];
      expect(lines, everyElement(isNotNull), reason: code);
      expect(lines.toSet(), hasLength(speciesCatalog.length), reason: code);
    }
    final de = lookupAppLocalizations(const Locale('de'));
    expect(speciesFlavour(de, 'pebble'), 'Ein Stein mit Herz und Moos.');
    expect(speciesFlavour(de, 'nope'), isNull);
  });
}
