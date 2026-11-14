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
      '## 8. Web version and hosting',
    ]) {
      expect(en, contains(h));
    }
    for (final h in [
      '## 3. Bewegung, Schritte und GPS',
      '## 5. Belohnte Videos (Werbung)',
      '## 7. Spielstand-Datei (Export und Import)',
      '## 8. Web-Version und Hosting',
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
    expect(numbers(en), List.generate(12, (i) => '${i + 1}'));
  });

  test('the public ads section is the short “currently off” sentence', () {
    expect(
      en,
      contains(
        'Currently no advertising; as soon as advertising is switched on, this statement will be updated beforehand and consent will be obtained.',
      ),
    );
    expect(
      de,
      contains(
        'Derzeit keine Werbung; sobald Werbung eingeschaltet wird, wird diese Erklärung vorher aktualisiert und eine Einwilligung eingeholt.',
      ),
    );
    // Long future-facing AdMob text stays internal, not in the public policy.
    expect(en, isNot(contains('Google User Messaging Platform')));
    expect(de, isNot(contains('Google User Messaging Platform')));
    expect(en, isNot(contains('[Interim text')));
    expect(de, isNot(contains('[Übergangstext')));
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
      '+49 152 22724856',
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

  test('privacy names GitHub Pages as the web host', () {
    for (final s in [en, de]) {
      expect(s, contains('GitHub Pages'));
      expect(s, contains('GitHub, Inc., 88 Colin P. Kelly Jr. Street'));
      expect(s, contains('San Francisco, CA 94107, USA'));
    }
    expect(en, contains('Data may be transferred to the USA.'));
    expect(de, contains('Daten können in die USA übermittelt werden.'));
    expect(en, contains('GitHub B.V., Prins Bernhardplein 200'));
    expect(de, contains('GitHub B.V., Prins Bernhardplein 200'));
    expect(en, contains('Art. 6 (1) (f) GDPR'));
    expect(de, contains('Art. 6 Abs. 1 lit. f DSGVO'));
    expect(en, contains('Art. 21 GDPR'));
    expect(de, contains('Art. 21 DSGVO'));
    expect(en, contains('§ 25 (2) no. 2 TDDDG'));
    expect(de, contains('§ 25 Abs. 2 Nr. 2 TDDDG'));
    expect(
      en,
      contains(
        'Fonts and the rendering engine (CanvasKit) are shipped with the app',
      ),
    );
    expect(
      de,
      contains(
        'Schriftarten und die Darstellungs-Engine (CanvasKit) werden mit der App ausgeliefert',
      ),
    );
    expect(en, isNot(contains('gstatic.com')));
    expect(de, isNot(contains('gstatic.com')));
    expect(en, isNot(contains('[name — fill in before publishing]')));
    expect(de, isNot(contains('[Name — vor Veröffentlichung eintragen]')));
  });

  test('terms have no place of jurisdiction clause', () {
    final termsEn = legalText(LegalDoc.terms, 'en');
    final termsDe = legalText(LegalDoc.terms, 'de');
    for (final s in [termsEn, termsDe]) {
      expect(s, isNot(contains('Gerichtsstand')));
      expect(s, isNot(contains('place of jurisdiction')));
      expect(s, isNot(contains('## 9. Law')));
      expect(s, isNot(contains('## 9. Recht')));
    }
    List<String> numbers(String s) => RegExp(
      r'^## (\d+)\.',
      multiLine: true,
    ).allMatches(s).map((m) => m.group(1)!).toList();
    expect(numbers(termsEn), List.generate(8, (i) => '${i + 1}'));
    expect(numbers(termsDe), numbers(termsEn));
  });

  test('legal texts have no leftover fill-in placeholders', () {
    for (final doc in LegalDoc.values) {
      for (final lang in ['en', 'de']) {
        final s = legalText(doc, lang);
        expect(s, isNot(contains('[Contact person')));
        expect(s, isNot(contains('[Ansprechpartner')));
        expect(s, isNot(contains('[address · e-mail]')));
        expect(s, isNot(contains('[Anschrift · E-Mail]')));
        expect(s, isNot(contains('fill in before publishing')));
        expect(s, isNot(contains('vor Veröffentlichung')));
        expect(s, isNot(contains('Gerichtsstand')));
        expect(s, isNot(contains('[')));
      }
    }
  });

  test(
    'imprint and terms § 1 name BENDER INTERACTIVE as a brand, not a legal entity',
    () {
      final imprintEn = legalText(LegalDoc.imprint, 'en');
      final imprintDe = legalText(LegalDoc.imprint, 'de');
      final termsEn = legalText(LegalDoc.terms, 'en');
      final termsDe = legalText(LegalDoc.terms, 'de');
      const brandDe =
          'BENDER INTERACTIVE ist die Geschäftsbezeichnung bzw. Marke von Philip Bender. Es handelt sich um keine juristische Person und kein im Handelsregister eingetragenes Unternehmen.';
      const brandEn =
          'BENDER INTERACTIVE is the trading name and brand of Philip Bender. It is not a legal entity and is not a company registered in the commercial register.';
      expect(imprintDe, contains(brandDe));
      expect(termsDe, contains(brandDe));
      expect(imprintEn, contains(brandEn));
      expect(termsEn, contains(brandEn));
      for (final s in [imprintEn, imprintDe, termsEn, termsDe]) {
        expect(s, isNot(contains('ODR')));
        expect(s, isNot(contains('Online-Streitbeilegung')));
      }
    },
  );

  test(
    'terms § 8 liability keeps intent, gross negligence and essential duties',
    () {
      final termsEn = legalText(LegalDoc.terms, 'en');
      final termsDe = legalText(LegalDoc.terms, 'de');
      expect(termsDe, contains('Vorsatz, grober Fahrlässigkeit'));
      expect(termsDe, contains('Verletzung von Leben, Körper oder Gesundheit'));
      expect(
        termsDe,
        contains(
          'leicht fahrlässige Verletzung wesentlicher Vertragspflichten',
        ),
      );
      expect(termsEn, contains('intent, gross negligence'));
      expect(termsEn, contains('injury to life, body or health'));
      expect(
        termsEn,
        contains(
          'slightly negligent breach of essential contractual obligations',
        ),
      );
    },
  );

  test(
    'privacy has a rights section with LfDI Baden-Württemberg and Art. 77',
    () {
      expect(en, contains('## 11. Your rights'));
      expect(de, contains('## 11. Deine Rechte'));
      expect(en, contains('Art. 15–21 GDPR'));
      expect(de, contains('Art. 15–21 DSGVO'));
      expect(en, contains('Art. 77 GDPR'));
      expect(de, contains('Art. 77 DSGVO'));
      expect(en, contains('https://www.baden-wuerttemberg.datenschutz.de/'));
      expect(de, contains('https://www.baden-wuerttemberg.datenschutz.de/'));
      expect(en, contains('Lautenschlagerstraße 20, 70173 Stuttgart'));
      expect(de, contains('Lautenschlagerstraße 20, 70173 Stuttgart'));
      expect(en, contains('Last updated: 13 November 2026'));
      expect(de, contains('Stand: 13.11.2026'));
    },
  );

  test('privacy mentions Telegram contact processing', () {
    expect(en, contains('## 10. Contact'));
    expect(de, contains('## 10. Kontakt'));
    expect(
      en,
      contains(
        'If you contact us via Telegram, your message and profile data are also processed by Telegram (Telegram Messenger Inc.) under its own privacy policy (https://telegram.org/privacy). We use your message only to answer your request.',
      ),
    );
    expect(
      de,
      contains(
        'Wenn du uns über Telegram kontaktierst, verarbeitet auch Telegram (Telegram Messenger Inc.) deine Nachricht und Profildaten nach eigener Datenschutzerklärung (https://telegram.org/privacy). Wir nutzen deine Nachricht nur, um deine Anfrage zu beantworten.',
      ),
    );
  });
}
