import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/ad_config.dart';
import '../game/game_controller.dart';
import '../theme/app_theme.dart';
import 'theme_store_sheet.dart';

class SettingsDialog extends StatelessWidget {
  final GameController controller;

  const SettingsDialog({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(controller: controller),
    );
  }

  static void showHowToPlay(BuildContext context, GameThemeType theme) {
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
          'HOW TO PLAY',
          style: TextStyle(
            color: isClassic ? AppTheme.darkText : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Swipe in any direction (UP, DOWN, LEFT, RIGHT) or use Arrow keys to slide tiles.',
              style: TextStyle(
                color: isClassic
                    ? AppTheme.darkText
                    : AppTheme.getSubtitleColor(theme),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When two tiles with the same number collide, they fuse into one!',
              style: TextStyle(
                color: isClassic
                    ? AppTheme.darkText
                    : AppTheme.getSubtitleColor(theme),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• 2 + 2 = 4\n• 4 + 4 = 8\n• 8 + 8 = 16\n• ... 1024 + 1024 = 2048!',
              style: TextStyle(
                color: AppTheme.getButtonColor(theme),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Join the numbers to reach the legendary 2048 tile!',
              style: TextStyle(
                color: isClassic ? AppTheme.darkText : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got It',
              style: TextStyle(
                color: AppTheme.getButtonColor(theme),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onRemoveAdsTapped(BuildContext context) {
    if (controller.adsRemoved) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: controller.theme == GameThemeType.classic
            ? AppTheme.background
            : const Color(0xFF131B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Remove Ads'),
        content: const Text(
          'Enjoy an ad-free experience without banners and interstitials.\n\n(TODO: Configure Google Play In-App Billing product ID in production)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getButtonColor(controller.theme),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.purchaseRemoveAds();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ads removed successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Remove Ads (Demo)'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AdConfig.privacyPolicyUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Privacy Policy: ${AdConfig.privacyPolicyUrl}'),
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Privacy Policy: ${AdConfig.privacyPolicyUrl}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final theme = controller.theme;
        final isClassic = theme == GameThemeType.classic;

        return AlertDialog(
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
            'Settings',
            style: TextStyle(
              color: isClassic ? AppTheme.darkText : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Store Navigation Tile
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.palette,
                    color: AppTheme.getButtonColor(theme),
                  ),
                  title: Text(
                    'Theme Store',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Current: ${controller.theme.label} (Tap to change in Store)',
                    style: TextStyle(
                      color: isClassic
                          ? AppTheme.subtitleText
                          : AppTheme.getSubtitleColor(theme),
                      fontSize: 11,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isClassic ? AppTheme.darkText : Colors.white60,
                    size: 20,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    ThemeStoreSheet.show(context, controller);
                  },
                ),
                const Divider(color: Colors.white12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Sound Effects',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: controller.isSoundEnabled,
                  activeTrackColor: AppTheme.getButtonColor(theme),
                  activeThumbColor: Colors.white,
                  onChanged: controller.toggleSound,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Vibration / Haptics',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: controller.isVibrationEnabled,
                  activeTrackColor: AppTheme.getButtonColor(theme),
                  activeThumbColor: Colors.white,
                  onChanged: controller.toggleVibration,
                ),
                const Divider(color: Colors.white12),
                // Remove Ads Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    controller.adsRemoved
                        ? Icons.check_circle
                        : Icons.block,
                    color: controller.adsRemoved
                        ? const Color(0xFF10B981)
                        : AppTheme.getButtonColor(theme),
                  ),
                  title: Text(
                    controller.adsRemoved ? 'Ads Removed' : 'Remove Ads',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    controller.adsRemoved
                        ? 'Premium active'
                        : 'Disable banners & interstitials',
                    style: TextStyle(
                      color: isClassic
                          ? AppTheme.subtitleText
                          : AppTheme.getSubtitleColor(theme),
                      fontSize: 11,
                    ),
                  ),
                  onTap: () => _onRemoveAdsTapped(context),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.help_outline,
                      color: AppTheme.getButtonColor(theme)),
                  title: Text(
                    'How to Play',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    showHowToPlay(context, theme);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.privacy_tip_outlined,
                      color: AppTheme.getButtonColor(theme)),
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _launchPrivacyPolicy(context),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline,
                      color: AppTheme.getButtonColor(theme)),
                  title: Text(
                    'About 2048 Neo',
                    style: TextStyle(
                      color: isClassic ? AppTheme.darkText : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    showAboutDialog(
                      context: context,
                      applicationName: '2048 Neo',
                      applicationVersion: '2.0.0',
                      applicationLegalese:
                          'A modern Neo-Aurora Glassmorphism 2048 game with AdMob monetization.',
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.getButtonColor(theme),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
