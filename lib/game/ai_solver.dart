import 'dart:math';
import '../models/tile.dart';
import 'game_logic.dart';

class AISolver {
  static SwipeDirection? findBestMove(
    List<Tile> tiles,
    int gridSize,
    GameLogic gameLogic,
  ) {
    SwipeDirection? bestDir;
    double bestScore = -double.infinity;

    for (final dir in SwipeDirection.values) {
      int tempId = 99990;
      final result = gameLogic.executeMove(
        tiles,
        dir,
        gridSize: gridSize,
        getNextId: () => tempId++,
      );

      if (!result.boardChanged) continue;

      final score = _evaluateState(result.tiles, gridSize) + result.scoreAdded;
      if (score > bestScore) {
        bestScore = score;
        bestDir = dir;
      }
    }

    return bestDir;
  }

  static double _evaluateState(List<Tile> tiles, int size) {
    final grid = List.generate(size, (_) => List<int>.filled(size, 0));
    final active = tiles.where((t) => t.mergedIntoId == null);

    int emptyCount = 0;
    int maxVal = 0;
    int maxR = 0, maxC = 0;

    for (final t in active) {
      if (t.row < size && t.col < size) {
        grid[t.row][t.col] = t.value;
        if (t.value > maxVal) {
          maxVal = t.value;
          maxR = t.row;
          maxC = t.col;
        }
      }
    }

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) emptyCount++;
      }
    }

    // Monotonicity score
    double monotonicity = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size - 1; c++) {
        if (grid[r][c] != 0 && grid[r][c + 1] != 0) {
          final diff = (log(grid[r][c]) / ln2) - (log(grid[r][c + 1]) / ln2);
          monotonicity -= diff.abs();
        }
      }
    }
    for (int c = 0; c < size; c++) {
      for (int r = 0; r < size - 1; r++) {
        if (grid[r][c] != 0 && grid[r + 1][c] != 0) {
          final diff = (log(grid[r][c]) / ln2) - (log(grid[r + 1][c]) / ln2);
          monotonicity -= diff.abs();
        }
      }
    }

    // Corner bonus for max tile
    double cornerBonus = 0;
    if ((maxR == 0 || maxR == size - 1) && (maxC == 0 || maxC == size - 1)) {
      cornerBonus = maxVal.toDouble() * 2.0;
    }

    return (emptyCount * 100.0) + (monotonicity * 10.0) + cornerBonus;
  }
}
