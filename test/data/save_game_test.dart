import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/save_game.dart';
import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/forge.dart';
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
    // A bare seal from before seal levels is read as an L2 seal.
    expect(loaded.game.companions.single.charms.first, 'grit@2');
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

  group('save format 3 (Forge)', () {
    Map<String, Object?> wrap(Object? game, int version) => {
      'format': 'treadplay-save',
      'version': version,
      'game': game,
    };

    GameData forged() {
      final gilt = Companion.fresh(
        id: 'm1-0',
        speciesId: 'gilt',
        rarity: Rarity.legendary,
      ).withSeal(0, const Seal(SealType.stride, 5));
      return GameData.initial(t0).copyWith(
        companions: [Companion.pebble(), gilt],
        forge: const ForgeState(
          stock: {'grit@3': 2, 'stride+fortune@5': 1},
          glut: 7,
          splinters: 4,
          placed: 3,
          combines: 1,
          bestLevel: 5,
          attempts: 9,
          fails: 2,
        ),
      );
    }

    test('export and import keep the whole forge state', () {
      final game = forged();
      final loaded = SaveGame.decode(SaveGame.encode(game, t0)).game;
      expect(jsonEncode(loaded.toJson()), jsonEncode(game.toJson()));
      expect(loaded.forge.glut, 7);
      expect(loaded.forge.splinters, 4);
      expect(loaded.forge.count(const Seal(SealType.grit, 3)), 2);
      expect(
        loaded.forge.count(Seal.combined(SealType.stride, SealType.fortune, 5)),
        1,
      );
      expect(loaded.companions.last.sealAt(0), const Seal(SealType.stride, 5));
    });

    test(
      'a version 2 file imports: bare seals become L2, uses count as set',
      () {
        final v2 = sample().toJson()..remove('forge');
        (v2['companions']! as List<Object?>)[0] = {
          ...sample().companions.single.toJson(),
          'charms': ['stride'],
        };
        final loaded = SaveGame.decode(bytesOf(wrap(v2, 2))).game;
        final pebble = loaded.companions.single;
        expect(pebble.charms, ['stride@2']);
        expect(pebble.sealBonus(SealType.stride), closeTo(0.09, 1e-9));
        expect(loaded.forge.placed, 2);
        expect(loaded.forge.glut, 0);
        expect(loaded.forge.stock, isEmpty);
        // Re-exported as version 3 and read again: unchanged.
        final again = SaveGame.decode(SaveGame.encode(loaded, t0)).game;
        expect(jsonEncode(again.toJson()), jsonEncode(loaded.toJson()));
      },
    );

    test('a stray forge block in an old file is ignored', () {
      final v2 = forged().toJson();
      final loaded = SaveGame.decode(bytesOf(wrap(v2, 2))).game;
      expect(loaded.forge.glut, 0);
      expect(loaded.forge.stock, isEmpty);
    });

    test('version 1 files still import', () {
      final v1 = sample().toJson()
        ..remove('forge')
        ..remove('wanderweg');
      final loaded = SaveGame.decode(bytesOf(wrap(v1, 1))).game;
      expect(loaded.companions.single.charms, ['grit@2']);
      expect(loaded.wanderweg.legacyForge, isTrue);
    });

    test('unknown seals in the case or in a socket are rejected', () {
      final badCase = forged().toJson();
      (badCase['forge']! as Map<String, Object?>)['stock'] = {'stride@9': 1};
      expect(
        errorOf(bytesOf(wrap(badCase, SaveGame.version))),
        SaveGameError.damaged,
      );
      final badSocket = forged().toJson();
      final comps = badSocket['companions']! as List<Object?>;
      comps[1] = {
        ...(comps[1]! as Map<String, Object?>),
        'charms': ['grit+grit@3', null, null],
      };
      expect(
        errorOf(bytesOf(wrap(badSocket, SaveGame.version))),
        SaveGameError.damaged,
      );
    });

    test('local storage from before seal levels loads too', () {
      final json = sample().toJson()..remove('forge');
      final game = GameData.fromJson(json, now: t0);
      expect(game.companions.single.charms, ['grit@2']);
      expect(game.forge.placed, 2);
    });
  });
}
