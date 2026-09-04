import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/daily_streak.dart';
import '../models/game_snapshot.dart';
import '../models/mission.dart';
import '../models/power_up.dart';

class StorageService {
  static const String _keyBestScore = '2048_best_score';
  static const String _keyCurrentGame = '2048_current_game';
  static const String _keyUndoSnapshot = '2048_undo_snapshot';
  static const String _keySoundEnabled = '2048_sound_enabled';
  static const String _keyVibrationEnabled = '2048_vibration_enabled';
  static const String _keyTheme = '2048_theme_type';
  static const String _keyAdsRemoved = '2048_ads_removed';
  static const String _keyCompletedGames = '2048_completed_games';

  // Gamification & Economy Keys
  static const String _keyCoins = '2048_coins';
  static const String _keyPowerUpInventory = '2048_powerup_inventory';
  static const String _keyUnlockedThemes = '2048_unlocked_themes';
  static const String _keyGridSize = '2048_grid_size';
  static const String _keyGameMode = '2048_game_mode';
  static const String _keyMissions = '2048_missions';
  static const String _keyAchievements = '2048_achievements';
  static const String _keyDailyStreak = '2048_daily_streak';
  static const String _keyLastFreeSpin = '2048_last_free_spin';
  static const String _keyCareerStats = '2048_career_stats';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Coins & Economy ---
  int loadCoins() => _prefs.getInt(_keyCoins) ?? 200; // Starting 200 bonus coins
  Future<void> saveCoins(int amount) => _prefs.setInt(_keyCoins, amount);

  // --- Power-Up Inventory ---
  PowerUpInventory loadInventory() {
    try {
      final str = _prefs.getString(_keyPowerUpInventory);
      if (str == null) return PowerUpInventory();
      return PowerUpInventory.fromJson(jsonDecode(str));
    } catch (_) {
      return PowerUpInventory();
    }
  }

  Future<void> saveInventory(PowerUpInventory inv) =>
      _prefs.setString(_keyPowerUpInventory, jsonEncode(inv.toJson()));

  // --- Unlocked Themes ---
  List<String> loadUnlockedThemes() {
    return _prefs.getStringList(_keyUnlockedThemes) ?? ['aurora', 'classic'];
  }

  Future<void> saveUnlockedThemes(List<String> themes) =>
      _prefs.setStringList(_keyUnlockedThemes, themes);

  // --- Grid Size & Mode ---
  int loadGridSize() => _prefs.getInt(_keyGridSize) ?? 4;
  Future<void> saveGridSize(int size) => _prefs.setInt(_keyGridSize, size);

  String loadGameMode() => _prefs.getString(_keyGameMode) ?? 'classic';
  Future<void> saveGameMode(String mode) => _prefs.setString(_keyGameMode, mode);

  // --- Missions ---
  List<Mission> loadMissions() {
    try {
      final str = _prefs.getString(_keyMissions);
      if (str == null) return _generateDefaultMissions();
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((e) => Mission.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _generateDefaultMissions();
    }
  }

  Future<void> saveMissions(List<Mission> missions) =>
      _prefs.setString(_keyMissions, jsonEncode(missions.map((m) => m.toJson()).toList()));

  List<Mission> _generateDefaultMissions() {
    return [
      Mission(id: 'm1', type: MissionType.mergeTiles, target: 25),
      Mission(id: 'm2', type: MissionType.reachTile, target: 128),
      Mission(id: 'm3', type: MissionType.scorePoints, target: 2000),
      Mission(id: 'm4', type: MissionType.makeCombo, target: 2),
      Mission(id: 'm5', type: MissionType.usePowerUp, target: 2),
    ];
  }

  // --- Achievements ---
  List<Achievement> loadAchievements() {
    try {
      final str = _prefs.getString(_keyAchievements);
      if (str == null) return Achievement.getInitialList();
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return Achievement.getInitialList();
    }
  }

  Future<void> saveAchievements(List<Achievement> achievements) =>
      _prefs.setString(_keyAchievements, jsonEncode(achievements.map((a) => a.toJson()).toList()));

  // --- Daily Streak ---
  DailyStreak loadDailyStreak() {
    try {
      final str = _prefs.getString(_keyDailyStreak);
      if (str == null) return DailyStreak();
      return DailyStreak.fromJson(jsonDecode(str));
    } catch (_) {
      return DailyStreak();
    }
  }

  Future<void> saveDailyStreak(DailyStreak streak) =>
      _prefs.setString(_keyDailyStreak, jsonEncode(streak.toJson()));

  // --- Lucky Spin Wheel Cooldown ---
  int loadLastFreeSpinTime() => _prefs.getInt(_keyLastFreeSpin) ?? 0;
  Future<void> saveLastFreeSpinTime(int timestamp) => _prefs.setInt(_keyLastFreeSpin, timestamp);

  // --- Career Stats ---
  Map<String, dynamic> loadCareerStats() {
    try {
      final str = _prefs.getString(_keyCareerStats);
      if (str == null) {
        return {
          'gamesPlayed': 0,
          'highestTile': 2,
          'highestScore': 0,
          'totalMerges': 0,
          'totalMoves': 0,
          'coinsEarned': 0,
        };
      }
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return {
        'gamesPlayed': 0,
        'highestTile': 2,
        'highestScore': 0,
        'totalMerges': 0,
        'totalMoves': 0,
        'coinsEarned': 0,
      };
    }
  }

  Future<void> saveCareerStats(Map<String, dynamic> stats) =>
      _prefs.setString(_keyCareerStats, jsonEncode(stats));

  // --- Basic State ---
  bool loadAdsRemoved() => _prefs.getBool(_keyAdsRemoved) ?? false;
  Future<void> saveAdsRemoved(bool removed) => _prefs.setBool(_keyAdsRemoved, removed);

  int loadCompletedGamesCount() => _prefs.getInt(_keyCompletedGames) ?? 0;
  Future<void> saveCompletedGamesCount(int count) => _prefs.setInt(_keyCompletedGames, count);

  String loadThemeName() => _prefs.getString(_keyTheme) ?? 'aurora';
  Future<void> saveThemeName(String name) => _prefs.setString(_keyTheme, name);

  int loadBestScore() => _prefs.getInt(_keyBestScore) ?? 0;
  Future<void> saveBestScore(int score) => _prefs.setInt(_keyBestScore, score);

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

  bool loadSoundEnabled() => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<void> saveSoundEnabled(bool enabled) => _prefs.setBool(_keySoundEnabled, enabled);

  bool loadVibrationEnabled() => _prefs.getBool(_keyVibrationEnabled) ?? true;
  Future<void> saveVibrationEnabled(bool enabled) => _prefs.setBool(_keyVibrationEnabled, enabled);
}
