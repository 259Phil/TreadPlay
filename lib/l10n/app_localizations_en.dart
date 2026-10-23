// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Treadplay';

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
      'One shared bar for all companions, +1 every 90 min. Taking a companion along only sets the max.';

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
  String get settingsHealthTitle => 'Health data';

  @override
  String get settingsHealthBody =>
      'Treadplay reads steps and distance from Apple Health or Health Connect only while a run is active. Apple and Google store your health data independently of us. We never upload it.';

  @override
  String get settingsPrivacyTitle => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'Your routes and runs stay on this device. No account, no cloud.';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get creditsArtwork =>
      'Artwork created with Grok (xAI) and edited by Treadplay.';

  @override
  String get appTagline => 'Walk with a companion.';

  @override
  String get tabShelf => 'Den';

  @override
  String get typeMoss => 'Moss';

  @override
  String get typeBrook => 'Brook';

  @override
  String get typeGale => 'Gale';

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
  String get filterType => 'Type';

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
  String get movementNoticeTitle => 'Movement and health';

  @override
  String get movementNoticeBody =>
      'To count a walk, TreadPlay asks for motion or health access (Apple Health or Health Connect, location only if GPS is used for distance). Readings stay on this device and are only used to check your pace and award LP. Nothing is uploaded. If you deny, real movement earns no LP.';

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
  String get forgeNeedsSpirit => 'Seals are set only at 100 % Spirit.';

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
  String get saveShareSubject => 'Treadplay save game';

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
  String get saveErrorNotASave => 'This file is not a Treadplay save game.';

  @override
  String get saveErrorNewer =>
      'This save game comes from a newer Treadplay version. Update the app first.';

  @override
  String get saveErrorDamaged =>
      'This save game is damaged and can\'t be loaded. Your current game is unchanged.';

  @override
  String get saveErrorDuringRun => 'Not possible during a run.';

  @override
  String get saveDeleteTitle => 'Delete save game?';

  @override
  String get saveDeleteBody =>
      'Companions, seals, LP, Breath, run history and lifetime totals are removed. You start again with Mossik.';

  @override
  String get saveDeleteReallyTitle => 'Really delete everything?';

  @override
  String get saveDeleteReallyBody =>
      'This cannot be undone. Without an export the save game is gone.';

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
    return 'All $total waymarks reached. The trail keeps growing.';
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
  String get wwTaskSweet58 => '1 run with Sweet Spot ≥ 58 %';

  @override
  String wwTaskSweet71(int n) {
    return '$n runs with Sweet Spot ≥ 71 %';
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
  String get wwUnlockForge => 'Forge (seals L1)';

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
  String get wwUnlockCombineL3 => 'Combining L3';

  @override
  String get wwUnlockNavyPouch => 'Navy pouch';

  @override
  String get wwUnlockWorldSpaceRobot => 'Worlds Space + Robot + species';

  @override
  String get wwUnlockForgeL5 => 'Forging L5';

  @override
  String get wwUnlockShelfPlus2 => 'Den +2 slots (12→14)';

  @override
  String get wwUnlockCombineL5 => 'Combining L5';

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
  String get wwLine5 =>
      'Two equal seals, one fire. Patience is the third part.';

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
  String forgeCombineLocked(int n, int wm) {
    return 'Combining L$n opens at waymark $wm.';
  }

  @override
  String get forgeNeedsPair => 'Needs 2 equal seals in the case.';

  @override
  String get forgeNeedsGlut => 'Not enough Glut yet.';

  @override
  String get forgeTopLevel => 'L5 is the highest level.';

  @override
  String get forgeComboFinal => 'Combined seals are not forged further.';

  @override
  String get forgeBadCombine =>
      'Needs two single seals of different stats at L3 or L5.';

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
      'At most +47 % per stat from all seals together. Combined seals free a socket but give less in total.';

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
  String get pouchContentsBrown => 'Glut 1–2, plus a seal L1 or 2 splinters';

  @override
  String get pouchContentsCopper =>
      'Glut 2, plus 1–2 of: seal L1–L2, 2 Glut, 2 splinters';

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
      '0': 'Kraa! Kolk reporting.',
      '1': 'Kraa, kraa! Nicely walked!',
      '2': 'Psst, Kolk here.',
      '3': 'Kraa! Guess who’s here.',
      '4': 'Hello, pacemaker!',
      '5': 'Kraa! I was waiting for you.',
      'other': 'Kraa! Kolk reporting.',
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
      '0': 'A little light flickers – Flimm is here.',
      '1': 'Sssh … I followed your light.',
      '2': 'Good evening, even if it’s day.',
      '3': 'Flimm here, very quietly.',
      '4': 'Your steps are glowing today.',
      '5': 'I came with the wind.',
      'other': 'A little light flickers – Flimm is here.',
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
      '0': 'Greetings. Vesper has descended.',
      '1': 'The stars told me where you walk.',
      '2': 'I rarely come. Today I come to you.',
      '3': 'Don’t bow – keep walking instead.',
      '4': 'The night sky sends me.',
      '5': 'A rare evening for a rare guest.',
      'other': 'Greetings. Vesper has descended.',
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
      '4': 'Done! The reward is in your case.',
      '5': 'Bravo – I knew you could.',
      'other': 'Done! Here’s your reward.',
    });
    return '$_temp0';
  }

  @override
  String get msgTitleRuhu => 'Ruhu · owl of the field paths';

  @override
  String get msgTitleKolk => 'Kolk · raven of the waysides';

  @override
  String get msgTitleFlimm => 'Flimm · lantern moth';

  @override
  String get msgTitleVesper => 'Vesper · star owl';

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
  String get msgDoneNote => 'The reward is already in your seal case.';

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
      other: '$n runs with ≥ 58 % Sweet Spot',
      one: '1 run with ≥ 58 % Sweet Spot',
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
}
