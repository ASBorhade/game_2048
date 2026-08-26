import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_snapshot.dart';

class StorageService {
  static const String _keyBestScore = '2048_best_score';
  static const String _keyCurrentGame = '2048_current_game';
  static const String _keyUndoSnapshot = '2048_undo_snapshot';
  static const String _keySoundEnabled = '2048_sound_enabled';
  static const String _keyVibrationEnabled = '2048_vibration_enabled';
  static const String _keyTheme = '2048_theme_type';
  static const String _keyAdsRemoved = '2048_ads_removed';
  static const String _keyBonusUndos = '2048_bonus_undos';
  static const String _keyCompletedGames = '2048_completed_games';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  bool loadAdsRemoved() {
    return _prefs.getBool(_keyAdsRemoved) ?? false;
  }

  Future<void> saveAdsRemoved(bool removed) async {
    await _prefs.setBool(_keyAdsRemoved, removed);
  }

  int loadBonusUndos() {
    return _prefs.getInt(_keyBonusUndos) ?? 0;
  }

  Future<void> saveBonusUndos(int count) async {
    await _prefs.setInt(_keyBonusUndos, count);
  }

  int loadCompletedGamesCount() {
    return _prefs.getInt(_keyCompletedGames) ?? 0;
  }

  Future<void> saveCompletedGamesCount(int count) async {
    await _prefs.setInt(_keyCompletedGames, count);
  }

  String loadThemeName() {
    return _prefs.getString(_keyTheme) ?? 'aurora';
  }

  Future<void> saveThemeName(String name) async {
    await _prefs.setString(_keyTheme, name);
  }

  int loadBestScore() {
    return _prefs.getInt(_keyBestScore) ?? 0;
  }

  Future<void> saveBestScore(int score) async {
    await _prefs.setInt(_keyBestScore, score);
  }

  GameSnapshot? loadCurrentGame() {
    try {
      final jsonStr = _prefs.getString(_keyCurrentGame);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameSnapshot.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCurrentGame(GameSnapshot snapshot) async {
    try {
      final jsonStr = jsonEncode(snapshot.toJson());
      await _prefs.setString(_keyCurrentGame, jsonStr);
    } catch (_) {}
  }

  GameSnapshot? loadUndoSnapshot() {
    try {
      final jsonStr = _prefs.getString(_keyUndoSnapshot);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameSnapshot.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUndoSnapshot(GameSnapshot? snapshot) async {
    try {
      if (snapshot == null) {
        await _prefs.remove(_keyUndoSnapshot);
      } else {
        final jsonStr = jsonEncode(snapshot.toJson());
        await _prefs.setString(_keyUndoSnapshot, jsonStr);
      }
    } catch (_) {}
  }

  Future<void> clearSavedGame() async {
    await _prefs.remove(_keyCurrentGame);
    await _prefs.remove(_keyUndoSnapshot);
  }

  bool loadSoundEnabled() {
    return _prefs.getBool(_keySoundEnabled) ?? true;
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEnabled, enabled);
  }

  bool loadVibrationEnabled() {
    return _prefs.getBool(_keyVibrationEnabled) ?? true;
  }

  Future<void> saveVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_keyVibrationEnabled, enabled);
  }
}
