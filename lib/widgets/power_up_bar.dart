import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/power_up.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

class PowerUpBar extends StatelessWidget {
  final GameController controller;

  const PowerUpBar({
    super.key,
    required this.controller,
  });

  void _onPowerUpTapped(BuildContext context, PowerUpType type) {
    if (controller.isGameOver || controller.isAnimating) return;

    final count = controller.inventory.getCount(type);

    if (count > 0) {
      switch (type) {
        case PowerUpType.undo:
          controller.undo();
          break;
        case PowerUpType.hammer:
          controller.toggleHammerMode();
          break;
        case PowerUpType.shuffle:
          controller.useShuffle();
          break;
        case PowerUpType.hint:
          controller.useAIHint();
          break;
      }
    } else {
      _showBuyPowerUpDialog(context, type);
    }
  }

  void _showBuyPowerUpDialog(BuildContext context, PowerUpType type) {
    final theme = controller.theme;
    final isClassic = theme == GameThemeType.classic;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
        title: Row(
          children: [
            _getPowerUpIcon(type, size: 24, color: AppTheme.getButtonColor(theme)),
            const SizedBox(width: 8),
            Text(
              'Get ${type.title}',
              style: TextStyle(
                color: isClassic ? AppTheme.darkText : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type.description,
              style: TextStyle(
                color: isClassic
                    ? AppTheme.subtitleText
                    : AppTheme.getSubtitleColor(theme),
              ),
            ),
            const SizedBox(height: 16),
            if (controller.inventory.isFull(type))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Inventory is full (Max 4). Use one first!',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Price: ${type.coinCost} Coins',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${controller.inventory.getCount(type)}/4 Owned',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          // Option 1: Buy with coins
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getButtonColor(theme),
              foregroundColor: Colors.white,
            ),
            onPressed: (!controller.inventory.isFull(type) && controller.coins >= type.coinCost)
                ? () {
                    Navigator.of(ctx).pop();
                    controller.buyPowerUp(type);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${type.title} purchased!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                : null,
            child: Text(controller.inventory.isFull(type) ? 'Full' : 'Buy (${type.coinCost} 🪙)'),
          ),
          // Option 2: Watch Ad for free item
          OutlinedButton.icon(
            icon: const Icon(Icons.play_circle_fill, size: 16),
            label: const Text('Free with Ad'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981)),
            ),
            onPressed: controller.inventory.isFull(type)
                ? null
                : () {
                    Navigator.of(ctx).pop();
                    controller.setAdLoading(true);
                    AdService().showRewardedAd(
                      onRewarded: () {
                        controller.setAdLoading(false);
                        controller.inventory.add(type, 1);
                        controller.storageService.saveInventory(controller.inventory);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Free ${type.title} unlocked!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      onFailed: () {
                        controller.setAdLoading(false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ad is loading, please try again shortly.'),
                          ),
                        );
                      },
                      onDismissed: () {
                        controller.setAdLoading(false);
                      },
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _getPowerUpIcon(PowerUpType type, {double size = 18, Color? color}) {
    switch (type) {
      case PowerUpType.undo:
        return Icon(Icons.undo, size: size, color: color);
      case PowerUpType.hammer:
        return Icon(Icons.gavel, size: size, color: color);
      case PowerUpType.shuffle:
        return Icon(Icons.shuffle, size: size, color: color);
      case PowerUpType.hint:
        return Icon(Icons.lightbulb, size: size, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final isClassic = theme == GameThemeType.classic;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(theme),
        borderRadius: BorderRadius.circular(16),
        border: isClassic
            ? null
            : Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
        boxShadow: isClassic
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: PowerUpType.values.map((type) {
          final count = controller.inventory.getCount(type);
          final isHammerHighlight =
              type == PowerUpType.hammer && controller.isHammerActive;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onPowerUpTapped(context, type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isHammerHighlight
                      ? const Color(0xFFEF4444)
                      : (count > 0
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                  border: isHammerHighlight
                      ? Border.all(color: Colors.white, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _getPowerUpIcon(
                          type,
                          size: 20,
                          color: isHammerHighlight
                              ? Colors.white
                              : (count > 0
                                  ? AppTheme.getButtonColor(theme)
                                  : (isClassic ? Colors.grey : Colors.white38)),
                        ),
                        Positioned(
                          top: -6,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: count > 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6B7280),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              count > 0 ? '$count' : '+',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.title,
                      style: TextStyle(
                        color: isHammerHighlight
                            ? Colors.white
                            : (isClassic
                                ? AppTheme.darkText
                                : (count > 0 ? Colors.white : Colors.white60)),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
