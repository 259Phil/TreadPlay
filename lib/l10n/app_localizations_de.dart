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
  String get breathRegenHint =>
      'Ein gemeinsamer Balken für alle Gefährten, +1 alle 90 min. Der mitgenommene Gefährte legt nur das Maximum fest.';

  @override
  String breathMax(int max) {
    return 'Puste max. $max';
  }

  @override
  String get breathEmptyHint =>
      'Außer Puste. Du kannst dich weiter bewegen, bekommst aber keine LP, bis sich der Balken erholt hat.';

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
  String get hintOutside =>
      'Außerhalb des Sweet Spots – Strecke zählt, keine LP';

  @override
  String get hintInside => 'Im Sweet Spot';

  @override
  String get hintNoBreath => 'Außer Puste – nur Tracking';

  @override
  String get demoTitle => 'Simulator (nur Debug-Build)';

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
  String get invalidRun => 'Nicht gewertet';

  @override
  String noRunsYet(String name) {
    return 'Noch keine Läufe. Nimm $name mit und los!';
  }

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

  @override
  String get appTagline => 'Lauf mit einem Gefährten.';

  @override
  String get tabShelf => 'Regal';

  @override
  String get typeMoss => 'Moos';

  @override
  String get typeBrook => 'Bach';

  @override
  String get typeGale => 'Bö';

  @override
  String get statStride => 'Stride';

  @override
  String get statGrit => 'Grit';

  @override
  String get statFortune => 'Fortune';

  @override
  String get statSpirit => 'Mut';

  @override
  String percentValue(String value) {
    return '$value %';
  }

  @override
  String get takeAlong => 'Mitnehmen';

  @override
  String get takenAlong => 'Dabei';

  @override
  String get levelUp => 'Aufleveln';

  @override
  String get repair => 'Reparieren';

  @override
  String get charms => 'Schmuck';

  @override
  String get charmSlotEmpty => 'Leer';

  @override
  String get notFoundYet => 'Noch nicht gefunden';

  @override
  String get filterWorld => 'Welt';

  @override
  String get filterType => 'Typ';

  @override
  String get filterRarity => 'Seltenheit';

  @override
  String get filterAll => 'Alle';

  @override
  String get shelfNothingHere => 'Mit diesen Filtern steht nichts im Regal.';

  @override
  String get worldMedieval => 'Mittelalter';

  @override
  String get worldSpace => 'Weltraum';

  @override
  String get worldUnderwater => 'Unterwasser';

  @override
  String get worldEgypt => 'Ägypten';

  @override
  String get worldJungle => 'Dschungel';

  @override
  String get worldPirate => 'Piraten';

  @override
  String get worldRobot => 'Roboter';

  @override
  String get worldRococo => 'Rokoko';

  @override
  String get worldSteampunk => 'Steampunk';

  @override
  String get worldCandy => 'Süßigkeiten';

  @override
  String get marketBuyTab => 'Kaufen';

  @override
  String get marketSellTab => 'Verkaufen';

  @override
  String get marketHint => 'Angebote und Preise wechseln im Lauf des Tages.';

  @override
  String shelfCount(int count, int cap) {
    return 'Regal $count/$cap';
  }

  @override
  String marketBuyFor(String price) {
    return 'Kaufen · $price';
  }

  @override
  String marketSellFor(String price) {
    return 'Verkaufen · $price';
  }

  @override
  String get marketGone => 'Dieses Angebot gibt es nicht mehr.';

  @override
  String marketShelfFull(int cap) {
    return 'Dein Regal ist voll ($cap/$cap). Verkaufe zuerst einen Gefährten.';
  }

  @override
  String get marketNotEnoughLp => 'Noch nicht genug LP.';

  @override
  String get marketNeedsSpirit => 'Handel nur bei 100 % Spirit.';

  @override
  String marketLastCompanion(String name) {
    return '$name bleibt, bis ein zweiter Gefährte in deinem Regal steht.';
  }

  @override
  String marketSellSwitches(String name) {
    return 'Danach geht $name mit dir.';
  }

  @override
  String get marketSoldOut => 'Alle Angebote sind weg. Später kommen neue.';

  @override
  String get settingsTerms => 'Nutzungsbedingungen';

  @override
  String get settingsMovement => 'Bewegungszugriff';

  @override
  String get settingsMovementOn =>
      'Echte Bewegung bringt LP. Die Werte bleiben auf dem Gerät.';

  @override
  String get settingsMovementOff => 'Aus: Echte Bewegung bringt keine LP.';

  @override
  String get movementNoticeTitle => 'Bewegung und Gesundheit';

  @override
  String get movementNoticeBody =>
      'Damit ein Lauf zählt, fragt TreadPlay Zugriff auf Bewegung oder Gesundheit (Apple Health bzw. Health Connect, Standort nur, wenn GPS für die Distanz genutzt wird). Die Werte bleiben auf dem Gerät und dienen nur dazu, dein Tempo zu prüfen und LP zu vergeben. Nichts wird hochgeladen. Lehnst du ab, gibt es keine LP aus echter Bewegung.';

  @override
  String get movementDeniedHint =>
      'Bewegungszugriff ist aus. Läufe bringen keine LP, bis du ihn erlaubst.';

  @override
  String get movementNoticePrivacyLink => 'Datenschutzerklärung lesen';

  @override
  String get movementAllow => 'Erlauben';

  @override
  String get movementDeny => 'Nicht jetzt';

  @override
  String todayKm(String km) {
    return 'Heute $km';
  }

  @override
  String sealName(String stat) {
    return '$stat-Siegel';
  }

  @override
  String sealBonus(int n, String stat) {
    return '+$n $stat';
  }

  @override
  String get forgeAlong => 'Siegel gehen an den Gefährten, den du dabeihast.';

  @override
  String forgeFreeSockets(int free, int total) {
    return '$free von $total Sockeln frei';
  }

  @override
  String get forgeRule =>
      'Jedes Siegel gibt +1 auf seinen Wert, höchstens +3 pro Wert. Bezahlt wird mit LP.';

  @override
  String forgeStatCount(int n) {
    return '+$n von +3';
  }

  @override
  String get forgeSet => 'Setzen';

  @override
  String get forgeMaxed => 'Max';

  @override
  String get forgeNeedsSpirit => 'Schmieden nur bei 100 % Mut.';

  @override
  String get forgeNotEnoughLp => 'Noch nicht genug LP.';

  @override
  String get forgeNoSocket => 'Kein freier Sockel mehr.';

  @override
  String get forgeSellNote =>
      'Siegel bleiben auf diesem Gefährten. Verkaufst du ihn, sind sie weg, LP gibt es nicht zurück.';

  @override
  String get forgeClearHint =>
      'Tippe auf einen vollen Sockel, um das Siegel zu entfernen.';

  @override
  String forgeClearTitle(String seal) {
    return '$seal entfernen?';
  }

  @override
  String get forgeClearBody =>
      'Der Sockel ist danach wieder leer. LP gibt es nicht zurück.';

  @override
  String get forgeClearAction => 'Entfernen';

  @override
  String get forgeClearKeep => 'Behalten';

  @override
  String get pace => 'Tempo';

  @override
  String paceValue(String pace) {
    return '$pace /km';
  }

  @override
  String get summaryBreathLeft => 'Puste übrig';

  @override
  String get runNoLp =>
      'Bewegungszugriff ist aus. Die Strecke wird nicht gelesen, dieser Lauf bringt keine LP.';

  @override
  String get summaryNoLp =>
      'Bewegungszugriff war aus, darum brachte dieser Lauf keine LP.';

  @override
  String get settingsHistory => 'Laufhistorie';

  @override
  String get historyTitle => 'Laufhistorie';

  @override
  String historyTotals(String km, int runs, String lp) {
    return '$km km · $runs Läufe · $lp LP insgesamt';
  }

  @override
  String get historyEmpty =>
      'Noch keine Läufe. Nach dem Stoppen erscheinen sie hier.';

  @override
  String get historyLocalNote =>
      'Nur auf diesem Gerät gespeichert. Keine Route, keine Karte.';

  @override
  String get historyErase => 'Lokale Aufzeichnung löschen';

  @override
  String get historyEraseTitle => 'Lokale Aufzeichnung löschen?';

  @override
  String get historyEraseBody =>
      'Alle gespeicherten Läufe auf diesem Gerät werden gelöscht. Deine Gesamtwerte für Meilensteine bleiben.';

  @override
  String get historyErased => 'Laufhistorie gelöscht.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get runDetailTitle => 'Lauf';

  @override
  String get date => 'Datum';

  @override
  String get breathUsed => 'Puste verbraucht';

  @override
  String get sweetSpotShare => 'Im Sweet Spot';

  @override
  String videoTooltip(String lp, int left) {
    return 'Optionales Video: +$lp LP (heute noch $left)';
  }

  @override
  String get videoTitle => 'Optionales Video';

  @override
  String videoBody(String lp, int max) {
    return 'Schau ein kurzes Video für +$lp LP. Bis zu $max am Tag, jedes etwas weniger. Laufen bringt immer mehr.';
  }

  @override
  String get videoWatch => 'Ansehen';

  @override
  String videoEarned(String lp) {
    return '+$lp LP aus dem Video';
  }

  @override
  String get videoSkipped => 'Video vorzeitig geschlossen. Diesmal keine LP.';

  @override
  String get videoFailed => 'Gerade ist kein Video verfügbar.';

  @override
  String get videoUsedUp =>
      'Die Videos für heute sind aufgebraucht. Morgen gibt es neue.';

  @override
  String get settingsSaveGame => 'Spielstand';

  @override
  String get saveHint =>
      'Dein Spielstand liegt nur auf diesem Gerät. Exportiere ihn als Datei, um eine Kopie zu behalten oder aufs neue Handy umzuziehen.';

  @override
  String get saveExport => 'Spielstand exportieren';

  @override
  String get saveNoExportYet => 'Noch kein Export';

  @override
  String saveLastExport(String date) {
    return 'Letzter Export: $date';
  }

  @override
  String get saveImport => 'Spielstand importieren';

  @override
  String get saveImportSub => 'Ersetzt den Spielstand auf diesem Gerät';

  @override
  String get saveDelete => 'Spielstand löschen';

  @override
  String get saveShareSubject => 'Treadplay Spielstand';

  @override
  String get saveExported => 'Spielstand exportiert.';

  @override
  String get saveDownloaded => 'Spielstand heruntergeladen.';

  @override
  String get saveImportTitle => 'Spielstand importieren?';

  @override
  String saveImportSummary(int companions, String lp, int runs, String date) {
    return 'Dieser Spielstand enthält $companions Gefährten, $lp LP und $runs gespeicherte Läufe. Exportiert: $date.\n\nErsetzen überschreibt deinen aktuellen Spielstand auf diesem Gerät.';
  }

  @override
  String get saveReplace => 'Ersetzen';

  @override
  String get saveImported => 'Spielstand importiert.';

  @override
  String get saveErrorNotASave => 'Diese Datei ist kein Treadplay-Spielstand.';

  @override
  String get saveErrorNewer =>
      'Dieser Spielstand stammt aus einer neueren Treadplay-Version. Aktualisiere zuerst die App.';

  @override
  String get saveErrorDamaged =>
      'Dieser Spielstand ist beschädigt und kann nicht geladen werden. Dein aktuelles Spiel bleibt unverändert.';

  @override
  String get saveErrorDuringRun => 'Während eines Laufs nicht möglich.';

  @override
  String get saveDeleteTitle => 'Spielstand löschen?';

  @override
  String get saveDeleteBody =>
      'Gefährten, Siegel, LP, Puste, Laufhistorie und Gesamtwerte werden entfernt. Du startest neu mit Pebble.';

  @override
  String get saveDeleteReallyTitle => 'Wirklich alles löschen?';

  @override
  String get saveDeleteReallyBody =>
      'Das kann nicht rückgängig gemacht werden. Ohne Export ist der Spielstand weg.';

  @override
  String get saveDeletePermanently => 'Endgültig löschen';

  @override
  String get saveDeleted => 'Spielstand gelöscht. Neustart mit Pebble.';

  @override
  String saveError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get wwTitle => 'Wanderweg';

  @override
  String wwWaymark(int n) {
    return 'Wegmarke $n';
  }

  @override
  String wwSettingsSub(int reached, int total, String km) {
    return '$reached von $total Wegmarken · nächste bei $km km';
  }

  @override
  String wwAllReached(int total) {
    return 'Alle $total Wegmarken erreicht. Der Weg wächst weiter.';
  }

  @override
  String wwLastAt(int n) {
    return 'Zuletzt an Wegmarke $n';
  }

  @override
  String get wwStartTitle => 'Der Weg beginnt';

  @override
  String wwStartLine(String km) {
    return 'Jeder gültige Lauf zählt. Die erste Wegmarke liegt $km km entfernt.';
  }

  @override
  String wwNext(int n) {
    return 'Nächste Wegmarke $n';
  }

  @override
  String wwKmTask(String km) {
    return '$km km insgesamt';
  }

  @override
  String wwKmValue(String done, String target) {
    return '$done / $target km';
  }

  @override
  String get wwLater => 'später';

  @override
  String get wwLaterNote =>
      '„später“: gibt es noch nicht im Spiel, zählt schon als erfüllt.';

  @override
  String get wwUnlocked => 'freigeschaltet';

  @override
  String get wwComingSoon => 'kommt mit einem Update';

  @override
  String get wwYou => 'du';

  @override
  String wwYouLeft(String km) {
    return 'noch $km km';
  }

  @override
  String get wwYouTask => 'Aufgabe offen';

  @override
  String wwReachedOne(int n, String unlock) {
    return 'Wegmarke $n erreicht · $unlock';
  }

  @override
  String wwReachedMany(int count) {
    return '$count Wegmarken erreicht';
  }

  @override
  String get wwOpenTrail => 'Zum Wanderweg';

  @override
  String wwFromWaymark(int n) {
    return 'ab Wegmarke $n';
  }

  @override
  String get wwLineLocked => 'Die Zeile des Boten wartet an dieser Wegmarke.';

  @override
  String wwForgeLocked(String km) {
    return 'Die Schmiede öffnet an Wegmarke 2 des Wanderwegs ($km km).';
  }

  @override
  String get wwClose => 'Schließen';

  @override
  String get wwTasks => 'Aufgaben';

  @override
  String get wwNoTask => 'Keine Aufgabe, nur Strecke.';

  @override
  String get wwTaskBrownPouch => '1 braunen Beutel öffnen';

  @override
  String get wwTaskCopperPouch => '1 Kupfer-Beutel öffnen';

  @override
  String get wwTaskTurquoisePouch => '1 Türkis-Beutel öffnen';

  @override
  String get wwTaskSealPlaced => '1 Siegel schmieden und einsetzen';

  @override
  String wwTaskSealsForged(int n) {
    return 'Insgesamt $n Siegel schmieden';
  }

  @override
  String get wwTaskSealL3 => '1 Siegel auf L3';

  @override
  String get wwTaskMessenger => '1 Boten treffen';

  @override
  String get wwTaskSweet58 => '1 Lauf mit Sweet Spot ≥ 58 %';

  @override
  String wwTaskSweet71(int n) {
    return '$n Läufe mit Sweet Spot ≥ 71 %';
  }

  @override
  String get wwTaskLeash => 'Leine füllen (alle 4 Clips mit Beutel)';

  @override
  String get wwTaskBuy => 'Zweiten Gefährten im Markt kaufen';

  @override
  String wwTaskLevel(int n) {
    return '1 Gefährte auf Level $n';
  }

  @override
  String get wwTaskCombine => '1× kombinieren';

  @override
  String get wwUnlockBrownPouch => 'Brauner Beutel';

  @override
  String get wwUnlockForge => 'Schmiede (Siegel L1)';

  @override
  String get wwUnlockMarketMedievalJungle =>
      'Markt +2 Arten (Mittelalter, Dschungel)';

  @override
  String get wwUnlockCopperPouch => 'Kupfer-Beutel';

  @override
  String get wwUnlockForgeL2 => 'Schmieden L2';

  @override
  String get wwUnlockWorldUnderwater => 'Welt Unterwasser + Arten';

  @override
  String get wwUnlockLeashClip4 => '4. Leinen-Clip';

  @override
  String get wwUnlockForgeL3 => 'Schmieden L3';

  @override
  String get wwUnlockMarketEgyptPirate => 'Markt +2 Arten (Ägypten, Piraten)';

  @override
  String get wwUnlockTurquoisePouch => 'Türkis-Beutel';

  @override
  String get wwUnlockWorldSteampunk => 'Welt Steampunk + Arten';

  @override
  String get wwUnlockForgeL4 => 'Schmieden L4';

  @override
  String get wwUnlockCombineL3 => 'Kombinieren L3';

  @override
  String get wwUnlockNavyPouch => 'Navy-Beutel';

  @override
  String get wwUnlockWorldSpaceRobot => 'Welt Weltraum + Roboter + Arten';

  @override
  String get wwUnlockForgeL5 => 'Schmieden L5';

  @override
  String get wwUnlockShelfPlus2 => 'Regal +2 Plätze (12→14)';

  @override
  String get wwUnlockCombineL5 => 'Kombinieren L5';

  @override
  String get wwUnlockWorldRococoCandy => 'Welt Rokoko + Süßigkeiten + Arten';

  @override
  String get wwLine1 =>
      'Ein Begleiter wächst nicht im Regal. Er wächst neben dir, Schritt für Schritt.';

  @override
  String get wwLine2 => 'Was ihr unterwegs findet, gehört euch beiden.';

  @override
  String get wwLine3 =>
      'Neue Spuren im Markt. Doch kein Begleiter kommt weit, wenn er nur getragen wird.';

  @override
  String get wwLine4 => 'Ein Siegel hält nur, was der Weg hineingelegt hat.';

  @override
  String get wwLine5 =>
      'Zwei gleiche Siegel, ein Feuer. Geduld ist das dritte Teil.';

  @override
  String get wwLine6 => 'Im richtigen Tempo hört ihr einander atmen.';

  @override
  String get wwLine7 => 'Ein Clip mehr heißt: mehr, das mit euch heimkommt.';

  @override
  String get wwLine8 =>
      'Die erste Glut im Messing. Sie brennt nur, weil ihr gegangen seid.';

  @override
  String get wwLine9 =>
      'Ferne Länder schicken ihre Tiere. Sie suchen jemanden, der mit ihnen geht.';

  @override
  String get wwLine10 => 'Eine volle Leine ist ein voller Weg.';

  @override
  String get wwLine11 =>
      'Dampf und Zahnräder. Auch Maschinen lernen erst unterwegs.';

  @override
  String get wwLine12 => 'Fünfmal geschmiedet. Jetzt wissen es deine Hände.';

  @override
  String get wwLine13 =>
      'Zwei Kräfte in einem Siegel, wie zwei, die denselben Weg gehen.';

  @override
  String get wwLine14 => 'Zu zweit wird der Weg nicht kürzer, aber heller.';

  @override
  String get wwLine15 =>
      'Selbst zwischen den Sternen zählt nur der nächste Schritt.';

  @override
  String get wwLine16 => 'Die Krone wird nicht verliehen. Sie wird gegangen.';

  @override
  String get wwLine17 =>
      'Mehr Platz im Regal. Das Wachsen passiert trotzdem draußen.';

  @override
  String get wwLine18 => 'Wer den Takt hält, dem folgt die Glut.';

  @override
  String get wwLine19 =>
      'Kein Ende, nur eine Biegung. Der Weg wächst mit euch.';
}
