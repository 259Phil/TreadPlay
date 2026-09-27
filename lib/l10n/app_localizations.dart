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

  /// No description provided for @tabGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get tabGarage;

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
  /// **'+1 every 90 min, per boot'**
  String get breathRegenHint;

  /// No description provided for @breathEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'This boot is out of breath. You can still move, but it earns no LP until it recovers.'**
  String get breathEmptyHint;

  /// No description provided for @typeStomper.
  ///
  /// In en, this message translates to:
  /// **'Stomper'**
  String get typeStomper;

  /// No description provided for @typeStrider.
  ///
  /// In en, this message translates to:
  /// **'Strider'**
  String get typeStrider;

  /// No description provided for @typeDasher.
  ///
  /// In en, this message translates to:
  /// **'Dasher'**
  String get typeDasher;

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

  /// No description provided for @noRunsYet.
  ///
  /// In en, this message translates to:
  /// **'No runs yet. Put on Cobble and get moving!'**
  String get noRunsYet;

  /// No description provided for @invalidRun.
  ///
  /// In en, this message translates to:
  /// **'Not counted'**
  String get invalidRun;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later update.'**
  String get comingSoon;

  /// No description provided for @garageTeaser.
  ///
  /// In en, this message translates to:
  /// **'Your boot shelf: collect, level up and repair boots.'**
  String get garageTeaser;

  /// No description provided for @forgeTeaser.
  ///
  /// In en, this message translates to:
  /// **'The forge: set seals into buckles and forge stronger ones.'**
  String get forgeTeaser;

  /// No description provided for @marketTeaser.
  ///
  /// In en, this message translates to:
  /// **'The market: buy boots and repair kits with your LP.'**
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
