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
  /// **'TreadPlay'**
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
  /// **'Outside the sweet spot – distance counts, no LP'**
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

  /// No description provided for @runWebGpsHint.
  ///
  /// In en, this message translates to:
  /// **'Keep the screen on and this page open – in the background the browser pauses GPS.'**
  String get runWebGpsHint;

  /// No description provided for @hintGpsWarmup.
  ///
  /// In en, this message translates to:
  /// **'GPS is settling – one moment …'**
  String get hintGpsWarmup;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Simulator (debug build only)'**
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
  /// **'Movement data'**
  String get settingsHealthTitle;

  /// No description provided for @settingsHealthBody.
  ///
  /// In en, this message translates to:
  /// **'TreadPlay uses location (GPS) and the step counter only while a run is active and only on this device. Only the run summary is saved, no route. Nothing is uploaded.'**
  String get settingsHealthBody;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your runs and your save game stay on this device. No account, no cloud.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// No description provided for @creditsArtwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork created with Grok (xAI) and edited by TreadPlay.'**
  String get creditsArtwork;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Walk with a companion.'**
  String get appTagline;

  /// No description provided for @tabShelf.
  ///
  /// In en, this message translates to:
  /// **'Den'**
  String get tabShelf;

  /// No description provided for @typeMoss.
  ///
  /// In en, this message translates to:
  /// **'Stroll'**
  String get typeMoss;

  /// No description provided for @typeBrook.
  ///
  /// In en, this message translates to:
  /// **'Trot'**
  String get typeBrook;

  /// No description provided for @typeGale.
  ///
  /// In en, this message translates to:
  /// **'Gallop'**
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
  /// **'Pace'**
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
  /// **'Nobody in the den with these filters.'**
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

  /// No description provided for @marketBuyTab.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get marketBuyTab;

  /// No description provided for @marketSellTab.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get marketSellTab;

  /// No description provided for @marketHint.
  ///
  /// In en, this message translates to:
  /// **'Offers and prices drift during the day.'**
  String get marketHint;

  /// Market subtitle in the last half hour before the offers change; deliberately vague, no countdown.
  ///
  /// In en, this message translates to:
  /// **'Traders will restock soon.'**
  String get marketRestockSoon;

  /// No description provided for @shelfCount.
  ///
  /// In en, this message translates to:
  /// **'Den {count}/{cap}'**
  String shelfCount(int count, int cap);

  /// No description provided for @marketBuyFor.
  ///
  /// In en, this message translates to:
  /// **'Buy · {price}'**
  String marketBuyFor(String price);

  /// No description provided for @marketSellFor.
  ///
  /// In en, this message translates to:
  /// **'Sell · {price}'**
  String marketSellFor(String price);

  /// No description provided for @marketGone.
  ///
  /// In en, this message translates to:
  /// **'This offer is no longer here.'**
  String get marketGone;

  /// No description provided for @marketShelfFull.
  ///
  /// In en, this message translates to:
  /// **'Your den is full ({cap}/{cap}). Sell a companion first.'**
  String marketShelfFull(int cap);

  /// No description provided for @marketNotEnoughLp.
  ///
  /// In en, this message translates to:
  /// **'Not enough LP yet.'**
  String get marketNotEnoughLp;

  /// No description provided for @marketNeedsSpirit.
  ///
  /// In en, this message translates to:
  /// **'Trading only at 100 % Spirit.'**
  String get marketNeedsSpirit;

  /// No description provided for @marketLastCompanion.
  ///
  /// In en, this message translates to:
  /// **'{name} stays until a second companion joins your den.'**
  String marketLastCompanion(String name);

  /// No description provided for @marketSellSwitches.
  ///
  /// In en, this message translates to:
  /// **'Afterwards {name} goes along with you.'**
  String marketSellSwitches(String name);

  /// No description provided for @marketSoldOut.
  ///
  /// In en, this message translates to:
  /// **'All offers are gone. New ones arrive later.'**
  String get marketSoldOut;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get settingsTerms;

  /// No description provided for @settingsMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement access'**
  String get settingsMovement;

  /// No description provided for @settingsMovementOn.
  ///
  /// In en, this message translates to:
  /// **'Real movement earns LP. Readings stay on this device.'**
  String get settingsMovementOn;

  /// No description provided for @settingsMovementOff.
  ///
  /// In en, this message translates to:
  /// **'Off: real movement earns no LP.'**
  String get settingsMovementOff;

  /// No description provided for @movementNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Movement and location'**
  String get movementNoticeTitle;

  /// No description provided for @movementNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'To count a walk, TreadPlay uses your location (GPS) and the step counter during the run. Readings stay on this device and are only used to measure distance and pace and to award LP. No route is saved and nothing is uploaded. If you deny, real movement earns no LP.'**
  String get movementNoticeBody;

  /// No description provided for @movementDeniedHint.
  ///
  /// In en, this message translates to:
  /// **'Movement access is off. Runs earn no LP until you allow it.'**
  String get movementDeniedHint;

  /// No description provided for @movementNoticePrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Read the privacy policy'**
  String get movementNoticePrivacyLink;

  /// No description provided for @movementAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get movementAllow;

  /// No description provided for @movementDeny.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get movementDeny;

  /// No description provided for @todayKm.
  ///
  /// In en, this message translates to:
  /// **'Today {km}'**
  String todayKm(String km);

  /// No description provided for @sealName.
  ///
  /// In en, this message translates to:
  /// **'{stat} seal'**
  String sealName(String stat);

  /// No description provided for @forgeFreeSockets.
  ///
  /// In en, this message translates to:
  /// **'{free} of {total} sockets free'**
  String forgeFreeSockets(int free, int total);

  /// No description provided for @forgeRule.
  ///
  /// In en, this message translates to:
  /// **'Each seal raises its stat by a share: L1 +4 %, L2 +9 %, L3 +15 %, L4 +22 %, L5 +31 %.'**
  String get forgeRule;

  /// No description provided for @forgeNeedsSpirit.
  ///
  /// In en, this message translates to:
  /// **'Seals are set only from 50 % Spirit.'**
  String get forgeNeedsSpirit;

  /// No description provided for @forgeNotEnoughLp.
  ///
  /// In en, this message translates to:
  /// **'Not enough LP yet.'**
  String get forgeNotEnoughLp;

  /// No description provided for @forgeNoSocket.
  ///
  /// In en, this message translates to:
  /// **'No empty socket left.'**
  String get forgeNoSocket;

  /// No description provided for @forgeSellNote.
  ///
  /// In en, this message translates to:
  /// **'Selling a companion puts its seals back into the case.'**
  String get forgeSellNote;

  /// No description provided for @forgeClearHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a seal to take it out, an empty socket to set one.'**
  String get forgeClearHint;

  /// No description provided for @forgeClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Take out {seal}?'**
  String forgeClearTitle(String seal);

  /// No description provided for @forgeClearBody.
  ///
  /// In en, this message translates to:
  /// **'It goes back into the case. Nothing is lost.'**
  String get forgeClearBody;

  /// No description provided for @forgeClearAction.
  ///
  /// In en, this message translates to:
  /// **'Take out'**
  String get forgeClearAction;

  /// No description provided for @forgeClearKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get forgeClearKeep;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @paceValue.
  ///
  /// In en, this message translates to:
  /// **'{pace} /km'**
  String paceValue(String pace);

  /// No description provided for @summaryBreathLeft.
  ///
  /// In en, this message translates to:
  /// **'Breath left'**
  String get summaryBreathLeft;

  /// No description provided for @runNoLp.
  ///
  /// In en, this message translates to:
  /// **'Movement access is off. Distance is not read and this run earns no LP.'**
  String get runNoLp;

  /// No description provided for @summaryNoLp.
  ///
  /// In en, this message translates to:
  /// **'Movement access was off, so this run earned no LP.'**
  String get summaryNoLp;

  /// No description provided for @settingsHistory.
  ///
  /// In en, this message translates to:
  /// **'Run history'**
  String get settingsHistory;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Run history'**
  String get historyTitle;

  /// No description provided for @historyTotals.
  ///
  /// In en, this message translates to:
  /// **'{km} km · {runs} runs · {lp} LP in total'**
  String historyTotals(String km, int runs, String lp);

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No runs yet. Your runs show up here after you stop.'**
  String get historyEmpty;

  /// No description provided for @historyLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device. No route, no map.'**
  String get historyLocalNote;

  /// No description provided for @historyErase.
  ///
  /// In en, this message translates to:
  /// **'Erase local record'**
  String get historyErase;

  /// No description provided for @historyEraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase local record?'**
  String get historyEraseTitle;

  /// No description provided for @historyEraseBody.
  ///
  /// In en, this message translates to:
  /// **'All stored runs on this device are deleted. Your lifetime totals for milestones stay.'**
  String get historyEraseBody;

  /// No description provided for @historyErased.
  ///
  /// In en, this message translates to:
  /// **'Run history erased.'**
  String get historyErased;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @runDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get runDetailTitle;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @breathUsed.
  ///
  /// In en, this message translates to:
  /// **'Breath used'**
  String get breathUsed;

  /// No description provided for @sweetSpotShare.
  ///
  /// In en, this message translates to:
  /// **'In sweet spot'**
  String get sweetSpotShare;

  /// No description provided for @videoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Optional video: +{lp} LP ({left} left today)'**
  String videoTooltip(String lp, int left);

  /// No description provided for @videoTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional video'**
  String get videoTitle;

  /// No description provided for @videoBody.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video for +{lp} LP. Up to {max} a day, each worth a little less. Running always earns more.'**
  String videoBody(String lp, int max);

  /// No description provided for @videoWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get videoWatch;

  /// No description provided for @videoEarned.
  ///
  /// In en, this message translates to:
  /// **'+{lp} LP from the video'**
  String videoEarned(String lp);

  /// No description provided for @videoSkipped.
  ///
  /// In en, this message translates to:
  /// **'Video closed early. No LP this time.'**
  String get videoSkipped;

  /// No description provided for @videoFailed.
  ///
  /// In en, this message translates to:
  /// **'No video available right now.'**
  String get videoFailed;

  /// No description provided for @videoUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Today\'s videos are used up. New ones tomorrow.'**
  String get videoUsedUp;

  /// No description provided for @settingsSaveGame.
  ///
  /// In en, this message translates to:
  /// **'Save game'**
  String get settingsSaveGame;

  /// No description provided for @saveHint.
  ///
  /// In en, this message translates to:
  /// **'Your save game lives only on this device. Export it as a file to keep a copy or to move to a new phone.'**
  String get saveHint;

  /// No description provided for @saveExport.
  ///
  /// In en, this message translates to:
  /// **'Export save game'**
  String get saveExport;

  /// No description provided for @saveNoExportYet.
  ///
  /// In en, this message translates to:
  /// **'No export yet'**
  String get saveNoExportYet;

  /// No description provided for @saveLastExport.
  ///
  /// In en, this message translates to:
  /// **'Last export: {date}'**
  String saveLastExport(String date);

  /// No description provided for @saveImport.
  ///
  /// In en, this message translates to:
  /// **'Import save game'**
  String get saveImport;

  /// No description provided for @saveImportSub.
  ///
  /// In en, this message translates to:
  /// **'Replaces the save game on this device'**
  String get saveImportSub;

  /// No description provided for @saveDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete save game'**
  String get saveDelete;

  /// No description provided for @saveShareSubject.
  ///
  /// In en, this message translates to:
  /// **'TreadPlay save game'**
  String get saveShareSubject;

  /// No description provided for @saveExported.
  ///
  /// In en, this message translates to:
  /// **'Save game exported.'**
  String get saveExported;

  /// No description provided for @saveDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Save game downloaded.'**
  String get saveDownloaded;

  /// No description provided for @saveImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import save game?'**
  String get saveImportTitle;

  /// No description provided for @saveImportSummary.
  ///
  /// In en, this message translates to:
  /// **'This save holds {companions} companions, {lp} LP and {runs} stored runs. Exported: {date}.\n\nReplace overwrites your current save game on this device.'**
  String saveImportSummary(int companions, String lp, int runs, String date);

  /// No description provided for @saveReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get saveReplace;

  /// No description provided for @saveImported.
  ///
  /// In en, this message translates to:
  /// **'Save game imported.'**
  String get saveImported;

  /// No description provided for @saveErrorNotASave.
  ///
  /// In en, this message translates to:
  /// **'This file is not a TreadPlay save game.'**
  String get saveErrorNotASave;

  /// No description provided for @saveErrorNewer.
  ///
  /// In en, this message translates to:
  /// **'This save game comes from a newer TreadPlay version. Update the app first.'**
  String get saveErrorNewer;

  /// No description provided for @saveErrorDamaged.
  ///
  /// In en, this message translates to:
  /// **'This save game is damaged and can\'t be loaded. Your current game is unchanged.'**
  String get saveErrorDamaged;

  /// No description provided for @saveErrorDuringRun.
  ///
  /// In en, this message translates to:
  /// **'Not possible during a run.'**
  String get saveErrorDuringRun;

  /// No description provided for @saveDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete save game?'**
  String get saveDeleteTitle;

  /// No description provided for @saveDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Companions, seals, LP, Breath, run history and lifetime totals are removed, and so are the export copies the app kept itself. You start again with Mossik. Files you saved or shared elsewhere stay.'**
  String get saveDeleteBody;

  /// No description provided for @saveDeleteReallyTitle.
  ///
  /// In en, this message translates to:
  /// **'Really delete everything?'**
  String get saveDeleteReallyTitle;

  /// No description provided for @saveDeleteReallyBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Only an export file you saved outside the app can bring the save game back.'**
  String get saveDeleteReallyBody;

  /// No description provided for @saveDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get saveDeletePermanently;

  /// No description provided for @saveDeleted.
  ///
  /// In en, this message translates to:
  /// **'Save game deleted. Fresh start with Mossik.'**
  String get saveDeleted;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String saveError(String error);

  /// No description provided for @wwTitle.
  ///
  /// In en, this message translates to:
  /// **'Trail'**
  String get wwTitle;

  /// No description provided for @wwWaymark.
  ///
  /// In en, this message translates to:
  /// **'Waymark {n}'**
  String wwWaymark(int n);

  /// No description provided for @wwSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'{reached} of {total} waymarks · next at {km} km'**
  String wwSettingsSub(int reached, int total, String km);

  /// No description provided for @wwAllReached.
  ///
  /// In en, this message translates to:
  /// **'All {total} waymarks reached. New waymarks coming soon.'**
  String wwAllReached(int total);

  /// No description provided for @wwLastAt.
  ///
  /// In en, this message translates to:
  /// **'Last at waymark {n}'**
  String wwLastAt(int n);

  /// No description provided for @wwStartTitle.
  ///
  /// In en, this message translates to:
  /// **'The trail begins'**
  String get wwStartTitle;

  /// No description provided for @wwStartLine.
  ///
  /// In en, this message translates to:
  /// **'Every valid run counts. The first waymark is {km} km away.'**
  String wwStartLine(String km);

  /// No description provided for @wwNext.
  ///
  /// In en, this message translates to:
  /// **'Next waymark {n}'**
  String wwNext(int n);

  /// No description provided for @wwKmTask.
  ///
  /// In en, this message translates to:
  /// **'{km} km in total'**
  String wwKmTask(String km);

  /// No description provided for @wwKmValue.
  ///
  /// In en, this message translates to:
  /// **'{done} / {target} km'**
  String wwKmValue(String done, String target);

  /// No description provided for @wwLater.
  ///
  /// In en, this message translates to:
  /// **'later'**
  String get wwLater;

  /// No description provided for @wwLaterNote.
  ///
  /// In en, this message translates to:
  /// **'“later”: not in the game yet, already counts as done.'**
  String get wwLaterNote;

  /// No description provided for @wwUnlocked.
  ///
  /// In en, this message translates to:
  /// **'unlocked'**
  String get wwUnlocked;

  /// No description provided for @wwComingSoon.
  ///
  /// In en, this message translates to:
  /// **'comes with an update'**
  String get wwComingSoon;

  /// No description provided for @wwYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get wwYou;

  /// No description provided for @wwYouLeft.
  ///
  /// In en, this message translates to:
  /// **'{km} km to go'**
  String wwYouLeft(String km);

  /// No description provided for @wwYouTask.
  ///
  /// In en, this message translates to:
  /// **'task open'**
  String get wwYouTask;

  /// No description provided for @wwReachedOne.
  ///
  /// In en, this message translates to:
  /// **'Waymark {n} reached · {unlock}'**
  String wwReachedOne(int n, String unlock);

  /// No description provided for @wwReachedMany.
  ///
  /// In en, this message translates to:
  /// **'{count} waymarks reached'**
  String wwReachedMany(int count);

  /// No description provided for @wwOpenTrail.
  ///
  /// In en, this message translates to:
  /// **'Open the trail'**
  String get wwOpenTrail;

  /// No description provided for @wwFromWaymark.
  ///
  /// In en, this message translates to:
  /// **'from waymark {n}'**
  String wwFromWaymark(int n);

  /// No description provided for @wwLineLocked.
  ///
  /// In en, this message translates to:
  /// **'The messenger’s line waits at this waymark.'**
  String get wwLineLocked;

  /// No description provided for @wwForgeLocked.
  ///
  /// In en, this message translates to:
  /// **'The Forge opens at waymark 2 of the trail ({km} km).'**
  String wwForgeLocked(String km);

  /// No description provided for @wwClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get wwClose;

  /// No description provided for @wwTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get wwTasks;

  /// No description provided for @wwNoTask.
  ///
  /// In en, this message translates to:
  /// **'No task, only distance.'**
  String get wwNoTask;

  /// No description provided for @wwTaskBrownPouch.
  ///
  /// In en, this message translates to:
  /// **'Open a brown pouch'**
  String get wwTaskBrownPouch;

  /// No description provided for @wwTaskCopperPouch.
  ///
  /// In en, this message translates to:
  /// **'Open a copper pouch'**
  String get wwTaskCopperPouch;

  /// No description provided for @wwTaskTurquoisePouch.
  ///
  /// In en, this message translates to:
  /// **'Open a turquoise pouch'**
  String get wwTaskTurquoisePouch;

  /// No description provided for @wwTaskSealPlaced.
  ///
  /// In en, this message translates to:
  /// **'Forge a seal and set it'**
  String get wwTaskSealPlaced;

  /// No description provided for @wwTaskSealsForged.
  ///
  /// In en, this message translates to:
  /// **'Forge {n} seals in total'**
  String wwTaskSealsForged(int n);

  /// No description provided for @wwTaskSealL3.
  ///
  /// In en, this message translates to:
  /// **'One seal at L3'**
  String get wwTaskSealL3;

  /// No description provided for @wwTaskMessenger.
  ///
  /// In en, this message translates to:
  /// **'Meet a messenger'**
  String get wwTaskMessenger;

  /// No description provided for @wwTaskSweet58.
  ///
  /// In en, this message translates to:
  /// **'1 run with sweet spot ≥ 58 %'**
  String get wwTaskSweet58;

  /// No description provided for @wwTaskPouches.
  ///
  /// In en, this message translates to:
  /// **'Open {n} pouches'**
  String wwTaskPouches(int n);

  /// No description provided for @wwTaskSweet71.
  ///
  /// In en, this message translates to:
  /// **'{n} runs with sweet spot ≥ 71 %'**
  String wwTaskSweet71(int n);

  /// No description provided for @wwTaskLeash.
  ///
  /// In en, this message translates to:
  /// **'Fill the leash (a pouch on all 4 clips)'**
  String get wwTaskLeash;

  /// No description provided for @wwTaskBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy a second companion in the Market'**
  String get wwTaskBuy;

  /// No description provided for @wwTaskLevel.
  ///
  /// In en, this message translates to:
  /// **'A companion at level {n}'**
  String wwTaskLevel(int n);

  /// No description provided for @wwTaskCombine.
  ///
  /// In en, this message translates to:
  /// **'Combine once'**
  String get wwTaskCombine;

  /// No description provided for @wwUnlockBrownPouch.
  ///
  /// In en, this message translates to:
  /// **'Brown pouch'**
  String get wwUnlockBrownPouch;

  /// No description provided for @wwUnlockForge.
  ///
  /// In en, this message translates to:
  /// **'Forge (seals L1)'**
  String get wwUnlockForge;

  /// No description provided for @wwUnlockMarketMedievalJungle.
  ///
  /// In en, this message translates to:
  /// **'Market +2 species (Medieval, Jungle)'**
  String get wwUnlockMarketMedievalJungle;

  /// No description provided for @wwUnlockCopperPouch.
  ///
  /// In en, this message translates to:
  /// **'Copper pouch'**
  String get wwUnlockCopperPouch;

  /// No description provided for @wwUnlockForgeL2.
  ///
  /// In en, this message translates to:
  /// **'Forging L2'**
  String get wwUnlockForgeL2;

  /// No description provided for @wwUnlockWorldUnderwater.
  ///
  /// In en, this message translates to:
  /// **'World Underwater + species'**
  String get wwUnlockWorldUnderwater;

  /// No description provided for @wwUnlockLeashClip4.
  ///
  /// In en, this message translates to:
  /// **'4th leash clip'**
  String get wwUnlockLeashClip4;

  /// No description provided for @wwUnlockForgeL3.
  ///
  /// In en, this message translates to:
  /// **'Forging L3'**
  String get wwUnlockForgeL3;

  /// No description provided for @wwUnlockMarketEgyptPirate.
  ///
  /// In en, this message translates to:
  /// **'Market +2 species (Egypt, Pirates)'**
  String get wwUnlockMarketEgyptPirate;

  /// No description provided for @wwUnlockTurquoisePouch.
  ///
  /// In en, this message translates to:
  /// **'Turquoise pouch'**
  String get wwUnlockTurquoisePouch;

  /// No description provided for @wwUnlockWorldSteampunk.
  ///
  /// In en, this message translates to:
  /// **'World Steampunk + species'**
  String get wwUnlockWorldSteampunk;

  /// No description provided for @wwUnlockForgeL4.
  ///
  /// In en, this message translates to:
  /// **'Forging L4'**
  String get wwUnlockForgeL4;

  /// No description provided for @wwUnlockCombineL3.
  ///
  /// In en, this message translates to:
  /// **'Combining L1–L3'**
  String get wwUnlockCombineL3;

  /// No description provided for @wwUnlockNavyPouch.
  ///
  /// In en, this message translates to:
  /// **'Navy pouch'**
  String get wwUnlockNavyPouch;

  /// No description provided for @wwUnlockWorldSpaceRobot.
  ///
  /// In en, this message translates to:
  /// **'Worlds Space + Robot + species'**
  String get wwUnlockWorldSpaceRobot;

  /// No description provided for @wwUnlockForgeL5.
  ///
  /// In en, this message translates to:
  /// **'Forging L5'**
  String get wwUnlockForgeL5;

  /// No description provided for @wwUnlockShelfPlus2.
  ///
  /// In en, this message translates to:
  /// **'Den +2 slots (12→14)'**
  String get wwUnlockShelfPlus2;

  /// No description provided for @wwUnlockCombineL5.
  ///
  /// In en, this message translates to:
  /// **'Combining L4–L5'**
  String get wwUnlockCombineL5;

  /// No description provided for @wwUnlockWorldRococoCandy.
  ///
  /// In en, this message translates to:
  /// **'Worlds Rococo + Candy + species'**
  String get wwUnlockWorldRococoCandy;

  /// No description provided for @wwLine1.
  ///
  /// In en, this message translates to:
  /// **'A companion doesn’t grow in a den. It grows beside you, step by step.'**
  String get wwLine1;

  /// No description provided for @wwLine2.
  ///
  /// In en, this message translates to:
  /// **'What you find along the way belongs to you both.'**
  String get wwLine2;

  /// No description provided for @wwLine3.
  ///
  /// In en, this message translates to:
  /// **'New tracks in the Market. But no companion gets far if it is only carried.'**
  String get wwLine3;

  /// No description provided for @wwLine4.
  ///
  /// In en, this message translates to:
  /// **'A seal only holds what the trail has put into it.'**
  String get wwLine4;

  /// No description provided for @wwLine5.
  ///
  /// In en, this message translates to:
  /// **'Two equal seals, one fire. Patience is the third.'**
  String get wwLine5;

  /// No description provided for @wwLine6.
  ///
  /// In en, this message translates to:
  /// **'At the right pace you hear each other breathe.'**
  String get wwLine6;

  /// No description provided for @wwLine7.
  ///
  /// In en, this message translates to:
  /// **'One more clip means more that comes home with you.'**
  String get wwLine7;

  /// No description provided for @wwLine8.
  ///
  /// In en, this message translates to:
  /// **'The first ember in the brass. It only burns because you walked.'**
  String get wwLine8;

  /// No description provided for @wwLine9.
  ///
  /// In en, this message translates to:
  /// **'Far lands send their creatures. They are looking for someone to walk with.'**
  String get wwLine9;

  /// No description provided for @wwLine10.
  ///
  /// In en, this message translates to:
  /// **'A full leash is a full trail.'**
  String get wwLine10;

  /// No description provided for @wwLine11.
  ///
  /// In en, this message translates to:
  /// **'Steam and cogs. Even machines only learn on the way.'**
  String get wwLine11;

  /// No description provided for @wwLine12.
  ///
  /// In en, this message translates to:
  /// **'Forged five times. Now your hands know it.'**
  String get wwLine12;

  /// No description provided for @wwLine13.
  ///
  /// In en, this message translates to:
  /// **'Two powers in one seal, like two who walk the same trail.'**
  String get wwLine13;

  /// No description provided for @wwLine14.
  ///
  /// In en, this message translates to:
  /// **'Two together don’t make the trail shorter, but brighter.'**
  String get wwLine14;

  /// No description provided for @wwLine15.
  ///
  /// In en, this message translates to:
  /// **'Even between the stars only the next step counts.'**
  String get wwLine15;

  /// No description provided for @wwLine16.
  ///
  /// In en, this message translates to:
  /// **'The crown is not given. It is walked.'**
  String get wwLine16;

  /// No description provided for @wwLine17.
  ///
  /// In en, this message translates to:
  /// **'More room in the den. The growing still happens outside.'**
  String get wwLine17;

  /// No description provided for @wwLine18.
  ///
  /// In en, this message translates to:
  /// **'Whoever keeps the beat, the ember follows.'**
  String get wwLine18;

  /// No description provided for @wwLine19.
  ///
  /// In en, this message translates to:
  /// **'No end, only a bend. The trail grows with you.'**
  String get wwLine19;

  /// No description provided for @forgeIntro.
  ///
  /// In en, this message translates to:
  /// **'Seals wait in the case. Set them into the companion you have along.'**
  String get forgeIntro;

  /// No description provided for @forgeCompanionLine.
  ///
  /// In en, this message translates to:
  /// **'{name} · {rarity} · {total} sockets'**
  String forgeCompanionLine(String name, String rarity, int total);

  /// No description provided for @sealLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {n}'**
  String sealLevel(int n);

  /// No description provided for @sealLevelShort.
  ///
  /// In en, this message translates to:
  /// **'L{n}'**
  String sealLevelShort(int n);

  /// No description provided for @sealStatBonus.
  ///
  /// In en, this message translates to:
  /// **'{stat} +{pct} %'**
  String sealStatBonus(String stat, String pct);

  /// No description provided for @sealComboName.
  ///
  /// In en, this message translates to:
  /// **'{a} + {b}'**
  String sealComboName(String a, String b);

  /// No description provided for @sealComboBonus.
  ///
  /// In en, this message translates to:
  /// **'+{pct} % / +{pct} %'**
  String sealComboBonus(String pct);

  /// No description provided for @statBonus.
  ///
  /// In en, this message translates to:
  /// **'+{pct} %'**
  String statBonus(String pct);

  /// No description provided for @statCapped.
  ///
  /// In en, this message translates to:
  /// **'+{pct} % (cap)'**
  String statCapped(String pct);

  /// No description provided for @forgeModeUp.
  ///
  /// In en, this message translates to:
  /// **'Forge up'**
  String get forgeModeUp;

  /// No description provided for @forgeModeCombine.
  ///
  /// In en, this message translates to:
  /// **'Combine'**
  String get forgeModeCombine;

  /// No description provided for @forgeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Forge: 2 equal seals + Glut'**
  String get forgeUpTitle;

  /// No description provided for @forgeCombineTitle.
  ///
  /// In en, this message translates to:
  /// **'Combine: 2 different seals + Glut'**
  String get forgeCombineTitle;

  /// No description provided for @forgeGlutCost.
  ///
  /// In en, this message translates to:
  /// **'+ {n} Glut'**
  String forgeGlutCost(int n);

  /// No description provided for @forgeLpCost.
  ///
  /// In en, this message translates to:
  /// **'+ {lp} LP'**
  String forgeLpCost(String lp);

  /// No description provided for @forgeFailNote.
  ///
  /// In en, this message translates to:
  /// **'Fail chance {pct} % · then 1 seal turns into 3 splinters'**
  String forgeFailNote(String pct);

  /// No description provided for @forgeGlutRange.
  ///
  /// In en, this message translates to:
  /// **'Glut {min}–{max}: each extra Glut lowers the fail chance.'**
  String forgeGlutRange(int min, int max);

  /// No description provided for @forgeGlutFixed.
  ///
  /// In en, this message translates to:
  /// **'Needs exactly {n} Glut.'**
  String forgeGlutFixed(int n);

  /// No description provided for @forgePickSeal.
  ///
  /// In en, this message translates to:
  /// **'Pick a seal in the case below.'**
  String get forgePickSeal;

  /// No description provided for @forgePickPartner.
  ///
  /// In en, this message translates to:
  /// **'Now pick a seal of another stat at the same level.'**
  String get forgePickPartner;

  /// No description provided for @forgeMysteryIdle.
  ///
  /// In en, this message translates to:
  /// **'The signs are asleep …'**
  String get forgeMysteryIdle;

  /// No description provided for @forgeMysteryStir.
  ///
  /// In en, this message translates to:
  /// **'Something stirs …'**
  String get forgeMysteryStir;

  /// No description provided for @forgeMysteryReady.
  ///
  /// In en, this message translates to:
  /// **'Two essences call to each other …'**
  String get forgeMysteryReady;

  /// No description provided for @forgeCaseNone.
  ///
  /// In en, this message translates to:
  /// **'No loose seals yet.'**
  String get forgeCaseNone;

  /// No description provided for @forgeCase.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get forgeCase;

  /// No description provided for @forgeCaseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No loose seals yet. Buy a seal L1 in the Case tab.'**
  String get forgeCaseEmpty;

  /// No description provided for @forgeGlutSource.
  ///
  /// In en, this message translates to:
  /// **'Glut comes from pouches. A run of 1 km or more without a pouch still brings 1 Glut.'**
  String get forgeGlutSource;

  /// No description provided for @forgeBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'New seal L1 · {lp} LP'**
  String forgeBuyTitle(String lp);

  /// No description provided for @forgeMeltTitle.
  ///
  /// In en, this message translates to:
  /// **'Melt 5 splinters into a seal L1'**
  String get forgeMeltTitle;

  /// No description provided for @forgeAction.
  ///
  /// In en, this message translates to:
  /// **'Forge'**
  String get forgeAction;

  /// No description provided for @forgeCombineAction.
  ///
  /// In en, this message translates to:
  /// **'Combine'**
  String get forgeCombineAction;

  /// No description provided for @forgeSetAction.
  ///
  /// In en, this message translates to:
  /// **'Set into {name}'**
  String forgeSetAction(String name);

  /// No description provided for @forgeLevelLocked.
  ///
  /// In en, this message translates to:
  /// **'Forging L{n} opens at waymark {wm}.'**
  String forgeLevelLocked(int n, int wm);

  /// No description provided for @forgeCombineLocked.
  ///
  /// In en, this message translates to:
  /// **'Combining L{n} opens at waymark {wm}.'**
  String forgeCombineLocked(int n, int wm);

  /// No description provided for @forgeNeedsPair.
  ///
  /// In en, this message translates to:
  /// **'Needs 2 equal seals in the case.'**
  String get forgeNeedsPair;

  /// No description provided for @forgeNeedsGlut.
  ///
  /// In en, this message translates to:
  /// **'Not enough Glut yet.'**
  String get forgeNeedsGlut;

  /// No description provided for @forgeTopLevel.
  ///
  /// In en, this message translates to:
  /// **'L5 is the highest level.'**
  String get forgeTopLevel;

  /// No description provided for @forgeComboFinal.
  ///
  /// In en, this message translates to:
  /// **'Combined seals are not forged further.'**
  String get forgeComboFinal;

  /// No description provided for @forgeBadCombine.
  ///
  /// In en, this message translates to:
  /// **'Needs two single seals of different stats at the same level.'**
  String get forgeBadCombine;

  /// No description provided for @forgeSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Forged'**
  String get forgeSuccessTitle;

  /// No description provided for @forgeSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{seal} is now in the case.'**
  String forgeSuccessBody(String seal);

  /// No description provided for @forgeFailTitle.
  ///
  /// In en, this message translates to:
  /// **'The fire failed'**
  String get forgeFailTitle;

  /// No description provided for @forgeFailBody.
  ///
  /// In en, this message translates to:
  /// **'{seal} fell to 3 splinters. The other seal is back in the case.'**
  String forgeFailBody(String seal);

  /// No description provided for @forgeOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get forgeOk;

  /// No description provided for @forgeLadder.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get forgeLadder;

  /// No description provided for @forgeLadderTitle.
  ///
  /// In en, this message translates to:
  /// **'Seal levels'**
  String get forgeLadderTitle;

  /// No description provided for @forgeLadderNote.
  ///
  /// In en, this message translates to:
  /// **'At most +47 % per stat from all seals together. Combined seals (any level, two different stats) free a socket and give each stat about 60 % of a single seal.'**
  String get forgeLadderNote;

  /// No description provided for @forgePickTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a seal'**
  String get forgePickTitle;

  /// No description provided for @summaryGlut.
  ///
  /// In en, this message translates to:
  /// **'Glut for the Forge'**
  String get summaryGlut;

  /// No description provided for @glutAmount.
  ///
  /// In en, this message translates to:
  /// **'+{n} Glut'**
  String glutAmount(int n);

  /// No description provided for @pouchTitle.
  ///
  /// In en, this message translates to:
  /// **'Pouches'**
  String get pouchTitle;

  /// No description provided for @pouchBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown pouch'**
  String get pouchBrown;

  /// No description provided for @pouchCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper pouch'**
  String get pouchCopper;

  /// No description provided for @pouchTurquoise.
  ///
  /// In en, this message translates to:
  /// **'Turquoise pouch'**
  String get pouchTurquoise;

  /// No description provided for @pouchNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy pouch'**
  String get pouchNavy;

  /// No description provided for @pouchContentsBrown.
  ///
  /// In en, this message translates to:
  /// **'Glut 1–2, plus a seal L1 or 2 splinters, rarely a small spirit salve'**
  String get pouchContentsBrown;

  /// No description provided for @pouchContentsCopper.
  ///
  /// In en, this message translates to:
  /// **'Glut 2, plus 1–2 of: seal L1–L2, 2 Glut, 2 splinters, rarely a small spirit salve'**
  String get pouchContentsCopper;

  /// No description provided for @pouchContentsTurquoise.
  ///
  /// In en, this message translates to:
  /// **'Glut 2–3, plus 2 of: seal L1–L2, 2 Glut, 3 splinters'**
  String get pouchContentsTurquoise;

  /// No description provided for @pouchContentsNavy.
  ///
  /// In en, this message translates to:
  /// **'Glut 3, plus 2 of: seal L1–L3, 3 Glut, 3 splinters'**
  String get pouchContentsNavy;

  /// No description provided for @pouchLeash.
  ///
  /// In en, this message translates to:
  /// **'Leash {n}/{clips}'**
  String pouchLeash(int n, int clips);

  /// No description provided for @pouchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pouch on the leash. Runs find pouches; a full Breath tank gives the best chance.'**
  String get pouchEmpty;

  /// No description provided for @pouchLocked.
  ///
  /// In en, this message translates to:
  /// **'Pouches start at waymark 1 ({km} km).'**
  String pouchLocked(String km);

  /// No description provided for @pouchWarm.
  ///
  /// In en, this message translates to:
  /// **'Walk it open: {done} / {total} km'**
  String pouchWarm(String done, String total);

  /// No description provided for @pouchWarmShort.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} km'**
  String pouchWarmShort(String done, String total);

  /// No description provided for @pouchReady.
  ///
  /// In en, this message translates to:
  /// **'Walked warm: opens for free.'**
  String get pouchReady;

  /// No description provided for @pouchReadyShort.
  ///
  /// In en, this message translates to:
  /// **'warm'**
  String get pouchReadyShort;

  /// No description provided for @pouchFades.
  ///
  /// In en, this message translates to:
  /// **'Stays about {h} h more unless a run warms it.'**
  String pouchFades(int h);

  /// No description provided for @pouchOpenLp.
  ///
  /// In en, this message translates to:
  /// **'Open · {lp} LP'**
  String pouchOpenLp(int lp);

  /// No description provided for @pouchOpenFree.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pouchOpenFree;

  /// No description provided for @pouchNotEnoughLp.
  ///
  /// In en, this message translates to:
  /// **'Not enough LP. Or walk it warm.'**
  String get pouchNotEnoughLp;

  /// No description provided for @pouchOpened.
  ///
  /// In en, this message translates to:
  /// **'{name} opened'**
  String pouchOpened(String name);

  /// No description provided for @pouchIntoCase.
  ///
  /// In en, this message translates to:
  /// **'Everything is in the Forge case now.'**
  String get pouchIntoCase;

  /// No description provided for @pouchToForge.
  ///
  /// In en, this message translates to:
  /// **'To the Forge'**
  String get pouchToForge;

  /// No description provided for @pouchContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pouchContinue;

  /// No description provided for @pouchChance.
  ///
  /// In en, this message translates to:
  /// **'Find chance after a full Breath tank: {pct}'**
  String pouchChance(String pct);

  /// No description provided for @pouchFortune.
  ///
  /// In en, this message translates to:
  /// **'Fortune ×{f}, also for rarer colours'**
  String pouchFortune(String f);

  /// No description provided for @pouchRule.
  ///
  /// In en, this message translates to:
  /// **'One full Breath tank counts per run. A full leash finds nothing new. Pouches not walked warm fade after a day.'**
  String get pouchRule;

  /// No description provided for @pouchCounts.
  ///
  /// In en, this message translates to:
  /// **'Found {f} · opened {o}'**
  String pouchCounts(int f, int o);

  /// No description provided for @pouchSplinters.
  ///
  /// In en, this message translates to:
  /// **'+{n} splinters'**
  String pouchSplinters(int n);

  /// No description provided for @pouchPick.
  ///
  /// In en, this message translates to:
  /// **'Tap a pouch on the leash.'**
  String get pouchPick;

  /// No description provided for @summaryPouchFound.
  ///
  /// In en, this message translates to:
  /// **'Pouch found'**
  String get summaryPouchFound;

  /// No description provided for @summaryLeashFull.
  ///
  /// In en, this message translates to:
  /// **'Leash full: no new pouch this time.'**
  String get summaryLeashFull;

  /// No description provided for @summaryPouchesWarm.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 pouch walked warm: free to open.} other{{n} pouches walked warm: free to open.}}'**
  String summaryPouchesWarm(int n);

  /// No description provided for @summaryToLeash.
  ///
  /// In en, this message translates to:
  /// **'To the leash'**
  String get summaryToLeash;

  /// No description provided for @homeLeash.
  ///
  /// In en, this message translates to:
  /// **'Leash'**
  String get homeLeash;

  /// No description provided for @homeLeashOpen.
  ///
  /// In en, this message translates to:
  /// **'Open leash'**
  String get homeLeashOpen;

  /// No description provided for @homeLeashClose.
  ///
  /// In en, this message translates to:
  /// **'Close leash'**
  String get homeLeashClose;

  /// No description provided for @storesSplinters.
  ///
  /// In en, this message translates to:
  /// **'Splinters {s}/5'**
  String storesSplinters(int s);

  /// No description provided for @storesGlut.
  ///
  /// In en, this message translates to:
  /// **'Glut {g}'**
  String storesGlut(int g);

  /// No description provided for @pouchColorOdds.
  ///
  /// In en, this message translates to:
  /// **'Colours: {list}'**
  String pouchColorOdds(String list);

  /// No description provided for @pouchShortBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get pouchShortBrown;

  /// No description provided for @pouchShortCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper'**
  String get pouchShortCopper;

  /// No description provided for @pouchShortTurquoise.
  ///
  /// In en, this message translates to:
  /// **'Turquoise'**
  String get pouchShortTurquoise;

  /// No description provided for @pouchShortNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy'**
  String get pouchShortNavy;

  /// No description provided for @pouchColorShare.
  ///
  /// In en, this message translates to:
  /// **'{name} {pct}'**
  String pouchColorShare(String name, String pct);

  /// One-line flavour text for the companion species pebble.
  ///
  /// In en, this message translates to:
  /// **'A stone with a heart – and moss.'**
  String get flavourPebble;

  /// One-line flavour text for the companion species lumen.
  ///
  /// In en, this message translates to:
  /// **'Glows brighter the farther you go.'**
  String get flavourLumen;

  /// One-line flavour text for the companion species coil.
  ///
  /// In en, this message translates to:
  /// **'Ball, shell, friend.'**
  String get flavourCoil;

  /// One-line flavour text for the companion species gilt.
  ///
  /// In en, this message translates to:
  /// **'Frills first, questions later.'**
  String get flavourGilt;

  /// One-line flavour text for the companion species hookfin.
  ///
  /// In en, this message translates to:
  /// **'Quick, sharp and a little cheeky.'**
  String get flavourHookfin;

  /// One-line flavour text for the companion species valve.
  ///
  /// In en, this message translates to:
  /// **'Whistles when it’s time to go.'**
  String get flavourValve;

  /// One-line flavour text for the companion species dune.
  ///
  /// In en, this message translates to:
  /// **'Sand in its ears, wanderlust in its eyes.'**
  String get flavourDune;

  /// One-line flavour text for the companion species brine.
  ///
  /// In en, this message translates to:
  /// **'Pops up where you least expect it.'**
  String get flavourBrine;

  /// One-line flavour text for the companion species vine.
  ///
  /// In en, this message translates to:
  /// **'Grows on you – literally.'**
  String get flavourVine;

  /// One-line flavour text for the companion species glaze.
  ///
  /// In en, this message translates to:
  /// **'Sweet, with crystal edges.'**
  String get flavourGlaze;

  /// No description provided for @msgGreetRuhu.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Hoo-hoo! There you are.} 1{Ruhu here, just landed.} 2{Good day, fellow wanderer!} 3{Hoo … I saw you on the path.} 4{Oh, how lovely to meet you!} 5{Softly, softly – Ruhu is here.} other{Hoo-hoo! There you are.}}'**
  String msgGreetRuhu(String n);

  /// No description provided for @msgGiftRuhu.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{I hung a brown pouch on your leash.} 1{It lay under a hedge. Now it hangs on your leash.} 2{A small pouch, but tied with care.} 3{For your steps today – a pouch for the leash.} 4{Not much, but honestly found. It’s already hanging.} 5{Walk it warm and it opens by itself.} other{I hung a brown pouch on your leash.}}'**
  String msgGiftRuhu(String n);

  /// No description provided for @msgTaskRuhu.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Would you help me? There’s a reward after.} 1{I have a small favour to ask.} 2{A task, no hurry at all.} 3{If you have time: I need your legs.} 4{Do this for me and it will pay off.} 5{Just a little thing, I promise.} other{Would you help me? There’s a reward after.}}'**
  String msgTaskRuhu(String n);

  /// No description provided for @msgGreetKolk.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Kraa! Krahni reporting.} 1{Kraa, kraa! Nicely walked!} 2{Psst, Krahni here.} 3{Kraa! Guess who’s here.} 4{Hello, pacemaker!} 5{Kraa! I was waiting for you.} other{Kraa! Krahni reporting.}}'**
  String msgGreetKolk(String n);

  /// No description provided for @msgGiftKolk.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{It shone by the path – now it hangs on your leash.} 1{A copper pouch! I didn’t steal it. Almost.} 2{Found for you, brought to you.} 3{Copper jingles so nicely. It’s on your leash.} 4{Keep the beat and I’ll bring more.} 5{I carried it over three rooftops.} other{It shone by the path – now it hangs on your leash.}}'**
  String msgGiftKolk(String n);

  /// No description provided for @msgTaskKolk.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Kraa! I’ve got a task for you.} 1{Want to earn something? Listen.} 2{A raven never forgets – nor a reward.} 3{Do this and I’ll leave something shiny.} 4{Small bet: can you do it?} 5{Kraa! Here’s a task, no hurry.} other{Kraa! I’ve got a task for you.}}'**
  String msgTaskKolk(String n);

  /// No description provided for @msgGreetFlimm.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{A little light flickers – Glimmsel is here.} 1{Sssh … I followed your light.} 2{Good evening, even if it’s day.} 3{Glimmsel here, very quietly.} 4{Your steps are glowing today.} 5{I came with the wind.} other{A little light flickers – Glimmsel is here.}}'**
  String msgGreetFlimm(String n);

  /// No description provided for @msgGiftFlimm.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{A turquoise pouch, as rare as a clear sky.} 1{I hung it gently on your leash.} 2{It shimmers like my lantern. For you.} 3{Not everyone gets one of these. You do.} 4{Walk it warm and it will show its light.} 5{The evening breeze gave it to me.} other{A turquoise pouch, as rare as a clear sky.}}'**
  String msgGiftFlimm(String n);

  /// No description provided for @msgTaskFlimm.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Will you help me feed my light?} 1{A small wish, no deadline.} 2{If you like, I’ll show you the way.} 3{Follow this task like a firefly.} 4{Do this and my lantern will reward you.} 5{Just a thread of light of a task.} other{Will you help me feed my light?}}'**
  String msgTaskFlimm(String n);

  /// No description provided for @msgGreetVesper.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Greetings. Sternuh has descended.} 1{The stars told me where you walk.} 2{I rarely come. Today I come to you.} 3{Don’t bow – keep walking instead.} 4{The night sky sends me.} 5{A rare evening for a rare guest.} other{Greetings. Sternuh has descended.}}'**
  String msgGreetVesper(String n);

  /// No description provided for @msgGiftVesper.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{A navy pouch – the rarest of them all.} 1{From the treasury of the stars, onto your leash.} 2{Carry it with pride. It’s already hanging.} 3{Your Fortune called me. Here is its reward.} 4{Few ever see this velvet. You are one of them.} 5{Walk it warm – it holds great things.} other{A navy pouch – the rarest of them all.}}'**
  String msgGiftVesper(String n);

  /// No description provided for @msgTaskVesper.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{I set you a worthy task.} 1{Show me your endurance.} 2{A task from the stars, no hurry.} 3{Complete this and the sky will reward you.} 4{Big steps for a big reward.} 5{I’ll wait. Patience is my strength.} other{I set you a worthy task.}}'**
  String msgTaskVesper(String n);

  /// No description provided for @msgLineFull.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Oh – your leash is full!} 1{No clip free, what a pity.} 2{Your leash is full, I’ll take it back with me.} 3{Hm, all taken. Open a few pouches!} 4{Full leash! I’ll come another time.} 5{Everything’s hanging already – next time.} other{Oh – your leash is full!}}'**
  String msgLineFull(String n);

  /// No description provided for @msgLineDone.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 0{Done! Here’s your reward.} 1{Task complete – well walked!} 2{As promised: your reward.} 3{You did that nicely.} 4{Done! The reward is in the Forge case.} 5{Bravo – I knew you could.} other{Done! Here’s your reward.}}'**
  String msgLineDone(String n);

  /// No description provided for @msgTitleRuhu.
  ///
  /// In en, this message translates to:
  /// **'Ruhu · owl of the field paths'**
  String get msgTitleRuhu;

  /// No description provided for @msgTitleKolk.
  ///
  /// In en, this message translates to:
  /// **'Krahni · raven of the waysides'**
  String get msgTitleKolk;

  /// No description provided for @msgTitleFlimm.
  ///
  /// In en, this message translates to:
  /// **'Glimmsel · lantern moth'**
  String get msgTitleFlimm;

  /// No description provided for @msgTitleVesper.
  ///
  /// In en, this message translates to:
  /// **'Sternuh · star owl'**
  String get msgTitleVesper;

  /// No description provided for @msgRankBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown messenger · common'**
  String get msgRankBrown;

  /// No description provided for @msgRankCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper messenger · uncommon'**
  String get msgRankCopper;

  /// No description provided for @msgRankTurquoise.
  ///
  /// In en, this message translates to:
  /// **'Turquoise messenger · rare'**
  String get msgRankTurquoise;

  /// No description provided for @msgRankNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy messenger · very rare'**
  String get msgRankNavy;

  /// No description provided for @msgBrings.
  ///
  /// In en, this message translates to:
  /// **'Brings you'**
  String get msgBrings;

  /// No description provided for @msgReward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get msgReward;

  /// No description provided for @msgThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks'**
  String get msgThanks;

  /// No description provided for @msgAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get msgAccept;

  /// No description provided for @msgPouchInstead.
  ///
  /// In en, this message translates to:
  /// **'Rather the pouch'**
  String get msgPouchInstead;

  /// No description provided for @msgTaskOptional.
  ///
  /// In en, this message translates to:
  /// **'Small task · optional'**
  String get msgTaskOptional;

  /// No description provided for @msgTaskNote.
  ///
  /// In en, this message translates to:
  /// **'Instead of the pouch: reward once done. No deadline.'**
  String get msgTaskNote;

  /// No description provided for @msgLeashFullNote.
  ///
  /// In en, this message translates to:
  /// **'Your leash is full, no clip for the pouch. Nothing is lost: your run brings its Glut as always.'**
  String get msgLeashFullNote;

  /// No description provided for @msgDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Task done'**
  String get msgDoneTitle;

  /// No description provided for @msgDoneNote.
  ///
  /// In en, this message translates to:
  /// **'The reward is already in the Forge case.'**
  String get msgDoneNote;

  /// No description provided for @msgBoard.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get msgBoard;

  /// No description provided for @msgClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get msgClose;

  /// No description provided for @msgFootnote.
  ///
  /// In en, this message translates to:
  /// **'Only comes by luck after a run · more Fortune, rarer messengers'**
  String get msgFootnote;

  /// No description provided for @msgTaskWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk {km} km'**
  String msgTaskWalk(String km);

  /// No description provided for @msgTaskSweet.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 run with ≥ 58 % sweet spot} other{{n} runs with ≥ 58 % sweet spot}}'**
  String msgTaskSweet(int n);

  /// No description provided for @msgTaskRuns.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 valid run of 1 km or more} other{{n} valid runs of 1 km or more}}'**
  String msgTaskRuns(int n);

  /// No description provided for @msgTaskOpen.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Open 1 pouch} other{Open {n} pouches}}'**
  String msgTaskOpen(int n);

  /// No description provided for @msgProgressKm.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b} km'**
  String msgProgressKm(String a, String b);

  /// No description provided for @msgProgress.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b}'**
  String msgProgress(int a, int b);

  /// No description provided for @salveSmall.
  ///
  /// In en, this message translates to:
  /// **'Small spirit salve'**
  String get salveSmall;

  /// No description provided for @salveMedium.
  ///
  /// In en, this message translates to:
  /// **'Spirit salve jar'**
  String get salveMedium;

  /// No description provided for @salveLarge.
  ///
  /// In en, this message translates to:
  /// **'Rune pot salve'**
  String get salveLarge;

  /// No description provided for @salveEffect.
  ///
  /// In en, this message translates to:
  /// **'+{n} % Spirit'**
  String salveEffect(int n);

  /// No description provided for @salveEffectFull.
  ///
  /// In en, this message translates to:
  /// **'Spirit to 100 %'**
  String get salveEffectFull;

  /// No description provided for @salveButton.
  ///
  /// In en, this message translates to:
  /// **'Spirit salve'**
  String get salveButton;

  /// No description provided for @salveSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Spirit salve for {name}'**
  String salveSheetTitle(String name);

  /// No description provided for @salveSheetSpirit.
  ///
  /// In en, this message translates to:
  /// **'Spirit now {mut} %'**
  String salveSheetSpirit(String mut);

  /// No description provided for @salveOwned.
  ///
  /// In en, this message translates to:
  /// **'{n} in the case'**
  String salveOwned(int n);

  /// No description provided for @salveUse.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get salveUse;

  /// No description provided for @salveNoneHint.
  ///
  /// In en, this message translates to:
  /// **'No salves in the case. The Market trader sells them.'**
  String get salveNoneHint;

  /// No description provided for @salveFull.
  ///
  /// In en, this message translates to:
  /// **'Spirit is full.'**
  String get salveFull;

  /// No description provided for @salveApplied.
  ///
  /// In en, this message translates to:
  /// **'{name} is back at {mut} % Spirit.'**
  String salveApplied(String name, String mut);

  /// No description provided for @salveVorratTitle.
  ///
  /// In en, this message translates to:
  /// **'Spirit salves'**
  String get salveVorratTitle;

  /// No description provided for @salveVorratHint.
  ///
  /// In en, this message translates to:
  /// **'Tap one to apply it.'**
  String get salveVorratHint;

  /// No description provided for @salveVorratEmpty.
  ///
  /// In en, this message translates to:
  /// **'No salves yet. The Market trader has them.'**
  String get salveVorratEmpty;

  /// No description provided for @levelXp.
  ///
  /// In en, this message translates to:
  /// **'XP {xp} / {need}'**
  String levelXp(int xp, int need);

  /// No description provided for @levelMax.
  ///
  /// In en, this message translates to:
  /// **'Highest level reached'**
  String get levelMax;

  /// No description provided for @levelNextLp.
  ///
  /// In en, this message translates to:
  /// **'Next level: +{pct} % LP per Breath point'**
  String levelNextLp(int pct);

  /// No description provided for @levelNextTank.
  ///
  /// In en, this message translates to:
  /// **'Next level: +{pct} % LP per Breath point and +1 Breath tank'**
  String levelNextTank(int pct);

  /// No description provided for @levelXpHint.
  ///
  /// In en, this message translates to:
  /// **'1 XP per Breath point used in the sweet spot'**
  String get levelXpHint;

  /// No description provided for @levelUpFor.
  ///
  /// In en, this message translates to:
  /// **'Level up · {lp} LP'**
  String levelUpFor(String lp);

  /// No description provided for @levelNeedsXp.
  ///
  /// In en, this message translates to:
  /// **'{n} XP to walk'**
  String levelNeedsXp(int n);

  /// No description provided for @levelNeedsLp.
  ///
  /// In en, this message translates to:
  /// **'{lp} LP missing'**
  String levelNeedsLp(String lp);

  /// No description provided for @levelUpDone.
  ///
  /// In en, this message translates to:
  /// **'{name} is level {level} now!'**
  String levelUpDone(String name, int level);

  /// No description provided for @levelUpDoneTank.
  ///
  /// In en, this message translates to:
  /// **'{name} is level {level} now. Tank: {tank} Breath!'**
  String levelUpDoneTank(String name, int level, int tank);

  /// No description provided for @spiritLossLine.
  ///
  /// In en, this message translates to:
  /// **'Spirit −{loss} % per Breath point in the sweet spot'**
  String spiritLossLine(String loss);

  /// No description provided for @spiritGritSaves.
  ///
  /// In en, this message translates to:
  /// **'Grit saves {pct} %'**
  String spiritGritSaves(int pct);

  /// No description provided for @spiritLow.
  ///
  /// In en, this message translates to:
  /// **'{name} is down to {mut} % Spirit. At 0 % runs bring no LP – a spirit salve helps.'**
  String spiritLow(String name, String mut);

  /// No description provided for @summarySpirit.
  ///
  /// In en, this message translates to:
  /// **'Spirit'**
  String get summarySpirit;

  /// No description provided for @summarySpiritValue.
  ///
  /// In en, this message translates to:
  /// **'{before} % → {after} %'**
  String summarySpiritValue(String before, String after);

  /// No description provided for @summaryXp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get summaryXp;

  /// No description provided for @summaryXpValue.
  ///
  /// In en, this message translates to:
  /// **'+{n} XP'**
  String summaryXpValue(int n);

  /// No description provided for @summaryLevelReady.
  ///
  /// In en, this message translates to:
  /// **'{name} can level up – in the den.'**
  String summaryLevelReady(String name);

  /// No description provided for @marketSalvesTab.
  ///
  /// In en, this message translates to:
  /// **'Salves'**
  String get marketSalvesTab;

  /// No description provided for @marketSalvesIntro.
  ///
  /// In en, this message translates to:
  /// **'Spirit salves from the trader. Prices move with the Market; sometimes one is on offer.'**
  String get marketSalvesIntro;

  /// No description provided for @marketSalveDeal.
  ///
  /// In en, this message translates to:
  /// **'Offer −30 %'**
  String get marketSalveDeal;

  /// No description provided for @marketSalveBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy · {lp} LP'**
  String marketSalveBuy(String lp);

  /// No description provided for @marketSalveBought.
  ///
  /// In en, this message translates to:
  /// **'{name} is in the Forge case now.'**
  String marketSalveBought(String name);
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
