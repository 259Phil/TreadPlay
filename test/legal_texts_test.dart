import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/features/legal/legal_texts.dart';

void main() {
  final en = legalText(LegalDoc.privacy, 'en');
  final de = legalText(LegalDoc.privacy, 'de');

  test('privacy covers the save file, GPS, videos and web in EN and DE', () {
    for (final h in [
      '## 3. Movement, steps and GPS',
      '## 5. Rewarded videos (ads)',
      '## 7. Save-game file (export and import)',
      '## 8. Web version',
    ]) {
      expect(en, contains(h));
    }
    for (final h in [
      '## 3. Bewegung, Schritte und GPS',
      '## 5. Belohnte Videos (Werbung)',
      '## 7. Spielstand-Datei (Export und Import)',
      '## 8. Web-Version',
    ]) {
      expect(de, contains(h));
    }
    expect(en, contains('treadplay-save-'));
    expect(de, contains('„Spielstand löschen“'));
    expect(en, contains('"Delete save game"'));
  });

  test('both languages have the same sections', () {
    List<String> numbers(String s) => RegExp(
      r'^## (\d+)\.',
      multiLine: true,
    ).allMatches(s).map((m) => m.group(1)!).toList();
    expect(numbers(de), numbers(en));
    expect(numbers(en), List.generate(10, (i) => '${i + 1}'));
  });

  test('the ads section is marked as interim until consent is wired', () {
    expect(en, contains('[Interim text: to be updated when AdMob'));
    expect(de, contains('[Übergangstext: wird aktualisiert, sobald AdMob'));
  });

  test('privacy says ads are currently switched off', () {
    expect(en, contains('**Currently off:** All monetization is switched off'));
    expect(
      de,
      contains('**Derzeit aus:** Die gesamte Monetarisierung ist abgeschaltet'),
    );
  });

  test('no claim that the app reads health stores', () {
    expect(en, contains('does not read Apple Health (HealthKit)'));
    expect(de, contains('liest weder Apple Health (HealthKit)'));
  });

  test('imprint and controller use the final address in EN and DE', () {
    final imprintEn = legalText(LegalDoc.imprint, 'en');
    final imprintDe = legalText(LegalDoc.imprint, 'de');
    final termsEn = legalText(LegalDoc.terms, 'en');
    final termsDe = legalText(LegalDoc.terms, 'de');

    const address = [
      'Philip Bender',
      'c/o IP-Management #12979',
      'Ludwig-Erhard-Straße 18',
      '20459 Hamburg',
      'kontakt.bender.interactive@gmail.com',
      '+49 176 70706133',
    ];
    for (final s in [en, de, imprintEn, imprintDe, termsEn, termsDe]) {
      for (final part in address) {
        expect(s, contains(part));
      }
    }

    expect(
      imprintEn,
      contains('Information pursuant to § 5 DDG (German Digital Services Act)'),
    );
    expect(imprintEn, contains('## Contact'));
    expect(imprintEn, contains('Email:'));
    expect(imprintEn, contains('Phone:'));
    expect(imprintEn, contains('Source: Impressum-Privatschutz'));

    expect(imprintDe, contains('## Inhalte gemäß § 5 DDG'));
    expect(imprintDe, contains('## Kontaktdaten'));
    expect(imprintDe, contains('E-Mail:'));
    expect(imprintDe, contains('Telefon:'));
    expect(imprintDe, contains('Quelle: Impressum-Privatschutz'));
  });

  test('legal texts have no leftover address placeholders', () {
    for (final doc in LegalDoc.values) {
      for (final lang in ['en', 'de']) {
        final s = legalText(doc, lang);
        expect(s, isNot(contains('[Contact person')));
        expect(s, isNot(contains('[Ansprechpartner')));
        expect(s, isNot(contains('[address · e-mail]')));
        expect(s, isNot(contains('[Anschrift · E-Mail]')));
      }
    }
  });
}
