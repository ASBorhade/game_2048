class DailyStreak {
  final int streakDays; // 1 to 7
  final String lastClaimDate; // YYYY-MM-DD
  final bool isClaimedToday;

  DailyStreak({
    this.streakDays = 0,
    this.lastClaimDate = '',
    this.isClaimedToday = false,
  });

  static const List<DailyRewardTier> rewards = [
    DailyRewardTier(day: 1, coins: 50, powerUp: 'Undo x1'),
    DailyRewardTier(day: 2, coins: 100, powerUp: 'Hint x1'),
    DailyRewardTier(day: 3, coins: 150, powerUp: 'Hammer x1'),
    DailyRewardTier(day: 4, coins: 200, powerUp: 'Shuffle x1'),
    DailyRewardTier(day: 5, coins: 250, powerUp: 'Undo x2'),
    DailyRewardTier(day: 6, coins: 350, powerUp: 'Hammer x2'),
    DailyRewardTier(day: 7, coins: 500, powerUp: 'Mega Pack (All x2)'),
  ];

  Map<String, dynamic> toJson() => {
        'streakDays': streakDays,
        'lastClaimDate': lastClaimDate,
        'isClaimedToday': isClaimedToday,
      };

  factory DailyStreak.fromJson(Map<String, dynamic> json) {
    return DailyStreak(
      streakDays: json['streakDays'] as int? ?? 0,
      lastClaimDate: json['lastClaimDate'] as String? ?? '',
      isClaimedToday: json['isClaimedToday'] as bool? ?? false,
    );
  }
}

class DailyRewardTier {
  final int day;
  final int coins;
  final String powerUp;

  const DailyRewardTier({
    required this.day,
    required this.coins,
    required this.powerUp,
  });
}
