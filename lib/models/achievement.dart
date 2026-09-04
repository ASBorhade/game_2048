class Achievement {
  final String id;
  final String title;
  final String description;
  final int target;
  final int rewardCoins;
  final String iconName;
  int current;
  bool isUnlocked;
  bool isClaimed;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.rewardCoins,
    required this.iconName,
    this.current = 0,
    this.isUnlocked = false,
    this.isClaimed = false,
  });

  double get progress => (current / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'target': target,
        'rewardCoins': rewardCoins,
        'iconName': iconName,
        'current': current,
        'isUnlocked': isUnlocked,
        'isClaimed': isClaimed,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      target: json['target'] as int,
      rewardCoins: json['rewardCoins'] as int,
      iconName: json['iconName'] as String,
      current: json['current'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }

  static List<Achievement> getInitialList() {
    return [
      Achievement(
        id: 'reach_128',
        title: 'Centurion',
        description: 'Reach the 128 tile',
        target: 128,
        rewardCoins: 50,
        iconName: 'military_tech',
      ),
      Achievement(
        id: 'reach_512',
        title: 'Halfway Hero',
        description: 'Reach the 512 tile',
        target: 512,
        rewardCoins: 100,
        iconName: 'workspace_premium',
      ),
      Achievement(
        id: 'reach_1024',
        title: 'Kilobyte King',
        description: 'Reach the 1024 tile',
        target: 1024,
        rewardCoins: 200,
        iconName: 'diamond',
      ),
      Achievement(
        id: 'reach_2048',
        title: 'The Legend (2048)',
        description: 'Reach the ultimate 2048 tile!',
        target: 2048,
        rewardCoins: 500,
        iconName: 'emoji_events',
      ),
      Achievement(
        id: 'reach_4096',
        title: 'Beyond Limits (4096)',
        description: 'Reach the 4096 tile!',
        target: 4096,
        rewardCoins: 1000,
        iconName: 'auto_awesome',
      ),
      Achievement(
        id: 'play_10_games',
        title: 'Dedicated Player',
        description: 'Complete 10 games',
        target: 10,
        rewardCoins: 150,
        iconName: 'sports_esports',
      ),
      Achievement(
        id: 'score_10000',
        title: 'Five Figures',
        description: 'Score 10,000 points in a single match',
        target: 10000,
        rewardCoins: 250,
        iconName: 'local_fire_department',
      ),
      Achievement(
        id: 'combo_x3',
        title: 'Chain Reaction',
        description: 'Perform a Combo x3 in a single turn',
        target: 3,
        rewardCoins: 200,
        iconName: 'bolt',
      ),
    ];
  }
}
