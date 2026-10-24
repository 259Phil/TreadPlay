# Handoff for Devin: AdMob + UMP + ATT for TreadPlay

Repo `259Phil/TreadPlay`, branch `grokbot/polish-2`. App id / bundle id: `com.benderinteractive.treadplay` (Android + iOS; iOS tests `com.benderinteractive.treadplay.RunnerTests`). Flutter 3.x, `google_mobile_ads: ^7.0.0` already in pubspec.

## 1. What exists today (audit, 24.10.2026)

- **Only ad format:** optional rewarded video. Button `VideoButton` (`lib/features/home/video_button.dart`), next to the LP pill on Home. Up to 3 per local day, rewards 1.0 / 0.6 / 0.4 of one Breath's LP (`lib/domain/video_rewards.dart`). The reward is paid only on `AdOutcome.earned` (`GameNotifier.claimVideo`).
- **Service seam:** `lib/ads/rewarded_ad_service.dart`
  - `RewardedAdService` interface (`available`, `show() -> AdOutcome earned/skipped/failed`).
  - `rewardedAdServiceProvider` (Riverpod): `TREADPLAY_FAKE_ADS=true` (non-release) gives `FakeRewardedAdService`; Web gives `UnavailableRewardedAdService` (the button is hidden); Android/iOS give `GoogleRewardedAdService` via conditional import (`google_rewarded_ad_service.dart` / `_stub.dart`).
- **`GoogleRewardedAdService`:** `MobileAds.instance.initialize()` runs lazily on the first tap, never at launch. It loads `RewardedAd` with a plain `AdRequest()` and **hard-coded Google TEST unit IDs** (Android `ca-app-pub-3940256099942544/5224354917`, iOS `ca-app-pub-3940256099942544/1712485313`). The class doc already has TODO(ads) notes.
- **App IDs:** Google TEST app IDs, hard-coded with a TODO comment:
  - `android/app/src/main/AndroidManifest.xml` meta-data `com.google.android.gms.ads.APPLICATION_ID` = `ca-app-pub-3940256099942544~3347511713`
  - `ios/Runner/Info.plist` `GADApplicationIdentifier` = `ca-app-pub-3940256099942544~1458002511`
- **Missing:** UMP consent, ATT, `NSUserTrackingUsageDescription`, `SKAdNetworkItems`, a settings entry for privacy options, a central ads config, and release IDs. There is no AdMob use on Web, and the web build should stay ad-free.
- **Tests:** `test/widget_test.dart` overrides `rewardedAdServiceProvider` with `FakeRewardedAdService`. Keep that seam.

## 2. What to build

1. **One config file**, e.g. `lib/config/ads_config.dart`: Android/iOS rewarded unit IDs as clearly marked placeholders (`TODO(philip)`), plus Google test unit IDs used whenever `!kReleaseMode`. The release placeholders should fail loudly or disable the button, never ship test IDs. Native app IDs: use a Gradle `manifestPlaceholders` value (`${admobAppId}`) and an `.xcconfig` variable `$(ADMOB_APP_ID)` in Info.plist, so the real IDs live in one documented spot. Debug keeps the test app IDs.
2. **UMP before any ad request** (google_mobile_ads `ConsentInformation` / `ConsentForm`):
   - Call `ConsentInformation.instance.requestConsentInfoUpdate(ConsentRequestParameters(), ...)` on every app start (cheap, no ad load), then `ConsentForm.loadAndShowConsentFormIfRequired`.
   - Before loading an ad, check `ConsentInformation.instance.canRequestAds()`. If it returns false, `show()` returns `failed` and the button explains this calmly.
   - `MobileAds.instance.initialize()` runs only after `canRequestAds()` is true. Keep the lazy start where possible.
   - Debug: `ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea, testIdentifiers: [...])` behind a dart-define.
3. **Settings entry "Datenschutz-Einstellungen" / "Privacy settings"** in `lib/features/settings/settings_screen.dart`, next to the "Datenschutz/Privacy" row. Show it when `getPrivacyOptionsRequirementStatus() == required` (always-visible on mobile is also fine). On tap, call `ConsentForm.showPrivacyOptionsForm`. Hide it on Web. Add l10n keys to `app_de.arb`/`app_en.arb`, then run `flutter gen-l10n`.
4. **iOS ATT**: either configure the IDFA explainer in AdMob "Privacy & messaging" so UMP shows ATT, or use `app_tracking_transparency` after the UMP flow (request only if `notDetermined`). Info.plist needs `NSUserTrackingUsageDescription`. Base value (EN) and German via `de.lproj/InfoPlist.strings`, and add `de` to the Xcode project's known regions (or `CFBundleLocalizations`). Suggested texts:
   - EN: "TreadPlay shows optional reward videos. If you allow it, Google can use your device's advertising ID to show more relevant ads. Without permission you still get ads, just less personalised."
   - DE: "TreadPlay zeigt freiwillige Belohnungsvideos. Wenn du es erlaubst, kann Google die Werbe-ID deines Geräts nutzen, um passendere Werbung zu zeigen. Ohne Erlaubnis gibt es trotzdem Werbung, nur weniger personalisiert."
   - Also add Google's `SKAdNetworkItems` list to Info.plist.
5. **Android:** play-services-ads merges the `com.google.android.gms.permission.AD_ID` permission. Check the merged manifest and declare it in the Play Console. Android 13+ needs nothing else.
6. **Ads never required to progress:** keep it that way. Videos are an optional bonus, and running is the main income. No ad at app start, no interstitials, no gating of runs, the market, the forge or the trail. A `failed` or `skipped` result costs nothing.

## 3. Tests to add (feasible without a device)

- `ads_config`: debug resolves test IDs, release placeholders are flagged/disabled.
- Settings shows the privacy-options row on Android/iOS when a fake consent service says `required`, and hides it on Web. Wrap UMP in a small `ConsentService` interface + Riverpod provider so widget tests can fake it, like `RewardedAdService`.
- `VideoButton`: when `canRequestAds == false`, it shows a message and pays nothing.
- Keep the existing checks green: `flutter analyze`, `flutter test`, `bash scripts/check_forbidden_terms.sh`.

## 4. Device-only checks

The UMP form actually appears in the EEA (debug geography), "Manage options" and "Privacy settings" reopen it, the ATT prompt shows once (iOS 14.5+), the test rewarded ad loads, plays and pays, and the merged Android manifest is correct. None of this runs in `flutter test`.

## 5. Privacy text to update afterwards

`lib/features/legal/legal_texts.dart` (DE+EN, mirrored in `docs/legal/privacy.md`). **Section 5 "Belohnte Videos (Werbung)" / "Rewarded videos (ads)"** is currently an interim text marked `[Übergangstext ...]` / `[Interim text ...]`, which says no consent dialog exists yet. Rewrite it to describe:
- UMP (Google as provider, personalised vs non-personalised),
- reopening consent via Settings → Datenschutz-Einstellungen,
- iOS ATT,
- legal basis (lawyer).

Then remove the interim marker and update `test/legal_texts_test.dart` (it asserts the marker). Draft review notes were kept outside the repo (DATENSCHUTZ_ENTWURF.md, ask Philip); the current text is in `docs/legal/privacy.md`.
