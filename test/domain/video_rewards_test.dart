import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/video_rewards.dart';

void main() {
  final morning = DateTime(2026, 3, 4, 9);

  test('rewards drop per video and scale with LP per Breath', () {
    double day(Rarity r) => [
      for (var i = 0; i < 3; i++) VideoRewards.rewardFor(i, r.lpPerBreath),
    ].reduce((a, b) => a + b);
    expect(
      [
        for (var i = 0; i < 3; i++)
          VideoRewards.rewardFor(i, Rarity.common.lpPerBreath),
      ],
      [2.5, 1.5, 1],
    );
    expect(day(Rarity.common), 5);
    expect(day(Rarity.rare), 8);
    expect(day(Rarity.epic), 14);
    expect(day(Rarity.legendary), 24);
    // Three videos stay clearly below one full-tank run for every rarity.
    for (final r in Rarity.values) {
      expect(day(r), lessThan(0.4 * r.tankSize * r.lpPerBreath));
    }
  });

  test('at most 3 a day, then none until local midnight', () {
    var v = const VideoRewards();
    expect(v.remaining(morning), 3);
    for (var i = 0; i < 3; i++) {
      expect(v.nextReward(morning, 2.5), isNotNull);
      v = v.claimed(morning.add(Duration(hours: i)));
    }
    expect(v.remaining(morning), 0);
    expect(v.nextReward(DateTime(2026, 3, 4, 23, 59), 2.5), isNull);
    final nextDay = DateTime(2026, 3, 5, 0, 0, 1);
    expect(v.remaining(nextDay), 3);
    expect(v.nextReward(nextDay, 2.5), 2.5);
    expect(v.claimed(nextDay).watchedOn(nextDay), 1);
  });

  test('game pays videos into LP and keeps the count in the save', () {
    var game = GameData.initial(morning);
    for (var i = 0; i < 3; i++) {
      game = game.claimingVideo(morning)!;
    }
    expect(game.lp, 5);
    expect(game.claimingVideo(morning), isNull);
    final copy = GameData.fromJson(game.toJson());
    expect(copy.videos.remaining(morning), 0);
    expect(copy.claimingVideo(morning.add(const Duration(days: 1))), isNotNull);
  });
}
