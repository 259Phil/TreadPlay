import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/run_summary.dart';
import 'package:treadplay/domain/totals.dart';
import 'package:treadplay/domain/video_rewards.dart';

void main() {
  final t0 = DateTime(2026, 3, 4, 9, 30);

  GameData sample() {
    final pebble = Companion.pebble();
    final sealed = Companion.fromJson({
      ...pebble.toJson(),
      'charms': [SealType.grit.name, null],
    });
    return GameData.initial(t0).copyWith(
      lp: 123.5,
      companions: [sealed],
      runs: [
        RunSummary(
          companionId: pebble.id,
          startedAt: t0,
          duration: const Duration(minutes: 12),
          distanceM: 1400,
          steps: 1800,
          lp: 9,
          breathUsed: 4,
          valid: true,
          sweetSpotShare: 0.7,
        ),
      ],
      totals: const Totals(distanceM: 9000, lp: 300, runs: 7, forgeUses: 2),
      videos: const VideoRewards(day: '2026-03-04', watched: 2),
    );
  }

  Uint8List bytesOf(Object json) =>
      Uint8List.fromList(utf8.encode(jsonEncode(json)));

  test('export then import gives back the same game', () {
    final game = sample();
    final file = SaveGame.encode(game, t0);
    final raw = jsonDecode(utf8.decode(file)) as Map<String, Object?>;
    expect(raw['format'], 'treadplay-save');
    expect(raw['version'], SaveGame.version);

    final loaded = SaveGame.decode(file);
    expect(loaded.exportedAt, t0);
    expect(jsonEncode(loaded.game.toJson()), jsonEncode(game.toJson()));
    expect(loaded.game.totals.forgeUses, 2);
    expect(loaded.game.videos.watched, 2);
    expect(loaded.game.companions.single.charms.first, 'grit');
  });

  test('file name is a dated json file', () {
    expect(SaveGame.fileName(t0), 'treadplay-save-2026-03-04T09-30-00.json');
  });

  SaveGameError errorOf(Uint8List bytes) {
    try {
      SaveGame.decode(bytes);
    } on SaveGameException catch (e) {
      return e.error;
    }
    fail('expected the file to be rejected');
  }

  test('rejects files that are not a save game', () {
    expect(
      errorOf(Uint8List.fromList(utf8.encode('hello'))),
      SaveGameError.notASave,
    );
    expect(
      errorOf(Uint8List.fromList([0xff, 0xfe, 0x00])),
      SaveGameError.notASave,
    );
    expect(errorOf(bytesOf([1, 2])), SaveGameError.notASave);
    expect(
      errorOf(bytesOf({'format': 'growcall', 'version': 1})),
      SaveGameError.notASave,
    );
  });

  test('rejects saves from a newer version', () {
    expect(
      errorOf(
        bytesOf({
          'format': 'treadplay-save',
          'version': SaveGame.version + 1,
          'game': sample().toJson(),
        }),
      ),
      SaveGameError.newerVersion,
    );
  });

  test('rejects damaged saves', () {
    Map<String, Object?> wrap(Object? game) => {
      'format': 'treadplay-save',
      'version': 1,
      'game': game,
    };
    expect(errorOf(bytesOf(wrap(null))), SaveGameError.damaged);
    expect(errorOf(bytesOf(wrap({'lp': 3}))), SaveGameError.damaged);
    expect(
      errorOf(
        bytesOf({'format': 'treadplay-save', 'version': 'x', 'game': {}}),
      ),
      SaveGameError.damaged,
    );
    final noActive = sample().toJson()..['activeCompanionId'] = 'ghost';
    expect(errorOf(bytesOf(wrap(noActive))), SaveGameError.damaged);
    final strange = sample().toJson();
    (strange['companions']! as List<Object?>)[0] = {
      ...sample().companions.single.toJson(),
      'speciesId': 'unknown-beast',
    };
    expect(errorOf(bytesOf(wrap(strange))), SaveGameError.damaged);
    final negative = sample().toJson()..['lp'] = -5;
    expect(errorOf(bytesOf(wrap(negative))), SaveGameError.damaged);
  });
}
