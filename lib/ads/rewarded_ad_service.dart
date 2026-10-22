import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'google_rewarded_ad_service_stub.dart'
    if (dart.library.io) 'google_rewarded_ad_service.dart';

/// Build with `--dart-define=TREADPLAY_FAKE_ADS=true` to use
/// [FakeRewardedAdService] (also on Web, for screenshots and tests).
/// Ignored in release builds.
const bool fakeAdsFlag =
    !kReleaseMode && bool.fromEnvironment('TREADPLAY_FAKE_ADS');

enum AdOutcome {
  /// Watched to the end: the reward may be paid.
  earned,

  /// Closed early: no reward.
  skipped,

  /// No ad could be loaded or shown.
  failed,
}

/// Shows one optional rewarded video. Whether the day's limit allows it is
/// decided by the game state, not here.
abstract class RewardedAdService {
  /// False where no rewarded video exists (Web): the button stays hidden.
  bool get available;

  Future<AdOutcome> show();
}

/// No videos on this platform.
class UnavailableRewardedAdService implements RewardedAdService {
  const UnavailableRewardedAdService();

  @override
  bool get available => false;

  @override
  Future<AdOutcome> show() async => AdOutcome.failed;
}

/// Debug stand-in: waits briefly, then reports the video as watched.
class FakeRewardedAdService implements RewardedAdService {
  FakeRewardedAdService({
    this.delay = const Duration(milliseconds: 600),
    this.outcome = AdOutcome.earned,
  });

  final Duration delay;
  AdOutcome outcome;

  @override
  bool get available => true;

  @override
  Future<AdOutcome> show() async {
    await Future<void>.delayed(delay);
    return outcome;
  }
}

final rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  if (fakeAdsFlag) return FakeRewardedAdService();
  if (kIsWeb) return const UnavailableRewardedAdService();
  return createPlatformRewardedAdService();
});
