import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_overlays.dart';
import '../widgets/score_box.dart';
import '../widgets/settings_dialog.dart';

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

  void _handleUndoPress(BuildContext context) {
    if (controller.canUndo && !controller.isGameOver && !controller.isAnimating) {
      controller.undo();
    } else if (!controller.isGameOver && !controller.isAnimating) {
      // Offer rewarded ad to get +1 Undo
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: controller.theme == GameThemeType.classic
              ? AppTheme.background
              : const Color(0xFF131B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Get +1 Undo'),
          content: const Text(
            'Watch a short video ad to earn 1 free Undo bonus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill, size: 18),
              label: const Text('Watch Ad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getButtonColor(controller.theme),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                AdService().showRewardedAd(
                  onRewarded: () {
                    controller.addBonusUndo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reward earned: +1 Undo added!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onFailed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ad is loading, please try again shortly.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }
  }

  void _handleRewardedContinue(BuildContext context) {
    AdService().showRewardedAd(
      onRewarded: () {
        controller.rewardedContinue();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game revived! Keep playing.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad is loading, please try again shortly.'),
            duration: Duration(seconds: 2),
          ),
        );
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
                // Ambient Aurora glowing orb accents in background
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
                            .withValues(alpha: 0.15),
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
                            .withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ],

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Header: Logo + Score Cards
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          AppTheme.getLogoGradient(theme)
                                              .createShader(bounds),
                                      child: const Text(
                                        '2048',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 44,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -2,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                    if (!isClassic)
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.getButtonColor(theme)
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: AppTheme.getButtonColor(theme)
                                                .withValues(alpha: 0.6),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          theme.label.toUpperCase(),
                                          style: TextStyle(
                                            color:
                                                AppTheme.getButtonColor(theme),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                ScoreBox(
                                  title: 'Score',
                                  score: controller.score,
                                  addedScore: controller.scoreAddedThisMove,
                                  theme: theme,
                                  icon: Icons.local_fire_department,
                                ),
                                const SizedBox(width: 8),
                                ScoreBox(
                                  title: 'Best',
                                  score: controller.bestScore,
                                  theme: theme,
                                  icon: Icons.emoji_events,
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Subtitle + Action Controls
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.bonusUndos > 0
                                        ? 'Bonus Undos: ${controller.bonusUndos}'
                                        : 'Join tiles to reach 2048!',
                                    style: TextStyle(
                                      color: controller.bonusUndos > 0
                                          ? AppTheme.getButtonColor(theme)
                                          : AppTheme.getSubtitleColor(theme),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Quick Theme Toggle
                                IconButton(
                                  onPressed: () {
                                    final nextIndex = (theme.index + 1) %
                                        GameThemeType.values.length;
                                    controller.setTheme(
                                        GameThemeType.values[nextIndex]);
                                  },
                                  icon: Icon(theme.icon, size: 18),
                                  tooltip: 'Switch Theme (${theme.label})',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.getCardBackground(theme),
                                    foregroundColor: Colors.white,
                                    side: isClassic
                                        ? null
                                        : BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.15),
                                          ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Undo Button / Watch Ad for Undo
                                IconButton(
                                  onPressed: () => _handleUndoPress(context),
                                  icon: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      const Icon(Icons.undo, size: 18),
                                      if (controller.bonusUndos > 0)
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 10,
                                            minHeight: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                  tooltip: controller.canUndo
                                      ? 'Undo Move'
                                      : 'Watch Ad for +1 Undo',
                                  style: IconButton.styleFrom(
                                    backgroundColor: controller.canUndo
                                        ? AppTheme.getButtonColor(theme)
                                        : (isClassic
                                            ? AppTheme.emptyCell
                                            : const Color(0x20FFFFFF)),
                                    foregroundColor: Colors.white,
                                    side: isClassic
                                        ? null
                                        : BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.1),
                                          ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Settings Button
                                IconButton(
                                  onPressed: () =>
                                      SettingsDialog.show(context, controller),
                                  icon: const Icon(Icons.settings, size: 18),
                                  tooltip: 'Settings',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.getCardBackground(theme),
                                    foregroundColor: Colors.white,
                                    side: isClassic
                                        ? null
                                        : BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.15),
                                          ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // New Game Button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.getButtonColor(theme),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: isClassic ? 0 : 3,
                                  ),
                                  onPressed: () => _confirmNewGame(context),
                                  child: const Text(
                                    'New Game',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Main Game Board Container with Overlays
                            Expanded(
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    GameBoardWidget(
                                      tiles: controller.tiles,
                                      theme: theme,
                                      onSwipe: (direction) =>
                                          controller.move(direction),
                                    ),
                                    if (controller.isGameOver)
                                      Positioned.fill(
                                        child: GameOverOverlay(
                                          score: controller.score,
                                          theme: theme,
                                          canRewardedContinue:
                                              controller.canRewardedContinue,
                                          onWatchAdContinue: () =>
                                              _handleRewardedContinue(context),
                                          onRestart: controller.startNewGame,
                                        ),
                                      ),
                                    if (controller.isWon &&
                                        !controller.wonDismissed)
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

                            const SizedBox(height: 6),

                            // Footer guide hint
                            GestureDetector(
                              onTap: () =>
                                  SettingsDialog.showHowToPlay(context, theme),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    size: 13,
                                    color: isClassic
                                        ? AppTheme.darkText
                                        : AppTheme.getSubtitleColor(theme),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Swipe to play • How to Play',
                                      style: TextStyle(
                                        color: AppTheme.getSubtitleColor(theme),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Anchored Adaptive Banner Ad at Bottom
                            AdBanner(isAdsRemoved: controller.adsRemoved),
                          ],
                        ),
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
