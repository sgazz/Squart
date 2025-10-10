import 'dart:math';
import '../models/cell.dart';
import '../models/token.dart';
import '../models/game_state.dart';
import '../models/game_settings.dart';
import '../core/constants/game_constants.dart';

/// Service for game logic and board management
class GameLogicService {
  final Random _random = Random();
  
  /// Create a new game with given settings
  GameState createNewGame(GameSettings settings) {
    final board = _generateBoard(settings.boardSize);
    return GameState(
      settings: settings,
      board: board,
      tokens: [],
      currentPlayer: GameConstants.playerBlue,
      gameStatus: GameConstants.statePlaying,
      startedAt: DateTime.now(),
    );
  }
  
  /// Generate board with black cells
  List<List<Cell>> _generateBoard(int size) {
    // Initialize empty board
    final board = List.generate(
      size,
      (row) => List.generate(
        size,
        (col) => Cell(row: row, col: col),
      ),
    );
    
    // Calculate number of black cells (17-19% of total)
    final totalCells = size * size;
    final minBlackCells = (totalCells * GameConstants.minBlackCellsPercent).round();
    final maxBlackCells = (totalCells * GameConstants.maxBlackCellsPercent).round();
    final blackCellsCount = minBlackCells + _random.nextInt(maxBlackCells - minBlackCells + 1);
    
    // Randomly place black cells
    final availablePositions = <(int, int)>[];
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        availablePositions.add((row, col));
      }
    }
    
    // Shuffle and pick black cells
    availablePositions.shuffle(_random);
    for (int i = 0; i < blackCellsCount && i < availablePositions.length; i++) {
      final (row, col) = availablePositions[i];
      board[row][col] = Cell(row: row, col: col, isBlack: true);
    }
    
    return board;
  }
  
  /// Validate if a move is legal
  bool isValidMove(GameState state, int row, int col) {
    // Check if position is within bounds
    if (row < 0 || row >= state.boardSize || col < 0 || col >= state.boardSize) {
      return false;
    }
    
    final orientation = state.isBluesTurn
        ? GameConstants.orientationHorizontal
        : GameConstants.orientationVertical;
    
    return _canPlaceToken(state.board, row, col, orientation, state.boardSize);
  }
  
  /// Check if token can be placed at position
  bool _canPlaceToken(
    List<List<Cell>> board,
    int row,
    int col,
    String orientation,
    int boardSize,
  ) {
    if (orientation == GameConstants.orientationHorizontal) {
      // Check horizontal (2 cells wide)
      if (col + 1 >= boardSize) return false;
      final cell1 = board[row][col];
      final cell2 = board[row][col + 1];
      return cell1.isAvailable && cell2.isAvailable;
    } else {
      // Check vertical (2 cells tall)
      if (row + 1 >= boardSize) return false;
      final cell1 = board[row][col];
      final cell2 = board[row + 1][col];
      return cell1.isAvailable && cell2.isAvailable;
    }
  }
  
  /// Place a token on the board
  GameState placeToken(GameState state, int row, int col) {
    if (!isValidMove(state, row, col)) {
      throw ArgumentError('Invalid move at position ($row, $col)');
    }
    
    // Create new token
    final orientation = state.isBluesTurn
        ? GameConstants.orientationHorizontal
        : GameConstants.orientationVertical;
    
    final token = Token(
      id: '${state.currentPlayer}_${DateTime.now().millisecondsSinceEpoch}',
      player: state.currentPlayer,
      orientation: orientation,
      row: row,
      col: col,
    );
    
    // Update board
    final newBoard = _copyBoard(state.board);
    final occupiedCells = token.getOccupiedCells();
    
    for (final (r, c) in occupiedCells) {
      newBoard[r][c] = newBoard[r][c].copyWith(
        occupiedBy: state.currentPlayer,
        tokenId: token.id,
      );
    }
    
    // Add token to list
    final newTokens = [...state.tokens, token];
    
    // Switch player
    final nextPlayer = state.isBluesTurn
        ? GameConstants.playerRed
        : GameConstants.playerBlue;
    
    // Check win condition (opponent has no moves)
    final newState = state.copyWith(
      board: newBoard,
      tokens: newTokens,
      currentPlayer: nextPlayer,
    );
    
    // Check if next player has valid moves
    if (!newState.hasValidMoves()) {
      // Current player wins (they made the last valid move)
      return newState.copyWith(
        gameStatus: GameConstants.stateFinished,
        winner: state.currentPlayer,
        winReason: GameConstants.winNoMoves,
        finishedAt: DateTime.now(),
      );
    }
    
    return newState;
  }
  
  /// Copy board for immutability
  List<List<Cell>> _copyBoard(List<List<Cell>> board) {
    return board.map((row) => row.map((cell) => cell).toList()).toList();
  }
  
  /// Get all valid moves for current player
  List<(int, int)> getValidMoves(GameState state) {
    final validMoves = <(int, int)>[];
    final orientation = state.isBluesTurn
        ? GameConstants.orientationHorizontal
        : GameConstants.orientationVertical;
    
    for (int row = 0; row < state.boardSize; row++) {
      for (int col = 0; col < state.boardSize; col++) {
        if (_canPlaceToken(state.board, row, col, orientation, state.boardSize)) {
          validMoves.add((row, col));
        }
      }
    }
    
    return validMoves;
  }
  
  /// Check if game is over due to timeout
  GameState checkTimeout(GameState state) {
    if (!state.settings.hasTimer) return state;
    if (state.isFinished) return state;
    
    final currentTime = state.currentPlayerTimeRemaining;
    
    if (currentTime <= 0) {
      // Current player loses due to timeout
      final winner = state.isBluesTurn
          ? GameConstants.playerRed
          : GameConstants.playerBlue;
      
      return state.copyWith(
        gameStatus: GameConstants.stateFinished,
        winner: winner,
        winReason: GameConstants.winTimeout,
        finishedAt: DateTime.now(),
      );
    }
    
    return state;
  }
  
  /// Update timer (decrement by 1 second)
  GameState updateTimer(GameState state) {
    if (!state.settings.hasTimer) return state;
    if (state.isFinished || state.isPaused) return state;
    
    if (state.isBluesTurn) {
      final newTime = (state.blueTimeRemaining - 1).clamp(0, state.settings.timePerPlayer);
      return state.copyWith(blueTimeRemaining: newTime);
    } else {
      final newTime = (state.redTimeRemaining - 1).clamp(0, state.settings.timePerPlayer);
      return state.copyWith(redTimeRemaining: newTime);
    }
  }
  
  /// Pause game
  GameState pauseGame(GameState state) {
    if (state.isFinished) return state;
    return state.copyWith(gameStatus: GameConstants.statePaused);
  }
  
  /// Resume game
  GameState resumeGame(GameState state) {
    if (state.isFinished) return state;
    return state.copyWith(gameStatus: GameConstants.statePlaying);
  }
  
  /// Get count of black cells on board
  int getBlackCellsCount(List<List<Cell>> board) {
    int count = 0;
    for (var row in board) {
      for (var cell in row) {
        if (cell.isBlack) count++;
      }
    }
    return count;
  }
  
  /// Get percentage of black cells
  double getBlackCellsPercentage(List<List<Cell>> board) {
    final total = board.length * board.length;
    final blackCount = getBlackCellsCount(board);
    return blackCount / total;
  }
}

