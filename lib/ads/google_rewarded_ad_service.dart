import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'rewarded_ad_service.dart';

RewardedAdService createPlatformRewardedAdService() =>
    (Platform.isAndroid || Platform.isIOS)
    ? GoogleRewardedAdService()
    : const UnavailableRewardedAdService();

/// Rewarded videos via Google Mobile Ads.
///
/// Only Google's public TEST ad units are used. Before release:
/// TODO(ads): real AdMob app IDs (AndroidManifest / Info.plist) and ad unit
///   IDs from Philip's AdMob account.
/// TODO(ads): EU/EEA consent via Google's User Messaging Platform
///   (ConsentInformation.requestConsentInfoUpdate + ConsentForm) before the
///   first ad, plus a way to change it in Settings (see privacy text).
/// TODO(ads): iOS App Tracking Transparency prompt and store privacy labels.
class GoogleRewardedAdService implements RewardedAdService {
  static final String _testUnitId = Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';

  Future<void>? _init;

  @override
  bool get available => true;

  @override
  Future<AdOutcome> show() async {
    // Started only on the first tap, never at app launch.
    await (_init ??= MobileAds.instance.initialize());
    final loaded = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: _testUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await loaded.future;
    if (ad == null) return AdOutcome.failed;

    final done = Completer<AdOutcome>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) {
          done.complete(earned ? AdOutcome.earned : AdOutcome.skipped);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!done.isCompleted) done.complete(AdOutcome.failed);
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return done.future;
  }
}
