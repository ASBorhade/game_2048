import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../theme/app_theme.dart';

class ThemeStoreSheet extends StatelessWidget {
  final GameController controller;

  const ThemeStoreSheet({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeStoreSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final isClassic = theme == GameThemeType.classic;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isClassic ? AppTheme.background : const Color(0xFF131B2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: isClassic
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.palette, color: Color(0xFFFFD700), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Theme Store',
                      style: TextStyle(
                        color: isClassic ? AppTheme.darkText : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${controller.coins}',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: GameThemeType.values.length,
                  itemBuilder: (context, index) {
                    final t = GameThemeType.values[index];
                    final isUnlocked = controller.unlockedThemes.contains(t.name);
                    final isEquipped = controller.theme == t;

                    final bgDeco = AppTheme.getScreenBackground(t);
                    return Container(
                      decoration: BoxDecoration(
                        color: bgDeco.color,
                        gradient: bgDeco.gradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEquipped
                              ? const Color(0xFF10B981)
                              : (isUnlocked ? Colors.white24 : Colors.white10),
                          width: isEquipped ? 2.5 : 1,
                        ),
                        boxShadow: isEquipped
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(t.icon, color: AppTheme.getButtonColor(t), size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  t.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Preview tile samples
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMiniTile(2, t),
                              const SizedBox(width: 4),
                              _buildMiniTile(8, t),
                              const SizedBox(width: 4),
                              _buildMiniTile(2048, t),
                            ],
                          ),
                          // Button: Equip / Buy / Equipped
                          if (isEquipped)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'EQUIPPED',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            )
                          else if (isUnlocked)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.getButtonColor(t),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => controller.setTheme(t),
                              child: const Text('Equip', style: TextStyle(fontSize: 12)),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: controller.coins >= t.coinCost
                                  ? () {
                                      controller.purchaseTheme(t);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${t.label} unlocked!')),
                                      );
                                    }
                                  : null,
                              child: Text(
                                '${t.coinCost} 🪙',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniTile(int value, GameThemeType theme) {
    final style = AppTheme.getTileStyle(value, theme);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: style.gradient,
        borderRadius: BorderRadius.circular(6),
        border: style.border,
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: style.textColor,
          fontSize: value >= 1000 ? 8 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
