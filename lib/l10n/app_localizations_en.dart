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
  String get breathRegenHint => '+1 every 90 min, per companion';

  @override
  String get breathEmptyHint =>
      'Your companion is out of breath. You can still move, but it earns no LP until it recovers.';

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
  String get hintOutside => 'Outside the sweet spot';

  @override
  String get hintInside => 'In the sweet spot';

  @override
  String get hintNoBreath => 'Out of breath – tracking only';

  @override
  String get demoTitle => 'Demo movement (real GPS comes later)';

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
  String get comingSoon => 'Coming in a later update.';

  @override
  String get forgeTeaser =>
      'The forge: set seals into charms and forge stronger ones.';

  @override
  String get marketTeaser =>
      'The market: find new companions and repair kits for LP.';

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
}
