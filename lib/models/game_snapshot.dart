import 'tile.dart';

class GameSnapshot {
  final List<Tile> tiles;
  final int score;
  final bool isGameOver;
  final bool isWon;
  final bool wonDismissed;

  GameSnapshot({
    required this.tiles,
    required this.score,
    required this.isGameOver,
    required this.isWon,
    required this.wonDismissed,
  });

  Map<String, dynamic> toJson() {
    return {
      'tiles': tiles.map((t) => t.toJson()).toList(),
      'score': score,
      'isGameOver': isGameOver,
      'isWon': isWon,
      'wonDismissed': wonDismissed,
    };
  }

  factory GameSnapshot.fromJson(Map<String, dynamic> json) {
    return GameSnapshot(
      tiles: (json['tiles'] as List<dynamic>)
          .map((t) => Tile.fromJson(t as Map<String, dynamic>))
          .toList(),
      score: json['score'] as int,
      isGameOver: json['isGameOver'] as bool? ?? false,
      isWon: json['isWon'] as bool? ?? false,
      wonDismissed: json['wonDismissed'] as bool? ?? false,
    );
  }
}
