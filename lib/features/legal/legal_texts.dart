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
TreadPlay works without a user account, login or cloud sync, and we run no game server. Companions, Lauf Points, Breath, seals, market, run history and settings are stored only in the app storage on your device (web version: in your browser's local storage). We cannot see your saves.

## 3. Movement, steps and GPS
A run counts real movement. Before the first run the app explains this and asks you. Only if you agree, and only while a run is active, it uses:

- Location (GPS) to measure the distance. Your phone or browser asks for location permission separately.
- The step counter of your phone (Android: physical activity, iOS: Motion & Fitness) when GPS is weak. Not in the web version.
- Positions are processed only on your device, to measure distance and check your pace. During a run only the last position is kept in memory. No route and no coordinates are saved or uploaded.
- After a run, only a summary is saved on the device: start time, duration, distance, steps, Lauf Points and game values.
- The app does not read Apple Health (HealthKit) or Google Health Connect.
- You can say no, or switch off "Movement access" in Settings. Then the app does not use location or the step counter, and real movement earns no Lauf Points. The game stays playable.

## 4. No profile, no sale
We do not sell data and we do not build a profile of you. For the rewarded videos, see section 5.

## 5. Rewarded videos (ads)
[Interim text: to be updated when AdMob and the consent query (Google UMP, iOS tracking prompt) are connected.]

- The Android and iOS apps offer an optional button for up to 3 rewarded videos a day, each for a few extra Lauf Points. Watching is voluntary. You can play the whole game without videos; running stays the main way to earn.
- The app requests a video from Google only after you tap the button and confirm.
- Provider: Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Ireland (Google AdMob). When a video is loaded and shown, Google may process device and usage data such as IP address, device type, app information, ad interactions and, where available, your device's advertising ID. Details: https://policies.google.com/technologies/ads and https://policies.google.com/privacy
- Personalised ads use your advertising ID and earlier activity to pick ads for you. Non-personalised ads are chosen only from context (for example this app and a rough location from the IP address). Google may still use data for frequency capping, ad measurement and fraud prevention.
- Your choice: this version does not yet show its own consent dialog. Before real ads are switched on, a consent query (Google User Messaging Platform) will be added. You will then be able to choose between personalised and non-personalised ads and change your choice at any time under Settings → Privacy settings.
- iOS: the app does not ask for tracking permission at the moment, so iOS does not give it your advertising ID (IDFA). Android: you can reset or delete your advertising ID in the system settings.
- The web version shows no videos and no ads.

## 6. Purchases (only if a later version enables them)
Purchases run through Apple App Store or Google Play. We do not receive your card data. Only the on-device purchase status would be stored.

## 7. Save-game file (export and import)
Under Settings → Save game you can export your save as a file (treadplay-save-<date>.json).

- Content: a format tag, a version number, the export time and your whole game: companions with rarity, level and seals, Lauf Points, Breath, market, forge, pouches, trail progress, messengers, today's video count, lifetime totals and your run history (start time, duration, distance, steps and Lauf Points per run).
- Not included: GPS coordinates or routes, name, e-mail, device IDs, and the device settings (language, sound, movement access).
- Android and iOS: the app writes the file to its own app folder and opens the system share sheet. You decide where it goes (for example Files, mail, a cloud drive). Web: your browser downloads the file.
- The app never uploads the file. We and others only receive it if you send it to them yourself. Wherever you store or send it, that service's terms apply. Anyone who has the file can import your game, so you are responsible for whom you share it with.
- Import reads only the file you pick and replaces the current game after you confirm.
- "Delete save game" (two confirmations) resets the game on this device to a fresh start; your settings stay. It does not delete files you already exported: delete copies you saved elsewhere yourself. The copy in the app folder is removed when you uninstall the app.
- Uninstalling the app (web: clearing the site data) deletes all local data. There is no account to erase on a server.

## 8. Web version
- The game data stays in your browser's local storage on this device.
- The page is delivered by our hosting provider [name — fill in before publishing]. Its servers technically process your IP address and log access.
- When the page loads, your browser fetches the Flutter rendering engine (CanvasKit) from Google servers (www.gstatic.com). Google receives your IP address for this.
- Location comes from your browser, only during a run and only with your browser's permission. During a run the app keeps the screen awake.

## 9. Children
TreadPlay is rated 9+. It is not directed at children under the age required by the store. We do not knowingly collect personal data from children.

## 10. Changes
We will update this text in the app if the data flow changes (for example when the ad consent query or cloud backup is added).
''';

const _privacyDe = r'''
Stand: Oktober 2026

## 1. Verantwortlicher
BENDER INTERACTIVE  
[Ansprechpartner · Anschrift · E-Mail — vor Veröffentlichung eintragen]

## 2. Grundsatz: Deine Daten bleiben auf deinem Gerät
TreadPlay funktioniert ohne Benutzerkonto, Login und Cloud, und wir betreiben keinen Spielserver. Gefährten, Laufpunkte, Puste, Siegel, Markt, Laufverlauf und Einstellungen liegen nur im App-Speicher deines Geräts (Web-Version: im lokalen Speicher deines Browsers). Wir können deine Spielstände nicht sehen.

## 3. Bewegung, Schritte und GPS
Ein Lauf zählt echte Bewegung. Vor dem ersten Lauf erklärt die App das und fragt dich. Nur wenn du zustimmst, und nur während ein Lauf läuft, nutzt sie:

- Den Standort (GPS), um die Strecke zu messen. Dein Handy bzw. Browser fragt die Standort-Freigabe zusätzlich ab.
- Den Schrittzähler deines Handys (Android: Körperliche Aktivität, iOS: Bewegung & Fitness), wenn GPS schwach ist. Nicht in der Web-Version.
- Positionen werden nur auf deinem Gerät verarbeitet, um die Strecke zu messen und dein Tempo zu prüfen. Während des Laufs bleibt nur die letzte Position im Arbeitsspeicher. Keine Route und keine Koordinaten werden gespeichert oder hochgeladen.
- Nach dem Lauf wird nur eine Zusammenfassung auf dem Gerät gespeichert: Startzeit, Dauer, Strecke, Schritte, Laufpunkte und Spielwerte.
- Die App liest weder Apple Health (HealthKit) noch Google Health Connect.
- Du kannst ablehnen oder „Bewegungszugriff“ in den Einstellungen ausschalten. Dann nutzt die App weder Standort noch Schrittzähler, und echte Bewegung bringt keine Laufpunkte. Spielbar bleibt das Spiel trotzdem.

## 4. Kein Profil, kein Verkauf
Wir verkaufen keine Daten und bilden kein Profil über dich. Zu den belohnten Videos siehe Abschnitt 5.

## 5. Belohnte Videos (Werbung)
[Übergangstext: wird aktualisiert, sobald AdMob und die Einwilligungsabfrage (Google UMP, iOS-Tracking-Abfrage) angebunden sind.]

- Die Android- und iOS-App bieten einen freiwilligen Knopf für bis zu 3 belohnte Videos am Tag, jeweils für ein paar zusätzliche Laufpunkte. Anschauen ist freiwillig. Du kannst das ganze Spiel ohne Videos spielen; Laufen bleibt der Hauptweg zu Punkten.
- Die App fordert ein Video bei Google erst an, wenn du den Knopf tippst und bestätigst.
- Anbieter: Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Irland (Google AdMob). Wenn ein Video geladen und gezeigt wird, kann Google Geräte- und Nutzungsdaten verarbeiten, etwa IP-Adresse, Gerätetyp, App-Informationen, Interaktionen mit der Werbung und, falls verfügbar, die Werbe-ID deines Geräts. Details: https://policies.google.com/technologies/ads und https://policies.google.com/privacy
- Personalisierte Werbung nutzt deine Werbe-ID und frühere Aktivitäten, um Werbung für dich auszuwählen. Nicht personalisierte Werbung wird nur nach dem Kontext gewählt (zum Beispiel diese App und ein ungefährer Ort aus der IP-Adresse). Google kann Daten trotzdem zur Begrenzung der Häufigkeit, zur Messung und gegen Betrug nutzen.
- Deine Wahl: Diese Version zeigt noch keinen eigenen Einwilligungsdialog. Bevor echte Werbung eingeschaltet wird, kommt eine Einwilligungsabfrage (Google User Messaging Platform) dazu. Dann kannst du zwischen personalisierter und nicht personalisierter Werbung wählen und deine Wahl jederzeit unter Einstellungen → Datenschutz-Einstellungen ändern.
- iOS: Die App fragt derzeit keine Tracking-Erlaubnis ab, daher gibt iOS ihr deine Werbe-ID (IDFA) nicht. Android: Deine Werbe-ID kannst du in den Systemeinstellungen zurücksetzen oder löschen.
- Die Web-Version zeigt keine Videos und keine Werbung.

## 6. Käufe (nur wenn eine spätere Version sie einschaltet)
Käufe laufen über den Apple App Store oder Google Play. Wir erhalten keine Kartendaten. Gespeichert würde nur der Kaufstatus auf dem Gerät.

## 7. Spielstand-Datei (Export und Import)
Unter Einstellungen → Spielstand kannst du deinen Spielstand als Datei exportieren (treadplay-save-<Datum>.json).

- Inhalt: eine Formatkennung, eine Versionsnummer, der Exportzeitpunkt und dein ganzes Spiel: Gefährten mit Seltenheit, Stufe und Siegeln, Laufpunkte, Puste, Markt, Schmiede, Beutel, Wanderweg-Fortschritt, Boten, die Zahl der heutigen Videos, Gesamtwerte und dein Laufverlauf (Startzeit, Dauer, Strecke, Schritte und Laufpunkte pro Lauf).
- Nicht enthalten: GPS-Koordinaten oder Routen, Name, E-Mail, Geräte-IDs und die Geräteeinstellungen (Sprache, Ton, Bewegungszugriff).
- Android und iOS: Die App legt die Datei in ihrem eigenen App-Ordner ab und öffnet das Teilen-Menü des Systems. Du entscheidest, wohin sie geht (zum Beispiel Dateien, Mail, ein Cloud-Speicher). Web: Dein Browser lädt die Datei herunter.
- Die App lädt die Datei nie hoch. Wir und andere erhalten sie nur, wenn du sie selbst schickst. Wo du sie speicherst oder hinschickst, gelten die Bedingungen dieses Dienstes. Wer die Datei hat, kann deinen Spielstand importieren; du bist also selbst dafür verantwortlich, mit wem du sie teilst.
- Import liest nur die Datei, die du auswählst, und ersetzt das aktuelle Spiel erst nach deiner Bestätigung.
- „Spielstand löschen“ (zwei Bestätigungen) setzt das Spiel auf diesem Gerät auf einen frischen Start zurück; deine Einstellungen bleiben. Bereits exportierte Dateien löscht es nicht: Kopien, die du woanders gespeichert hast, löschst du selbst. Die Kopie im App-Ordner wird beim Deinstallieren der App entfernt.
- App deinstallieren (Web: Websitedaten löschen) löscht alle lokalen Daten. Ein Konto zum Löschen auf einem Server gibt es nicht.

## 8. Web-Version
- Die Spieldaten bleiben im lokalen Speicher deines Browsers auf diesem Gerät.
- Die Seite wird von unserem Hosting-Anbieter ausgeliefert [Name — vor Veröffentlichung eintragen]. Dessen Server verarbeiten technisch bedingt deine IP-Adresse und protokollieren Zugriffe.
- Beim Laden holt dein Browser die Flutter-Darstellungs-Engine (CanvasKit) von Google-Servern (www.gstatic.com). Google erhält dafür deine IP-Adresse.
- Den Standort liefert dein Browser, nur während eines Laufs und nur mit seiner Freigabe. Während eines Laufs hält die App den Bildschirm wach.

## 9. Kinder
Altersfreigabe 9+. Die App richtet sich nicht an Kinder unter dem Store-Mindestalter. Wir erheben wissentlich keine personenbezogenen Daten von Kindern.

## 10. Änderungen
Ändert sich der Datenfluss (zum Beispiel durch die Einwilligungsabfrage für Werbung oder ein Cloud-Backup), aktualisieren wir diesen Text in der App.
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
