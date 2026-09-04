import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../theme/app_theme.dart';

class StatsDialog extends StatelessWidget {
  final GameController controller;

  const StatsDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (context) => StatsDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final isClassic = theme == GameThemeType.classic;
    final stats = controller.careerStats;

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
          const Icon(Icons.analytics, color: Color(0xFF38BDF8)),
          const SizedBox(width: 8),
          Text(
            'Career Statistics',
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatRow('Games Played', '${stats['gamesPlayed'] ?? 0}', Icons.sports_esports, theme, isClassic),
          _buildStatRow('Highest Score', '${stats['highestScore'] ?? controller.bestScore}', Icons.emoji_events, theme, isClassic),
          _buildStatRow('Highest Tile', '${stats['highestTile'] ?? 2}', Icons.military_tech, theme, isClassic),
          _buildStatRow('Total Merges', '${stats['totalMerges'] ?? 0}', Icons.merge_type, theme, isClassic),
          _buildStatRow('Total Moves', '${stats['totalMoves'] ?? 0}', Icons.touch_app, theme, isClassic),
          _buildStatRow('Total Coins Earned', '${stats['coinsEarned'] ?? controller.coins} 🪙', Icons.monetization_on, theme, isClassic),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, GameThemeType theme, bool isClassic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isClassic ? const Color(0xFFEDE0C8) : const Color(0x18FFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.getButtonColor(theme)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white70,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
