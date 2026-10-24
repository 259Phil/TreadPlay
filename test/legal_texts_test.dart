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

  test('no claim that the app reads health stores', () {
    expect(en, contains('does not read Apple Health (HealthKit)'));
    expect(de, contains('liest weder Apple Health (HealthKit)'));
  });
}
