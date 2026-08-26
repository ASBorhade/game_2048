import 'package:flutter/material.dart';
import '../models/tile.dart';
import '../theme/app_theme.dart';

class GameTileWidget extends StatefulWidget {
  final Tile tile;
  final double tileSize;
  final double cellSpacing;
  final double boardPadding;
  final GameThemeType theme;

  const GameTileWidget({
    super.key,
    required this.tile,
    required this.tileSize,
    required this.cellSpacing,
    required this.boardPadding,
    required this.theme,
  });

  @override
  State<GameTileWidget> createState() => _GameTileWidgetState();
}

class _GameTileWidgetState extends State<GameTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    if (widget.tile.isNew) {
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 70),
        TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(
        parent: _popController,
        curve: Curves.easeOut,
      ));
      _popController.forward();
    } else if (widget.tile.isMerged) {
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(
        parent: _popController,
        curve: Curves.easeOut,
      ));
      _popController.forward();
    } else {
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void didUpdateWidget(covariant GameTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isMerged && !oldWidget.tile.isMerged) {
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(
        parent: _popController,
        curve: Curves.easeOut,
      ));
      _popController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.boardPadding +
        widget.tile.col * (widget.tileSize + widget.cellSpacing);
    final top = widget.boardPadding +
        widget.tile.row * (widget.tileSize + widget.cellSpacing);

    final style = AppTheme.getTileStyle(widget.tile.value, widget.theme);
    final isClassic = widget.theme == GameThemeType.classic;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOutCubic,
      left: left,
      top: top,
      width: widget.tileSize,
      height: widget.tileSize,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: style.gradient,
            borderRadius: BorderRadius.circular(isClassic ? 6 : 12),
            border: style.border,
            boxShadow: style.shadows,
          ),
          alignment: Alignment.center,
          child: Text(
            '${widget.tile.value}',
            style: TextStyle(
              color: style.textColor,
              fontSize: AppTheme.getTileFontSize(
                widget.tile.value,
                widget.tileSize,
              ),
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}
