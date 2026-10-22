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

  /// No description provided for @shelfCount.
  ///
  /// In en, this message translates to:
  /// **'Shelf {count}/{cap}'**
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
  /// **'Your shelf is full ({cap}/{cap}). Sell a companion first.'**
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
  /// **'{name} stays until a second companion joins your shelf.'**
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
  /// **'Movement and health'**
  String get movementNoticeTitle;

  /// No description provided for @movementNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'To count a walk, TreadPlay asks for motion or health access (Apple Health or Health Connect, location only if GPS is used for distance). Readings stay on this device and are only used to check your pace and award LP. Nothing is uploaded. If you deny, real movement earns no LP.'**
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

  /// No description provided for @sealBonus.
  ///
  /// In en, this message translates to:
  /// **'+{n} {stat}'**
  String sealBonus(int n, String stat);

  /// No description provided for @forgeAlong.
  ///
  /// In en, this message translates to:
  /// **'Seals go to the companion you have along.'**
  String get forgeAlong;

  /// No description provided for @forgeFreeSockets.
  ///
  /// In en, this message translates to:
  /// **'{free} of {total} sockets free'**
  String forgeFreeSockets(int free, int total);

  /// No description provided for @forgeRule.
  ///
  /// In en, this message translates to:
  /// **'Each seal adds +1 to its stat, up to +3 per stat. Paid in LP.'**
  String get forgeRule;

  /// No description provided for @forgeStatCount.
  ///
  /// In en, this message translates to:
  /// **'+{n} of +3'**
  String forgeStatCount(int n);

  /// No description provided for @forgeSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get forgeSet;

  /// No description provided for @forgeMaxed.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get forgeMaxed;

  /// No description provided for @forgeNeedsSpirit.
  ///
  /// In en, this message translates to:
  /// **'Forging only at 100 % Spirit.'**
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
  /// **'Seals stay on this companion. Selling it removes them; LP are not refunded.'**
  String get forgeSellNote;

  /// No description provided for @forgeClearHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a filled socket to remove its seal.'**
  String get forgeClearHint;

  /// No description provided for @forgeClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {seal}?'**
  String forgeClearTitle(String seal);

  /// No description provided for @forgeClearBody.
  ///
  /// In en, this message translates to:
  /// **'The socket will be empty again. LP are not refunded.'**
  String get forgeClearBody;

  /// No description provided for @forgeClearAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
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
  /// **'Treadplay save game'**
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
  /// **'This file is not a Treadplay save game.'**
  String get saveErrorNotASave;

  /// No description provided for @saveErrorNewer.
  ///
  /// In en, this message translates to:
  /// **'This save game comes from a newer Treadplay version. Update the app first.'**
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
  /// **'Companions, seals, LP, Breath, run history and lifetime totals are removed. You start again with Pebble.'**
  String get saveDeleteBody;

  /// No description provided for @saveDeleteReallyTitle.
  ///
  /// In en, this message translates to:
  /// **'Really delete everything?'**
  String get saveDeleteReallyTitle;

  /// No description provided for @saveDeleteReallyBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Without an export the save game is gone.'**
  String get saveDeleteReallyBody;

  /// No description provided for @saveDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get saveDeletePermanently;

  /// No description provided for @saveDeleted.
  ///
  /// In en, this message translates to:
  /// **'Save game deleted. Fresh start with Pebble.'**
  String get saveDeleted;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String saveError(String error);
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
