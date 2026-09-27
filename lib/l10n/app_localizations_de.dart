// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Treadplay';

  @override
  String get tabHome => 'Start';

  @override
  String get tabGarage => 'Garage';

  @override
  String get tabForge => 'Schmiede';

  @override
  String get tabMarket => 'Markt';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String lpAmount(String lp) {
    return '$lp LP';
  }

  @override
  String levelShort(int level) {
    return 'Lv $level';
  }

  @override
  String get breath => 'Puste';

  @override
  String breathValue(String current, int max) {
    return '$current / $max';
  }

  @override
  String get breathRegenHint => '+1 alle 90 min, pro Schuh';

  @override
  String get breathEmptyHint =>
      'Dieser Schuh ist außer Puste. Du kannst dich weiter bewegen, bekommst aber keine LP, bis er sich erholt hat.';

  @override
  String get typeStomper => 'Stomper';

  @override
  String get typeStrider => 'Strider';

  @override
  String get typeDasher => 'Dasher';

  @override
  String get rarityCommon => 'Gewöhnlich';

  @override
  String get rarityRare => 'Selten';

  @override
  String get rarityEpic => 'Episch';

  @override
  String get rarityLegendary => 'Legendär';

  @override
  String sweetSpotAt(String speed) {
    return 'Sweet Spot $speed km/h';
  }

  @override
  String get startRun => 'Los';

  @override
  String get stopRun => 'Stopp';

  @override
  String get distance => 'Distanz';

  @override
  String get time => 'Zeit';

  @override
  String get speed => 'Tempo';

  @override
  String get steps => 'Schritte';

  @override
  String kmValue(String km) {
    return '$km km';
  }

  @override
  String kmhValue(String kmh) {
    return '$kmh km/h';
  }

  @override
  String get lpThisRun => 'LP in diesem Lauf';

  @override
  String get hintStanding => 'Bleib in Bewegung – Stehen bringt nichts.';

  @override
  String get hintOutside => 'Außerhalb des Sweet Spots';

  @override
  String get hintInside => 'Im Sweet Spot';

  @override
  String get hintNoBreath => 'Außer Puste – nur Tracking';

  @override
  String get demoTitle => 'Demo-Bewegung (echtes GPS folgt)';

  @override
  String get demoTimeLapse => '10× Zeit';

  @override
  String get summaryTitle => 'Lauf beendet';

  @override
  String get summaryInvalid =>
      'Die Bewegung sah nicht plausibel aus, deshalb gibt es keine LP. Distanz und Zeit sind trotzdem gespeichert.';

  @override
  String get summaryLp => 'LP verdient';

  @override
  String get summaryBreathUsed => 'Puste verbraucht';

  @override
  String get done => 'Fertig';

  @override
  String get lastRun => 'Letzter Lauf';

  @override
  String get noRunsYet => 'Noch keine Läufe. Zieh Cobble an und los!';

  @override
  String get invalidRun => 'Nicht gewertet';

  @override
  String get comingSoon => 'Kommt in einem späteren Update.';

  @override
  String get garageTeaser =>
      'Dein Schuhregal: Schuhe sammeln, leveln und reparieren.';

  @override
  String get forgeTeaser =>
      'Die Schmiede: Siegel in Schnallen setzen und stärkere schmieden.';

  @override
  String get marketTeaser =>
      'Der Markt: Schuhe und Reparaturkits für LP kaufen.';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsKaching => 'Ka-ching-Sound';

  @override
  String get settingsHealthTitle => 'Gesundheitsdaten';

  @override
  String get settingsHealthBody =>
      'Treadplay liest Schritte und Distanz aus Apple Health oder Health Connect nur während eines Laufs. Apple und Google speichern deine Gesundheitsdaten unabhängig von uns. Wir laden sie nie hoch.';

  @override
  String get settingsPrivacyTitle => 'Datenschutz';

  @override
  String get settingsPrivacyBody =>
      'Deine Routen und Läufe bleiben auf diesem Gerät. Kein Konto, keine Cloud.';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get creditsArtwork =>
      'Artwork erstellt mit Grok (xAI) und bearbeitet von Treadplay.';
}
