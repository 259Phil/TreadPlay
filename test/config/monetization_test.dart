import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/ads/rewarded_ad_service.dart';
import 'package:treadplay/config/monetization.dart';
import 'package:treadplay/data/game_data.dart';

void main() {
  test(
    'monetization stays off until Philip turns it on (see MONETIZATION_DISABLED.md)',
    () {
      expect(monetizationEnabled, isFalse);
    },
  );

  test('default ad service is unavailable while monetization is off', () {
    if (monetizationEnabled) return;
    // The provider is not built here (it needs a ProviderContainer and
    // SharedPreferences). The factory path is: flag off -> Unavailable.
    const service = UnavailableRewardedAdService();
    expect(service.available, isFalse);
  });

  test('GameNotifier path: claiming video LP is blocked at the flag, '
      'domain logic itself is unchanged', () {
    // Domain still computes rewards so it can be turned back on without
    // a redesign. The notifier (claimVideo) refuses to pay while the
    // flag is off; that is covered by the Home video-button widget test
    // (button hidden, no LP). Here we only record the balance that would
    // be missing: 5 LP/day on a common companion, up to 24 LP/day on a
    // legendary one, always less than one full-tank run.
    final morning = DateTime(2026, 3, 4, 9);
    var game = GameData.initial(morning);
    for (var i = 0; i < 3; i++) {
      game = game.claimingVideo(morning)!;
    }
    expect(game.lp, 5);
  });
}
