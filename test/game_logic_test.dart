import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/game/ai_solver.dart';
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

    test('Movement in 3x3 Grid: [2, 0, 0] -> RIGHT -> [0, 0, 2]', () {
      final tiles = [Tile(id: getNextId(), value: 2, row: 0, col: 0)];

      final result = logic.executeMove(
        tiles,
        SwipeDirection.right,
        gridSize: 3,
        getNextId: getNextId,
      );

      expect(result.boardChanged, isTrue);
      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 1);
      expect(active.first.row, 0);
      expect(active.first.col, 2);
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

    test('Basic Merge: [2, 2, 0, 0] -> LEFT -> [4, 0, 0, 0] (+4 score, Combo x1)', () {
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
      expect(result.comboCount, 1);

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

    test('Double Merge Combo: [2, 2, 4, 4] -> LEFT -> [4, 8, 0, 0] (Combo x2)', () {
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
      expect(result.comboCount, 2);

      final active = result.tiles.where((t) => t.mergedIntoId == null).toList();
      expect(active.length, 2);
      expect(active.any((t) => t.row == 0 && t.col == 0 && t.value == 4), isTrue);
      expect(active.any((t) => t.row == 0 && t.col == 1 && t.value == 8), isTrue);
    });

    test('Power-Up: Hammer smashes tile', () {
      final tiles = [
        Tile(id: 10, value: 128, row: 0, col: 0),
        Tile(id: 20, value: 64, row: 1, col: 1),
      ];

      final afterHammer = logic.smashTile(tiles, 10);
      expect(afterHammer.length, 1);
      expect(afterHammer.first.id, 20);
      expect(afterHammer.first.value, 64);
    });

    test('Power-Up: Shuffle rearranges tiles without changing count or values', () {
      final tiles = [
        Tile(id: 1, value: 2, row: 0, col: 0),
        Tile(id: 2, value: 4, row: 0, col: 1),
        Tile(id: 3, value: 8, row: 1, col: 0),
      ];

      final shuffled = logic.shuffleTiles(tiles, 4);
      expect(shuffled.length, 3);
      final values = shuffled.map((t) => t.value).toList()..sort();
      expect(values, [2, 4, 8]);
    });

    test('AI Solver: Recommends a valid directional move', () {
      final tiles = [
        Tile(id: 1, value: 2, row: 0, col: 0),
        Tile(id: 2, value: 2, row: 0, col: 1),
      ];

      final bestMove = AISolver.findBestMove(tiles, 4, logic);
      expect(bestMove, isNotNull);
      expect([SwipeDirection.left, SwipeDirection.right].contains(bestMove), isTrue);
    });

    test('Game Over Detection', () {
      // Board with empty cells is not game over
      final partialTiles = [
        Tile(id: 1, value: 2, row: 0, col: 0),
        Tile(id: 2, value: 4, row: 0, col: 1),
      ];
      expect(logic.isGameOver(partialTiles), isFalse);

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
  });
}
