import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/constants/app_sizes.dart';
import 'board_cell.dart';

/// Widget for displaying the game board
class GameBoard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final availableSize = screenSize.width - (AppSizes.boardPadding * 2);
    
    // Calculate cell size
    final totalGap = (gameState.boardSize - 1) * AppSizes.cellGap;
    var cellSize = (availableSize - totalGap) / gameState.boardSize;
    cellSize = cellSize.clamp(AppSizes.minCellSize, AppSizes.maxCellSize);
    
    final boardWidth = (cellSize * gameState.boardSize) + totalGap;
    
    return Center(
      child: SizedBox(
        width: boardWidth,
        height: boardWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(gameState.boardSize, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(gameState.boardSize, (col) {
                final cell = gameState.board[row][col];
                final isHighlighted = validMoves.contains((row, col));
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: col < gameState.boardSize - 1 ? AppSizes.cellGap : 0,
                    bottom: row < gameState.boardSize - 1 ? AppSizes.cellGap : 0,
                  ),
                  child: BoardCell(
                    cell: cell,
                    size: cellSize,
                    isHighlighted: isHighlighted,
                    onTap: () => onCellTap(row, col),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}

