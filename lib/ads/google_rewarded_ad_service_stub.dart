import 'rewarded_ad_service.dart';

/// Web: no rewarded video equivalent.
RewardedAdService createPlatformRewardedAdService() =>
    const UnavailableRewardedAdService();
