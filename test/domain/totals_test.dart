import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/run_summary.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 8);

  RunSummary run(double m, double lp, {bool valid = true}) => RunSummary(
    companionId: 'pebble-1',
    startedAt: t0,
    duration: const Duration(minutes: 10),
    distanceM: m,
    steps: 0,
    lp: lp,
    breathUsed: 2,
    valid: valid,
  );

  test('old saves without totals start them from stored valid runs', () {
    final json =
        GameData.initial(
            t0,
          ).copyWith(runs: [run(1000, 10), run(500, 0, valid: false)]).toJson()
          ..remove('totals')
          ..remove('videos');
    final game = GameData.fromJson(json);
    expect(game.totals.distanceM, 1000);
    expect(game.totals.lp, 10);
    expect(game.totals.runs, 1);
    expect(game.runs.first.sweetSpotShare, isNull);
  });

  test('totals are not capped and survive erasing the history', () {
    var game = GameData.initial(t0);
    for (var i = 0; i < GameData.maxStoredRuns + 5; i++) {
      game = game.recordingRun(run(100, 1));
    }
    expect(game.runs.length, GameData.maxStoredRuns);
    expect(game.totals.runs, GameData.maxStoredRuns + 5);
    final erased = GameData.fromJson(game.erasingRuns().toJson());
    expect(erased.runs, isEmpty);
    expect(erased.totals.runs, GameData.maxStoredRuns + 5);
    expect(erased.totals.distanceM, closeTo(5500, 1e-6));
  });

  test('forging counts a forge use', () {
    final game = GameData.initial(t0).copyWith(lp: 100);
    final id = game.activeCompanionId;
    expect(game.forging(id, SealType.grit).totals.forgeUses, 1);
  });
}
