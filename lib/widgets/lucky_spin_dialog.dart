import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/power_up.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

class SpinPrize {
  final String label;
  final int coins;
  final PowerUpType? powerUp;
  final Color color;

  const SpinPrize({
    required this.label,
    this.coins = 0,
    this.powerUp,
    required this.color,
  });
}

class LuckySpinDialog extends StatefulWidget {
  final GameController controller;

  const LuckySpinDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (context) => LuckySpinDialog(controller: controller),
    );
  }

  @override
  State<LuckySpinDialog> createState() => _LuckySpinDialogState();
}

class _LuckySpinDialogState extends State<LuckySpinDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _animation;
  double _currentRotation = 0;
  bool _isSpinning = false;
  SpinPrize? _wonPrize;

  static const List<SpinPrize> _prizes = [
    SpinPrize(label: '10 🪙', coins: 10, color: Color(0xFF3B82F6)),
    SpinPrize(label: '🔨 Hammer', powerUp: PowerUpType.hammer, color: Color(0xFFEF4444)),
    SpinPrize(label: '15 🪙', coins: 15, color: Color(0xFF10B981)),
    SpinPrize(label: '💡 Hint', powerUp: PowerUpType.hint, color: Color(0xFF8B5CF6)),
    SpinPrize(label: '25 🪙', coins: 25, color: Color(0xFFF59E0B)),
    SpinPrize(label: '🔀 Shuffle', powerUp: PowerUpType.shuffle, color: Color(0xFFEC4899)),
    SpinPrize(label: '↩️ Undo', powerUp: PowerUpType.undo, color: Color(0xFF06B6D4)),
    SpinPrize(label: '🏆 50 🪙', coins: 50, color: Color(0xFFFFD700)),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    final rand = Random();
    final winningIndex = rand.nextInt(_prizes.length);
    final segmentAngle = (2 * pi) / _prizes.length;

    // Segment i center is at angle (-pi/2 + (i + 0.5) * segmentAngle).
    // Rotating clockwise by angle brings the center to -pi/2 (top pointer) when:
    // angle (mod 2*pi) == (2 * pi - (winningIndex + 0.5) * segmentAngle) % (2 * pi)
    final targetMod = (2 * pi - ((winningIndex + 0.5) * segmentAngle)) % (2 * pi);
    final currentMod = _currentRotation % (2 * pi);
    double diff = targetMod - currentMod;
    if (diff <= 0) {
      diff += 2 * pi;
    }

    final extraRounds = 5 + rand.nextInt(3);
    final totalDelta = (extraRounds * 2 * pi) + diff;
    final endRotation = _currentRotation + totalDelta;

    setState(() {
      _isSpinning = true;
      _wonPrize = null;
    });

    _animation = Tween<double>(
      begin: _currentRotation,
      end: endRotation,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.forward(from: 0.0).then((_) {
      _currentRotation = endRotation % (2 * pi);
      final prize = _prizes[winningIndex];

      widget.controller.spinPrizeEarned(
        prize: prize.label,
        coinAmount: prize.coins,
        powerUp: prize.powerUp,
      );

      setState(() {
        _isSpinning = false;
        _wonPrize = prize;
      });
    });
  }

  void _handleSpinWithAd() {
    widget.controller.setAdLoading(true);
    AdService().showRewardedAd(
      onRewarded: () {
        widget.controller.setAdLoading(false);
        _spinWheel();
      },
      onFailed: () {
        widget.controller.setAdLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad is loading, please try again shortly.')),
        );
      },
      onDismissed: () {
        widget.controller.setAdLoading(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.controller.theme;
    final isClassic = theme == GameThemeType.classic;

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
          const Icon(Icons.casino, color: Color(0xFFFFD700)),
          const SizedBox(width: 8),
          Text(
            'Lucky Wheel',
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
          // Wheel Stack
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    final angle = _isSpinning
                        ? _animation.value
                        : _currentRotation;
                    return Transform.rotate(
                      angle: angle,
                      child: CustomPaint(
                        size: const Size(240, 240),
                        painter: _WheelPainter(prizes: _prizes),
                      ),
                    );
                  },
                ),
                // Center Pointer Pin
                Positioned(
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black45, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.arrow_drop_down, color: Colors.red, size: 20),
                  ),
                ),
                // Center Hub
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700), width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.stars, color: Color(0xFFFFD700), size: 22),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_wonPrize != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Text(
                '🎉 You Won: ${_wonPrize!.label}!',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

          const SizedBox(height: 16),

          if (widget.controller.canSpinToday)
            ElevatedButton.icon(
              icon: const Icon(Icons.casino, size: 18),
              label: const Text('Free Daily Spin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getButtonColor(theme),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSpinning ? null : _spinWheel,
            )
          else ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isClassic ? const Color(0xFFEDE0C8) : const Color(0x18FFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✅ Free Daily Spin Claimed',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.play_circle_fill, size: 18),
              label: const Text('Watch Ad for Extra Spin 🎬'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSpinning ? null : _handleSpinWithAd,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSpinning ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<SpinPrize> prizes;

  _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final arcAngle = (2 * pi) / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * arcAngle - (pi / 2);
      final paint = Paint()
        ..color = prizes[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcAngle,
        true,
        borderPaint,
      );

      // Draw segment label
      final textAngle = startAngle + (arcAngle / 2);
      final textOffset = Offset(
        center.dx + (radius * 0.65) * cos(textAngle),
        center.dy + (radius * 0.65) * sin(textAngle),
      );

      final textSpan = TextSpan(
        text: prizes[i].label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle + (pi / 2));
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
