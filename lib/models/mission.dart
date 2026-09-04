enum MissionType {
  mergeTiles('Merge Master', 'Merge a total of {target} tiles', 20, 50),
  reachTile('Tile Climber', 'Reach the {target} tile', 256, 75),
  scorePoints('High Roller', 'Score {target} points in a match', 3000, 100),
  usePowerUp('Power Player', 'Use {target} power-ups in gameplay', 3, 60),
  playGames('Dedicated Player', 'Play {target} game matches', 3, 50),
  makeCombo('Combo King', 'Achieve a Combo x2 or higher', 2, 80);

  final String title;
  final String descriptionTemplate;
  final int defaultTarget;
  final int coinReward;

  const MissionType(
    this.title,
    this.descriptionTemplate,
    this.defaultTarget,
    this.coinReward,
  );
}

class Mission {
  final String id;
  final MissionType type;
  final int target;
  int current;
  bool isClaimed;

  Mission({
    required this.id,
    required this.type,
    required this.target,
    this.current = 0,
    this.isClaimed = false,
  });

  bool get isCompleted => current >= target;
  double get progress => (current / target).clamp(0.0, 1.0);

  String get description =>
      type.descriptionTemplate.replaceAll('{target}', '$target');

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'target': target,
        'current': current,
        'isClaimed': isClaimed,
      };

  factory Mission.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = MissionType.values.firstWhere(
      (m) => m.name == typeName,
      orElse: () => MissionType.mergeTiles,
    );
    return Mission(
      id: json['id'] as String,
      type: type,
      target: json['target'] as int,
      current: json['current'] as int? ?? 0,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}
