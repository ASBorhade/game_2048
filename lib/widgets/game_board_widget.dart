import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_logic.dart';
import '../models/tile.dart';
import '../theme/app_theme.dart';
import 'game_tile_widget.dart';

class GameBoardWidget extends StatefulWidget {
  final List<Tile> tiles;
  final GameThemeType theme;
  final Function(SwipeDirection) onSwipe;

  const GameBoardWidget({
    super.key,
    required this.tiles,
    required this.theme,
    required this.onSwipe,
  });

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  Offset? _panStart;
  bool _panHandled = false;
  static const double _minSwipeDistance = 30.0;
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
    if (_panStart == null || _panHandled) return;

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
              const boardPadding = 12.0;
              const cellSpacing = 10.0;
              final tileSize =
                  (boardWidth - (boardPadding * 2) - (cellSpacing * 3)) / 4;

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
                    // Static background 4x4 grid cells
                    for (int r = 0; r < 4; r++)
                      for (int c = 0; c < 4; c++)
                        Positioned(
                          left: c * (tileSize + cellSpacing),
                          top: r * (tileSize + cellSpacing),
                          width: tileSize,
                          height: tileSize,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getEmptyCellColor(widget.theme),
                              borderRadius:
                                  BorderRadius.circular(isClassic ? 6 : 12),
                              border: isClassic
                                  ? null
                                  : Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.05),
                                      width: 1,
                                    ),
                            ),
                          ),
                        ),

                    // Active and animated tiles
                    for (final tile in widget.tiles)
                      GameTileWidget(
                        key: ValueKey(tile.id),
                        tile: tile,
                        tileSize: tileSize,
                        cellSpacing: cellSpacing,
                        boardPadding: 0,
                        theme: widget.theme,
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
}
