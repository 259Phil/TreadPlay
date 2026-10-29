// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TreadPlay';

  @override
  String get tabHome => 'Home';

  @override
  String get tabForge => 'Forge';

  @override
  String get tabMarket => 'Market';

  @override
  String get tabSettings => 'Settings';

  @override
  String lpAmount(String lp) {
    return '$lp LP';
  }

  @override
  String levelShort(int level) {
    return 'Lv $level';
  }

  @override
  String get breath => 'Breath';

  @override
  String breathValue(String current, int max) {
    return '$current / $max';
  }

  @override
  String get breathRegenHint =>
      'One shared bar for all companions, +1 every 90 min. The companion taken along sets the max, the collector bonus adds up to 3.';

  @override
  String breathMax(int max) {
    return 'Breath max $max';
  }

  @override
  String get breathEmptyHint =>
      'Out of breath. You can still move, but you earn no LP until the bar recovers.';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String sweetSpotAt(String speed) {
    return 'Sweet spot $speed km/h';
  }

  @override
  String get startRun => 'Start';

  @override
  String get stopRun => 'Stop';

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Time';

  @override
  String get speed => 'Speed';

  @override
  String get steps => 'Steps';

  @override
  String kmValue(String km) {
    return '$km km';
  }

  @override
  String kmhValue(String kmh) {
    return '$kmh km/h';
  }

  @override
  String get lpThisRun => 'LP this run';

  @override
  String get hintStanding => 'Keep moving – standing still earns nothing.';

  @override
  String get hintOutside => 'Outside the sweet spot – distance counts, no LP';

  @override
  String get hintInside => 'In the sweet spot';

  @override
  String get hintNoBreath => 'Out of breath – tracking only';

  @override
  String get runWebGpsHint =>
      'Keep the screen on and this page open – in the background the browser pauses GPS.';

  @override
  String get hintGpsWarmup => 'GPS is settling – one moment …';

  @override
  String get demoTitle => 'Simulator (debug build only)';

  @override
  String get demoTimeLapse => '10× time';

  @override
  String get summaryTitle => 'Run complete';

  @override
  String get summaryInvalid =>
      'This movement didn\'t look plausible, so it earned no LP. Your distance and time are still saved.';

  @override
  String get summaryLp => 'LP earned';

  @override
  String get summaryBreathUsed => 'Breath used';

  @override
  String get done => 'Done';

  @override
  String get lastRun => 'Last run';

  @override
  String get invalidRun => 'Not counted';

  @override
  String noRunsYet(String name) {
    return 'No runs yet. Take $name along and get moving!';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsKaching => 'Ka-ching sound';

  @override
  String get settingsHealthTitle => 'Movement data';

  @override
  String get settingsHealthBody =>
      'TreadPlay uses location (GPS) and the step counter only while a run is active and only on this device. Only the run summary is saved, no route. Nothing is uploaded.';

  @override
  String get settingsPrivacyTitle => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'Your runs and your save game stay on this device. No account, no cloud.';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get creditsArtwork =>
      'Artwork created with Grok (xAI) and edited by TreadPlay.';

  @override
  String get appTagline => 'Walk with a companion.';

  @override
  String get tabShelf => 'Den';

  @override
  String get typeMoss => 'Stroll';

  @override
  String get typeBrook => 'Trot';

  @override
  String get typeGale => 'Gallop';

  @override
  String get statStride => 'Stride';

  @override
  String get statGrit => 'Grit';

  @override
  String get statFortune => 'Fortune';

  @override
  String get statSpirit => 'Spirit';

  @override
  String percentValue(String value) {
    return '$value %';
  }

  @override
  String get takeAlong => 'Take along';

  @override
  String get takenAlong => 'Along';

  @override
  String get levelUp => 'Level up';

  @override
  String get repair => 'Repair';

  @override
  String get charms => 'Charms';

  @override
  String get charmSlotEmpty => 'Empty';

  @override
  String get notFoundYet => 'Not found yet';

  @override
  String get filterWorld => 'World';

  @override
  String get filterType => 'Pace';

  @override
  String get filterRarity => 'Rarity';

  @override
  String get filterAll => 'All';

  @override
  String get shelfNothingHere => 'Nobody in the den with these filters.';

  @override
  String get worldMedieval => 'Medieval';

  @override
  String get worldSpace => 'Space';

  @override
  String get worldUnderwater => 'Underwater';

  @override
  String get worldEgypt => 'Egypt';

  @override
  String get worldJungle => 'Jungle';

  @override
  String get worldPirate => 'Pirate';

  @override
  String get worldRobot => 'Robot';

  @override
  String get worldRococo => 'Rococo';

  @override
  String get worldSteampunk => 'Steampunk';

  @override
  String get worldCandy => 'Candy';

  @override
  String get marketBuyTab => 'Buy';

  @override
  String get marketSellTab => 'Sell';

  @override
  String get marketHint => 'Offers and prices drift during the day.';

  @override
  String get marketRestockSoon => 'Traders will restock soon.';

  @override
  String shelfCount(int count, int cap) {
    return 'Den $count/$cap';
  }

  @override
  String marketBuyFor(String price) {
    return 'Buy · $price';
  }

  @override
  String marketSellFor(String price) {
    return 'Sell · $price';
  }

  @override
  String get marketGone => 'This offer is no longer here.';

  @override
  String marketShelfFull(int cap) {
    return 'Your den is full ($cap/$cap). Sell a companion first.';
  }

  @override
  String get marketNotEnoughLp => 'Not enough LP yet.';

  @override
  String get marketNeedsSpirit => 'Trading only at 100 % Spirit.';

  @override
  String marketLastCompanion(String name) {
    return '$name stays until a second companion joins your den.';
  }

  @override
  String marketSellSwitches(String name) {
    return 'Afterwards $name goes along with you.';
  }

  @override
  String get marketSoldOut => 'All offers are gone. New ones arrive later.';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsMovement => 'Movement access';

  @override
  String get settingsMovementOn =>
      'Real movement earns LP. Readings stay on this device.';

  @override
  String get settingsMovementOff => 'Off: real movement earns no LP.';

  @override
  String get movementNoticeTitle => 'Movement and location';

  @override
  String get movementNoticeBody =>
      'To count a walk, TreadPlay uses your location (GPS) and the step counter during the run. Readings stay on this device and are only used to measure distance and pace and to award LP. No route is saved and nothing is uploaded. If you deny, real movement earns no LP.';

  @override
  String get movementDeniedHint =>
      'Movement access is off. Runs earn no LP until you allow it.';

  @override
  String get movementNoticePrivacyLink => 'Read the privacy policy';

  @override
  String get movementAllow => 'Allow';

  @override
  String get movementDeny => 'Not now';

  @override
  String todayKm(String km) {
    return 'Today $km';
  }

  @override
  String sealName(String stat) {
    return '$stat seal';
  }

  @override
  String forgeFreeSockets(int free, int total) {
    return '$free of $total sockets free';
  }

  @override
  String get forgeRule =>
      'Each seal raises its stat by a share: L1 +4 %, L2 +9 %, L3 +15 %, L4 +22 %, L5 +31 %.';

  @override
  String get forgeNeedsSpirit => 'Seals are set only from 50 % Spirit.';

  @override
  String get forgeNotEnoughLp => 'Not enough LP yet.';

  @override
  String get forgeNoSocket => 'No empty socket left.';

  @override
  String get forgeSellNote =>
      'Selling a companion puts its seals back into the case.';

  @override
  String get forgeClearHint =>
      'Tap a seal to take it out, an empty socket to set one.';

  @override
  String forgeClearTitle(String seal) {
    return 'Take out $seal?';
  }

  @override
  String get forgeClearBody => 'It goes back into the case. Nothing is lost.';

  @override
  String get forgeClearAction => 'Take out';

  @override
  String get forgeClearKeep => 'Keep';

  @override
  String get pace => 'Pace';

  @override
  String paceValue(String pace) {
    return '$pace /km';
  }

  @override
  String get summaryBreathLeft => 'Breath left';

  @override
  String get runNoLp =>
      'Movement access is off. Distance is not read and this run earns no LP.';

  @override
  String get summaryNoLp =>
      'Movement access was off, so this run earned no LP.';

  @override
  String get settingsHistory => 'Run history';

  @override
  String get historyTitle => 'Run history';

  @override
  String historyTotals(String km, int runs, String lp) {
    return '$km km · $runs runs · $lp LP in total';
  }

  @override
  String get historyEmpty =>
      'No runs yet. Your runs show up here after you stop.';

  @override
  String get historyLocalNote =>
      'Stored only on this device. No route, no map.';

  @override
  String get historyErase => 'Erase local record';

  @override
  String get historyEraseTitle => 'Erase local record?';

  @override
  String get historyEraseBody =>
      'All stored runs on this device are deleted. Your lifetime totals for milestones stay.';

  @override
  String get historyErased => 'Run history erased.';

  @override
  String get cancel => 'Cancel';

  @override
  String get runDetailTitle => 'Run';

  @override
  String get date => 'Date';

  @override
  String get breathUsed => 'Breath used';

  @override
  String get sweetSpotShare => 'In sweet spot';

  @override
  String videoTooltip(String lp, int left) {
    return 'Optional video: +$lp LP ($left left today)';
  }

  @override
  String get videoTitle => 'Optional video';

  @override
  String videoBody(String lp, int max) {
    return 'Watch a short video for +$lp LP. Up to $max a day, each worth a little less. Running always earns more.';
  }

  @override
  String get videoWatch => 'Watch';

  @override
  String videoEarned(String lp) {
    return '+$lp LP from the video';
  }

  @override
  String get videoSkipped => 'Video closed early. No LP this time.';

  @override
  String get videoFailed => 'No video available right now.';

  @override
  String get videoUsedUp => 'Today\'s videos are used up. New ones tomorrow.';

  @override
  String get settingsSaveGame => 'Save game';

  @override
  String get saveHint =>
      'Your save game lives only on this device. Export it as a file to keep a copy or to move to a new phone.';

  @override
  String get saveExport => 'Export save game';

  @override
  String get saveNoExportYet => 'No export yet';

  @override
  String saveLastExport(String date) {
    return 'Last export: $date';
  }

  @override
  String get saveImport => 'Import save game';

  @override
  String get saveImportSub => 'Replaces the save game on this device';

  @override
  String get saveDelete => 'Delete save game';

  @override
  String get saveShareSubject => 'TreadPlay save game';

  @override
  String get saveExported => 'Save game exported.';

  @override
  String get saveDownloaded => 'Save game downloaded.';

  @override
  String get saveImportTitle => 'Import save game?';

  @override
  String saveImportSummary(int companions, String lp, int runs, String date) {
    return 'This save holds $companions companions, $lp LP and $runs stored runs. Exported: $date.\n\nReplace overwrites your current save game on this device.';
  }

  @override
  String get saveReplace => 'Replace';

  @override
  String get saveImported => 'Save game imported.';

  @override
  String get saveErrorNotASave => 'This file is not a TreadPlay save game.';

  @override
  String get saveErrorNewer =>
      'This save game comes from a newer TreadPlay version. Update the app first.';

  @override
  String get saveErrorDamaged =>
      'This save game is damaged and can\'t be loaded. Your current game is unchanged.';

  @override
  String get saveErrorDuringRun => 'Not possible during a run.';

  @override
  String get saveDeleteTitle => 'Delete save game?';

  @override
  String get saveDeleteBody =>
      'Companions, seals, LP, Breath, run history and lifetime totals are removed, and so are the export copies the app kept itself. You start again with Mossik. Files you saved or shared elsewhere stay.';

  @override
  String get saveDeleteReallyTitle => 'Really delete everything?';

  @override
  String get saveDeleteReallyBody =>
      'This cannot be undone. Only an export file you saved outside the app can bring the save game back.';

  @override
  String get saveDeletePermanently => 'Delete permanently';

  @override
  String get saveDeleted => 'Save game deleted. Fresh start with Mossik.';

  @override
  String saveError(String error) {
    return 'Error: $error';
  }

  @override
  String get wwTitle => 'Trail';

  @override
  String wwWaymark(int n) {
    return 'Waymark $n';
  }

  @override
  String wwSettingsSub(int reached, int total, String km) {
    return '$reached of $total waymarks · next at $km km';
  }

  @override
  String wwAllReached(int total) {
    return 'All $total waymarks reached. New waymarks coming soon.';
  }

  @override
  String wwLastAt(int n) {
    return 'Last at waymark $n';
  }

  @override
  String get wwStartTitle => 'The trail begins';

  @override
  String wwStartLine(String km) {
    return 'Every valid run counts. The first waymark is $km km away.';
  }

  @override
  String wwNext(int n) {
    return 'Next waymark $n';
  }

  @override
  String wwKmTask(String km) {
    return '$km km in total';
  }

  @override
  String wwKmValue(String done, String target) {
    return '$done / $target km';
  }

  @override
  String get wwLater => 'later';

  @override
  String get wwLaterNote =>
      '“later”: not in the game yet, already counts as done.';

  @override
  String get wwUnlocked => 'unlocked';

  @override
  String get wwComingSoon => 'comes with an update';

  @override
  String get wwYou => 'you';

  @override
  String wwYouLeft(String km) {
    return '$km km to go';
  }

  @override
  String get wwYouTask => 'task open';

  @override
  String wwReachedOne(int n, String unlock) {
    return 'Waymark $n reached · $unlock';
  }

  @override
  String wwReachedMany(int count) {
    return '$count waymarks reached';
  }

  @override
  String get wwOpenTrail => 'Open the trail';

  @override
  String wwFromWaymark(int n) {
    return 'from waymark $n';
  }

  @override
  String get wwLineLocked => 'The messenger’s line waits at this waymark.';

  @override
  String wwForgeLocked(String km) {
    return 'The Forge opens at waymark 2 of the trail ($km km).';
  }

  @override
  String get wwClose => 'Close';

  @override
  String get wwTasks => 'Tasks';

  @override
  String get wwNoTask => 'No task, only distance.';

  @override
  String get wwTaskBrownPouch => 'Open a brown pouch';

  @override
  String get wwTaskCopperPouch => 'Open a copper pouch';

  @override
  String get wwTaskTurquoisePouch => 'Open a turquoise pouch';

  @override
  String get wwTaskSealPlaced => 'Forge a seal and set it';

  @override
  String wwTaskSealsForged(int n) {
    return 'Forge $n seals in total';
  }

  @override
  String get wwTaskSealL3 => 'One seal at L3';

  @override
  String get wwTaskMessenger => 'Meet a messenger';

  @override
  String get wwTaskSweet58 => '1 run with sweet spot ≥ 58 %';

  @override
  String wwTaskPouches(int n) {
    return 'Open $n pouches';
  }

  @override
  String wwTaskSweet71(int n) {
    return '$n runs with sweet spot ≥ 71 %';
  }

  @override
  String get wwTaskLeash => 'Fill the leash (a pouch on all 4 clips)';

  @override
  String get wwTaskBuy => 'Buy a second companion in the Market';

  @override
  String wwTaskLevel(int n) {
    return 'A companion at level $n';
  }

  @override
  String get wwTaskCombine => 'Combine once';

  @override
  String get wwUnlockBrownPouch => 'Brown pouch';

  @override
  String get wwUnlockForge => 'Forge (seals L1, combining)';

  @override
  String get wwUnlockMarketMedievalJungle =>
      'Market +2 species (Medieval, Jungle)';

  @override
  String get wwUnlockCopperPouch => 'Copper pouch';

  @override
  String get wwUnlockForgeL2 => 'Forging L2';

  @override
  String get wwUnlockWorldUnderwater => 'World Underwater + species';

  @override
  String get wwUnlockLeashClip4 => '4th leash clip';

  @override
  String get wwUnlockForgeL3 => 'Forging L3';

  @override
  String get wwUnlockMarketEgyptPirate => 'Market +2 species (Egypt, Pirates)';

  @override
  String get wwUnlockTurquoisePouch => 'Turquoise pouch';

  @override
  String get wwUnlockWorldSteampunk => 'World Steampunk + species';

  @override
  String get wwUnlockForgeL4 => 'Forging L4';

  @override
  String wwUnlockGlutGift(int n) {
    return 'Gift: $n Glut';
  }

  @override
  String get wwUnlockNavyPouch => 'Navy pouch';

  @override
  String get wwUnlockWorldSpaceRobot => 'Worlds Space + Robot + species';

  @override
  String get wwUnlockForgeL5 => 'Forging L5';

  @override
  String get wwUnlockShelfPlus2 => 'Den +2 slots (12→14)';

  @override
  String get wwUnlockSalveGift => 'Gift: a rune pot salve (Spirit to 100 %)';

  @override
  String get wwUnlockWorldRococoCandy => 'Worlds Rococo + Candy + species';

  @override
  String get wwLine1 =>
      'A companion doesn’t grow in a den. It grows beside you, step by step.';

  @override
  String get wwLine2 => 'What you find along the way belongs to you both.';

  @override
  String get wwLine3 =>
      'New tracks in the Market. But no companion gets far if it is only carried.';

  @override
  String get wwLine4 => 'A seal only holds what the trail has put into it.';

  @override
  String get wwLine5 => 'Two equal seals, one fire. Patience is the third.';

  @override
  String get wwLine6 => 'At the right pace you hear each other breathe.';

  @override
  String get wwLine7 => 'One more clip means more that comes home with you.';

  @override
  String get wwLine8 =>
      'The first ember in the brass. It only burns because you walked.';

  @override
  String get wwLine9 =>
      'Far lands send their creatures. They are looking for someone to walk with.';

  @override
  String get wwLine10 => 'A full leash is a full trail.';

  @override
  String get wwLine11 => 'Steam and cogs. Even machines only learn on the way.';

  @override
  String get wwLine12 => 'Forged five times. Now your hands know it.';

  @override
  String get wwLine13 =>
      'Two powers in one seal, like two who walk the same trail.';

  @override
  String get wwLine14 =>
      'Two together don’t make the trail shorter, but brighter.';

  @override
  String get wwLine15 => 'Even between the stars only the next step counts.';

  @override
  String get wwLine16 => 'The crown is not given. It is walked.';

  @override
  String get wwLine17 =>
      'More room in the den. The growing still happens outside.';

  @override
  String get wwLine18 => 'Whoever keeps the beat, the ember follows.';

  @override
  String get wwLine19 => 'No end, only a bend. The trail grows with you.';

  @override
  String get forgeIntro =>
      'Seals wait in the case. Set them into the companion you have along.';

  @override
  String forgeCompanionLine(String name, String rarity, int total) {
    return '$name · $rarity · $total sockets';
  }

  @override
  String sealLevel(int n) {
    return 'Level $n';
  }

  @override
  String sealLevelShort(int n) {
    return 'L$n';
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
    return '+$pct % (cap)';
  }

  @override
  String get forgeModeUp => 'Forge up';

  @override
  String get forgeModeCombine => 'Combine';

  @override
  String get forgeUpTitle => 'Forge: 2 equal seals + Glut';

  @override
  String get forgeCombineTitle => 'Combine: 2 different seals + Glut';

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
    return 'Fail chance $pct % · then 1 seal turns into 3 splinters';
  }

  @override
  String forgeGlutRange(int min, int max) {
    return 'Glut $min–$max: each extra Glut lowers the fail chance.';
  }

  @override
  String forgeGlutFixed(int n) {
    return 'Needs exactly $n Glut.';
  }

  @override
  String get forgePickSeal => 'Pick a seal in the case below.';

  @override
  String get forgePickPartner =>
      'Now pick a seal of another stat at the same level.';

  @override
  String get forgeMysteryIdle => 'The signs are asleep …';

  @override
  String get forgeMysteryStir => 'Something stirs …';

  @override
  String get forgeMysteryReady => 'Two essences call to each other …';

  @override
  String get forgeCaseNone => 'No loose seals yet.';

  @override
  String get forgeCase => 'Case';

  @override
  String get forgeCaseEmpty =>
      'No loose seals yet. Buy a seal L1 in the Case tab.';

  @override
  String get forgeGlutSource =>
      'Glut comes from pouches. A run of 1 km or more without a pouch still brings 1 Glut.';

  @override
  String forgeBuyTitle(String lp) {
    return 'New seal L1 · $lp LP';
  }

  @override
  String get forgeMeltTitle => 'Melt 5 splinters into a seal L1';

  @override
  String get forgeAction => 'Forge';

  @override
  String get forgeCombineAction => 'Combine';

  @override
  String forgeSetAction(String name) {
    return 'Set into $name';
  }

  @override
  String forgeLevelLocked(int n, int wm) {
    return 'Forging L$n opens at waymark $wm.';
  }

  @override
  String get forgeNeedsPair => 'Needs 2 equal seals in the case.';

  @override
  String get forgeNeedsGlut => 'Not enough Glut yet.';

  @override
  String get forgeTopLevel => 'L5 is the highest level.';

  @override
  String get forgeComboFinal =>
      'Recipe seals are not forged up; with a third seal they grow to level 2 in Combine.';

  @override
  String get forgeBadCombine =>
      'Needs two single seals of different stats, or a recipe seal and a single seal of its missing stat, at the same level.';

  @override
  String get forgeSuccessTitle => 'Forged';

  @override
  String forgeSuccessBody(String seal) {
    return '$seal is now in the case.';
  }

  @override
  String get forgeFailTitle => 'The fire failed';

  @override
  String forgeFailBody(String seal) {
    return '$seal fell to 3 splinters. The other seal is back in the case.';
  }

  @override
  String get forgeOk => 'OK';

  @override
  String get forgeLadder => 'Levels';

  @override
  String get forgeLadderTitle => 'Seal levels';

  @override
  String get forgeLadderNote =>
      'At most +47 % per stat from all seals together. Recipe seals give their first stat about 60 % and the second about 40 %, plus the recipe effect while they sit in the companion you take along.';

  @override
  String get forgePickTitle => 'Set a seal';

  @override
  String get summaryGlut => 'Glut for the Forge';

  @override
  String glutAmount(int n) {
    return '+$n Glut';
  }

  @override
  String get pouchTitle => 'Pouches';

  @override
  String get pouchBrown => 'Brown pouch';

  @override
  String get pouchCopper => 'Copper pouch';

  @override
  String get pouchTurquoise => 'Turquoise pouch';

  @override
  String get pouchNavy => 'Navy pouch';

  @override
  String get pouchContentsBrown =>
      'Glut 1–2, plus a seal L1 or 2 splinters, rarely a small spirit salve';

  @override
  String get pouchContentsCopper =>
      'Glut 2, plus 1–2 of: seal L1–L2, 2 Glut, 2 splinters, rarely a small spirit salve';

  @override
  String get pouchContentsTurquoise =>
      'Glut 2–3, plus 2 of: seal L1–L2, 2 Glut, 3 splinters';

  @override
  String get pouchContentsNavy =>
      'Glut 3, plus 2 of: seal L1–L3, 3 Glut, 3 splinters';

  @override
  String pouchLeash(int n, int clips) {
    return 'Leash $n/$clips';
  }

  @override
  String get pouchEmpty =>
      'No pouch on the leash. Runs find pouches; a full Breath tank gives the best chance.';

  @override
  String pouchLocked(String km) {
    return 'Pouches start at waymark 1 ($km km).';
  }

  @override
  String pouchWarm(String done, String total) {
    return 'Walk it open: $done / $total km';
  }

  @override
  String pouchWarmShort(String done, String total) {
    return '$done/$total km';
  }

  @override
  String get pouchReady => 'Walked warm: opens for free.';

  @override
  String get pouchReadyShort => 'warm';

  @override
  String pouchFades(int h) {
    return 'Stays about $h h more unless a run warms it.';
  }

  @override
  String pouchOpenLp(int lp) {
    return 'Open · $lp LP';
  }

  @override
  String get pouchOpenFree => 'Open';

  @override
  String get pouchNotEnoughLp => 'Not enough LP. Or walk it warm.';

  @override
  String pouchOpened(String name) {
    return '$name opened';
  }

  @override
  String get pouchIntoCase => 'Everything is in the Forge case now.';

  @override
  String get pouchToForge => 'To the Forge';

  @override
  String get pouchContinue => 'Continue';

  @override
  String pouchChance(String pct) {
    return 'Find chance after a full Breath tank: $pct';
  }

  @override
  String pouchFortune(String f) {
    return 'Fortune ×$f, also for rarer colours';
  }

  @override
  String get pouchRule =>
      'One full Breath tank counts per run. A full leash finds nothing new. Pouches not walked warm fade after a day.';

  @override
  String pouchCounts(int f, int o) {
    return 'Found $f · opened $o';
  }

  @override
  String pouchSplinters(int n) {
    return '+$n splinters';
  }

  @override
  String get pouchPick => 'Tap a pouch on the leash.';

  @override
  String get summaryPouchFound => 'Pouch found';

  @override
  String get summaryLeashFull => 'Leash full: no new pouch this time.';

  @override
  String summaryPouchesWarm(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pouches walked warm: free to open.',
      one: '1 pouch walked warm: free to open.',
    );
    return '$_temp0';
  }

  @override
  String get summaryToLeash => 'To the leash';

  @override
  String get homeLeash => 'Leash';

  @override
  String get homeLeashOpen => 'Open leash';

  @override
  String get homeLeashClose => 'Close leash';

  @override
  String storesSplinters(int s) {
    return 'Splinters $s/5';
  }

  @override
  String storesGlut(int g) {
    return 'Glut $g';
  }

  @override
  String pouchColorOdds(String list) {
    return 'Colours: $list';
  }

  @override
  String get pouchShortBrown => 'Brown';

  @override
  String get pouchShortCopper => 'Copper';

  @override
  String get pouchShortTurquoise => 'Turquoise';

  @override
  String get pouchShortNavy => 'Navy';

  @override
  String pouchColorShare(String name, String pct) {
    return '$name $pct';
  }

  @override
  String get flavourPebble => 'A stone with a heart – and moss.';

  @override
  String get flavourLumen => 'Glows brighter the farther you go.';

  @override
  String get flavourCoil => 'Ball, shell, friend.';

  @override
  String get flavourGilt => 'Frills first, questions later.';

  @override
  String get flavourHookfin => 'Quick, sharp and a little cheeky.';

  @override
  String get flavourValve => 'Whistles when it’s time to go.';

  @override
  String get flavourDune => 'Sand in its ears, wanderlust in its eyes.';

  @override
  String get flavourBrine => 'Pops up where you least expect it.';

  @override
  String get flavourVine => 'Grows on you – literally.';

  @override
  String get flavourGlaze => 'Sweet, with crystal edges.';

  @override
  String get flavourZinnbuck => 'Old as the castle wall, and just as patient.';

  @override
  String get flavourRingelpanz => 'Clinks a little proudly with every step.';

  @override
  String get flavourNebulo => 'Takes a whole starry sky for a walk.';

  @override
  String get flavourKraterix => 'Every crater an adventure, every step a leap.';

  @override
  String get flavourDrahtel => 'Always wired – in the best way.';

  @override
  String get flavourMuttrix => 'Bolted tight to you and the path.';

  @override
  String get flavourPorzella => 'Fragile? Only at first glance.';

  @override
  String get flavourPuderling => 'A cloud of curls on little feet.';

  @override
  String get flavourTeerbock => 'Smells of harbours and long voyages.';

  @override
  String get flavourSegelkamm => 'Always has a tailwind, even on land.';

  @override
  String get flavourMessingor => 'Polished by the wind of many kilometres.';

  @override
  String get flavourEmaillo => 'Gleams in every colour of the workshop.';

  @override
  String get flavourPapyrix => 'Writes every path into its fibres.';

  @override
  String get flavourLapisor => 'A piece of night sky from the temple.';

  @override
  String get flavourMuschlo => 'Hears the sea calling in every shell.';

  @override
  String get flavourTangwell => 'Sways along as if the road were a current.';

  @override
  String get flavourFarnix => 'Only unfurls when it is time to go.';

  @override
  String get flavourSchwammo => 'Soaks up every shower and beams.';

  @override
  String get flavourKaramello => 'Sticks to your heels – in a good way.';

  @override
  String get flavourLakrillo => 'Black, twisted and lightning-fast.';

  @override
  String get albumTitle => 'Album';

  @override
  String get albumOpen => 'Album';

  @override
  String albumProgress(int owned, int total, int shimmer) {
    return '$owned/$total found · ✦ $shimmer';
  }

  @override
  String get albumShimmerHint =>
      '✦ Shimmer: 0.1 % per offer; after 300 km without one, the Market is sure to have one. Worth ×1.5.';

  @override
  String albumFromKm(String km) {
    return 'from $km km';
  }

  @override
  String get albumInMarket => 'in the Market';

  @override
  String albumFind(String rate) {
    return 'Find: $rate';
  }

  @override
  String get findRateFrequent => 'frequent';

  @override
  String get findRateScarce => 'scarce';

  @override
  String get findRateElusive => 'elusive';

  @override
  String get findRateMythic => 'fabled';

  @override
  String get shimmerTag => '✦ SHIMMER';

  @override
  String get shimmerNote => '✦ Shimmer · worth ×1.5';

  @override
  String msgGreetRuhu(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Hoo-hoo! There you are.',
      '1': 'Ruhu here, just landed.',
      '2': 'Good day, fellow wanderer!',
      '3': 'Hoo … I saw you on the path.',
      '4': 'Oh, how lovely to meet you!',
      '5': 'Softly, softly – Ruhu is here.',
      'other': 'Hoo-hoo! There you are.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftRuhu(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'I hung a brown pouch on your leash.',
      '1': 'It lay under a hedge. Now it hangs on your leash.',
      '2': 'A small pouch, but tied with care.',
      '3': 'For your steps today – a pouch for the leash.',
      '4': 'Not much, but honestly found. It’s already hanging.',
      '5': 'Walk it warm and it opens by itself.',
      'other': 'I hung a brown pouch on your leash.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskRuhu(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Would you help me? There’s a reward after.',
      '1': 'I have a small favour to ask.',
      '2': 'A task, no hurry at all.',
      '3': 'If you have time: I need your legs.',
      '4': 'Do this for me and it will pay off.',
      '5': 'Just a little thing, I promise.',
      'other': 'Would you help me? There’s a reward after.',
    });
    return '$_temp0';
  }

  @override
  String msgGreetKolk(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Kraa! Krahni reporting.',
      '1': 'Kraa, kraa! Nicely walked!',
      '2': 'Psst, Krahni here.',
      '3': 'Kraa! Guess who’s here.',
      '4': 'Hello, pacemaker!',
      '5': 'Kraa! I was waiting for you.',
      'other': 'Kraa! Krahni reporting.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftKolk(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'It shone by the path – now it hangs on your leash.',
      '1': 'A copper pouch! I didn’t steal it. Almost.',
      '2': 'Found for you, brought to you.',
      '3': 'Copper jingles so nicely. It’s on your leash.',
      '4': 'Keep the beat and I’ll bring more.',
      '5': 'I carried it over three rooftops.',
      'other': 'It shone by the path – now it hangs on your leash.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskKolk(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Kraa! I’ve got a task for you.',
      '1': 'Want to earn something? Listen.',
      '2': 'A raven never forgets – nor a reward.',
      '3': 'Do this and I’ll leave something shiny.',
      '4': 'Small bet: can you do it?',
      '5': 'Kraa! Here’s a task, no hurry.',
      'other': 'Kraa! I’ve got a task for you.',
    });
    return '$_temp0';
  }

  @override
  String msgGreetFlimm(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'A little light flickers – Glimmsel is here.',
      '1': 'Sssh … I followed your light.',
      '2': 'Good evening, even if it’s day.',
      '3': 'Glimmsel here, very quietly.',
      '4': 'Your steps are glowing today.',
      '5': 'I came with the wind.',
      'other': 'A little light flickers – Glimmsel is here.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftFlimm(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'A turquoise pouch, as rare as a clear sky.',
      '1': 'I hung it gently on your leash.',
      '2': 'It shimmers like my lantern. For you.',
      '3': 'Not everyone gets one of these. You do.',
      '4': 'Walk it warm and it will show its light.',
      '5': 'The evening breeze gave it to me.',
      'other': 'A turquoise pouch, as rare as a clear sky.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskFlimm(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Will you help me feed my light?',
      '1': 'A small wish, no deadline.',
      '2': 'If you like, I’ll show you the way.',
      '3': 'Follow this task like a firefly.',
      '4': 'Do this and my lantern will reward you.',
      '5': 'Just a thread of light of a task.',
      'other': 'Will you help me feed my light?',
    });
    return '$_temp0';
  }

  @override
  String msgGreetVesper(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Greetings. Sternuh has descended.',
      '1': 'The stars told me where you walk.',
      '2': 'I rarely come. Today I come to you.',
      '3': 'Don’t bow – keep walking instead.',
      '4': 'The night sky sends me.',
      '5': 'A rare evening for a rare guest.',
      'other': 'Greetings. Sternuh has descended.',
    });
    return '$_temp0';
  }

  @override
  String msgGiftVesper(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'A navy pouch – the rarest of them all.',
      '1': 'From the treasury of the stars, onto your leash.',
      '2': 'Carry it with pride. It’s already hanging.',
      '3': 'Your Fortune called me. Here is its reward.',
      '4': 'Few ever see this velvet. You are one of them.',
      '5': 'Walk it warm – it holds great things.',
      'other': 'A navy pouch – the rarest of them all.',
    });
    return '$_temp0';
  }

  @override
  String msgTaskVesper(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'I set you a worthy task.',
      '1': 'Show me your endurance.',
      '2': 'A task from the stars, no hurry.',
      '3': 'Complete this and the sky will reward you.',
      '4': 'Big steps for a big reward.',
      '5': 'I’ll wait. Patience is my strength.',
      'other': 'I set you a worthy task.',
    });
    return '$_temp0';
  }

  @override
  String msgLineFull(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Oh – your leash is full!',
      '1': 'No clip free, what a pity.',
      '2': 'Your leash is full, I’ll take it back with me.',
      '3': 'Hm, all taken. Open a few pouches!',
      '4': 'Full leash! I’ll come another time.',
      '5': 'Everything’s hanging already – next time.',
      'other': 'Oh – your leash is full!',
    });
    return '$_temp0';
  }

  @override
  String msgLineDone(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '0': 'Done! Here’s your reward.',
      '1': 'Task complete – well walked!',
      '2': 'As promised: your reward.',
      '3': 'You did that nicely.',
      '4': 'Done! The reward is in the Forge case.',
      '5': 'Bravo – I knew you could.',
      'other': 'Done! Here’s your reward.',
    });
    return '$_temp0';
  }

  @override
  String get msgTitleRuhu => 'Ruhu · owl of the field paths';

  @override
  String get msgTitleKolk => 'Krahni · raven of the waysides';

  @override
  String get msgTitleFlimm => 'Glimmsel · lantern moth';

  @override
  String get msgTitleVesper => 'Sternuh · star owl';

  @override
  String get msgRankBrown => 'Brown messenger · common';

  @override
  String get msgRankCopper => 'Copper messenger · uncommon';

  @override
  String get msgRankTurquoise => 'Turquoise messenger · rare';

  @override
  String get msgRankNavy => 'Navy messenger · very rare';

  @override
  String get msgBrings => 'Brings you';

  @override
  String get msgReward => 'Reward';

  @override
  String get msgThanks => 'Thanks';

  @override
  String get msgAccept => 'Accept';

  @override
  String get msgPouchInstead => 'Rather the pouch';

  @override
  String get msgTaskOptional => 'Small task · optional';

  @override
  String get msgTaskNote =>
      'Instead of the pouch: reward once done. No deadline.';

  @override
  String get msgLeashFullNote =>
      'Your leash is full, no clip for the pouch. Nothing is lost: your run brings its Glut as always.';

  @override
  String get msgDoneTitle => 'Task done';

  @override
  String get msgDoneNote => 'The reward is already in the Forge case.';

  @override
  String get msgBoard => 'Notice';

  @override
  String get msgClose => 'Close';

  @override
  String get msgFootnote =>
      'Only comes by luck after a run · more Fortune, rarer messengers';

  @override
  String msgTaskWalk(String km) {
    return 'Walk $km km';
  }

  @override
  String msgTaskSweet(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n runs with ≥ 58 % sweet spot',
      one: '1 run with ≥ 58 % sweet spot',
    );
    return '$_temp0';
  }

  @override
  String msgTaskRuns(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n valid runs of 1 km or more',
      one: '1 valid run of 1 km or more',
    );
    return '$_temp0';
  }

  @override
  String msgTaskOpen(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Open $n pouches',
      one: 'Open 1 pouch',
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

  @override
  String get salveSmall => 'Small spirit salve';

  @override
  String get salveMedium => 'Spirit salve jar';

  @override
  String get salveLarge => 'Rune pot salve';

  @override
  String salveEffect(int n) {
    return '+$n % Spirit';
  }

  @override
  String get salveEffectFull => 'Spirit to 100 %';

  @override
  String get salveButton => 'Spirit salve';

  @override
  String salveSheetTitle(String name) {
    return 'Spirit salve for $name';
  }

  @override
  String salveSheetSpirit(String mut) {
    return 'Spirit now $mut %';
  }

  @override
  String salveOwned(int n) {
    return '$n in the case';
  }

  @override
  String get salveUse => 'Apply';

  @override
  String get salveNoneHint =>
      'No salves in the case. The Market trader sells them.';

  @override
  String get salveFull => 'Spirit is full.';

  @override
  String salveApplied(String name, String mut) {
    return '$name is back at $mut % Spirit.';
  }

  @override
  String get salveVorratTitle => 'Spirit salves';

  @override
  String get salveVorratHint => 'Tap one to apply it.';

  @override
  String get salveVorratEmpty => 'No salves yet. The Market trader has them.';

  @override
  String levelXp(int xp, int need) {
    return 'XP $xp / $need';
  }

  @override
  String get levelMax => 'Highest level reached';

  @override
  String levelNextLp(int pct) {
    return 'Next level: +$pct % LP per Breath point';
  }

  @override
  String levelNextTank(int pct) {
    return 'Next level: +$pct % LP per Breath point and +1 Breath tank';
  }

  @override
  String get levelXpHint => '1 XP per Breath point used in the sweet spot';

  @override
  String levelUpFor(String lp) {
    return 'Level up · $lp LP';
  }

  @override
  String levelNeedsXp(int n) {
    return '$n XP to walk';
  }

  @override
  String levelNeedsLp(String lp) {
    return '$lp LP missing';
  }

  @override
  String levelUpDone(String name, int level) {
    return '$name is level $level now!';
  }

  @override
  String levelUpDoneTank(String name, int level, int tank) {
    return '$name is level $level now. Tank: $tank Breath!';
  }

  @override
  String spiritLossLine(String loss) {
    return 'Spirit −$loss % per Breath point in the sweet spot';
  }

  @override
  String spiritGritSaves(int pct) {
    return 'Grit saves $pct %';
  }

  @override
  String spiritLow(String name, String mut) {
    return '$name is down to $mut % Spirit. At 0 % runs bring no LP – a spirit salve helps.';
  }

  @override
  String get summarySpirit => 'Spirit';

  @override
  String summarySpiritValue(String before, String after) {
    return '$before % → $after %';
  }

  @override
  String get summaryXp => 'XP';

  @override
  String summaryXpValue(int n) {
    return '+$n XP';
  }

  @override
  String summaryLevelReady(String name) {
    return '$name can level up – in the den.';
  }

  @override
  String get marketSalvesTab => 'Salves';

  @override
  String get marketSalvesIntro =>
      'Spirit salves from the trader. Prices move with the Market; sometimes one is on offer.';

  @override
  String get marketSalveDeal => 'Offer −30 %';

  @override
  String marketSalveBuy(String lp) {
    return 'Buy · $lp LP';
  }

  @override
  String marketSalveBought(String name) {
    return '$name is in the Forge case now.';
  }

  @override
  String get recipeNameAusdauer => 'Stamina';

  @override
  String get recipeNameFaehrte => 'Trail';

  @override
  String get recipeNameSchutz => 'Ward Amulet';

  @override
  String get recipeNameWanderstern => 'Wander Star';

  @override
  String get recipeNameSpurenleser => 'Tracker';

  @override
  String get recipeNameGlutherz => 'Ember Heart';

  @override
  String get recipeHintAusdauer => 'Breath and iron …';

  @override
  String get recipeHintFaehrte => 'The stride follows luck …';

  @override
  String get recipeHintSchutz => 'What breaks, remains …';

  @override
  String get recipeHintWanderstern => 'Who walks steadily is found …';

  @override
  String get recipeHintSpurenleser => 'Old tracks grow warm …';

  @override
  String get recipeHintGlutherz => 'A heart that never cools …';

  @override
  String get recipeForAusdauer => 'Changing pace, treadmill starters';

  @override
  String get recipeForFaehrte => 'Long distances, pouch collectors';

  @override
  String get recipeForSchutz => 'Smiths who dare L4/L5';

  @override
  String get recipeForWanderstern => 'Messenger hunters, daily tasks';

  @override
  String get recipeForSpurenleser => 'A full leash, little LP to open';

  @override
  String get recipeForGlutherz => 'Frequent smiths (Glut is scarce)';

  @override
  String recipeFxSweetSpot(String kmh) {
    return 'Sweet spot ±$kmh km/h wider';
  }

  @override
  String recipeFxPouch(String pts) {
    return 'Pouch chance +$pts pts (runs from 3 km)';
  }

  @override
  String recipeFxFail(String pts) {
    return 'Fail chance −$pts pts · +1 splinter on a fail';
  }

  @override
  String recipeFxMessenger(String pts) {
    return 'Messenger chance +$pts pts';
  }

  @override
  String recipeFxWarm(String pct) {
    return 'Pouches warm $pct % faster';
  }

  @override
  String recipeFxGlut(String pct) {
    return '$pct %: +1 Glut per run from 1 km (once a day)';
  }

  @override
  String get baumTitle => 'FORGE TREE';

  @override
  String baumCount(int known, int total) {
    return 'Recipes $known / $total';
  }

  @override
  String baumLevels(int known, int total) {
    return 'Levels $known / $total';
  }

  @override
  String baumSeen(int seen, int total) {
    return 'Seals $seen / $total';
  }

  @override
  String baumSingleSeen(String stat, int level) {
    return 'Single seal $stat L$level · owned before';
  }

  @override
  String baumSingleNever(String stat, int level) {
    return 'Single seal $stat L$level · never owned';
  }

  @override
  String get baumSingleFirst =>
      'Buy L1 in the forge, find it in pouches or melt it from splinters.';

  @override
  String baumSingleUp(int below) {
    return 'Made by forging up: two equal seals L$below become one.';
  }

  @override
  String get baumTagline =>
      'Two single seals make a recipe · recipe + third seal = level 2';

  @override
  String get baumUndiscovered => '??? · UNDISCOVERED';

  @override
  String baumHint(String hint) {
    return 'Hint: $hint';
  }

  @override
  String get baumNext => 'next';

  @override
  String get baumReady => 'Ready to forge now';

  @override
  String baumLocked(String name) {
    return 'Forge $name first';
  }

  @override
  String baumForged(int level) {
    return 'Forged up to L$level';
  }

  @override
  String baumFor(String who) {
    return 'For: $who';
  }

  @override
  String get baumWhere =>
      'Forge in Combine. Works while the seal sits in the companion you take along.';

  @override
  String forgeRecipeLocked(String name) {
    return 'Forge $name first, then its level 2 opens.';
  }

  @override
  String forgeRecipeNew(String name) {
    return 'New recipe: $name!';
  }

  @override
  String forgeRecipeMade(String name) {
    return 'Recipe $name';
  }

  @override
  String get recipeEffectsTitle => 'Recipe effects';

  @override
  String get recipeEffectsNone => 'No recipe seals set.';

  @override
  String recipeEffectsIdle(String name) {
    return 'They work once $name is taken along.';
  }

  @override
  String recipeEffectLine(String name, int level, String effect) {
    return '$name L$level: $effect';
  }

  @override
  String get collectorTitle => 'Collector bonus';

  @override
  String collectorBonus(int bonus) {
    return '+$bonus Breath tank';
  }

  @override
  String get collectorNone => 'No bonus yet';

  @override
  String collectorCount(int count) {
    return '$count companions with at least 50 % spirit';
  }

  @override
  String collectorNext(int at, int bonus, int need) {
    return 'Next step: from $at companions +$bonus Breath tank ($need to go)';
  }

  @override
  String get collectorMaxed => 'Top step reached: +3 Breath tank.';

  @override
  String get collectorExplain =>
      'From 5, 10 and 20 companions with at least 50 % spirit, the shared Breath tank grows by 1 each (max +3). A companion below 50 % spirit counts again once its spirit is back.';

  @override
  String breathMaxBonus(int max, int bonus) {
    return 'Breath max $max (incl. +$bonus collector bonus)';
  }

  @override
  String shelfSlotsLine(int count, int cap) {
    return 'Den $count/$cap spots';
  }

  @override
  String shelfBuySlot(int price) {
    return '+1 spot · $price LP';
  }

  @override
  String get shelfBuyTitle => 'Buy a den spot?';

  @override
  String shelfBuyBody(int slot, int price) {
    return 'Unlock spot $slot for $price LP? Every further spot costs 30 LP more, 30 spots at most.';
  }

  @override
  String get shelfBuyConfirm => 'Buy';

  @override
  String shelfBuyDone(int cap) {
    return 'Your den has $cap spots now.';
  }

  @override
  String get shelfSlotsMax => '30 spots is the most a den can have.';

  @override
  String shelfSlotNoLp(int slot, int price) {
    return 'Not enough LP for spot $slot ($price LP).';
  }

  @override
  String get collectorMore => 'How does it work?';
}
