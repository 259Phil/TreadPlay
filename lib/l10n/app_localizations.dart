import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Treadplay'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabForge.
  ///
  /// In en, this message translates to:
  /// **'Forge'**
  String get tabForge;

  /// No description provided for @tabMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get tabMarket;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @lpAmount.
  ///
  /// In en, this message translates to:
  /// **'{lp} LP'**
  String lpAmount(String lp);

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String levelShort(int level);

  /// No description provided for @breath.
  ///
  /// In en, this message translates to:
  /// **'Breath'**
  String get breath;

  /// No description provided for @breathValue.
  ///
  /// In en, this message translates to:
  /// **'{current} / {max}'**
  String breathValue(String current, int max);

  /// No description provided for @breathRegenHint.
  ///
  /// In en, this message translates to:
  /// **'One shared bar for all companions, +1 every 90 min. Taking a companion along only sets the max.'**
  String get breathRegenHint;

  /// No description provided for @breathMax.
  ///
  /// In en, this message translates to:
  /// **'Breath max {max}'**
  String breathMax(int max);

  /// No description provided for @breathEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Out of breath. You can still move, but you earn no LP until the bar recovers.'**
  String get breathEmptyHint;

  /// No description provided for @rarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  /// No description provided for @rarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  /// No description provided for @rarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get rarityEpic;

  /// No description provided for @rarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get rarityLegendary;

  /// No description provided for @sweetSpotAt.
  ///
  /// In en, this message translates to:
  /// **'Sweet spot {speed} km/h'**
  String sweetSpotAt(String speed);

  /// No description provided for @startRun.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startRun;

  /// No description provided for @stopRun.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopRun;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @kmValue.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String kmValue(String km);

  /// No description provided for @kmhValue.
  ///
  /// In en, this message translates to:
  /// **'{kmh} km/h'**
  String kmhValue(String kmh);

  /// No description provided for @lpThisRun.
  ///
  /// In en, this message translates to:
  /// **'LP this run'**
  String get lpThisRun;

  /// No description provided for @hintStanding.
  ///
  /// In en, this message translates to:
  /// **'Keep moving – standing still earns nothing.'**
  String get hintStanding;

  /// No description provided for @hintOutside.
  ///
  /// In en, this message translates to:
  /// **'Outside the sweet spot'**
  String get hintOutside;

  /// No description provided for @hintInside.
  ///
  /// In en, this message translates to:
  /// **'In the sweet spot'**
  String get hintInside;

  /// No description provided for @hintNoBreath.
  ///
  /// In en, this message translates to:
  /// **'Out of breath – tracking only'**
  String get hintNoBreath;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo movement (real GPS comes later)'**
  String get demoTitle;

  /// No description provided for @demoTimeLapse.
  ///
  /// In en, this message translates to:
  /// **'10× time'**
  String get demoTimeLapse;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Run complete'**
  String get summaryTitle;

  /// No description provided for @summaryInvalid.
  ///
  /// In en, this message translates to:
  /// **'This movement didn\'t look plausible, so it earned no LP. Your distance and time are still saved.'**
  String get summaryInvalid;

  /// No description provided for @summaryLp.
  ///
  /// In en, this message translates to:
  /// **'LP earned'**
  String get summaryLp;

  /// No description provided for @summaryBreathUsed.
  ///
  /// In en, this message translates to:
  /// **'Breath used'**
  String get summaryBreathUsed;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @lastRun.
  ///
  /// In en, this message translates to:
  /// **'Last run'**
  String get lastRun;

  /// No description provided for @invalidRun.
  ///
  /// In en, this message translates to:
  /// **'Not counted'**
  String get invalidRun;

  /// No description provided for @noRunsYet.
  ///
  /// In en, this message translates to:
  /// **'No runs yet. Take {name} along and get moving!'**
  String noRunsYet(String name);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later update.'**
  String get comingSoon;

  /// No description provided for @forgeTeaser.
  ///
  /// In en, this message translates to:
  /// **'The forge: set seals into charms and forge stronger ones.'**
  String get forgeTeaser;

  /// No description provided for @marketTeaser.
  ///
  /// In en, this message translates to:
  /// **'The market: find new companions and repair kits for LP.'**
  String get marketTeaser;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsKaching.
  ///
  /// In en, this message translates to:
  /// **'Ka-ching sound'**
  String get settingsKaching;

  /// No description provided for @settingsHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health data'**
  String get settingsHealthTitle;

  /// No description provided for @settingsHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Treadplay reads steps and distance from Apple Health or Health Connect only while a run is active. Apple and Google store your health data independently of us. We never upload it.'**
  String get settingsHealthBody;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your routes and runs stay on this device. No account, no cloud.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// No description provided for @creditsArtwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork created with Grok (xAI) and edited by Treadplay.'**
  String get creditsArtwork;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Walk with a companion.'**
  String get appTagline;

  /// No description provided for @tabShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get tabShelf;

  /// No description provided for @typeMoss.
  ///
  /// In en, this message translates to:
  /// **'Moss'**
  String get typeMoss;

  /// No description provided for @typeBrook.
  ///
  /// In en, this message translates to:
  /// **'Brook'**
  String get typeBrook;

  /// No description provided for @typeGale.
  ///
  /// In en, this message translates to:
  /// **'Gale'**
  String get typeGale;

  /// No description provided for @statStride.
  ///
  /// In en, this message translates to:
  /// **'Stride'**
  String get statStride;

  /// No description provided for @statGrit.
  ///
  /// In en, this message translates to:
  /// **'Grit'**
  String get statGrit;

  /// No description provided for @statFortune.
  ///
  /// In en, this message translates to:
  /// **'Fortune'**
  String get statFortune;

  /// No description provided for @statSpirit.
  ///
  /// In en, this message translates to:
  /// **'Spirit'**
  String get statSpirit;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value} %'**
  String percentValue(String value);

  /// No description provided for @takeAlong.
  ///
  /// In en, this message translates to:
  /// **'Take along'**
  String get takeAlong;

  /// No description provided for @takenAlong.
  ///
  /// In en, this message translates to:
  /// **'Along'**
  String get takenAlong;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up'**
  String get levelUp;

  /// No description provided for @repair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get repair;

  /// No description provided for @charms.
  ///
  /// In en, this message translates to:
  /// **'Charms'**
  String get charms;

  /// No description provided for @charmSlotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get charmSlotEmpty;

  /// No description provided for @notFoundYet.
  ///
  /// In en, this message translates to:
  /// **'Not found yet'**
  String get notFoundYet;

  /// No description provided for @filterWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get filterWorld;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get filterRarity;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @shelfNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the shelf with these filters.'**
  String get shelfNothingHere;

  /// No description provided for @worldMedieval.
  ///
  /// In en, this message translates to:
  /// **'Medieval'**
  String get worldMedieval;

  /// No description provided for @worldSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get worldSpace;

  /// No description provided for @worldUnderwater.
  ///
  /// In en, this message translates to:
  /// **'Underwater'**
  String get worldUnderwater;

  /// No description provided for @worldEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get worldEgypt;

  /// No description provided for @worldJungle.
  ///
  /// In en, this message translates to:
  /// **'Jungle'**
  String get worldJungle;

  /// No description provided for @worldPirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate'**
  String get worldPirate;

  /// No description provided for @worldRobot.
  ///
  /// In en, this message translates to:
  /// **'Robot'**
  String get worldRobot;

  /// No description provided for @worldRococo.
  ///
  /// In en, this message translates to:
  /// **'Rococo'**
  String get worldRococo;

  /// No description provided for @worldSteampunk.
  ///
  /// In en, this message translates to:
  /// **'Steampunk'**
  String get worldSteampunk;

  /// No description provided for @worldCandy.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get worldCandy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
