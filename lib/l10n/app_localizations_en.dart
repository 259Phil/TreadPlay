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
  String get tabShelf => 'Shelf';

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
  String get shelfNothingHere => 'Nothing on the shelf with these filters.';

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
    return 'Shelf $count/$cap';
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
    return 'Your shelf is full ($cap/$cap). Sell a companion first.';
  }

  @override
  String get marketNotEnoughLp => 'Not enough LP yet.';

  @override
  String get marketNeedsSpirit => 'Trading only at 100 % Spirit.';

  @override
  String marketLastCompanion(String name) {
    return '$name stays until a second companion joins your shelf.';
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
  String sealBonus(int n, String stat) {
    return '+$n $stat';
  }

  @override
  String get forgeAlong => 'Seals go to the companion you have along.';

  @override
  String forgeFreeSockets(int free, int total) {
    return '$free of $total sockets free';
  }

  @override
  String get forgeRule =>
      'Each seal adds +1 to its stat, up to +3 per stat. Paid in LP.';

  @override
  String forgeStatCount(int n) {
    return '+$n of +3';
  }

  @override
  String get forgeSet => 'Set';

  @override
  String get forgeMaxed => 'Max';

  @override
  String get forgeNeedsSpirit => 'Forging only at 100 % Spirit.';

  @override
  String get forgeNotEnoughLp => 'Not enough LP yet.';

  @override
  String get forgeNoSocket => 'No empty socket left.';

  @override
  String get forgeSellNote =>
      'Seals stay on this companion. Selling it removes them; LP are not refunded.';

  @override
  String get forgeClearHint => 'Tap a filled socket to remove its seal.';

  @override
  String forgeClearTitle(String seal) {
    return 'Remove $seal?';
  }

  @override
  String get forgeClearBody =>
      'The socket will be empty again. LP are not refunded.';

  @override
  String get forgeClearAction => 'Remove';

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
      'Companions, seals, LP, Breath, run history and lifetime totals are removed. You start again with Pebble.';

  @override
  String get saveDeleteReallyTitle => 'Really delete everything?';

  @override
  String get saveDeleteReallyBody =>
      'This cannot be undone. Without an export the save game is gone.';

  @override
  String get saveDeletePermanently => 'Delete permanently';

  @override
  String get saveDeleted => 'Save game deleted. Fresh start with Pebble.';

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
  String get wwUnlockShelfPlus2 => 'Shelf +2 slots (12→14)';

  @override
  String get wwUnlockCombineL5 => 'Combining L5';

  @override
  String get wwUnlockWorldRococoCandy => 'Worlds Rococo + Candy + species';

  @override
  String get wwLine1 =>
      'A companion doesn’t grow on a shelf. It grows beside you, step by step.';

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
      'More room on the shelf. The growing still happens outside.';

  @override
  String get wwLine18 => 'Whoever keeps the beat, the ember follows.';

  @override
  String get wwLine19 => 'No end, only a bend. The trail grows with you.';
}
