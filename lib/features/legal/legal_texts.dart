// Full privacy policy and terms of use, EN and DE.
// Source: docs/legal/privacy.md and docs/legal/terms.md. Bracketed
// placeholders stay until the provider data is filled in.

enum LegalDoc { privacy, terms }

String legalText(LegalDoc doc, String languageCode) {
  final de = languageCode == 'de';
  return switch (doc) {
    LegalDoc.privacy => de ? _privacyDe : _privacyEn,
    LegalDoc.terms => de ? _termsDe : _termsEn,
  };
}

const _privacyEn = r'''
Last updated: October 2026

## 1. Controller
BENDER INTERACTIVE  
[Contact person · address · e-mail — fill in before publishing]

## 2. Principle: your data stays on your device
TreadPlay is an offline game. Companions, Lauf Points, breath, seals, market state and settings are stored only in the app storage on your device. There is no user account, no login and no cloud sync. We cannot see your saves.

## 3. Movement and health
To count a walk, the app asks for motion or health access (Apple Health / HealthKit, or Google Health Connect / activity recognition, and location only if GPS is used for distance).

- Readings are used on the device to check pace and to award Lauf Points.
- We do not upload steps, routes, heart rate or GPS tracks.
- You can deny permission. Then the game cannot award points from real movement.
- iOS: Health data is also governed by Apple. Android: by Google Health Connect, if used.

## 4. No profile, no sale
We do not sell data. We do not build an advertising profile of you on our servers, because we do not run a game server for saves.

## 5. Ads (only if a later version enables them)
If a rewarded ad is shown, Google AdMob may process an advertising identifier and device data. In the EU/EEA, consent is requested via Google’s User Messaging Platform before the first ad. You can change that choice in Settings. Google: https://policies.google.com/technologies/ads  
V1 may ship with no ads. This section applies only once ads are on.

## 6. Purchases (only if a later version enables them)
Purchases run through Apple App Store or Google Play. We do not receive your card data. Only the on-device purchase status would be stored.

## 7. Export and deletion
Deleting the app deletes local saves. There is no account to erase on a server. A future export file leaves the device only if you share it yourself.

## 8. Children
TreadPlay is rated 9+. It is not directed at children under the age required by the store. We do not knowingly collect personal data from children.

## 9. Changes
We will update this text in the app if the data flow changes (for example if cloud backup is added).
''';

const _privacyDe = r'''
Stand: Oktober 2026

## 1. Verantwortlicher
BENDER INTERACTIVE  
[Ansprechpartner · Anschrift · E-Mail — vor Veröffentlichung eintragen]

## 2. Grundsatz: Deine Daten bleiben auf deinem Gerät
TreadPlay ist ein Offline-Spiel. Gefährten, Laufpunkte, Puste, Siegel, Marktstand und Einstellungen liegen nur im App-Speicher deines Geräts. Es gibt kein Benutzerkonto, keinen Login und keine Cloud. Wir können deine Spielstände nicht sehen.

## 3. Bewegung und Gesundheit
Damit ein Lauf zählt, fragt die App Zugriff auf Bewegung oder Gesundheit (Apple Health / HealthKit bzw. Google Health Connect / Aktivitätserkennung, und Standort nur, wenn GPS für die Distanz genutzt wird).

- Die Werte werden auf dem Gerät geprüft (Tempo, Laufpunkte).
- Wir laden keine Schritte, Routen, Herzfrequenz oder GPS-Spuren hoch.
- Du kannst die Freigabe ablehnen. Dann gibt es keine Punkte aus echter Bewegung.
- iOS: Gesundheitsdaten unterliegen zusätzlich Apple. Android: Google Health Connect, falls genutzt.

## 4. Kein Profil, kein Verkauf
Wir verkaufen keine Daten. Wir bauen kein Werbeprofil von dir auf unseren Servern, weil es für Spielstände keinen Server gibt.

## 5. Werbung (nur wenn eine spätere Version sie einschaltet)
Zeigt die App ein belohntes Video, kann Google AdMob eine Werbe-ID und Gerätedaten verarbeiten. In der EU/dem EWR wird vor der ersten Werbung die Einwilligung über die Google User Messaging Platform eingeholt. Die Auswahl kannst du in den Einstellungen ändern. Google: https://policies.google.com/technologies/ads  
V1 kann ohne Werbung erscheinen. Dieser Abschnitt gilt erst, wenn Werbung an ist.

## 6. Käufe (nur wenn eine spätere Version sie einschaltet)
Käufe laufen über den Apple App Store oder Google Play. Wir erhalten keine Kartendaten. Gespeichert würde nur der Kaufstatus auf dem Gerät.

## 7. Export und Löschen
App löschen löscht die lokalen Spielstände. Ein Konto zum Löschen auf einem Server gibt es nicht. Eine spätere Export-Datei verlässt das Gerät nur, wenn du sie selbst teilst.

## 8. Kinder
Altersfreigabe 9+. Die App richtet sich nicht an Kinder unter dem Store-Mindestalter. Wir erheben wissentlich keine personenbezogenen Daten von Kindern.

## 9. Änderungen
Ändert sich der Datenfluss (zum Beispiel Cloud-Backup), aktualisieren wir diesen Text in der App.
''';

const _termsEn = r'''
Last updated: October 2026

## 1. Provider
BENDER INTERACTIVE  
[address · e-mail]

## 2. What the app is
TreadPlay is a walking game with invented companions. Lauf Points, breath and seals are virtual items inside the app. They are not money and cannot be cashed out.

## 3. Licence
We grant you a personal, non-transferable licence to use the app. You may not copy the game, resell companions, or reverse engineer it except where the law allows.

## 4. Fair play
Points require real, plausible movement. Automated tapping, fake GPS and modified clients are not allowed. We may reset local progress that was produced that way, where we can detect it on device.

## 5. Health
The app is not medical advice. Stop if you feel unwell. You are responsible for where you walk.

## 6. Art
Companion and world art was created with Grok (xAI) and edited by TreadPlay. Credits stay in Settings.

## 7. Store rules
If you buy something later, Apple’s or Google’s terms apply to the payment.

## 8. Liability
The app is provided as is. We are not liable for lost local saves (device loss, uninstall) beyond what mandatory law requires.

## 9. Law
[German law / courts at the provider’s seat — confirm before publishing.]
''';

const _termsDe = r'''
Stand: Oktober 2026

## 1. Anbieter
BENDER INTERACTIVE  
[Anschrift · E-Mail]

## 2. Was die App ist
TreadPlay ist ein Laufspiel mit erfundenen Gefährten. Laufpunkte, Puste und Siegel sind virtuelle Gegenstände in der App. Sie sind kein Geld und nicht auszahlbar.

## 3. Lizenz
Du erhältst eine persönliche, nicht übertragbare Lizenz zur Nutzung. Kopieren des Spiels, Weiterverkauf von Gefährten und Reverse Engineering sind unzulässig, soweit das Gesetz nichts anderes erlaubt.

## 4. Faires Spiel
Punkte brauchen echte, plausible Bewegung. Automaten, falsches GPS und veränderte Clients sind nicht erlaubt. Lokal erkennbaren Fehlfortschritt dürfen wir auf dem Gerät zurücksetzen.

## 5. Gesundheit
Die App ist kein medizinischer Rat. Bei Unwohlsein aufhören. Du bist für deinen Weg verantwortlich.

## 6. Grafik
Gefährten und Welten wurden mit Grok (xAI) erstellt und von TreadPlay bearbeitet. Credits bleiben in den Einstellungen.

## 7. Store
Spätere Käufe unterliegen den Bedingungen von Apple oder Google.

## 8. Haftung
Die App wird wie gesehen bereitgestellt. Für verlorene lokale Spielstände (Geräteverlust, Deinstallation) haften wir nur, soweit zwingendes Recht das verlangt.

## 9. Recht
[Deutsches Recht / Gerichtsstand am Sitz — vor Veröffentlichung festlegen.]
''';
