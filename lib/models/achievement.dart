class AchievementTier {
  final int target;
  final String title;
  final String description;
  final int rewardCoins;

  const AchievementTier({
    required this.target,
    required this.title,
    required this.description,
    required this.rewardCoins,
  });
}

class Achievement {
  final String id;
  final String iconName;
  final List<AchievementTier> tiers;
  int level; // 1-based index into tiers
  int current;
  bool isClaimed;

  Achievement({
    required this.id,
    required this.iconName,
    required this.tiers,
    this.level = 1,
    this.current = 0,
    this.isClaimed = false,
  });

  AchievementTier get currentTier =>
      tiers[(level - 1).clamp(0, tiers.length - 1)];

  String get title => '${currentTier.title} (Lv.$level)';
  String get description => currentTier.description;
  int get target => currentTier.target;
  int get rewardCoins => currentTier.rewardCoins;
  bool get isMaxLevel => level >= tiers.length && isClaimed;

  bool get isUnlocked => current >= target;
  double get progress => (current / target).clamp(0.0, 1.0);

  /// Advances to next level if available upon claiming reward
  bool advanceLevel() {
    if (level < tiers.length) {
      level++;
      isClaimed = false;
      return true;
    } else {
      isClaimed = true;
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'iconName': iconName,
        'level': level,
        'current': current,
        'isClaimed': isClaimed,
      };

  factory Achievement.fromJson(
    Map<String, dynamic> json,
    List<AchievementTier> templateTiers,
  ) {
    return Achievement(
      id: json['id'] as String,
      iconName: json['iconName'] as String,
      tiers: templateTiers,
      level: json['level'] as int? ?? 1,
      current: json['current'] as int? ?? 0,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }

  static List<Achievement> getInitialList() {
    return [
      Achievement(
        id: 'reach_tile',
        iconName: 'military_tech',
        tiers: const [
          AchievementTier(target: 128, title: 'Centurion', description: 'Reach the 128 tile', rewardCoins: 15),
          AchievementTier(target: 256, title: 'Quarter Master', description: 'Reach the 256 tile', rewardCoins: 20),
          AchievementTier(target: 512, title: 'Halfway Hero', description: 'Reach the 512 tile', rewardCoins: 30),
          AchievementTier(target: 1024, title: 'Kilobyte King', description: 'Reach the 1024 tile', rewardCoins: 40),
          AchievementTier(target: 2048, title: 'The Legend', description: 'Reach the ultimate 2048 tile!', rewardCoins: 60),
          AchievementTier(target: 4096, title: 'Beyond Limits', description: 'Reach the epic 4096 tile!', rewardCoins: 100),
          AchievementTier(target: 8192, title: 'Master of Merges', description: 'Reach the legendary 8192 tile!', rewardCoins: 150),
          AchievementTier(target: 16384, title: 'Mythical Grandmaster', description: 'Reach the mythical 16,384 tile!', rewardCoins: 250),
          AchievementTier(target: 32768, title: 'Immortal Mind', description: 'Reach the god-tier 32,768 tile!', rewardCoins: 500),
          AchievementTier(target: 65536, title: 'Cosmic Ascendant', description: 'Reach the ultimate 65,536 tile!', rewardCoins: 1000),
        ],
      ),
      Achievement(
        id: 'high_score',
        iconName: 'local_fire_department',
        tiers: const [
          AchievementTier(target: 3000, title: 'Bronze Score', description: 'Score 3,000 points in a match', rewardCoins: 15),
          AchievementTier(target: 8000, title: 'Silver Score', description: 'Score 8,000 points in a match', rewardCoins: 20),
          AchievementTier(target: 20000, title: 'Gold Score', description: 'Score 20,000 points in a match', rewardCoins: 30),
          AchievementTier(target: 50000, title: 'Diamond Score', description: 'Score 50,000 points in a match', rewardCoins: 50),
          AchievementTier(target: 100000, title: 'Master Score', description: 'Score 100,000 points in a match', rewardCoins: 80),
          AchievementTier(target: 250000, title: 'Godlike Score', description: 'Score 250,000 points in a match', rewardCoins: 150),
        ],
      ),
      Achievement(
        id: 'total_merges',
        iconName: 'merge_type',
        tiers: const [
          AchievementTier(target: 100, title: 'Merge Novice', description: 'Merge a total of 100 tiles', rewardCoins: 15),
          AchievementTier(target: 500, title: 'Merge Adept', description: 'Merge a total of 500 tiles', rewardCoins: 20),
          AchievementTier(target: 2000, title: 'Merge Master', description: 'Merge a total of 2,000 tiles', rewardCoins: 35),
          AchievementTier(target: 5000, title: 'Merge Legend', description: 'Merge a total of 5,000 tiles', rewardCoins: 60),
          AchievementTier(target: 15000, title: 'Merge Titan', description: 'Merge a total of 15,000 tiles', rewardCoins: 100),
          AchievementTier(target: 50000, title: 'Merge Deity', description: 'Merge a total of 50,000 tiles', rewardCoins: 200),
        ],
      ),
      Achievement(
        id: 'games_played',
        iconName: 'sports_esports',
        tiers: const [
          AchievementTier(target: 5, title: 'Rookie', description: 'Complete 5 game matches', rewardCoins: 10),
          AchievementTier(target: 20, title: 'Regular', description: 'Complete 20 game matches', rewardCoins: 15),
          AchievementTier(target: 50, title: 'Dedicated', description: 'Complete 50 game matches', rewardCoins: 25),
          AchievementTier(target: 100, title: 'Veteran', description: 'Complete 100 game matches', rewardCoins: 40),
          AchievementTier(target: 250, title: 'Elite Player', description: 'Complete 250 game matches', rewardCoins: 75),
          AchievementTier(target: 500, title: 'Centurion Master', description: 'Complete 500 game matches', rewardCoins: 150),
        ],
      ),
      Achievement(
        id: 'combos',
        iconName: 'bolt',
        tiers: const [
          AchievementTier(target: 2, title: 'Double Trouble', description: 'Perform a Combo x2 merge', rewardCoins: 15),
          AchievementTier(target: 3, title: 'Triple Threat', description: 'Perform a Combo x3 merge', rewardCoins: 25),
          AchievementTier(target: 4, title: 'Chain Reaction', description: 'Perform a Combo x4 merge', rewardCoins: 40),
          AchievementTier(target: 5, title: 'Combo Frenzy', description: 'Perform a Combo x5 merge', rewardCoins: 60),
          AchievementTier(target: 6, title: 'Supernova Surge', description: 'Perform a massive Combo x6 merge!', rewardCoins: 100),
        ],
      ),
    ];
  }
}
