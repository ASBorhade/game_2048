import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/game/game_logic.dart';
import 'package:game_2048/models/tile.dart';

void main() {
  group('GameLogic 2048 Algorithm Tests', () {
    late GameLogic logic;
    int idCounter = 1;
    int getNextId() => idCounter++;

    setUp(() {
      logic = GameLogic();
      idCounter = 1;
    });

    test('Movement: [2, 0, 0, 0] -> RIGHT -> [0, 0, 0, 2]', () {
      final tiles = [Tile(id: getNextId(), value: 2, row: 0, col: 0)];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.right,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 1);
      expect(active.first.row, 0);
      expect(active.first.col, 3);
      expect(active.first.value, 2);
    });

    test('Movement: [0, 0, 2, 0] -> LEFT -> [2, 0, 0, 0]', () {
      final tiles = [Tile(id: getNextId(), value: 2, row: 0, col: 2)];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.left,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 1);
      expect(active.first.row, 0);
      expect(active.first.col, 0);
      expect(active.first.value, 2);
    });

    test('Basic Merge: [2, 2, 0, 0] -> LEFT -> [4, 0, 0, 0] (+4 score)', () {
      final tiles = [
        Tile(id: getNextId(), value: 2, row: 0, col: 0),
        Tile(id: getNextId(), value: 2, row: 0, col: 1),
      ];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.left,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      expect(result.scoreAdded, 4);

      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 1);
      expect(active.first.row, 0);
      expect(active.first.col, 0);
      expect(active.first.value, 4);
      expect(active.first.isMerged, isTrue);
    });

    test('Triple Merge: [2, 2, 2, 0] -> LEFT -> [4, 2, 0, 0]', () {
      final tiles = [
        Tile(id: getNextId(), value: 2, row: 0, col: 0),
        Tile(id: getNextId(), value: 2, row: 0, col: 1),
        Tile(id: getNextId(), value: 2, row: 0, col: 2),
      ];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.left,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      expect(result.scoreAdded, 4);

      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 2);
      expect(active.any((t) => t.row == 0 && t.col == 0 && t.value == 4), isTrue);
      expect(active.any((t) => t.row == 0 && t.col == 1 && t.value == 2), isTrue);
    });

    test('Double Merge: [2, 2, 4, 4] -> LEFT -> [4, 8, 0, 0]', () {
      final tiles = [
        Tile(id: getNextId(), value: 2, row: 0, col: 0),
        Tile(id: getNextId(), value: 2, row: 0, col: 1),
        Tile(id: getNextId(), value: 4, row: 0, col: 2),
        Tile(id: getNextId(), value: 4, row: 0, col: 3),
      ];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.left,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      expect(result.scoreAdded, 12);

      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 2);
      expect(active.any((t) => t.row == 0 && t.col == 0 && t.value == 4), isTrue);
      expect(active.any((t) => t.row == 0 && t.col == 1 && t.value == 8), isTrue);
    });

    test('No Invalid Double Merge: [4, 4, 4, 4] -> LEFT -> [8, 8, 0, 0]', () {
      final tiles = [
        Tile(id: getNextId(), value: 4, row: 0, col: 0),
        Tile(id: getNextId(), value: 4, row: 0, col: 1),
        Tile(id: getNextId(), value: 4, row: 0, col: 2),
        Tile(id: getNextId(), value: 4, row: 0, col: 3),
      ];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.left,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      expect(result.scoreAdded, 16);

      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 2);
      expect(active.any((t) => t.row == 0 && t.col == 0 && t.value == 8), isTrue);
      expect(active.any((t) => t.row == 0 && t.col == 1 && t.value == 8), isTrue);
    });

    test('No Cascading Merge: [2, 2, 4, 0] -> LEFT -> [4, 4, 0, 0] NOT [8, 0, 0, 0]', () {
      final tiles = [
        Tile(id: getNextId(), value: 2, row: 0, col: 0),
        Tile(id: getNextId(), value: 2, row: 0, col: 1),
        Tile(id: getNextId(), value: 4, row: 0, col: 2),
      ];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.left,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      expect(result.scoreAdded, 4);

      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 2);
      expect(active.any((t) => t.row == 0 && t.col == 0 && t.value == 4), isTrue);
      expect(active.any((t) => t.row == 0 && t.col == 1 && t.value == 4), isTrue);
    });

    test('Vertical Movements: UP and DOWN', () {
      final tiles = [
        Tile(id: getNextId(), value: 2, row: 0, col: 1),
        Tile(id: getNextId(), value: 2, row: 2, col: 1),
      ];

      final downResult = logic.executeMove(
        tiles,
        SwipeDirection.down,
        getNextId: getNextId,
      );

      expect(downResult.boardChanged, isTrue);
      expect(downResult.scoreAdded, 4);
      final active = downResult.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 1);
      expect(active.first.row, 3);
      expect(active.first.col, 1);
      expect(active.first.value, 4);
    });

    test('Game Over Detection', () {
      // Board with empty cells is not game over
      final partialTiles = [
        Tile(id: 1, value: 2, row: 0, col: 0),
        Tile(id: 2, value: 4, row: 0, col: 1),
      ];
      expect(logic.isGameOver(partialTiles), isFalse);

      // Full board with adjacent merges available is not game over
      final fullWithMerges = <Tile>[];
      int val = 2;
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          fullWithMerges.add(Tile(id: r * 4 + c + 1, value: val, row: r, col: c));
        }
      }
      expect(logic.isGameOver(fullWithMerges), isFalse);

      // Full board with NO valid moves is game over
      final gridValues = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];
      final gameOverTiles = <Tile>[];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          gameOverTiles.add(Tile(
            id: r * 4 + c + 1,
            value: gridValues[r][c],
            row: r,
            col: c,
          ));
        }
      }
      expect(logic.isGameOver(gameOverTiles), isTrue);
    });

    test('Win Detection: Reaching 2048 tile', () {
      final tiles = [
        Tile(id: getNextId(), value: 1024, row: 0, col: 0),
        Tile(id: getNextId(), value: 1024, row: 0, col: 1),
      ];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.left,
        getNextId: getNextId,
      );

      expect(result.hasWon, isTrue);
      expect(result.scoreAdded, 2048);
    });
  });
}
