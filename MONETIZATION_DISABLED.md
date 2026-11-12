# Monetarisierung abgeschaltet

Stand: 12. November 2026.

Philip hat die Gewerbeanmeldung von BENDER INTERACTIVE wegen offener Fragen beim Finanzamt verschoben. Bis er ausdrücklich grünes Licht gibt, läuft TreadPlay als kostenlose Version ohne Werbung und ohne jede Einnahme. Code wurde nicht gelöscht, sondern hinter einem zentralen Schalter abgeschaltet. Kein Store-Upload und kein Produktions-Deploy ohne ausdrückliches OK von Philip.

## Zentraler Schalter

```dart
// lib/config/monetization.dart
const bool monetizationEnabled = false;
```

Solange dieser Wert `false` ist, gilt alles unten. Zum Wiedereinschalten reicht in erster Linie, ihn auf `true` zu setzen (plus die Schritte am Ende dieser Datei).

## Was abgeschaltet wurde

### In der App (hinter dem Schalter)

| Stelle | Datei | Verhalten bei `false` |
|---|---|---|
| Ad-Service-Provider | `lib/ads/rewarded_ad_service.dart` | Liefert immer `UnavailableRewardedAdService`. Kein Fake-Ad, kein Plattform-Service. |
| AdMob-SDK | `lib/ads/google_rewarded_ad_service.dart` | `available` ist `false`. `show()` kehrt sofort mit `failed` zurück und ruft weder `MobileAds.instance.initialize()` noch `RewardedAd.load()` auf. |
| Video-Knopf | `lib/features/home/video_button.dart`, `lib/features/home/home_screen.dart` | Wird auf Home nicht gebaut (auch nicht, wenn ein Test einen Fake-Service einsetzt). |
| LP aus Videos | `lib/state/providers.dart` → `GameNotifier.claimVideo()` | Gibt immer `false` zurück, zahlt keine LP. |
| Datenschutztext | `lib/features/legal/legal_texts.dart`, gespiegelt in `docs/legal/privacy.md` | Abschnitt 5 sagt klar „Derzeit aus“ / „Currently off“: keine Werbung, kein Video-Knopf, kein SDK-Start, keine Werbedaten an Google. Die alte Beschreibung bleibt darunter als Text für das Wiedereinschalten. |

Die Spiellogik selbst (`lib/domain/video_rewards.dart`, `GameData.claimingVideo`, Speicherfeld `videos` im Spielstand) bleibt unverändert, damit sich die Funktion ohne Umbau wieder einschalten lässt. Sie ist nur nicht mehr über die Oberfläche oder den Notifier erreichbar.

### Native Einträge (bewusst stehen gelassen)

Die Google-Mobile-Ads-Bibliothek steht weiter in `pubspec.yaml` (`google_mobile_ads: ^7.0.0`). Die Test-App-IDs bleiben in den nativen Dateien, weil das SDK beim Linken eine `APPLICATION_ID` verlangt und die App sonst auf Android/iOS abstürzen kann:

- `android/app/src/main/AndroidManifest.xml`: `com.google.android.gms.ads.APPLICATION_ID` = Googles öffentliche Test-ID `ca-app-pub-3940256099942544~3347511713`
- `ios/Runner/Info.plist`: `GADApplicationIdentifier` = Googles öffentliche Test-ID `ca-app-pub-3940256099942544~1458002511`

Es sind weiterhin nur Test-IDs, keine echten Werbe-IDs von Philip. Das Dart-SDK wird nicht initialisiert, es wird keine Anzeige geladen, es fließt kein Geld. Vor einem echten Release müssen diese IDs ohnehin durch echte ersetzt werden (siehe `docs/HANDOFF_DEVIN_ADMOB.md`).

### Nicht vorhanden (nichts zu schalten)

Im gesamten Projekt gibt es kein AdSense, keine In-App-Käufe (`in_app_purchase`, RevenueCat), keine Spenden, keine Paywalls und keine bezahlten Store-Links. Datenschutz-Abschnitt 6 („Käufe / Purchases“) beschreibt Käufe nur für den Fall, dass eine spätere Version sie einschaltet – umgesetzt ist nichts davon.

`main.dart` startet das Ad-SDK nicht; das passierte schon vorher erst beim ersten Tipp auf den Video-Knopf. Dieser Knopf ist jetzt weg.

## Tests

- Neu: `test/config/monetization_test.dart` prüft, dass `monetizationEnabled` `false` ist. Dieser Test muss beim Wiedereinschalten auf `isTrue` gedreht (oder entfernt) werden.
- Neu: Widget-Test „video button stays hidden while monetization is off, even with a fake ad service“ in `test/widget_test.dart`. Läuft nur, solange der Schalter aus ist (`skip: monetizationEnabled`).
- Übersprungen, solange der Schalter aus ist: „video button pays 3 shrinking rewards, then dims“ in `test/widget_test.dart` (`skip: !monetizationEnabled`). Die Domain-Tests in `test/domain/video_rewards_test.dart` und der Spielstand-Test (`videos.watched`) laufen weiter, weil die Logik erhalten bleibt.
- `test/legal_texts_test.dart` prüft zusätzlich den Hinweis „Derzeit aus“ / „Currently off“.

## Auswirkung auf die Spielbalance

Belohnte Videos waren ein optionaler Zusatz, nie der Hauptweg zu LP. Pro Tag, abhängig von der Seltenheit des mitgenommenen Begleiters:

| Seltenheit | 3 Videos zusammen | Anteil an einem vollen Lauf (Puste-Tank) |
|---|---|---|
| Gewöhnlich | 5 LP | 33 % |
| Selten | 8 LP | 25 % |
| Episch | 14 LP | 20 % |
| Legendär | 24 LP | 17 % |

Das Spiel ist ohne diese Quelle voll spielbar; der Masterplan und der Datenschutztext sagen das schon. Es gibt kein Ausgleich-Redesign: Wer vorher Videos geschaut hat, verdient schlicht etwas weniger LP am Tag. Laufen bleibt der Hauptweg.

## Wieder einschalten

Nur nach ausdrücklichem Go von Philip:

1. In `lib/config/monetization.dart` `monetizationEnabled` auf `true` setzen.
2. In `test/config/monetization_test.dart` die Erwartung auf `isTrue` ändern (oder den Test entfernen). Die Skip-Bedingungen in `test/widget_test.dart` drehen sich dann von selbst: der „pays 3 rewards“-Test läuft wieder, der „stays hidden“-Test wird übersprungen.
3. Datenschutz-Abschnitt 5 in `lib/features/legal/legal_texts.dart` und `docs/legal/privacy.md` aktualisieren: den Hinweis „Derzeit aus“ / „Currently off“ entfernen oder ersetzen, und den Übergangstext durch den echten Text zur Einwilligung ersetzen, sobald UMP und ATT angebunden sind (siehe `docs/HANDOFF_DEVIN_ADMOB.md`). Den zugehörigen Test in `test/legal_texts_test.dart` anpassen.
4. Vor einem Release mit echten Anzeigen: echte AdMob-App- und Unit-IDs einsetzen (nicht die Test-IDs), UMP-Einwilligung und iOS-ATT verdrahten. Das macht Devin; Details stehen in `docs/HANDOFF_DEVIN_ADMOB.md`.
5. `flutter analyze`, `flutter test` und `scripts/check_forbidden_terms.sh` müssen grün sein.
6. Weiterhin: kein Merge auf `main`, kein Store-Upload, kein Produktions-Deploy, bis Philip „accepted“ bzw. ausdrücklich zustimmt.
