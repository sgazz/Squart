import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/game_constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/game_board.dart';
import '../providers/game_provider.dart';

/// Main game screen
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(isDark),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Squart'),
          actions: [
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () => _showPauseMenu(context),
            ),
          ],
        ),
        body: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final gameState = gameProvider.gameState;
            
            if (gameState == null) {
              return const Center(
                child: Text('No active game'),
              );
            }
            
            // Get valid moves if hints are enabled
            final validMoves = gameState.settings.showHints && !gameState.isFinished
                ? gameProvider.getValidMoves()
                : <(int, int)>[];
            
            return SafeArea(
              child: Column(
                children: [
                  // Player Info Section
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.spaceM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Blue Player
                        Expanded(
                          child: _buildPlayerInfo(
                            context,
                            'Blue',
                            GameConstants.playerBlue,
                            AppColors.blueToken,
                            gameState.blueTimeRemaining,
                            gameState.isBluesTurn,
                            gameState.settings.hasTimer,
                          ),
                        ),
                        
                        const SizedBox(width: AppSizes.spaceM),
                        
                        // Red Player
                        Expanded(
                          child: _buildPlayerInfo(
                            context,
                            gameProvider.isPlayerVsAI ? 'AI' : 'Red',
                            GameConstants.playerRed,
                            AppColors.redToken,
                            gameState.redTimeRemaining,
                            gameState.isRedsTurn,
                            gameState.settings.hasTimer,
                            isAI: gameProvider.isPlayerVsAI,
                            isAIThinking: gameProvider.isAIThinking,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Game Board
                  Expanded(
                    child: Center(
                      child: GameBoard(
                        gameState: gameState,
                        validMoves: validMoves,
                        onCellTap: (row, col) {
                          if (!gameState.isFinished) {
                            gameProvider.makeMove(row, col);
                          }
                        },
                      ),
                    ),
                  ),
                  
                  // Game Info
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.spaceM),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(AppSizes.spaceM),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Moves: ${gameState.tokens.length}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (gameState.settings.showHints && !gameState.isFinished)
                            Text(
                              'Valid moves: ${validMoves.length}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildPlayerInfo(
    BuildContext context,
    String name,
    String player,
    Color color,
    int timeRemaining,
    bool isActive,
    bool hasTimer, {
    bool isAI = false,
    bool isAIThinking = false,
  }) {
    final isWarning = timeRemaining <= GameConstants.timerWarningThreshold;
    
    return GlassContainer(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      borderColor: isActive ? color : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (hasTimer) ...[
            const SizedBox(height: AppSizes.spaceS),
            Text(
              _formatTime(timeRemaining),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isWarning ? AppColors.timerWarning : null,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          // AI Thinking Indicator (as badge, doesn't push layout)
          if (isAI && isAIThinking) ...[
            const SizedBox(height: AppSizes.spaceXS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceS,
                vertical: AppSizes.spaceXS,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(color: color.withOpacity(0.5), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceXS),
                  Text(
                    'Thinking',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  void _showPauseMenu(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final gameState = gameProvider.gameState;
    
    if (gameState == null) return;
    
    if (gameState.isFinished) {
      _showGameOverDialog(context);
      return;
    }
    
    gameProvider.pauseGame();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Paused'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_outline, size: 64),
            const SizedBox(height: AppSizes.spaceM),
            const Text('Game is paused'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameProvider.resumeGame();
            },
            child: const Text('Resume'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              gameProvider.endGame();
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
  
  void _showGameOverDialog(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final gameState = gameProvider.gameState;
    
    if (gameState == null || !gameState.isFinished) return;
    
    final winner = gameState.winner;
    final winnerName = winner == GameConstants.playerBlue ? 'Blue' : 'Red';
    final winnerColor = winner == GameConstants.playerBlue 
        ? AppColors.blueToken 
        : AppColors.redToken;
    final reason = gameState.winReason == GameConstants.winTimeout
        ? 'Opponent ran out of time'
        : 'Opponent has no valid moves';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          title: Text(
            '$winnerName Wins!',
            style: TextStyle(color: winnerColor),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: (1 - value) * 0.5,
                      child: Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: winnerColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spaceL),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSizes.spaceM),
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: winnerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Text(
                  'Total moves: ${gameState.tokens.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                gameProvider.endGame();
              },
              child: const Text('Back to Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                gameProvider.startNewGame(gameState.settings);
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}

