import 'dart:convert';
import 'dart:typed_data';

import '../domain/companion.dart';
import '../domain/forge.dart';
import '../domain/pouch.dart';
import 'game_data.dart';
import 'species.dart';

/// Why a picked file can't be imported.
enum SaveGameError {
  /// Not JSON or not a TreadPlay save at all.
  notASave,

  /// Written by a newer app version than this one understands.
  newerVersion,

  /// A TreadPlay save, but its game data is incomplete or broken.
  damaged,
}

class SaveGameException implements Exception {
  const SaveGameException(this.error);

  final SaveGameError error;

  @override
  String toString() => 'SaveGameException(${error.name})';
}

/// A save read from a file, ready to replace the current game.
class LoadedSave {
  const LoadedSave({required this.game, this.exportedAt});

  final GameData game;
  final DateTime? exportedAt;
}

/// Save-game file: one JSON object with a format tag, a version and the full
/// [GameData] (companions, seals, LP, Breath, market, runs, totals, videos).
/// Device settings (language, sound, movement access) are not part of it.
class SaveGame {
  static const String format = 'treadplay-save';

  /// 2: adds the Wanderweg (reached waymarks) and new lifetime counters.
  /// Version 1 files still import: [GameData.fromJson] grants them every
  /// waymark their km allow and counts the new totals from their runs.
  ///
  /// 3: seal levels and the Forge ('forge': seal case, Glut, splinters,
  /// counters). Version 1 and 2 files still import: their bare seals
  /// (`stride`) become L[Seal.legacyLevel] seals and every forge use counts
  /// as a placed seal.
  ///
  /// 4: treat pouches ('pouches': the leash and pouch counters). Older
  /// files still import with an empty leash.
  ///
  /// 5: messengers ('messengers': visits met, the open task, today's
  /// count). Older files still import with none met yet.
  ///
  /// 6: a gait per companion ('tempo' on owned companions and market
  /// offers). Older files still import: every companion and offer gets its
  /// species' home gait, the one it ran at before.
  ///
  /// 7: the market carries its rolling rules ('generation' in 'market').
  /// Older files still import; their market (one species, one gait for
  /// fresh players) is rolled anew once on load, owned companions stay.
  ///
  /// 8: levelling and Mutsalben ('xp' on companions, 'salves' in the game,
  /// salve prices in 'market', Mut and XP on runs). Older files still
  /// import: every companion keeps its level and Mut and starts at 0 XP,
  /// the Vorrat holds no salves.
  ///
  /// 9: the Schmiede-Baum ('recipes' and 'glutherzDay' in 'forge'; recipe
  /// seals with a lead stat, `grit+stride@2`, and level-2 recipe seals,
  /// `stride+grit+fortune@2`). Older files still import: their combined
  /// seals become recipe seals led by the first stat, and every recipe seal
  /// they own (case or sockets) counts as discovered at its level, and the
  /// original starter gets the uneven starter stats once
  /// (see [GameData.starterKey]).
  ///
  /// 10: seals ever owned ('seen' in 'forge', for the Schmiede-Baum).
  /// Older files still import: every seal in the case or a socket and every
  /// discovered recipe at its best level counts as owned.
  static const int version = 10;

  static String fileName(DateTime now) {
    final stamp = now.toIso8601String().replaceAll(':', '-').split('.').first;
    return 'treadplay-save-$stamp.json';
  }

  static Uint8List encode(GameData game, DateTime now) => Uint8List.fromList(
    utf8.encode(
      const JsonEncoder.withIndent('  ').convert({
        'format': format,
        'version': version,
        'exportedAt': now.toIso8601String(),
        'game': game.toJson(),
      }),
    ),
  );

  /// Reads and checks a save file. Throws [SaveGameException].
  static LoadedSave decode(Uint8List bytes) {
    final Object? raw;
    try {
      raw = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const SaveGameException(SaveGameError.notASave);
    }
    if (raw is! Map<String, Object?> || raw['format'] != format) {
      throw const SaveGameException(SaveGameError.notASave);
    }
    final v = raw['version'];
    if (v is! int || v < 1) {
      throw const SaveGameException(SaveGameError.damaged);
    }
    if (v > version) {
      throw const SaveGameException(SaveGameError.newerVersion);
    }
    final json = _withoutSeen(
      _withoutRecipes(
        _withoutLevelling(_withHomeTempo(_migrate(raw['game'], v), v), v),
        v,
      ),
      v,
    );
    if (json is! Map<String, Object?>) {
      throw const SaveGameException(SaveGameError.damaged);
    }
    final GameData game;
    try {
      game = GameData.fromJson(json);
    } catch (_) {
      throw const SaveGameException(SaveGameError.damaged);
    }
    if (game.companions.isEmpty ||
        !game.companions.any((c) => c.id == game.activeCompanionId) ||
        game.lp.isNaN ||
        game.lp < 0 ||
        !game.companions.every(_known)) {
      throw const SaveGameException(SaveGameError.damaged);
    }
    return LoadedSave(
      game: game,
      exportedAt: DateTime.tryParse(raw['exportedAt'] as String? ?? ''),
    );
  }

  /// Version 1 games carry no 'wanderweg', versions 1–2 no 'forge', versions
  /// 1–3 no 'pouches'; drop
  /// stray ones so the legacy rules always apply to them. Bare seal names
  /// are read as levelled seals by [Companion.fromJson].
  static Object? _migrate(Object? game, int fromVersion) {
    if (game is! Map<String, Object?>) return game;
    if (fromVersion >= 3) {
      final f = game['forge'];
      if (f != null &&
          (f is! Map<String, Object?> ||
              ForgeState.unknownCodes(f).isNotEmpty)) {
        return null;
      }
      if (fromVersion < 4) {
        return {...game}
          ..remove('pouches')
          ..remove('messengers');
      }
      final p = game['pouches'];
      if (p != null && PouchState.problems(p)) return null;
      if (fromVersion < 5) return {...game}..remove('messengers');
      return game;
    }
    final next = {...game}
      ..remove('forge')
      ..remove('pouches')
      ..remove('messengers');
    if (fromVersion < 2) next.remove('wanderweg');
    return next;
  }

  /// Before version 6 a companion's gait was its species'; stray 'tempo'
  /// keys are replaced so old files keep their sweet spots.
  static Object? _withHomeTempo(Object? game, int fromVersion) {
    if (fromVersion >= 6 || game is! Map<String, Object?>) return game;
    Object? fix(Object? c) {
      if (c is! Map<String, Object?>) return c;
      final home = speciesById[c['speciesId']]?.type;
      return home == null ? c : {...c, 'tempo': home.name};
    }

    final next = {...game};
    if (game['companions'] case final List<Object?> owned) {
      next['companions'] = [for (final c in owned) fix(c)];
    }
    if (game['market'] case final Map<String, Object?> m) {
      if (m['offers'] case final List<Object?> offers) {
        next['market'] = {
          ...m,
          'offers': [for (final c in offers) fix(c)],
        };
      }
    }
    return next;
  }

  /// Before version 8 nothing levelled: stray 'xp' and 'salves' keys are
  /// dropped, so every companion starts at 0 XP and the Vorrat is empty.
  static Object? _withoutLevelling(Object? game, int fromVersion) {
    if (fromVersion >= 8 || game is! Map<String, Object?>) return game;
    final next = {...game}..remove('salves');
    if (game['companions'] case final List<Object?> owned) {
      next['companions'] = [
        for (final c in owned)
          c is Map<String, Object?> ? ({...c}..remove('xp')) : c,
      ];
    }
    return next;
  }

  /// Before version 9 there were no recipes: stray 'recipes' and
  /// 'glutherzDay' keys are dropped, so the recipes come from the owned
  /// recipe seals alone; a stray starter mark is dropped too, so the
  /// starter is retuned once.
  static Object? _withoutRecipes(Object? game, int fromVersion) {
    if (fromVersion >= 9 || game is! Map<String, Object?>) return game;
    final next = {...game}..remove(GameData.starterKey);
    if (game['forge'] case final Map<String, Object?> f) {
      next['forge'] = {...f}
        ..remove('recipes')
        ..remove('glutherzDay');
    }
    return next;
  }

  /// Before version 10 nothing noted seals ever owned: a stray 'seen' is
  /// dropped, so it comes from the case, the sockets and the recipes.
  static Object? _withoutSeen(Object? game, int fromVersion) {
    if (fromVersion >= 10 || game is! Map<String, Object?>) return game;
    if (game['forge'] case final Map<String, Object?> f) {
      return {
        ...game,
        'forge': {...f}..remove('seen'),
      };
    }
    return game;
  }

  /// Only species and seals this app version knows.
  static bool _known(Companion c) =>
      speciesById.containsKey(c.speciesId) &&
      c.charms.every((s) => s == null || Seal.tryParse(s) != null);
}
