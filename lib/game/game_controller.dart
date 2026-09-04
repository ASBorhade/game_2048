import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/ad_config.dart';
import '../models/achievement.dart';
import '../models/daily_streak.dart';
import '../models/game_snapshot.dart';
import '../models/mission.dart';
import '../models/power_up.dart';
import '../models/tile.dart';
import '../services/ad_service.dart';
import '../services/audio_feedback_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'ai_solver.dart';
import 'game_logic.dart';

enum GameMode {
  classic('Classic Endless', 'Play at your own pace'),
  timed('Timed Rush', 'Reach max score in 2 minutes'),
  daily('Daily Challenge', 'Same puzzle for all players today');

  final String label;
  final String subtitle;
  const GameMode(this.label, this.subtitle);
}

class GameController extends ChangeNotifier {
  final StorageService storageService;
  final AudioFeedbackService audioService;
  final GameLogic _gameLogic;

  List<Tile> _tiles = [];
  int _score = 0;
  int _bestScore = 0;
  int _scoreAddedThisMove = 0;
  int _lastComboCount = 0;
  bool _isGameOver = false;
  bool _isWon = false;
  bool _wonDismissed = false;
  bool _isAnimating = false;
  bool _isLoading = false;
  bool _isAdLoading = false;

  int _gridSize = 4;
  GameMode _gameMode = GameMode.classic;
  Timer? _timedTimer;
  int _timedSecondsRemaining = 120;

  GameThemeType _theme = GameThemeType.aurora;
  List<String> _unlockedThemes = ['aurora', 'classic'];

  int _coins = 200;
  PowerUpInventory _inventory = PowerUpInventory();
  bool _isHammerActive = false;
  SwipeDirection? _suggestedMove;

  List<Mission> _missions = [];
  List<Achievement> _achievements = [];
  DailyStreak _dailyStreak = DailyStreak();
  Map<String, dynamic> _careerStats = {};

  bool _hasUsedRewardedContinueThisGame = false;
  bool _adsRemoved = false;
  int _completedGamesCount = 0;

  GameSnapshot? _undoSnapshot;
  int _nextTileId = 1;

  GameController({
    required this.storageService,
    required this.audioService,
    GameLogic? gameLogic,
  }) : _gameLogic = gameLogic ?? GameLogic();

  // Getters
  List<Tile> get tiles => _tiles;
  int get score => _score;
  int get bestScore => _bestScore;
  int get scoreAddedThisMove => _scoreAddedThisMove;
  int get lastComboCount => _lastComboCount;
  bool get isGameOver => _isGameOver;
  bool get isWon => _isWon;
  bool get wonDismissed => _wonDismissed;
  bool get canUndo => _undoSnapshot != null || _inventory.undoCount > 0;
  bool get hasTurnUndo => _undoSnapshot != null;
  bool get canRewardedContinue => _isGameOver && !_hasUsedRewardedContinueThisGame;
  bool get isAnimating => _isAnimating;
  bool get isLoading => _isLoading;
  bool get isAdLoading => _isAdLoading;
  bool get isSoundEnabled => audioService.isSoundEnabled;
  bool get isVibrationEnabled => audioService.isVibrationEnabled;
  bool get adsRemoved => _adsRemoved;
  GameThemeType get theme => _theme;
  List<String> get unlockedThemes => _unlockedThemes;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setAdLoading(bool loading) {
    _isAdLoading = loading;
    notifyListeners();
  }

  int get coins => _coins;
  PowerUpInventory get inventory => _inventory;
  bool get isHammerActive => _isHammerActive;
  SwipeDirection? get suggestedMove => _suggestedMove;

  int get gridSize => _gridSize;
  GameMode get gameMode => _gameMode;
  int get timedSecondsRemaining => _timedSecondsRemaining;

  List<Mission> get missions => _missions;
  List<Achievement> get achievements => _achievements;
  DailyStreak get dailyStreak => _dailyStreak;
  Map<String, dynamic> get careerStats => _careerStats;

  int get claimableMissionsCount => _missions.where((m) => m.isCompleted && !m.isClaimed).length;
  int get claimableAchievementsCount => _achievements.where((a) => a.isUnlocked && !a.isClaimed).length;

  void init() {
    _bestScore = storageService.loadBestScore();
    _adsRemoved = storageService.loadAdsRemoved();
    _completedGamesCount = storageService.loadCompletedGamesCount();
    _coins = storageService.loadCoins();
    _inventory = storageService.loadInventory();
    _unlockedThemes = storageService.loadUnlockedThemes();
    _gridSize = storageService.loadGridSize();
    _missions = storageService.loadMissions();
    _achievements = storageService.loadAchievements();
    _dailyStreak = storageService.loadDailyStreak();
    _careerStats = storageService.loadCareerStats();

    final modeName = storageService.loadGameMode();
    _gameMode = GameMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => GameMode.classic,
    );

    audioService.isSoundEnabled = storageService.loadSoundEnabled();
    audioService.isVibrationEnabled = storageService.loadVibrationEnabled();

    final themeName = storageService.loadThemeName();
    _theme = GameThemeType.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => GameThemeType.aurora,
    );

    _checkDailyStreak();

    final savedGame = storageService.loadCurrentGame();
    if (savedGame != null && savedGame.tiles.isNotEmpty) {
      _tiles = savedGame.tiles;
      _score = savedGame.score;
      _isGameOver = savedGame.isGameOver;
      _isWon = savedGame.isWon;
      _wonDismissed = savedGame.wonDismissed;
      _undoSnapshot = storageService.loadUndoSnapshot();

      for (final t in _tiles) {
        if (t.id >= _nextTileId) {
          _nextTileId = t.id + 1;
        }
      }
    } else {
      _startFreshGameInternal();
    }
    notifyListeners();
  }

  void _checkDailyStreak() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_dailyStreak.lastClaimDate != todayStr) {
      _dailyStreak = DailyStreak(
        streakDays: _dailyStreak.streakDays,
        lastClaimDate: _dailyStreak.lastClaimDate,
        isClaimedToday: false,
      );
    }
  }

  void _startFreshGameInternal() {
    _timedTimer?.cancel();
    _suggestedMove = null;
    _isHammerActive = false;
    _lastComboCount = 0;

    if (_gameMode == GameMode.daily) {
      _tiles = _gameLogic.createDailyBoard(DateTime.now(), gridSize: _gridSize, nextId: _nextTileId);
      _nextTileId += 4;
    } else {
      _tiles = _gameLogic.createInitialBoard(gridSize: _gridSize, nextId: _nextTileId);
      _nextTileId += 2;
    }

    _score = 0;
    _scoreAddedThisMove = 0;
    _isGameOver = false;
    _isWon = false;
    _wonDismissed = false;
    _hasUsedRewardedContinueThisGame = false;
    _undoSnapshot = null;
    _isAnimating = false;

    if (_gameMode == GameMode.timed) {
      _timedSecondsRemaining = 120;
      _startTimedCountdown();
    }

    _saveGameState();
  }

  void _startTimedCountdown() {
    _timedTimer?.cancel();
    _timedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timedSecondsRemaining > 0 && !_isGameOver) {
        _timedSecondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        _isGameOver = true;
        audioService.playGameOver();
        notifyListeners();
      }
    });
  }

  void startNewGame() {
    if (_score > 0 || _isGameOver) {
      _completedGamesCount++;
      storageService.saveCompletedGamesCount(_completedGamesCount);
      _updateStats(gamesPlayedInc: 1);
      _checkMissions(MissionType.playGames, 1);
      _checkAchievements('play_10_games', _careerStats['gamesPlayed'] ?? 1);

      if (!_adsRemoved &&
          AdConfig.enableInterstitialAds &&
          _completedGamesCount % AdConfig.interstitialEveryNGames == 0) {
        AdService().showInterstitialIfReady(onClosed: () {
          _startFreshGameInternal();
          notifyListeners();
        });
        return;
      }
    }

    _startFreshGameInternal();
    notifyListeners();
  }

  void setGridSize(int newSize) {
    if (_gridSize == newSize) return;
    _gridSize = newSize;
    storageService.saveGridSize(newSize);
    startNewGame();
  }

  void setGameMode(GameMode newMode) {
    if (_gameMode == newMode) return;
    _gameMode = newMode;
    storageService.saveGameMode(newMode.name);
    startNewGame();
  }

  int _getNextId() => _nextTileId++;

  void dismissWin() {
    _wonDismissed = true;
    _saveGameState();
    notifyListeners();
  }

  Future<void> move(SwipeDirection direction) async {
    if (_isGameOver || (_isWon && !_wonDismissed) || _isAnimating || _isHammerActive) {
      return;
    }

    _suggestedMove = null;

    final previousSnapshot = GameSnapshot(
      tiles: _tiles
          .where((t) => t.mergedIntoId == null)
          .map((t) => t.copyWith())
          .toList(),
      score: _score,
      isGameOver: _isGameOver,
      isWon: _isWon,
      wonDismissed: _wonDismissed,
    );

    final result = _gameLogic.executeMove(
      _tiles,
      direction,
      gridSize: _gridSize,
      getNextId: _getNextId,
    );

    if (!result.boardChanged) {
      return;
    }

    _undoSnapshot = previousSnapshot;
    _tiles = result.tiles;
    _score += result.scoreAdded;
    _scoreAddedThisMove = result.scoreAdded;
    _lastComboCount = result.comboCount;

    // Coins reward from regular merges and multi-merge combos
    int earnedCoins = (result.scoreAdded ~/ 20).clamp(0, 50);
    if (result.comboCount >= 2) {
      earnedCoins += (result.comboCount * 10);
      _checkMissions(MissionType.makeCombo, result.comboCount);
      _checkAchievements('combo_x3', result.comboCount);
    }
    if (earnedCoins > 0) {
      addCoins(earnedCoins);
    }

    // Update career stats
    _updateStats(
      movesInc: 1,
      mergesInc: result.comboCount,
      score: _score,
      maxTile: _getMaxTileValue(),
    );

    _checkMissions(MissionType.mergeTiles, result.comboCount);
    _checkMissions(MissionType.scorePoints, _score);
    _checkMissions(MissionType.reachTile, _getMaxTileValue());
    _checkTileAchievements(_getMaxTileValue());

    if (_score > _bestScore) {
      _bestScore = _score;
      storageService.saveBestScore(_bestScore);
    }

    if (result.hasWon && !_wonDismissed) {
      _isWon = true;
      audioService.playWin();
    } else if (result.scoreAdded > 0) {
      audioService.playMerge();
    } else {
      audioService.playMove();
    }

    _isAnimating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 140));

    _tiles = _tiles.where((t) => t.mergedIntoId == null).map((t) {
      return t.copyWith(previousRow: null, previousCol: null, isMerged: false);
    }).toList();

    final newTile = _gameLogic.spawnRandomTile(_tiles, _getNextId(), gridSize: _gridSize);
    if (newTile != null) {
      _tiles.add(newTile);
    }

    if (_gameLogic.isGameOver(_tiles, gridSize: _gridSize)) {
      _isGameOver = true;
      _timedTimer?.cancel();
      audioService.playGameOver();
    }

    _isAnimating = false;
    _saveGameState();
    notifyListeners();
  }

  int _getMaxTileValue() {
    int maxV = 0;
    for (final t in _tiles) {
      if (t.mergedIntoId == null && t.value > maxV) {
        maxV = t.value;
      }
    }
    return maxV;
  }

  // --- Power-Ups Actions ---

  void undo() {
    if (_undoSnapshot != null) {
      _tiles = _undoSnapshot!.tiles;
      _score = _undoSnapshot!.score;
      _isGameOver = _undoSnapshot!.isGameOver;
      _isWon = _undoSnapshot!.isWon;
      _wonDismissed = _undoSnapshot!.wonDismissed;
      _undoSnapshot = null;
      _scoreAddedThisMove = 0;
      _lastComboCount = 0;
      _suggestedMove = null;

      _saveGameState();
      notifyListeners();
    } else if (_inventory.consume(PowerUpType.undo)) {
      storageService.saveInventory(_inventory);
      if (_tiles.length > 2) {
        _tiles.sort((a, b) => a.value.compareTo(b.value));
        _tiles.removeRange(0, 2);
      }
      _isGameOver = false;
      _saveGameState();
      notifyListeners();
    }
  }

  void toggleHammerMode() {
    if (_inventory.hammerCount <= 0 && !_isHammerActive) return;
    _isHammerActive = !_isHammerActive;
    notifyListeners();
  }

  void smashTileWithHammer(int tileId) {
    if (!_isHammerActive) return;
    if (_inventory.consume(PowerUpType.hammer)) {
      storageService.saveInventory(_inventory);
      _tiles = _gameLogic.smashTile(_tiles, tileId);
      _isHammerActive = false;
      _isGameOver = false;
      audioService.playMerge();
      _checkMissions(MissionType.usePowerUp, 1);
      _saveGameState();
      notifyListeners();
    }
  }

  void useShuffle() {
    if (_inventory.consume(PowerUpType.shuffle)) {
      storageService.saveInventory(_inventory);
      _tiles = _gameLogic.shuffleTiles(_tiles, _gridSize);
      _isGameOver = false;
      audioService.playMove();
      _checkMissions(MissionType.usePowerUp, 1);
      _saveGameState();
      notifyListeners();
    }
  }

  void useAIHint() {
    if (_inventory.consume(PowerUpType.hint)) {
      storageService.saveInventory(_inventory);
      _suggestedMove = AISolver.findBestMove(_tiles, _gridSize, _gameLogic);
      _checkMissions(MissionType.usePowerUp, 1);
      notifyListeners();
    }
  }

  bool buyPowerUp(PowerUpType type) {
    if (_coins >= type.coinCost) {
      _coins -= type.coinCost;
      storageService.saveCoins(_coins);
      _inventory.add(type, 1);
      storageService.saveInventory(_inventory);
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Economy & Themes ---

  void addCoins(int amount) {
    _coins += amount;
    storageService.saveCoins(_coins);
    _careerStats['coinsEarned'] = (_careerStats['coinsEarned'] ?? 0) + amount;
    storageService.saveCareerStats(_careerStats);
    notifyListeners();
  }

  bool purchaseTheme(GameThemeType newTheme) {
    if (_unlockedThemes.contains(newTheme.name)) {
      setTheme(newTheme);
      return true;
    }
    if (_coins >= newTheme.coinCost) {
      _coins -= newTheme.coinCost;
      storageService.saveCoins(_coins);
      _unlockedThemes.add(newTheme.name);
      storageService.saveUnlockedThemes(_unlockedThemes);
      setTheme(newTheme);
      return true;
    }
    return false;
  }

  void setTheme(GameThemeType newTheme) {
    _theme = newTheme;
    storageService.saveThemeName(newTheme.name);
    notifyListeners();
  }

  // --- Daily Rewards & Spin Wheel ---

  void claimDailyReward() {
    if (_dailyStreak.isClaimedToday) return;

    final nextDay = (_dailyStreak.streakDays % 7) + 1;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final tier = DailyStreak.rewards[nextDay - 1];
    addCoins(tier.coins);

    if (nextDay == 1) _inventory.add(PowerUpType.undo, 1);
    if (nextDay == 2) _inventory.add(PowerUpType.hint, 1);
    if (nextDay == 3) _inventory.add(PowerUpType.hammer, 1);
    if (nextDay == 4) _inventory.add(PowerUpType.shuffle, 1);
    if (nextDay == 5) _inventory.add(PowerUpType.undo, 2);
    if (nextDay == 6) _inventory.add(PowerUpType.hammer, 2);
    if (nextDay == 7) {
      _inventory.add(PowerUpType.undo, 2);
      _inventory.add(PowerUpType.hammer, 2);
      _inventory.add(PowerUpType.shuffle, 2);
      _inventory.add(PowerUpType.hint, 2);
    }
    storageService.saveInventory(_inventory);

    _dailyStreak = DailyStreak(
      streakDays: nextDay,
      lastClaimDate: todayStr,
      isClaimedToday: true,
    );
    storageService.saveDailyStreak(_dailyStreak);
    notifyListeners();
  }

  void spinPrizeEarned({required String prize, required int coinAmount, PowerUpType? powerUp}) {
    if (coinAmount > 0) {
      addCoins(coinAmount);
    }
    if (powerUp != null) {
      _inventory.add(powerUp, 1);
      storageService.saveInventory(_inventory);
    }
    storageService.saveLastFreeSpinTime(DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
  }

  // --- Missions & Achievements ---

  void _checkMissions(MissionType type, int progress) {
    bool changed = false;
    for (final m in _missions) {
      if (m.type == type && !m.isCompleted) {
        if (type == MissionType.reachTile || type == MissionType.scorePoints) {
          if (progress > m.current) {
            m.current = progress;
            changed = true;
          }
        } else {
          m.current += progress;
          changed = true;
        }
      }
    }
    if (changed) {
      storageService.saveMissions(_missions);
      notifyListeners();
    }
  }

  void _checkAchievements(String id, int progress) {
    for (final a in _achievements) {
      if (a.id == id && !a.isUnlocked) {
        a.current = progress;
        if (a.current >= a.target) {
          a.isUnlocked = true;
          storageService.saveAchievements(_achievements);
          notifyListeners();
        }
      }
    }
  }

  void _checkTileAchievements(int maxTile) {
    if (maxTile >= 128) _checkAchievements('reach_128', maxTile);
    if (maxTile >= 512) _checkAchievements('reach_512', maxTile);
    if (maxTile >= 1024) _checkAchievements('reach_1024', maxTile);
    if (maxTile >= 2048) _checkAchievements('reach_2048', maxTile);
    if (maxTile >= 4096) _checkAchievements('reach_4096', maxTile);
  }

  void claimMissionReward(Mission mission) {
    if (mission.isCompleted && !mission.isClaimed) {
      mission.isClaimed = true;
      addCoins(mission.type.coinReward);
      storageService.saveMissions(_missions);
      notifyListeners();
    }
  }

  void claimAchievementReward(Achievement achievement) {
    if (achievement.isUnlocked && !achievement.isClaimed) {
      achievement.isClaimed = true;
      addCoins(achievement.rewardCoins);
      storageService.saveAchievements(_achievements);
      notifyListeners();
    }
  }

  // --- Rewarded Revive & Ads ---

  void rewardedContinue() {
    if (!canRewardedContinue) return;
    _hasUsedRewardedContinueThisGame = true;
    _isGameOver = false;

    if (_undoSnapshot != null) {
      _tiles = _undoSnapshot!.tiles;
      _score = _undoSnapshot!.score;
      _undoSnapshot = null;
    } else {
      final active = _tiles.where((t) => t.mergedIntoId == null).toList();
      if (active.length > 2) {
        active.sort((a, b) => a.value.compareTo(b.value));
        final toRemove = active.take(2).map((t) => t.id).toSet();
        _tiles = _tiles.where((t) => !toRemove.contains(t.id)).toList();
      }
    }

    if (_gameMode == GameMode.timed && _timedSecondsRemaining <= 0) {
      _timedSecondsRemaining = 30; // +30s bonus on continue
      _startTimedCountdown();
    }

    _saveGameState();
    notifyListeners();
  }

  void purchaseRemoveAds() {
    _adsRemoved = true;
    storageService.saveAdsRemoved(true);
    notifyListeners();
  }

  void toggleSound(bool value) {
    audioService.isSoundEnabled = value;
    storageService.saveSoundEnabled(value);
    notifyListeners();
  }

  void toggleVibration(bool value) {
    audioService.isVibrationEnabled = value;
    storageService.saveVibrationEnabled(value);
    notifyListeners();
  }

  void _updateStats({int gamesPlayedInc = 0, int movesInc = 0, int mergesInc = 0, int? score, int? maxTile}) {
    _careerStats['gamesPlayed'] = (_careerStats['gamesPlayed'] ?? 0) + gamesPlayedInc;
    _careerStats['totalMoves'] = (_careerStats['totalMoves'] ?? 0) + movesInc;
    _careerStats['totalMerges'] = (_careerStats['totalMerges'] ?? 0) + mergesInc;
    if (score != null && score > (_careerStats['highestScore'] ?? 0)) {
      _careerStats['highestScore'] = score;
    }
    if (maxTile != null && maxTile > (_careerStats['highestTile'] ?? 2)) {
      _careerStats['highestTile'] = maxTile;
    }
    storageService.saveCareerStats(_careerStats);
  }

  void _saveGameState() {
    final activeTiles = _tiles.where((t) => t.mergedIntoId == null).toList();
    final snapshot = GameSnapshot(
      tiles: activeTiles,
      score: _score,
      isGameOver: _isGameOver,
      isWon: _isWon,
      wonDismissed: _wonDismissed,
    );
    storageService.saveCurrentGame(snapshot);
    storageService.saveUndoSnapshot(_undoSnapshot);
  }

  @override
  void dispose() {
    _timedTimer?.cancel();
    super.dispose();
  }
}
