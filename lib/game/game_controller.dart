import 'package:flutter/foundation.dart';
import '../config/ad_config.dart';
import '../models/tile.dart';
import '../models/game_snapshot.dart';
import '../services/ad_service.dart';
import '../services/storage_service.dart';
import '../services/audio_feedback_service.dart';
import '../theme/app_theme.dart';
import 'game_logic.dart';

class GameController extends ChangeNotifier {
  final StorageService storageService;
  final AudioFeedbackService audioService;
  final GameLogic _gameLogic;

  List<Tile> _tiles = [];
  int _score = 0;
  int _bestScore = 0;
  int _scoreAddedThisMove = 0;
  bool _isGameOver = false;
  bool _isWon = false;
  bool _wonDismissed = false;
  bool _isAnimating = false;
  GameThemeType _theme = GameThemeType.aurora;

  bool _hasUsedRewardedContinueThisGame = false;
  int _bonusUndos = 0;
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
  bool get isGameOver => _isGameOver;
  bool get isWon => _isWon;
  bool get wonDismissed => _wonDismissed;
  bool get canUndo => _undoSnapshot != null || _bonusUndos > 0;
  bool get hasTurnUndo => _undoSnapshot != null;
  bool get canRewardedContinue =>
      _isGameOver && !_hasUsedRewardedContinueThisGame;
  bool get isAnimating => _isAnimating;
  bool get isSoundEnabled => audioService.isSoundEnabled;
  bool get isVibrationEnabled => audioService.isVibrationEnabled;
  bool get adsRemoved => _adsRemoved;
  int get bonusUndos => _bonusUndos;
  GameThemeType get theme => _theme;

  void init() {
    _bestScore = storageService.loadBestScore();
    _adsRemoved = storageService.loadAdsRemoved();
    _bonusUndos = storageService.loadBonusUndos();
    _completedGamesCount = storageService.loadCompletedGamesCount();
    audioService.isSoundEnabled = storageService.loadSoundEnabled();
    audioService.isVibrationEnabled = storageService.loadVibrationEnabled();

    final themeName = storageService.loadThemeName();
    _theme = GameThemeType.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => GameThemeType.aurora,
    );

    final savedGame = storageService.loadCurrentGame();
    if (savedGame != null && savedGame.tiles.isNotEmpty) {
      _tiles = savedGame.tiles;
      _score = savedGame.score;
      _isGameOver = savedGame.isGameOver;
      _isWon = savedGame.isWon;
      _wonDismissed = savedGame.wonDismissed;
      _undoSnapshot = storageService.loadUndoSnapshot();

      // Ensure nextTileId is larger than any existing tile id
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

  void _startFreshGameInternal() {
    _tiles = _gameLogic.createInitialBoard(nextId: _nextTileId);
    _nextTileId += 2;
    _score = 0;
    _scoreAddedThisMove = 0;
    _isGameOver = false;
    _isWon = false;
    _wonDismissed = false;
    _hasUsedRewardedContinueThisGame = false;
    _undoSnapshot = null;
    _isAnimating = false;

    _saveGameState();
  }

  void startNewGame() {
    // If the previous game was played / finished, increment counter and check interstitial frequency
    if (_score > 0 || _isGameOver) {
      _completedGamesCount++;
      storageService.saveCompletedGamesCount(_completedGamesCount);

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

  int _getNextId() {
    return _nextTileId++;
  }

  void dismissWin() {
    _wonDismissed = true;
    _saveGameState();
    notifyListeners();
  }

  Future<void> move(SwipeDirection direction) async {
    if (_isGameOver || (_isWon && !_wonDismissed) || _isAnimating) {
      return;
    }

    // Capture state for undo before applying move
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
      getNextId: _getNextId,
    );

    if (!result.boardChanged) {
      return;
    }

    _undoSnapshot = previousSnapshot;
    _tiles = result.tiles;
    _score += result.scoreAdded;
    _scoreAddedThisMove = result.scoreAdded;

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

    // Short sliding transition window
    await Future.delayed(const Duration(milliseconds: 140));

    // Remove merged away tiles and spawn new tile
    _tiles = _tiles.where((t) => t.mergedIntoId == null).map((t) {
      return t.copyWith(
        previousRow: null,
        previousCol: null,
        isMerged: false,
      );
    }).toList();

    final newTile = _gameLogic.spawnRandomTile(_tiles, _getNextId());
    if (newTile != null) {
      _tiles.add(newTile);
    }

    if (_gameLogic.isGameOver(_tiles)) {
      _isGameOver = true;
      audioService.playGameOver();
    }

    _isAnimating = false;
    _saveGameState();
    notifyListeners();
  }

  void undo() {
    if (_undoSnapshot != null) {
      _tiles = _undoSnapshot!.tiles;
      _score = _undoSnapshot!.score;
      _isGameOver = _undoSnapshot!.isGameOver;
      _isWon = _undoSnapshot!.isWon;
      _wonDismissed = _undoSnapshot!.wonDismissed;
      _undoSnapshot = null;
      _scoreAddedThisMove = 0;

      _saveGameState();
      notifyListeners();
    } else if (_bonusUndos > 0) {
      _bonusUndos--;
      storageService.saveBonusUndos(_bonusUndos);

      // If no undo snapshot exists but user has a bonus undo, remove 2 lowest tiles to give fresh space
      if (_tiles.length > 2) {
        _tiles.sort((a, b) => a.value.compareTo(b.value));
        _tiles.removeRange(0, 2);
      }

      _isGameOver = false;
      _saveGameState();
      notifyListeners();
    }
  }

  /// Adds +1 Bonus Undo after watching a rewarded ad
  void addBonusUndo() {
    _bonusUndos++;
    storageService.saveBonusUndos(_bonusUndos);
    notifyListeners();
  }

  /// Revives the game from Game Over after watching a rewarded ad
  void rewardedContinue() {
    if (!canRewardedContinue) return;

    _hasUsedRewardedContinueThisGame = true;
    _isGameOver = false;

    if (_undoSnapshot != null) {
      _tiles = _undoSnapshot!.tiles;
      _score = _undoSnapshot!.score;
      _undoSnapshot = null;
    } else {
      // Remove 2 lowest tiles so board has open slots to continue playing
      final active = _tiles.where((t) => t.mergedIntoId == null).toList();
      if (active.length > 2) {
        active.sort((a, b) => a.value.compareTo(b.value));
        final toRemove = active.take(2).map((t) => t.id).toSet();
        _tiles = _tiles.where((t) => !toRemove.contains(t.id)).toList();
      }
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

  void setTheme(GameThemeType newTheme) {
    if (_theme == newTheme) return;
    _theme = newTheme;
    storageService.saveThemeName(newTheme.name);
    notifyListeners();
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
}
