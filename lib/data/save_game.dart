import 'dart:convert';
import 'dart:typed_data';

import '../domain/companion.dart';
import 'game_data.dart';
import 'species.dart';

/// Why a picked file can't be imported.
enum SaveGameError {
  /// Not JSON or not a Treadplay save at all.
  notASave,

  /// Written by a newer app version than this one understands.
  newerVersion,

  /// A Treadplay save, but its game data is incomplete or broken.
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
  static const int version = 2;

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
    final json = _migrate(raw['game'], v);
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

  /// Version 1 games carry no 'wanderweg'; drop a stray one so the legacy
  /// grant always applies to them.
  static Object? _migrate(Object? game, int fromVersion) {
    if (fromVersion >= 2 || game is! Map<String, Object?>) return game;
    return {...game}..remove('wanderweg');
  }

  static final Set<String> _seals = {for (final t in SealType.values) t.name};

  /// Only species and seals this app version knows.
  static bool _known(Companion c) =>
      speciesById.containsKey(c.speciesId) &&
      c.charms.every((s) => s == null || _seals.contains(s));
}
