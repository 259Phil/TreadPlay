/// Optional rewarded videos: at most [dailyLimit] a day, each worth less than
/// the one before. The day resets at local midnight; no countdown is shown.
///
/// Sizing: a video pays a share of one Breath of the companion taken along
/// (1.0, 0.6, 0.4), so all three together are worth 2 Breath. A full run
/// empties the tank, 6–12 Breath by rarity (one per 250 m in the sweet spot):
///
/// | Rarity    | LP/Breath | full run | 3 videos      | share |
/// |-----------|-----------|----------|---------------|-------|
/// | Common    | 2.5       | 15 LP    | 2.5+1.5+1 = 5 | 33 %  |
/// | Rare      | 4         | 32 LP    | 4+2.5+1.5 = 8 | 25 %  |
/// | Epic      | 7         | 70 LP    | 7+4+3 = 14    | 20 %  |
/// | Legendary | 12        | 144 LP   | 12+7+5 = 24   | 17 %  |
///
/// Running always stays the main way to earn.
class VideoRewards {
  const VideoRewards({this.day, this.watched = 0});

  /// Share of one Breath's LP for the first, second and third video of a day.
  static const List<double> breathShares = [1.0, 0.6, 0.4];
  static int get dailyLimit => breathShares.length;

  /// Local calendar day of [watched], as yyyy-mm-dd; null before the first.
  final String? day;
  final int watched;

  static String dayOf(DateTime now) {
    final l = now.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}';
  }

  /// LP for video number [index] (0-based) with [lpPerBreath], to 0.5 LP.
  static double rewardFor(int index, double lpPerBreath) =>
      (breathShares[index] * lpPerBreath * 2).roundToDouble() / 2;

  /// Videos already watched on the local day of [now].
  int watchedOn(DateTime now) => day == dayOf(now) ? watched : 0;

  int remaining(DateTime now) => dailyLimit - watchedOn(now);

  /// LP the next video pays today, or null when today's videos are used up.
  double? nextReward(DateTime now, double lpPerBreath) {
    final n = watchedOn(now);
    return n < dailyLimit ? rewardFor(n, lpPerBreath) : null;
  }

  /// Counts one finished video. Check [nextReward] first.
  VideoRewards claimed(DateTime now) =>
      VideoRewards(day: dayOf(now), watched: watchedOn(now) + 1);

  Map<String, Object?> toJson() => {'day': day, 'watched': watched};

  factory VideoRewards.fromJson(Map<String, Object?> json) => VideoRewards(
    day: json['day'] as String?,
    watched: json['watched'] as int? ?? 0,
  );
}
