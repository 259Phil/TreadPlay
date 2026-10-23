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
  String get tabShelf => 'Gehege';

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
      'Gefährten, Siegel, LP, Puste, Laufhistorie und Gesamtwerte werden entfernt. Du startest neu mit Mossik.';

  @override
  String get saveDeleteReallyTitle => 'Wirklich alles löschen?';

  @override
  String get saveDeleteReallyBody =>
      'Das kann nicht rückgängig gemacht werden. Ohne Export ist der Spielstand weg.';

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
}
