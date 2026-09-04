import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/achievement.dart';
import '../models/mission.dart';
import '../theme/app_theme.dart';

class MissionsSheet extends StatefulWidget {
  final GameController controller;

  const MissionsSheet({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MissionsSheet(controller: controller),
    );
  }

  @override
  State<MissionsSheet> createState() => _MissionsSheetState();
}

class _MissionsSheetState extends State<MissionsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.controller.theme;
    final isClassic = theme == GameThemeType.classic;

    return ListenableBuilder(
      listenable: widget.controller,
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
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.getButtonColor(theme),
                labelColor: isClassic ? AppTheme.darkText : Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(
                    icon: Badge(
                      isLabelVisible: widget.controller.claimableMissionsCount > 0,
                      label: Text('${widget.controller.claimableMissionsCount}'),
                      child: const Icon(Icons.assignment),
                    ),
                    text: 'Daily Quests',
                  ),
                  Tab(
                    icon: Badge(
                      isLabelVisible: widget.controller.claimableAchievementsCount > 0,
                      label: Text('${widget.controller.claimableAchievementsCount}'),
                      child: const Icon(Icons.emoji_events),
                    ),
                    text: 'Achievements',
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Daily Quests Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.controller.missions.length,
                      itemBuilder: (context, index) {
                        final mission = widget.controller.missions[index];
                        return _buildMissionCard(mission, theme, isClassic);
                      },
                    ),
                    // Achievements Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.controller.achievements.length,
                      itemBuilder: (context, index) {
                        final ach = widget.controller.achievements[index];
                        return _buildAchievementCard(ach, theme, isClassic);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionCard(Mission mission, GameThemeType theme, bool isClassic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isClassic ? const Color(0xFFEDE0C8) : const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: mission.isCompleted && !mission.isClaimed
              ? const Color(0xFF10B981)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.type.title,
                  style: TextStyle(
                    color: isClassic ? AppTheme.darkText : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mission.description,
                  style: TextStyle(
                    color: isClassic ? AppTheme.subtitleText : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    backgroundColor: Colors.white12,
                    color: mission.isCompleted ? const Color(0xFF10B981) : AppTheme.getButtonColor(theme),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mission.current} / ${mission.target}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (mission.isClaimed)
            const Text(
              'Claimed',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            )
          else if (mission.isCompleted)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () => widget.controller.claimMissionReward(mission),
              child: Text('+${mission.type.coinReward} 🪙'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${mission.type.coinReward} 🪙',
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement ach, GameThemeType theme, bool isClassic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isClassic ? const Color(0xFFEDE0C8) : const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ach.isUnlocked && !ach.isClaimed
              ? const Color(0xFFFFD700)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            ach.isUnlocked ? Icons.emoji_events : Icons.lock,
            color: ach.isUnlocked ? const Color(0xFFFFD700) : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ach.title,
                  style: TextStyle(
                    color: isClassic ? AppTheme.darkText : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  ach.description,
                  style: TextStyle(
                    color: isClassic ? AppTheme.subtitleText : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (ach.isClaimed)
            const Text('Unlocked', style: TextStyle(color: Colors.grey, fontSize: 12))
          else if (ach.isUnlocked)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => widget.controller.claimAchievementReward(ach),
              child: Text('+${ach.rewardCoins} 🪙'),
            )
          else
            Text('+${ach.rewardCoins} 🪙', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
