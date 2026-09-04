import 'dart:math';
import '../models/tile.dart';

enum SwipeDirection { up, down, left, right }

class MoveResult {
  final List<Tile> tiles;
  final int scoreAdded;
  final bool boardChanged;
  final bool hasWon;
  final int comboCount;

  MoveResult({
    required this.tiles,
    required this.scoreAdded,
    required this.boardChanged,
    required this.hasWon,
    this.comboCount = 0,
  });
}

class GameLogic {
  final Random _random;

  GameLogic({Random? random}) : _random = random ?? Random();

  /// Creates a fresh board with 2 randomly placed initial tiles.
  List<Tile> createInitialBoard({int gridSize = 4, int nextId = 1, int? seed}) {
    final rand = seed != null ? Random(seed) : _random;
    final List<Tile> tiles = [];
    int currentId = nextId;

    final totalCells = gridSize * gridSize;
    final pos1 = rand.nextInt(totalCells);
    var pos2 = rand.nextInt(totalCells);
    while (pos2 == pos1) {
      pos2 = rand.nextInt(totalCells);
    }

    final val1 = rand.nextDouble() < 0.9 ? 2 : 4;
    final val2 = rand.nextDouble() < 0.9 ? 2 : 4;

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

  /// Creates a deterministic daily challenge board based on calendar date
  List<Tile> createDailyBoard(DateTime date, {int gridSize = 4, int nextId = 1}) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final board = createInitialBoard(gridSize: gridSize, nextId: nextId, seed: seed);
    // Add 1 extra challenge tile
    final rand = Random(seed + 42);
    final occupied = board.map((t) => '${t.row},${t.col}').toSet();
    final emptyCells = <Point<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!occupied.contains('$r,$c')) {
          emptyCells.add(Point(r, c));
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      final cell = emptyCells[rand.nextInt(emptyCells.length)];
      board.add(Tile(
        id: nextId + 2,
        value: 8,
        row: cell.x,
        col: cell.y,
        isNew: true,
      ));
    }
    return board;
  }

  /// Spawns a random tile (2 with 90% chance, 4 with 10% chance) in an empty cell.
  Tile? spawnRandomTile(List<Tile> currentTiles, int nextId, {int gridSize = 4}) {
    final occupied = <String>{};
    for (final t in currentTiles) {
      if (t.mergedIntoId == null) {
        occupied.add('${t.row},${t.col}');
      }
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

  /// Executes a move in the given direction across an arbitrary NxN board.
  MoveResult executeMove(
    List<Tile> currentTiles,
    SwipeDirection direction, {
    int gridSize = 4,
    required int Function() getNextId,
  }) {
    final List<Tile> nextTiles = [];
    int scoreAdded = 0;
    bool boardChanged = false;
    bool hasWon = false;
    int comboCount = 0;

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

    // Organize tiles into an NxN matrix
    final matrix = List.generate(
      gridSize,
      (_) => List<Tile?>.filled(gridSize, null),
    );
    for (final tile in activeTiles) {
      if (tile.row < gridSize && tile.col < gridSize) {
        matrix[tile.row][tile.col] = tile;
      }
    }

    for (int i = 0; i < gridSize; i++) {
      // Extract line of tiles in the order of movement
      final List<Tile> line = [];
      for (int j = 0; j < gridSize; j++) {
        final Point<int> pt = _getCoordinate(direction, i, j, gridSize);
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
        final Point<int> targetPt = _getCoordinate(direction, i, targetIdx, gridSize);

        if (k + 1 < line.length && current.value == line[k + 1].value) {
          // Merge two tiles
          final next = line[k + 1];
          final mergedValue = current.value * 2;
          scoreAdded += mergedValue;
          comboCount++;
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
      comboCount: comboCount,
    );
  }

  /// Smashes (removes) a target tile using the Hammer power-up
  List<Tile> smashTile(List<Tile> tiles, int tileId) {
    return tiles.where((t) => t.id != tileId).toList();
  }

  /// Shuffles existing tile positions randomly across available cells
  List<Tile> shuffleTiles(List<Tile> tiles, int gridSize) {
    final active = tiles.where((t) => t.mergedIntoId == null).toList();
    if (active.isEmpty) return tiles;

    final allPositions = <Point<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        allPositions.add(Point(r, c));
      }
    }
    allPositions.shuffle(_random);

    final updated = <Tile>[];
    for (int i = 0; i < active.length; i++) {
      final pos = allPositions[i];
      updated.add(active[i].copyWith(
        row: pos.x,
        col: pos.y,
        previousRow: active[i].row,
        previousCol: active[i].col,
        isMerged: false,
        isNew: false,
      ));
    }
    return updated;
  }

  Point<int> _getCoordinate(SwipeDirection direction, int line, int index, int size) {
    switch (direction) {
      case SwipeDirection.left:
        return Point(line, index);
      case SwipeDirection.right:
        return Point(line, size - 1 - index);
      case SwipeDirection.up:
        return Point(index, line);
      case SwipeDirection.down:
        return Point(size - 1 - index, line);
    }
  }

  /// Checks if no valid moves remain (Game Over)
  bool isGameOver(List<Tile> currentTiles, {int gridSize = 4}) {
    final active = currentTiles.where((t) => t.mergedIntoId == null).toList();
    if (active.length < gridSize * gridSize) {
      return false;
    }

    final grid = List.generate(
      gridSize,
      (_) => List<int>.filled(gridSize, 0),
    );

    for (final t in active) {
      if (t.row < gridSize && t.col < gridSize) {
        grid[t.row][t.col] = t.value;
      }
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

  bool checkWin(List<Tile> currentTiles) {
    return currentTiles.any((t) => t.mergedIntoId == null && t.value >= 2048);
  }
}
