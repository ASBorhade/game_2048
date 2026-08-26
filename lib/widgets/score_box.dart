import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScoreBox extends StatefulWidget {
  final String title;
  final int score;
  final int addedScore;
  final GameThemeType theme;
  final IconData? icon;

  const ScoreBox({
    super.key,
    required this.title,
    required this.score,
    required this.theme,
    this.addedScore = 0,
    this.icon,
  });

  @override
  State<ScoreBox> createState() => _ScoreBoxState();
}

class _ScoreBoxState extends State<ScoreBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _addScoreController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _lastAdded = 0;

  @override
  void initState() {
    super.initState();
    _addScoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _addScoreController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.2),
    ).animate(
      CurvedAnimation(parent: _addScoreController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant ScoreBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.addedScore > 0 && widget.addedScore != oldWidget.addedScore) {
      _lastAdded = widget.addedScore;
      _addScoreController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _addScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isClassic = widget.theme == GameThemeType.classic;

    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(widget.theme),
        borderRadius: BorderRadius.circular(10),
        border: isClassic
            ? null
            : Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
        boxShadow: isClassic
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null && !isClassic) ...[
                    Icon(
                      widget.icon,
                      size: 11,
                      color: AppTheme.getButtonColor(widget.theme),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    widget.title.toUpperCase(),
                    style: TextStyle(
                      color: isClassic
                          ? AppTheme.scoreLabelColor
                          : AppTheme.getSubtitleColor(widget.theme),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.score}',
                style: TextStyle(
                  color: isClassic ? Colors.white : AppTheme.getTextColor(widget.theme),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          if (_lastAdded > 0)
            Positioned(
              top: -4,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.getButtonColor(widget.theme),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$_lastAdded',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
