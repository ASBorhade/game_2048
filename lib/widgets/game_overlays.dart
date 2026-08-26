import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GameOverOverlay extends StatelessWidget {
  final int score;
  final GameThemeType theme;
  final bool canRewardedContinue;
  final VoidCallback onRestart;
  final VoidCallback? onWatchAdContinue;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.theme,
    required this.onRestart,
    this.canRewardedContinue = false,
    this.onWatchAdContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isClassic = theme == GameThemeType.classic;

    return Container(
      decoration: BoxDecoration(
        color: isClassic
            ? const Color(0xDDFAF8EF)
            : const Color(0xE00B0F19),
        borderRadius: BorderRadius.circular(isClassic ? 8 : 16),
        border: isClassic
            ? null
            : Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Game Over!',
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Final Score: $score',
            style: TextStyle(
              color: isClassic
                  ? AppTheme.subtitleText
                  : AppTheme.getSubtitleColor(theme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (canRewardedContinue && onWatchAdContinue != null) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill, size: 20),
              label: const Text(
                'Watch Ad & Continue',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              onPressed: onWatchAdContinue,
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getButtonColor(theme),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            onPressed: onRestart,
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameWinOverlay extends StatelessWidget {
  final GameThemeType theme;
  final VoidCallback onContinue;
  final VoidCallback onRestart;

  const GameWinOverlay({
    super.key,
    required this.theme,
    required this.onContinue,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isClassic = theme == GameThemeType.classic;

    return Container(
      decoration: BoxDecoration(
        color: isClassic
            ? const Color(0xDDFAF8EF)
            : const Color(0xE00B0F19),
        borderRadius: BorderRadius.circular(isClassic ? 8 : 16),
        border: isClassic
            ? null
            : Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                width: 2,
              ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6), Color(0xFF06B6D4)],
            ).createShader(bounds),
            child: const Text(
              'YOU WIN!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You reached the 2048 tile!',
            style: TextStyle(
              color: isClassic
                  ? AppTheme.subtitleText
                  : AppTheme.getSubtitleColor(theme),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getButtonColor(theme),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                onPressed: onContinue,
                child: const Text(
                  'Keep Going',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isClassic ? AppTheme.darkText : Colors.white,
                  side: BorderSide(
                    color: AppTheme.getButtonColor(theme),
                    width: 1.5,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onRestart,
                child: const Text(
                  'New Game',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
