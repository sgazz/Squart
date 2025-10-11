import 'dart:math';
import '../models/game_state.dart';
import '../models/ai_difficulty.dart';
import '../models/ai_move.dart';
import '../core/constants/game_constants.dart';

/// Service for AI opponent logic
class AIService {
  final Random _random = Random();
  
  /// Calculate the best move for AI based on difficulty
  Future<AIMove> calculateMove(
    GameState state,
    AIDifficulty difficulty,
  ) async {
    // Get all valid moves
    final validMoves = state.getValidMoves();
    
    if (validMoves.isEmpty) {
      throw StateError('No valid moves available for AI');
    }
    
    // Add thinking delay to make it feel more natural
    final (minDelay, maxDelay) = difficulty.thinkingDelayRange;
    final delay = minDelay + _random.nextInt(maxDelay - minDelay);
    await Future.delayed(Duration(milliseconds: delay));
    
    // Calculate move based on difficulty
    AIMove move;
    switch (difficulty) {
      case AIDifficulty.easy:
        move = _calculateEasyMove(state, validMoves);
        break;
      case AIDifficulty.medium:
        move = _calculateMediumMove(state, validMoves);
        break;
      case AIDifficulty.hard:
        move = _calculateHardMove(state, validMoves);
        break;
    }
    
    return move;
  }
  
  /// Easy AI: 60% greedy, 30% center, 10% random
  AIMove _calculateEasyMove(GameState state, List<(int, int)> validMoves) {
    final roll = _random.nextDouble();
    
    if (roll < 0.6) {
      // 60% - Greedy: minimize opponent's options
      return _greedyMove(state, validMoves);
    } else if (roll < 0.9) {
      // 30% - Center preference
      return _centerMove(state, validMoves);
    } else {
      // 10% - Random
      return _randomMove(validMoves);
    }
  }
  
  /// Medium AI: Minimax with depth 3
  AIMove _calculateMediumMove(GameState state, List<(int, int)> validMoves) {
    return _minimaxMove(state, validMoves, AIDifficulty.medium.minimaxDepth);
  }
  
  /// Hard AI: Minimax with alpha-beta pruning, depth 5
  AIMove _calculateHardMove(GameState state, List<(int, int)> validMoves) {
    return _minimaxMove(state, validMoves, AIDifficulty.hard.minimaxDepth, useAlphaBeta: true);
  }
  
  /// Random move selection
  AIMove _randomMove(List<(int, int)> validMoves) {
    final move = validMoves[_random.nextInt(validMoves.length)];
    return AIMove(
      row: move.$1,
      col: move.$2,
      score: 0.0,
      reasoning: 'Random move',
    );
  }
  
  /// Center-preferring move
  AIMove _centerMove(GameState state, List<(int, int)> validMoves) {
    final center = state.boardSize / 2.0;
    
    // Score moves by distance to center (closer is better)
    double bestScore = double.infinity;
    (int, int)? bestMove;
    
    for (final move in validMoves) {
      final distance = sqrt(
        pow(move.$1 - center, 2) + pow(move.$2 - center, 2)
      );
      
      if (distance < bestScore) {
        bestScore = distance;
        bestMove = move;
      }
    }
    
    // Fallback to random if no move found
    if (bestMove == null) {
      return _randomMove(validMoves);
    }
    
    return AIMove(
      row: bestMove.$1,
      col: bestMove.$2,
      score: -bestScore,
      reasoning: 'Center preference',
    );
  }
  
  /// Greedy move: minimize opponent's options
  AIMove _greedyMove(GameState state, List<(int, int)> validMoves) {
    int bestScore = -1;
    (int, int)? bestMove;
    
    for (final move in validMoves) {
      // Simulate placing the token
      final simState = _simulateMove(state, move.$1, move.$2);
      
      // Count opponent's remaining moves
      final opponentMoves = simState.getValidMoves().length;
      
      // Lower opponent moves = better for us
      final score = -opponentMoves;
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    // Fallback to random if no move found
    if (bestMove == null) {
      return _randomMove(validMoves);
    }
    
    return AIMove(
      row: bestMove.$1,
      col: bestMove.$2,
      score: bestScore.toDouble(),
      reasoning: 'Greedy: minimize opponent options',
    );
  }
  
  /// Minimax algorithm with optional alpha-beta pruning
  AIMove _minimaxMove(
    GameState state,
    List<(int, int)> validMoves,
    int depth, {
    bool useAlphaBeta = false,
  }) {
    double bestScore = double.negativeInfinity;
    (int, int)? bestMove;
    
    // Sort moves for better alpha-beta pruning
    if (useAlphaBeta) {
      validMoves = _orderMoves(state, validMoves);
    }
    
    for (final move in validMoves) {
      final simState = _simulateMove(state, move.$1, move.$2);
      
      final score = useAlphaBeta
          ? _alphabeta(simState, depth - 1, double.negativeInfinity, double.infinity, false)
          : _minimax(simState, depth - 1, false);
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    // Fallback to random if no move found
    if (bestMove == null) {
      return _randomMove(validMoves);
    }
    
    return AIMove(
      row: bestMove.$1,
      col: bestMove.$2,
      score: bestScore,
      reasoning: useAlphaBeta ? 'Alpha-beta pruning' : 'Minimax',
    );
  }
  
  /// Minimax recursive evaluation
  double _minimax(GameState state, int depth, bool isMaximizing) {
    // Terminal conditions
    if (depth == 0 || state.isFinished) {
      return _evaluatePosition(state);
    }
    
    final validMoves = state.getValidMoves();
    
    // No moves = game over
    if (validMoves.isEmpty) {
      return isMaximizing ? double.negativeInfinity : double.infinity;
    }
    
    if (isMaximizing) {
      double maxScore = double.negativeInfinity;
      for (final move in validMoves) {
        final simState = _simulateMove(state, move.$1, move.$2);
        final score = _minimax(simState, depth - 1, false);
        maxScore = max(maxScore, score);
      }
      return maxScore;
    } else {
      double minScore = double.infinity;
      for (final move in validMoves) {
        final simState = _simulateMove(state, move.$1, move.$2);
        final score = _minimax(simState, depth - 1, true);
        minScore = min(minScore, score);
      }
      return minScore;
    }
  }
  
  /// Alpha-beta pruning algorithm
  double _alphabeta(GameState state, int depth, double alpha, double beta, bool isMaximizing) {
    // Terminal conditions
    if (depth == 0 || state.isFinished) {
      return _evaluatePosition(state);
    }
    
    final validMoves = state.getValidMoves();
    
    // No moves = game over
    if (validMoves.isEmpty) {
      return isMaximizing ? double.negativeInfinity : double.infinity;
    }
    
    if (isMaximizing) {
      double maxScore = double.negativeInfinity;
      for (final move in validMoves) {
        final simState = _simulateMove(state, move.$1, move.$2);
        final score = _alphabeta(simState, depth - 1, alpha, beta, false);
        maxScore = max(maxScore, score);
        alpha = max(alpha, score);
        if (beta <= alpha) {
          break; // Beta cutoff
        }
      }
      return maxScore;
    } else {
      double minScore = double.infinity;
      for (final move in validMoves) {
        final simState = _simulateMove(state, move.$1, move.$2);
        final score = _alphabeta(simState, depth - 1, alpha, beta, true);
        minScore = min(minScore, score);
        beta = min(beta, score);
        if (beta <= alpha) {
          break; // Alpha cutoff
        }
      }
      return minScore;
    }
  }
  
  /// Evaluate board position (positive = good for AI, negative = good for opponent)
  double _evaluatePosition(GameState state) {
    // If game is finished, return extreme values
    if (state.isFinished) {
      if (state.winner == GameConstants.playerRed) {
        return 1000.0; // AI wins (assuming AI is always Red)
      } else {
        return -1000.0; // AI loses
      }
    }
    
    // Count available moves for each player
    final currentPlayerMoves = state.getValidMoves().length;
    
    // Simulate opponent's turn to count their moves
    final opponentState = state.copyWith(
      currentPlayer: state.isBluesTurn 
        ? GameConstants.playerRed 
        : GameConstants.playerBlue,
    );
    final opponentMoves = opponentState.getValidMoves().length;
    
    // Basic heuristic: mobility difference
    double score = (currentPlayerMoves - opponentMoves).toDouble();
    
    // Bonus for center control
    score += _evaluateCenterControl(state) * 0.5;
    
    // Bonus for blocking opponent
    score += _evaluateBlocking(state) * 0.3;
    
    return state.isRedsTurn ? score : -score; // Flip for Blue's perspective
  }
  
  /// Evaluate center control
  double _evaluateCenterControl(GameState state) {
    final center = state.boardSize / 2.0;
    double score = 0.0;
    
    for (final token in state.tokens) {
      if (token.player == state.currentPlayer) {
        final distance = sqrt(
          pow(token.row - center, 2) + pow(token.col - center, 2)
        );
        score += (state.boardSize - distance);
      }
    }
    
    return score;
  }
  
  /// Evaluate blocking potential
  double _evaluateBlocking(GameState state) {
    // Count cells adjacent to opponent's tokens
    double score = 0.0;
    final opponent = state.isBluesTurn 
      ? GameConstants.playerRed 
      : GameConstants.playerBlue;
    
    for (int row = 0; row < state.boardSize; row++) {
      for (int col = 0; col < state.boardSize; col++) {
        final cell = state.board[row][col];
        if (cell.occupiedBy == opponent) {
          // Check adjacent cells
          if (_hasAdjacentToken(state, row, col, state.currentPlayer)) {
            score += 1.0;
          }
        }
      }
    }
    
    return score;
  }
  
  /// Check if position has adjacent token of given player
  bool _hasAdjacentToken(GameState state, int row, int col, String player) {
    final directions = [
      (-1, 0), (1, 0), (0, -1), (0, 1), // orthogonal
    ];
    
    for (final (dr, dc) in directions) {
      final newRow = row + dr;
      final newCol = col + dc;
      
      if (state.isValidPosition(newRow, newCol)) {
        if (state.board[newRow][newCol].occupiedBy == player) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Order moves for better alpha-beta pruning (center moves first)
  List<(int, int)> _orderMoves(GameState state, List<(int, int)> moves) {
    final center = state.boardSize / 2.0;
    
    final sortedMoves = List<(int, int)>.from(moves);
    sortedMoves.sort((a, b) {
      final distA = sqrt(pow(a.$1 - center, 2) + pow(a.$2 - center, 2));
      final distB = sqrt(pow(b.$1 - center, 2) + pow(b.$2 - center, 2));
      return distA.compareTo(distB);
    });
    
    return sortedMoves;
  }
  
  /// Simulate a move without modifying original state
  GameState _simulateMove(GameState state, int row, int col) {
    // Create token
    final orientation = state.isBluesTurn
        ? GameConstants.orientationHorizontal
        : GameConstants.orientationVertical;
    
    // Copy board
    final newBoard = state.board.map((r) => r.map((c) => c).toList()).toList();
    
    // Place token on board
    if (orientation == GameConstants.orientationHorizontal) {
      newBoard[row][col] = newBoard[row][col].copyWith(
        occupiedBy: state.currentPlayer,
      );
      newBoard[row][col + 1] = newBoard[row][col + 1].copyWith(
        occupiedBy: state.currentPlayer,
      );
    } else {
      newBoard[row][col] = newBoard[row][col].copyWith(
        occupiedBy: state.currentPlayer,
      );
      newBoard[row + 1][col] = newBoard[row + 1][col].copyWith(
        occupiedBy: state.currentPlayer,
      );
    }
    
    // Switch player
    final nextPlayer = state.isBluesTurn
        ? GameConstants.playerRed
        : GameConstants.playerBlue;
    
    return state.copyWith(
      board: newBoard,
      currentPlayer: nextPlayer,
    );
  }
}

