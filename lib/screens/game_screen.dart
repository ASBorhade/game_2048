import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner.dart';
import '../widgets/daily_reward_dialog.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_overlays.dart';
import '../widgets/lucky_spin_dialog.dart';
import '../widgets/missions_sheet.dart';
import '../widgets/mode_selector_dialog.dart';
import '../widgets/power_up_bar.dart';
import '../widgets/score_box.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/stats_dialog.dart';
import '../widgets/theme_store_sheet.dart';

class GameScreen extends StatelessWidget {
  final GameController controller;

  const GameScreen({
    super.key,
    required this.controller,
  });

  void _confirmNewGame(BuildContext context) {
    if (controller.score == 0 || controller.isGameOver) {
      controller.startNewGame();
      return;
    }

    final theme = controller.theme;
    final isClassic = theme == GameThemeType.classic;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isClassic ? AppTheme.background : const Color(0xFF131B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isClassic
              ? BorderSide.none
              : BorderSide(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
        ),
        title: Text(
          'Start New Game?',
          style: TextStyle(
            color: isClassic ? AppTheme.darkText : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your current progress and board state will be reset.',
          style: TextStyle(
            color: isClassic
                ? AppTheme.subtitleText
                : AppTheme.getSubtitleColor(theme),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isClassic
                    ? AppTheme.darkText
                    : AppTheme.getSubtitleColor(theme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getButtonColor(theme),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              controller.startNewGame();
            },
            child: const Text(
              'New Game',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRewardedContinue(BuildContext context) {
    controller.setAdLoading(true);
    AdService().showRewardedAd(
      onRewarded: () {
        controller.setAdLoading(false);
        controller.rewardedContinue();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Game revived! Keep going.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onFailed: () {
        controller.setAdLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad is loading, please try again shortly.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onDismissed: () {
        controller.setAdLoading(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final theme = controller.theme;
        final isClassic = theme == GameThemeType.classic;

        return Scaffold(
          body: Container(
            decoration: AppTheme.getScreenBackground(theme),
            child: Stack(
              children: [
                // Ambient Aurora glowing orb accents
                if (!isClassic) ...[
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (theme == GameThemeType.aurora
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFFFF007F))
                            .withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: -60,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (theme == GameThemeType.aurora
                                ? const Color(0xFF818CF8)
                                : const Color(0xFF00F0FF))
                            .withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ],

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1. Top Feature Bar (Coins, Spin Wheel, Missions, Streak, Mode)
                            Row(
                              children: [
                                // Coins Pill
                                GestureDetector(
                                  onTap: () => ThemeStoreSheet.show(context, controller),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${controller.coins}',
                                          style: const TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.add_circle, color: Color(0xFFFFD700), size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Lucky Spin Button
                                IconButton(
                                  icon: const Icon(Icons.casino, color: Color(0xFFFFD700), size: 20),
                                  tooltip: 'Lucky Wheel',
                                  onPressed: () => LuckySpinDialog.show(context, controller),
                                ),
                                // Daily Streak Button
                                IconButton(
                                  icon: Badge(
                                    isLabelVisible: !controller.dailyStreak.isClaimedToday,
                                    backgroundColor: const Color(0xFF10B981),
                                    child: const Icon(Icons.calendar_month, color: Color(0xFF38BDF8), size: 20),
                                  ),
                                  tooltip: 'Daily Rewards',
                                  onPressed: () => DailyRewardDialog.show(context, controller),
                                ),
                                // Missions / Quests Button
                                IconButton(
                                  icon: Badge(
                                    isLabelVisible: (controller.claimableMissionsCount + controller.claimableAchievementsCount) > 0,
                                    label: Text('${controller.claimableMissionsCount + controller.claimableAchievementsCount}'),
                                    child: const Icon(Icons.military_tech, color: Color(0xFFA855F7), size: 20),
                                  ),
                                  tooltip: 'Missions & Achievements',
                                  onPressed: () => MissionsSheet.show(context, controller),
                                ),
                                // Theme Store Button
                                IconButton(
                                  icon: const Icon(Icons.palette, color: Color(0xFFEC4899), size: 20),
                                  tooltip: 'Theme Store',
                                  onPressed: () => ThemeStoreSheet.show(context, controller),
                                ),
                                // Stats Button
                                IconButton(
                                  icon: const Icon(Icons.analytics_outlined, color: Colors.white70, size: 20),
                                  tooltip: 'Career Stats',
                                  onPressed: () => StatsDialog.show(context, controller),
                                ),
                                // Settings Button
                                IconButton(
                                  icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                                  tooltip: 'Settings',
                                  onPressed: () => SettingsDialog.show(context, controller),
                                ),
                              ],
                            ),

                            // 2. Header Section: Title & Score Cards
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          AppTheme.getLogoGradient(theme).createShader(bounds),
                                      child: const Text(
                                        '2048',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -2,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    GestureDetector(
                                      onTap: () => ModeSelectorDialog.show(context, controller),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.getButtonColor(theme).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppTheme.getButtonColor(theme).withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${controller.gridSize}x${controller.gridSize} • ${controller.gameMode.label.toUpperCase()}',
                                              style: TextStyle(
                                                color: AppTheme.getButtonColor(theme),
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.arrow_drop_down, color: AppTheme.getButtonColor(theme), size: 12),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (controller.gameMode == GameMode.timed) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: controller.timedSecondsRemaining <= 20
                                          ? const Color(0xFFEF4444)
                                          : const Color(0x30FFFFFF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timer, size: 16, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${controller.timedSecondsRemaining}s',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                ScoreBox(
                                  title: 'Score',
                                  score: controller.score,
                                  addedScore: controller.scoreAddedThisMove,
                                  theme: theme,
                                  icon: Icons.local_fire_department,
                                ),
                                const SizedBox(width: 6),
                                ScoreBox(
                                  title: 'Best',
                                  score: controller.bestScore,
                                  theme: theme,
                                  icon: Icons.emoji_events,
                                ),
                              ],
                            ),

                            // 3. Floating Combo Banner (if combo >= 2)
                            if (controller.lastComboCount >= 2)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF007F), Color(0xFFFFD700)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0xFFFF007F), blurRadius: 10, spreadRadius: 1),
                                  ],
                                ),
                                child: Text(
                                  '🔥 COMBO x${controller.lastComboCount}!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),

                            // 4. Game Board Container with Overlays
                            Expanded(
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    GameBoardWidget(
                                      tiles: controller.tiles,
                                      gridSize: controller.gridSize,
                                      theme: theme,
                                      isHammerActive: controller.isHammerActive,
                                      suggestedMove: controller.suggestedMove,
                                      onSwipe: (direction) => controller.move(direction),
                                      onTileTapped: (tileId) => controller.smashTileWithHammer(tileId),
                                    ),
                                    if (controller.isGameOver)
                                      Positioned.fill(
                                        child: GameOverOverlay(
                                          score: controller.score,
                                          theme: theme,
                                          canRewardedContinue: controller.canRewardedContinue,
                                          onWatchAdContinue: () => _handleRewardedContinue(context),
                                          onRestart: controller.startNewGame,
                                        ),
                                      ),
                                    if (controller.isWon && !controller.wonDismissed)
                                      Positioned.fill(
                                        child: GameWinOverlay(
                                          theme: theme,
                                          onContinue: controller.dismissWin,
                                          onRestart: controller.startNewGame,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // 5. In-Game Power-Up Dock (Undo, Hammer, Shuffle, AI Hint)
                            PowerUpBar(controller: controller),

                            // 6. Action Controls Bar (New Game Button)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Restart Game'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.getSubtitleColor(theme),
                                  ),
                                  onPressed: () => _confirmNewGame(context),
                                ),
                              ],
                            ),

                            // 7. Anchored Adaptive Banner Ad
                            AdBanner(isAdsRemoved: controller.adsRemoved),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 8. Ad Loading Overlay
                if (controller.isAdLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131B2E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 16),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.getButtonColor(theme),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Loading Video Ad...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Preparing your reward',
                                style: TextStyle(
                                  color: AppTheme.getSubtitleColor(theme),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 9. App / Board Loading Overlay
                if (controller.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: isClassic ? AppTheme.background : const Color(0xFF090D16),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.getLogoGradient(theme).createShader(bounds),
                              child: const Text(
                                '2048',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CircularProgressIndicator(
                              color: AppTheme.getButtonColor(theme),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
