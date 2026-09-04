import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/daily_streak.dart';
import '../theme/app_theme.dart';

class DailyRewardDialog extends StatelessWidget {
  final GameController controller;

  const DailyRewardDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (context) => DailyRewardDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final isClassic = theme == GameThemeType.classic;
    final streak = controller.dailyStreak;

    return AlertDialog(
      backgroundColor:
          isClassic ? AppTheme.background : const Color(0xFF131B2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isClassic
            ? BorderSide.none
            : BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, color: Color(0xFFFFD700)),
          const SizedBox(width: 8),
          Text(
            'Daily Login Streak',
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log in daily to claim coins & free power-ups!',
              style: TextStyle(
                color: isClassic
                    ? AppTheme.subtitleText
                    : AppTheme.getSubtitleColor(theme),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: DailyStreak.rewards.map((tier) {
                final isCurrentDay = tier.day == (streak.streakDays % 7) + 1 && !streak.isClaimedToday;
                final isClaimed = tier.day <= streak.streakDays && (tier.day < streak.streakDays || streak.isClaimedToday);

                return Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrentDay
                        ? AppTheme.getButtonColor(theme).withValues(alpha: 0.25)
                        : (isClaimed
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : (isClassic
                                ? const Color(0xFFEDE0C8)
                                : const Color(0x20FFFFFF))),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentDay
                          ? AppTheme.getButtonColor(theme)
                          : (isClaimed ? const Color(0xFF10B981) : Colors.white10),
                      width: isCurrentDay ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Day ${tier.day}',
                        style: TextStyle(
                          color: isClassic ? AppTheme.darkText : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        isClaimed
                            ? Icons.check_circle
                            : (tier.day == 7 ? Icons.card_giftcard : Icons.monetization_on),
                        color: isClaimed
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFFD700),
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${tier.coins}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tier.powerUp,
                        style: TextStyle(
                          color: isClassic ? AppTheme.darkText : Colors.white60,
                          fontSize: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (!streak.isClaimedToday)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  controller.claimDailyReward();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 Daily reward claimed!')),
                  );
                },
                child: const Text('Claim Today\'s Reward', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else
              const Text(
                '✅ You claimed today\'s reward. Come back tomorrow!',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
