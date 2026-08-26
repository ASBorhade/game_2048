import 'dart:math';
import '../models/tile.dart';

enum SwipeDirection { up, down, left, right }

class MoveResult {
  final List<Tile> tiles;
  final int scoreAdded;
  final bool boardChanged;
  final bool hasWon;

  MoveResult({
    required this.tiles,
    required this.scoreAdded,
    required this.boardChanged,
    required this.hasWon,
  });
}

class GameLogic {
  static const int gridSize = 4;
  final Random _random;

  GameLogic({Random? random}) : _random = random ?? Random();

  /// Creates a fresh board with 2 randomly placed initial tiles.
  List<Tile> createInitialBoard({int nextId = 1}) {
    final List<Tile> tiles = [];
    int currentId = nextId;

    // Pick 2 distinct random positions
    final pos1 = _random.nextInt(gridSize * gridSize);
    var pos2 = _random.nextInt(gridSize * gridSize);
    while (pos2 == pos1) {
      pos2 = _random.nextInt(gridSize * gridSize);
    }

    final val1 = _random.nextDouble() < 0.9 ? 2 : 4;
    final val2 = _random.nextDouble() < 0.9 ? 2 : 4;

    tiles.add(Tile(
      id: currentId++,
      value: val1,
      row: pos1 ~/ gridSize,
      col: pos1 % gridSize,
      isNew: true,
    ));

    tiles.add(Tile(
      id: currentId++,
      value: val2,
      row: pos2 ~/ gridSize,
      col: pos2 % gridSize,
      isNew: true,
    ));

    return tiles;
  }

  /// Spawns a random tile (2 with 90% chance, 4 with 10% chance) in an empty cell.
  Tile? spawnRandomTile(List<Tile> currentTiles, int nextId) {
    final occupied = <String>{};
    for (final t in currentTiles) {
      occupied.add('${t.row},${t.col}');
    }

    final emptyCells = <Point<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!occupied.contains('$r,$c')) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isEmpty) return null;

    final cell = emptyCells[_random.nextInt(emptyCells.length)];
    final value = _random.nextDouble() < 0.9 ? 2 : 4;

    return Tile(
      id: nextId,
      value: value,
      row: cell.x,
      col: cell.y,
      isNew: true,
    );
  }

  /// Executes a move in the given direction.
  /// Returns updated tiles, score gained, whether board changed, and win status.
  MoveResult executeMove(
    List<Tile> currentTiles,
    SwipeDirection direction, {
    required int Function() getNextId,
  }) {
    final List<Tile> nextTiles = [];
    int scoreAdded = 0;
    bool boardChanged = false;
    bool hasWon = false;

    // Clean up flags from previous moves and prepare active tiles
    final activeTiles = currentTiles
        .where((t) => t.mergedIntoId == null)
        .map((t) => t.copyWith(
              previousRow: t.row,
              previousCol: t.col,
              isNew: false,
              isMerged: false,
            ))
        .toList();

    // Organize tiles into a 4x4 matrix for fast positional lookup
    final matrix = List.generate(
      gridSize,
      (_) => List<Tile?>.filled(gridSize, null),
    );
    for (final tile in activeTiles) {
      matrix[tile.row][tile.col] = tile;
    }

    for (int i = 0; i < gridSize; i++) {
      // Extract line of tiles in the order of movement
      final List<Tile> line = [];
      for (int j = 0; j < gridSize; j++) {
        final Point<int> pt = _getCoordinate(direction, i, j);
        final tile = matrix[pt.x][pt.y];
        if (tile != null) {
          line.add(tile);
        }
      }

      // Process merging and movement along this line
      int targetIdx = 0;
      int k = 0;
      while (k < line.length) {
        final current = line[k];
        final Point<int> targetPt = _getCoordinate(direction, i, targetIdx);

        if (k + 1 < line.length && current.value == line[k + 1].value) {
          // Merge two tiles
          final next = line[k + 1];
          final mergedValue = current.value * 2;
          scoreAdded += mergedValue;
          if (mergedValue >= 2048) {
            hasWon = true;
          }

          final newMergedTile = Tile(
            id: getNextId(),
            value: mergedValue,
            row: targetPt.x,
            col: targetPt.y,
            previousRow: current.row,
            previousCol: current.col,
            isMerged: true,
          );

          // Mark current and next as merging into newMergedTile
          current.row = targetPt.x;
          current.col = targetPt.y;
          current.mergedIntoId = newMergedTile.id;

          next.row = targetPt.x;
          next.col = targetPt.y;
          next.mergedIntoId = newMergedTile.id;

          nextTiles.add(current);
          nextTiles.add(next);
          nextTiles.add(newMergedTile);

          boardChanged = true;
          targetIdx++;
          k += 2;
        } else {
          // Slide without merging
          if (current.row != targetPt.x || current.col != targetPt.y) {
            boardChanged = true;
            current.row = targetPt.x;
            current.col = targetPt.y;
          }
          nextTiles.add(current);
          targetIdx++;
          k++;
        }
      }
    }

    return MoveResult(
      tiles: nextTiles,
      scoreAdded: scoreAdded,
      boardChanged: boardChanged,
      hasWon: hasWon,
    );
  }

  /// Coordinate translation helper based on line index and progress along line
  Point<int> _getCoordinate(SwipeDirection direction, int line, int index) {
    switch (direction) {
      case SwipeDirection.left:
        return Point(line, index);
      case SwipeDirection.right:
        return Point(line, gridSize - 1 - index);
      case SwipeDirection.up:
        return Point(index, line);
      case SwipeDirection.down:
        return Point(gridSize - 1 - index, line);
    }
  }

  /// Checks if no valid moves remain (Game Over)
  bool isGameOver(List<Tile> currentTiles) {
    final active = currentTiles.where((t) => t.mergedIntoId == null).toList();
    if (active.length < gridSize * gridSize) {
      return false;
    }

    final grid = List.generate(
      gridSize,
      (_) => List<int>.filled(gridSize, 0),
    );

    for (final t in active) {
      grid[t.row][t.col] = t.value;
    }

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == 0) return false;
        if (c + 1 < gridSize && grid[r][c] == grid[r][c + 1]) return false;
        if (r + 1 < gridSize && grid[r][c] == grid[r + 1][c]) return false;
      }
    }

    return true;
  }

  /// Checks if board contains a 2048 tile or higher
  bool checkWin(List<Tile> currentTiles) {
    return currentTiles.any((t) => t.mergedIntoId == null && t.value >= 2048);
  }
}
