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
  String get runWebGpsHint =>
      'Bildschirm an und diese Seite offen lassen – im Hintergrund pausiert der Browser das GPS.';

  @override
  String get hintGpsWarmup => 'GPS wird genauer – kurz warten …';

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
  String get settingsHealthTitle => 'Bewegungsdaten';

  @override
  String get settingsHealthBody =>
      'Treadplay nutzt Standort (GPS) und Schrittzähler nur während eines Laufs und nur auf diesem Gerät. Gespeichert wird nur die Zusammenfassung des Laufs, keine Route. Nichts wird hochgeladen.';

  @override
  String get settingsPrivacyTitle => 'Datenschutz';

  @override
  String get settingsPrivacyBody =>
      'Deine Läufe und dein Spielstand bleiben auf diesem Gerät. Kein Konto, keine Cloud.';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get creditsArtwork =>
      'Artwork erstellt mit Grok (xAI) und bearbeitet von Treadplay.';

  @override
  String get appTagline => 'Lauf mit einem Gefährten.';

  @override
  String get tabShelf => 'Gehege';

  @override
  String get typeMoss => 'Schritt';

  @override
  String get typeBrook => 'Trab';

  @override
  String get typeGale => 'Galopp';

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
  String get filterType => 'Tempo';

  @override
  String get filterRarity => 'Seltenheit';

  @override
  String get filterAll => 'Alle';

  @override
  String get shelfNothingHere => 'Mit diesen Filtern ist niemand im Gehege.';

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
  String get marketRestockSoon => 'Die Händler packen bald neu.';

  @override
  String shelfCount(int count, int cap) {
    return 'Gehege $count/$cap';
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
    return 'Dein Gehege ist voll ($cap/$cap). Verkaufe zuerst einen Gefährten.';
  }

  @override
  String get marketNotEnoughLp => 'Noch nicht genug LP.';

  @override
  String get marketNeedsSpirit => 'Handel nur bei 100 % Spirit.';

  @override
  String marketLastCompanion(String name) {
    return '$name bleibt, bis ein zweiter Gefährte in deinem Gehege lebt.';
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
  String get movementNoticeTitle => 'Bewegung und Standort';

  @override
  String get movementNoticeBody =>
      'Damit ein Lauf zählt, nutzt TreadPlay während des Laufs deinen Standort (GPS) und den Schrittzähler. Die Werte bleiben auf dem Gerät und dienen nur dazu, Strecke und Tempo zu messen und LP zu vergeben. Keine Route wird gespeichert, nichts wird hochgeladen. Lehnst du ab, gibt es keine LP aus echter Bewegung.';

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
  String forgeFreeSockets(int free, int total) {
    return '$free von $total Sockeln frei';
  }

  @override
  String get forgeRule =>
      'Jedes Siegel hebt seinen Wert anteilig: St.1 +4 %, St.2 +9 %, St.3 +15 %, St.4 +22 %, St.5 +31 %.';

  @override
  String get forgeNeedsSpirit => 'Einsetzen nur bei 100 % Mut.';

  @override
  String get forgeNotEnoughLp => 'Noch nicht genug LP.';

  @override
  String get forgeNoSocket => 'Kein freier Sockel mehr.';

  @override
  String get forgeSellNote =>
      'Verkaufst du einen Gefährten, kommen seine Siegel zurück in den Vorrat.';

  @override
  String get forgeClearHint =>
      'Tippe auf ein Siegel, um es herauszunehmen, oder auf einen leeren Sockel zum Einsetzen.';

  @override
  String forgeClearTitle(String seal) {
    return '$seal herausnehmen?';
  }

  @override
  String get forgeClearBody =>
      'Es kommt zurück in den Vorrat. Nichts geht verloren.';

  @override
  String get forgeClearAction => 'Herausnehmen';

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
      'Gefährten, Siegel, LP, Puste, Laufhistorie und Gesamtwerte werden entfernt, ebenso die Export-Kopien, die die App selbst abgelegt hat. Du startest neu mit Mossik. Dateien, die du woanders gespeichert oder geteilt hast, bleiben erhalten.';

  @override
  String get saveDeleteReallyTitle => 'Wirklich alles löschen?';

  @override
  String get saveDeleteReallyBody =>
      'Das kann nicht rückgängig gemacht werden. Zurück holt den Spielstand nur eine Export-Datei, die du außerhalb der App gespeichert hast.';

  @override
  String get saveDeletePermanently => 'Endgültig löschen';

  @override
  String get saveDeleted => 'Spielstand gelöscht. Neustart mit Mossik.';

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
  String get wwUnlockShelfPlus2 => 'Gehege +2 Plätze (12→14)';

  @override
  String get wwUnlockCombineL5 => 'Kombinieren L5';

  @override
  String get wwUnlockWorldRococoCandy => 'Welt Rokoko + Süßigkeiten + Arten';

  @override
  String get wwLine1 =>
      'Ein Begleiter wächst nicht im Gehege. Er wächst neben dir, Schritt für Schritt.';

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
      'Mehr Platz im Gehege. Das Wachsen passiert trotzdem draußen.';

  @override
  String get wwLine18 => 'Wer den Takt hält, dem folgt die Glut.';

  @override
  String get wwLine19 =>
      'Kein Ende, nur eine Biegung. Der Weg wächst mit euch.';

  @override
  String get forgeIntro =>
      'Siegel liegen im Vorrat. Einsetzen kannst du sie beim Gefährten, den du dabeihast.';

  @override
  String forgeCompanionLine(String name, String rarity, int total) {
    return '$name · $rarity · $total Sockel';
  }

  @override
  String sealLevel(int n) {
    return 'Stufe $n';
  }

  @override
  String sealLevelShort(int n) {
    return 'St.$n';
  }

  @override
  String sealStatBonus(String stat, String pct) {
    return '$stat +$pct %';
  }

  @override
  String sealComboName(String a, String b) {
    return '$a + $b';
  }

  @override
  String sealComboBonus(String pct) {
    return '+$pct % / +$pct %';
  }

  @override
  String statBonus(String pct) {
    return '+$pct %';
  }

  @override
  String statCapped(String pct) {
    return '+$pct % (Grenze)';
  }

  @override
  String get forgeModeUp => 'Aufwerten';

  @override
  String get forgeModeCombine => 'Kombinieren';

  @override
  String get forgeUpTitle => 'Schmieden: 2 gleiche Siegel + Glut';

  @override
  String get forgeCombineTitle => 'Kombinieren: 2 verschiedene Siegel + Glut';

  @override
  String forgeGlutCost(int n) {
    return '+ $n Glut';
  }

  @override
  String forgeLpCost(String lp) {
    return '+ $lp LP';
  }

  @override
  String forgeFailNote(String pct) {
    return 'Fehlschlag $pct % · dann wird 1 Siegel zu 3 Splittern';
  }

  @override
  String forgeGlutRange(int min, int max) {
    return 'Glut $min–$max: jede Glut mehr senkt den Fehlschlag.';
  }

  @override
  String forgeGlutFixed(int n) {
    return 'Braucht genau $n Glut.';
  }

  @override
  String get forgePickSeal => 'Wähle unten im Vorrat ein Siegel.';

  @override
  String get forgePickPartner =>
      'Wähle jetzt ein Siegel eines anderen Werts mit gleicher Stufe.';

  @override
  String get forgeCaseNone => 'Noch keine losen Siegel.';

  @override
  String get forgeCase => 'Vorrat';

  @override
  String get forgeCaseEmpty =>
      'Noch keine losen Siegel. Kaufe ein Siegel L1 im Tab Vorrat.';

  @override
  String get forgeGlutSource =>
      'Glut kommt aus Beuteln. Ein Lauf ab 1 km ohne Beutel bringt trotzdem 1 Glut.';

  @override
  String forgeBuyTitle(String lp) {
    return 'Neues Siegel L1 · $lp LP';
  }

  @override
  String get forgeMeltTitle => '5 Splitter zu einem Siegel L1 schmelzen';

  @override
  String get forgeAction => 'Schmieden';

  @override
  String get forgeCombineAction => 'Kombinieren';

  @override
  String forgeSetAction(String name) {
    return 'In $name einsetzen';
  }

  @override
  String forgeLevelLocked(int n, int wm) {
    return 'Schmieden St.$n öffnet an Wegmarke $wm.';
  }

  @override
  String forgeCombineLocked(int n, int wm) {
    return 'Kombinieren St.$n öffnet an Wegmarke $wm.';
  }

  @override
  String get forgeNeedsPair => 'Braucht 2 gleiche Siegel im Vorrat.';

  @override
  String get forgeNeedsGlut => 'Noch nicht genug Glut.';

  @override
  String get forgeTopLevel => 'Stufe 5 ist die höchste Stufe.';

  @override
  String get forgeComboFinal => 'Kombi-Siegel werden nicht weiter geschmiedet.';

  @override
  String get forgeBadCombine =>
      'Braucht zwei Einzelsiegel verschiedener Werte auf Stufe 3 oder 5.';

  @override
  String get forgeSuccessTitle => 'Geschmiedet';

  @override
  String forgeSuccessBody(String seal) {
    return '$seal liegt jetzt im Vorrat.';
  }

  @override
  String get forgeFailTitle => 'Fehlschlag';

  @override
  String forgeFailBody(String seal) {
    return '$seal ist zu 3 Splittern zerfallen. Das andere Siegel liegt wieder im Vorrat.';
  }

  @override
  String get forgeOk => 'OK';

  @override
  String get forgeLadder => 'Stufen';

  @override
  String get forgeLadderTitle => 'Siegel-Stufen';

  @override
  String get forgeLadderNote =>
      'Höchstens +47 % pro Wert aus allen Siegeln zusammen. Kombi-Siegel machen einen Sockel frei, geben in Summe aber weniger.';

  @override
  String get forgePickTitle => 'Siegel einsetzen';

  @override
  String get summaryGlut => 'Glut für die Schmiede';

  @override
  String glutAmount(int n) {
    return '+$n Glut';
  }

  @override
  String get pouchTitle => 'Beutel';

  @override
  String get pouchBrown => 'Brauner Beutel';

  @override
  String get pouchCopper => 'Kupfer-Beutel';

  @override
  String get pouchTurquoise => 'Türkis-Beutel';

  @override
  String get pouchNavy => 'Navy-Beutel';

  @override
  String get pouchContentsBrown =>
      'Glut 1–2, dazu ein Siegel L1 oder 2 Splitter';

  @override
  String get pouchContentsCopper =>
      'Glut 2, dazu 1–2 Fächer: Siegel L1–L2, 2 Glut oder 2 Splitter';

  @override
  String get pouchContentsTurquoise =>
      'Glut 2–3, dazu 2 Fächer: Siegel L1–L2, 2 Glut oder 3 Splitter';

  @override
  String get pouchContentsNavy =>
      'Glut 3, dazu 2 Fächer: Siegel L1–L3, 3 Glut oder 3 Splitter';

  @override
  String pouchLeash(int n, int clips) {
    return 'Leine $n/$clips';
  }

  @override
  String get pouchEmpty =>
      'Kein Beutel an der Leine. Läufe finden Beutel; ein voller Atem-Tank gibt die beste Chance.';

  @override
  String pouchLocked(String km) {
    return 'Beutel gibt es ab Wegmarke 1 ($km km).';
  }

  @override
  String pouchWarm(String done, String total) {
    return 'Einlaufen: $done / $total km';
  }

  @override
  String pouchWarmShort(String done, String total) {
    return '$done/$total km';
  }

  @override
  String get pouchReady => 'Warm gelaufen: öffnet sich gratis.';

  @override
  String get pouchReadyShort => 'warm';

  @override
  String pouchFades(int h) {
    return 'Hängt noch etwa $h h, außer ein Lauf wärmt ihn.';
  }

  @override
  String pouchOpenLp(int lp) {
    return 'Öffnen · $lp LP';
  }

  @override
  String get pouchOpenFree => 'Öffnen';

  @override
  String get pouchNotEnoughLp => 'Zu wenig LP. Oder lauf ihn warm.';

  @override
  String pouchOpened(String name) {
    return '$name geöffnet';
  }

  @override
  String get pouchIntoCase => 'Alles liegt jetzt im Vorrat der Schmiede.';

  @override
  String get pouchToForge => 'Zur Schmiede';

  @override
  String get pouchContinue => 'Weiter';

  @override
  String pouchChance(String pct) {
    return 'Fundchance nach vollem Atem-Tank: $pct';
  }

  @override
  String pouchFortune(String f) {
    return 'Fortune ×$f, auch für seltenere Farben';
  }

  @override
  String get pouchRule =>
      'Pro Lauf zählt ein voller Atem-Tank. Volle Leine: kein neuer Fund. Nicht warm gelaufene Beutel verblassen nach einem Tag.';

  @override
  String pouchCounts(int f, int o) {
    return 'Gefunden $f · geöffnet $o';
  }

  @override
  String pouchSplinters(int n) {
    return '+$n Splitter';
  }

  @override
  String get pouchPick => 'Tippe einen Beutel an der Leine an.';

  @override
  String get summaryPouchFound => 'Beutel gefunden';

  @override
  String get summaryLeashFull => 'Leine voll: diesmal kein neuer Beutel.';

  @override
  String summaryPouchesWarm(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Beutel warm gelaufen: gratis zu öffnen.',
      one: '1 Beutel warm gelaufen: gratis zu öffnen.',
    );
    return '$_temp0';
  }

  @override
  String get summaryToLeash => 'Zur Leine';

  @override
  String get homeLeash => 'Leine';

  @override
  String get homeLeashOpen => 'Leine öffnen';

  @override
  String get homeLeashClose => 'Leine einfahren';

  @override
  String storesSplinters(int s) {
    return 'Splitter $s/5';
  }

  @override
  String storesGlut(int g) {
    return 'Glut $g';
  }

  @override
  String pouchColorOdds(String list) {
    return 'Farben: $list';
  }

  @override
  String get pouchShortBrown => 'Braun';

  @override
  String get pouchShortCopper => 'Kupfer';

  @override
  String get pouchShortTurquoise => 'Türkis';

  @override
  String get pouchShortNavy => 'Navy';

  @override
  String pouchColorShare(String name, String pct) {
    return '$name $pct';
  }

  @override
  String get flavourPebble => 'Ein Stein mit Herz und Moos.';

  @override
  String get flavourLumen => 'Leuchtet heller, je weiter ihr geht.';

  @override
  String get flavourCoil => 'Kugel, Panzer, Freund.';

  @override
  String get flavourGilt => 'Rüschen zuerst, Fragen später.';

  @override
  String get flavourHookfin => 'Schnell, scharf und ein bisschen frech.';

  @override
  String get flavourValve => 'Pfeift, wenn es Zeit zum Losgehen ist.';

  @override
  String get flavourDune => 'Sand in den Ohren, Fernweh im Blick.';

  @override
  String get flavourBrine => 'Taucht auf, wo du es nicht erwartest.';

  @override
  String get flavourVine => 'Wächst dir ans Herz – wortwörtlich.';

  @override
  String get flavourGlaze => 'Süß, aber mit Kristallkanten.';

  @override
  String msgGreetRuhu(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Huhu! Da bist du ja.',
      '1': 'Ruhu hier, gerade gelandet.',
      '2': 'Guten Tag, Wanderfreund!',
      '3': 'Huu … ich hab dich am Weg gesehen.',
      '4': 'Ach, wie schön, dich zu treffen!',
      '5': 'Leise, leise – Ruhu ist da.',
      'other': 'Huhu! Da bist du ja.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftRuhu(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Ich hab dir einen braunen Beutel an die Leine gehängt.',
      '1': 'Der lag unter einer Hecke. Jetzt hängt er an deiner Leine.',
      '2': 'Ein kleiner Beutel, aber mit Liebe geschnürt.',
      '3': 'Für deine Schritte heute – ein Beutel für die Leine.',
      '4': 'Nicht viel, aber ehrlich gefunden. Er hängt schon.',
      '5': 'Lauf ihn warm, dann öffnet er sich von allein.',
      'other': 'Ich hab dir einen braunen Beutel an die Leine gehängt.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskRuhu(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Magst du mir helfen? Danach gibt’s einen Lohn.',
      '1': 'Ich hätte da eine kleine Bitte an dich.',
      '2': 'Ein Auftrag, ganz ohne Eile.',
      '3': 'Wenn du Zeit hast: Ich brauche deine Beine.',
      '4': 'Erledige das für mich, dann lohnt es sich.',
      '5': 'Nur eine Kleinigkeit, versprochen.',
      'other': 'Magst du mir helfen? Danach gibt’s einen Lohn.',
    });
    return '$_temp0';
  }

  @override
  String msgGreetKolk(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Kraa! Krahni meldet sich.',
      '1': 'Kraa, kraa! Gut gelaufen!',
      '2': 'Psst, Krahni hier.',
      '3': 'Kraa! Rate mal, wer da ist.',
      '4': 'Hallo, Schrittmacher!',
      '5': 'Kraa! Ich hab auf dich gewartet.',
      'other': 'Kraa! Krahni meldet sich.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftKolk(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Glänzte am Wegrand – jetzt hängt’s an deiner Leine.',
      '1': 'Ein Kupferbeutel! Ich hab ihn nicht geklaut. Fast.',
      '2': 'Für dich gefunden, für dich gebracht.',
      '3': 'Kupfer klimpert so schön. Er hängt schon an der Leine.',
      '4': 'Bleib im Takt, dann bring ich mehr.',
      '5': 'Den hab ich über drei Dächer getragen.',
      'other': 'Glänzte am Wegrand – jetzt hängt’s an deiner Leine.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskKolk(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Kraa! Ich hab einen Auftrag für dich.',
      '1': 'Willst du was verdienen? Hör zu.',
      '2': 'Ein Rabe vergisst nie – auch keinen Lohn.',
      '3': 'Mach das, und ich lass was Glänzendes da.',
      '4': 'Kleine Wette: Schaffst du das?',
      '5': 'Kraa! Hier eine Aufgabe, keine Eile.',
      'other': 'Kraa! Ich hab einen Auftrag für dich.',
    });
    return '$_temp0';
  }

  @override
  String msgGreetFlimm(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Ein Lichtlein flackert – Glimmsel ist da.',
      '1': 'Sssst … ich bin deinem Licht gefolgt.',
      '2': 'Guten Abend, auch wenn’s Tag ist.',
      '3': 'Glimmsel hier, ganz leise.',
      '4': 'Deine Schritte leuchten heute.',
      '5': 'Ich kam mit dem Wind.',
      'other': 'Ein Lichtlein flackert – Glimmsel ist da.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftFlimm(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Ein türkiser Beutel, so selten wie ein klarer Himmel.',
      '1': 'Ich hab ihn sanft an deine Leine gehängt.',
      '2': 'Er schimmert wie meine Laterne. Für dich.',
      '3': 'Nicht jeder bekommt so einen. Du schon.',
      '4': 'Lauf ihn warm, dann zeigt er sein Licht.',
      '5': 'Den hat mir der Abendwind gegeben.',
      'other': 'Ein türkiser Beutel, so selten wie ein klarer Himmel.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskFlimm(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Hilfst du mir, mein Licht zu nähren?',
      '1': 'Ein kleiner Wunsch, ganz ohne Frist.',
      '2': 'Wenn du magst, zeig ich dir den Weg.',
      '3': 'Folge diesem Auftrag wie einem Glühwürmchen.',
      '4': 'Tu dies, und meine Laterne lohnt es dir.',
      '5': 'Nur ein Lichtfaden von einer Aufgabe.',
      'other': 'Hilfst du mir, mein Licht zu nähren?',
    });
    return '$_temp0';
  }

  @override
  String msgGreetVesper(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Sei gegrüßt. Sternuh ist herabgestiegen.',
      '1': 'Die Sterne sagten mir, wo du läufst.',
      '2': 'Selten komme ich. Heute komme ich zu dir.',
      '3': 'Verneige dich nicht – lauf lieber weiter.',
      '4': 'Der Nachthimmel schickt mich.',
      '5': 'Ein seltener Abend für einen seltenen Gast.',
      'other': 'Sei gegrüßt. Sternuh ist herabgestiegen.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftVesper(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Ein nachtblauer Beutel – der seltenste von allen.',
      '1': 'Aus der Schatzkammer der Sterne, an deine Leine.',
      '2': 'Trag ihn mit Stolz. Er hängt schon.',
      '3': 'Dein Glück hat mich gerufen. Hier ist sein Lohn.',
      '4': 'Nur wenige sehen diesen Samt. Du gehörst dazu.',
      '5': 'Lauf ihn warm – er birgt Großes.',
      'other': 'Ein nachtblauer Beutel – der seltenste von allen.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskVesper(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Ich stelle dir eine würdige Aufgabe.',
      '1': 'Zeig mir dein Durchhalten.',
      '2': 'Ein Auftrag der Sterne, ohne Eile.',
      '3': 'Vollende dies, und der Himmel lohnt es dir.',
      '4': 'Große Schritte für einen großen Lohn.',
      '5': 'Ich warte. Geduld ist meine Stärke.',
      'other': 'Ich stelle dir eine würdige Aufgabe.',
    });
    return '$_temp0';
  }

  @override
  String msgLineFull(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Oh – deine Leine ist ja voll!',
      '1': 'Kein Haken mehr frei, schade.',
      '2': 'Deine Leine ist voll, ich nehm ihn wieder mit.',
      '3': 'Hm, alles belegt. Öffne ein paar Beutel!',
      '4': 'Volle Leine! Ich komme ein andermal.',
      '5': 'Da hängt schon alles voll – nächstes Mal.',
      'other': 'Oh – deine Leine ist ja voll!',
    });
    return '$_temp0';
  }

  @override
  String msgLineDone(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Geschafft! Hier ist dein Lohn.',
      '1': 'Auftrag erfüllt – gut gelaufen!',
      '2': 'Wie versprochen: dein Lohn.',
      '3': 'Das hast du fein gemacht.',
      '4': 'Erledigt! Der Lohn liegt in deinem Kasten.',
      '5': 'Bravo – ich wusste, du schaffst das.',
      'other': 'Geschafft! Hier ist dein Lohn.',
    });
    return '$_temp0';
  }

  @override
  String get msgTitleRuhu => 'Ruhu · Eule der Feldwege';

  @override
  String get msgTitleKolk => 'Krahni · Rabe der Wegränder';

  @override
  String get msgTitleFlimm => 'Glimmsel · Laternenfalter';

  @override
  String get msgTitleVesper => 'Sternuh · Sterneule';

  @override
  String get msgRankBrown => 'Brauner Bote · häufig';

  @override
  String get msgRankCopper => 'Kupferbote · selten';

  @override
  String get msgRankTurquoise => 'Türkisbote · sehr selten';

  @override
  String get msgRankNavy => 'Nachtblau · äußerst selten';

  @override
  String get msgBrings => 'Bringt dir';

  @override
  String get msgReward => 'Lohn';

  @override
  String get msgThanks => 'Danke';

  @override
  String get msgAccept => 'Annehmen';

  @override
  String get msgPouchInstead => 'Beutel nehmen';

  @override
  String get msgTaskOptional => 'Kleiner Auftrag · freiwillig';

  @override
  String get msgTaskNote =>
      'Statt des Beutels: Lohn, sobald erledigt. Keine Frist.';

  @override
  String get msgLeashFullNote =>
      'Deine Leine ist voll, kein Haken für den Beutel. Nichts geht verloren: dein Lauf bringt seine Glut wie immer.';

  @override
  String get msgDoneTitle => 'Auftrag erledigt';

  @override
  String get msgDoneNote => 'Der Lohn liegt schon in deinem Siegelkasten.';

  @override
  String get msgBoard => 'Aushang';

  @override
  String get msgClose => 'Schließen';

  @override
  String get msgFootnote =>
      'Kommt nur mit Glück nach einem Lauf · mehr Fortune, seltenere Boten';

  @override
  String msgTaskWalk(String km) {
    return '$km km laufen';
  }

  @override
  String msgTaskSweet(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Läufe mit ≥ 58 % Sweet Spot',
      one: '1 Lauf mit ≥ 58 % Sweet Spot',
    );
    return '$_temp0';
  }

  @override
  String msgTaskRuns(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gültige Läufe ab 1 km',
      one: '1 gültiger Lauf ab 1 km',
    );
    return '$_temp0';
  }

  @override
  String msgTaskOpen(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Beutel öffnen',
      one: '1 Beutel öffnen',
    );
    return '$_temp0';
  }

  @override
  String msgProgressKm(String a, String b) {
    return '$a / $b km';
  }

  @override
  String msgProgress(int a, int b) {
    return '$a / $b';
  }
}
