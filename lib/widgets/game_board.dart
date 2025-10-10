import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/constants/app_sizes.dart';
import 'board_cell.dart';

/// Widget for displaying the game board with staggered reveal animation
class GameBoard extends StatefulWidget {
  final GameState gameState;
  final List<(int, int)> validMoves;
  final Function(int row, int col) onCellTap;
  
  const GameBoard({
    super.key,
    required this.gameState,
    required this.validMoves,
    required this.onCellTap,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<List<Animation<double>>> _cellAnimations;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: AppSizes.animationSlow + (widget.gameState.boardSize * 30),
      ),
    );

    // Create staggered animations for each cell
    _cellAnimations = List.generate(
      widget.gameState.boardSize,
      (row) => List.generate(
        widget.gameState.boardSize,
        (col) {
          // Calculate delay based on distance from top-left corner
          final distance = row + col;
          final maxDistance = (widget.gameState.boardSize - 1) * 2;
          final delayFraction = distance / maxDistance * 0.7;
          
          return Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                delayFraction,
                delayFraction + 0.3,
                curve: Curves.easeOutBack,
              ),
            ),
          );
        },
      ),
    );

    _animationsInitialized = true;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_animationsInitialized) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final availableSize = screenSize.width - (AppSizes.boardPadding * 2);
    
    // Calculate cell size
    final totalGap = (widget.gameState.boardSize - 1) * AppSizes.cellGap;
    var cellSize = (availableSize - totalGap) / widget.gameState.boardSize;
    cellSize = cellSize.clamp(AppSizes.minCellSize, AppSizes.maxCellSize);
    
    final boardWidth = (cellSize * widget.gameState.boardSize) + totalGap;
    
    return Center(
      child: SizedBox(
        width: boardWidth,
        height: boardWidth,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.gameState.boardSize, (row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.gameState.boardSize, (col) {
                    final cell = widget.gameState.board[row][col];
                    final isHighlighted = widget.validMoves.contains((row, col));
                    final animation = _cellAnimations[row][col];
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        right: col < widget.gameState.boardSize - 1 ? AppSizes.cellGap : 0,
                        bottom: row < widget.gameState.boardSize - 1 ? AppSizes.cellGap : 0,
                      ),
                      child: Transform.scale(
                        scale: animation.value,
                        child: Opacity(
                          opacity: animation.value,
                          child: BoardCell(
                            cell: cell,
                            size: cellSize,
                            isHighlighted: isHighlighted,
                            onTap: () => widget.onCellTap(row, col),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

