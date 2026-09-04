import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../theme/app_theme.dart';

class ModeSelectorDialog extends StatelessWidget {
  final GameController controller;

  const ModeSelectorDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (context) => ModeSelectorDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
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
      title: Text(
        'Game Modes & Grid',
        style: TextStyle(
          color: isClassic ? AppTheme.darkText : Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Board Size',
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [3, 4, 5, 6].map((size) {
              final isSelected = controller.gridSize == size;
              return ChoiceChip(
                label: Text('${size}x$size'),
                selected: isSelected,
                selectedColor: AppTheme.getButtonColor(theme),
                backgroundColor: isClassic ? const Color(0xFFEDE0C8) : const Color(0x20FFFFFF),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isClassic ? AppTheme.darkText : Colors.white70),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (selected) {
                  if (selected) {
                    controller.setGridSize(size);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          Text(
            'Game Mode',
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...GameMode.values.map((mode) {
            final isSelected = controller.gameMode == mode;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.getButtonColor(theme).withValues(alpha: 0.2)
                    : (isClassic ? const Color(0xFFEDE0C8) : const Color(0x15FFFFFF)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.getButtonColor(theme) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                dense: true,
                leading: Icon(
                  mode == GameMode.classic
                      ? Icons.all_inclusive
                      : (mode == GameMode.timed ? Icons.timer : Icons.calendar_today),
                  color: isSelected ? AppTheme.getButtonColor(theme) : Colors.grey,
                ),
                title: Text(
                  mode.label,
                  style: TextStyle(
                    color: isClassic ? AppTheme.darkText : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  mode.subtitle,
                  style: TextStyle(
                    color: isClassic ? AppTheme.subtitleText : Colors.white60,
                    fontSize: 11,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20)
                    : null,
                onTap: () {
                  controller.setGameMode(mode);
                  Navigator.of(context).pop();
                },
              ),
            );
          }),
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
}
