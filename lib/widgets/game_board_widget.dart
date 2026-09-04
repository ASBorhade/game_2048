import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_logic.dart';
import '../models/tile.dart';
import '../theme/app_theme.dart';
import 'game_tile_widget.dart';

class GameBoardWidget extends StatefulWidget {
  final List<Tile> tiles;
  final int gridSize;
  final GameThemeType theme;
  final bool isHammerActive;
  final SwipeDirection? suggestedMove;
  final Function(SwipeDirection) onSwipe;
  final Function(int tileId)? onTileTapped;

  const GameBoardWidget({
    super.key,
    required this.tiles,
    this.gridSize = 4,
    required this.theme,
    this.isHammerActive = false,
    this.suggestedMove,
    required this.onSwipe,
    this.onTileTapped,
  });

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  Offset? _panStart;
  bool _panHandled = false;
  static const double _minSwipeDistance = 25.0;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      widget.onSwipe(SwipeDirection.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      widget.onSwipe(SwipeDirection.down);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      widget.onSwipe(SwipeDirection.left);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      widget.onSwipe(SwipeDirection.right);
    }
  }

  void _onPanStart(DragStartDetails details) {
    _panStart = details.localPosition;
    _panHandled = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStart == null || _panHandled || widget.isHammerActive) return;

    final dx = details.localPosition.dx - _panStart!.dx;
    final dy = details.localPosition.dy - _panStart!.dy;

    if (dx.abs() > _minSwipeDistance || dy.abs() > _minSwipeDistance) {
      _panHandled = true;
      if (dx.abs() > dy.abs()) {
        if (dx > 0) {
          widget.onSwipe(SwipeDirection.right);
        } else {
          widget.onSwipe(SwipeDirection.left);
        }
      } else {
        if (dy > 0) {
          widget.onSwipe(SwipeDirection.down);
        } else {
          widget.onSwipe(SwipeDirection.up);
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _panStart = null;
    _panHandled = false;
  }

  @override
  Widget build(BuildContext context) {
    final isClassic = widget.theme == GameThemeType.classic;
    final size = widget.gridSize;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.opaque,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boardWidth = constraints.maxWidth;
              const boardPadding = 10.0;
              final cellSpacing = size >= 5 ? 6.0 : 8.0;
              final tileSize =
                  (boardWidth - (boardPadding * 2) - (cellSpacing * (size - 1))) /
                      size;

              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.getBoardBackground(widget.theme),
                  borderRadius: BorderRadius.circular(isClassic ? 8 : 16),
                  border: AppTheme.getBoardBorder(widget.theme),
                  boxShadow: AppTheme.getBoardShadow(widget.theme),
                ),
                padding: const EdgeInsets.all(boardPadding),
                child: Stack(
                  children: [
                    // Background NxN empty cell slots
                    for (int r = 0; r < size; r++)
                      for (int c = 0; c < size; c++)
                        Positioned(
                          left: c * (tileSize + cellSpacing),
                          top: r * (tileSize + cellSpacing),
                          width: tileSize,
                          height: tileSize,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getEmptyCellColor(widget.theme),
                              borderRadius: BorderRadius.circular(
                                isClassic ? 6 : (size >= 5 ? 8 : 12),
                              ),
                              border: isClassic
                                  ? null
                                  : Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      width: 1,
                                    ),
                            ),
                          ),
                        ),

                    // Active animated tiles
                    for (final tile in widget.tiles)
                      GameTileWidget(
                        key: ValueKey(tile.id),
                        tile: tile,
                        tileSize: tileSize,
                        cellSpacing: cellSpacing,
                        boardPadding: 0,
                        theme: widget.theme,
                        isTargetable: widget.isHammerActive,
                        onTap: widget.isHammerActive && widget.onTileTapped != null
                            ? () => widget.onTileTapped!(tile.id)
                            : null,
                      ),

                    // Hammer Targeting Banner
                    if (widget.isHammerActive)
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black45, blurRadius: 8),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.gavel, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Tap any tile to SMASH it!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // AI Hint Move Overlay
                    if (widget.suggestedMove != null)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF8B5CF6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lightbulb, size: 16, color: Color(0xFFFFD700)),
                                const SizedBox(width: 6),
                                Text(
                                  'Best Move: ${_directionToString(widget.suggestedMove!)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _directionToString(SwipeDirection dir) {
    switch (dir) {
      case SwipeDirection.left:
        return '← LEFT';
      case SwipeDirection.right:
        return '→ RIGHT';
      case SwipeDirection.up:
        return '↑ UP';
      case SwipeDirection.down:
        return '↓ DOWN';
    }
  }
}
