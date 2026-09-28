import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_data.dart';

class GameRepository {
  GameRepository(this._prefs);

  static const _gameKey = 'game.v2';
  static const _settingsKey = 'settings.v1';

  final SharedPreferences _prefs;

  GameData? loadGame() {
    final raw = _prefs.getString(_gameKey);
    if (raw == null) return null;
    return GameData.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<void> saveGame(GameData data) =>
      _prefs.setString(_gameKey, jsonEncode(data.toJson()));

  AppSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<void> saveSettings(AppSettings settings) =>
      _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
}
