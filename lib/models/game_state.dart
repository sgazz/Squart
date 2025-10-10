import 'cell.dart';
import 'token.dart';
import 'game_settings.dart';
import '../core/constants/game_constants.dart';

/// Represents the complete state of a game
class GameState {
  final GameSettings settings;
  final List<List<Cell>> board;
  final List<Token> tokens;
  final String currentPlayer;
  final String gameStatus;
  final int blueTimeRemaining; // seconds
  final int redTimeRemaining; // seconds
  final String? winner;
  final String? winReason;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  
  GameState({
    required this.settings,
    required this.board,
    this.tokens = const [],
    this.currentPlayer = GameConstants.playerBlue,
    this.gameStatus = GameConstants.statePlaying,
    int? blueTimeRemaining,
    int? redTimeRemaining,
    this.winner,
    this.winReason,
    this.startedAt,
    this.finishedAt,
  }) : blueTimeRemaining = blueTimeRemaining ?? settings.timePerPlayer,
       redTimeRemaining = redTimeRemaining ?? settings.timePerPlayer;
  
  /// Get board size
  int get boardSize => settings.boardSize;
  
  /// Check if game is finished
  bool get isFinished => gameStatus == GameConstants.stateFinished;
  
  /// Check if game is paused
  bool get isPaused => gameStatus == GameConstants.statePaused;
  
  /// Check if game is playing
  bool get isPlaying => gameStatus == GameConstants.statePlaying;
  
  /// Check if it's blue player's turn
  bool get isBluesTurn => currentPlayer == GameConstants.playerBlue;
  
  /// Check if it's red player's turn
  bool get isRedsTurn => currentPlayer == GameConstants.playerRed;
  
  /// Get current player's time remaining
  int get currentPlayerTimeRemaining => 
    isBluesTurn ? blueTimeRemaining : redTimeRemaining;
  
  /// Get cell at position
  Cell getCell(int row, int col) {
    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
      throw ArgumentError('Invalid cell position: ($row, $col)');
    }
    return board[row][col];
  }
  
  /// Check if position is valid
  bool isValidPosition(int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }
  
  /// Get all available cells
  List<Cell> getAvailableCells() {
    final available = <Cell>[];
    for (var row in board) {
      for (var cell in row) {
        if (cell.isAvailable) {
          available.add(cell);
        }
      }
    }
    return available;
  }
  
  /// Get valid moves for current player
  List<(int, int)> getValidMoves() {
    final validMoves = <(int, int)>[];
    final orientation = isBluesTurn 
      ? GameConstants.orientationHorizontal 
      : GameConstants.orientationVertical;
    
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_canPlaceToken(row, col, orientation)) {
          validMoves.add((row, col));
        }
      }
    }
    
    return validMoves;
  }
  
  /// Check if token can be placed at position
  bool _canPlaceToken(int row, int col, String orientation) {
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
  
  /// Check if current player has any valid moves
  bool hasValidMoves() {
    return getValidMoves().isNotEmpty;
  }
  
  /// Create a copy with modified properties
  GameState copyWith({
    GameSettings? settings,
    List<List<Cell>>? board,
    List<Token>? tokens,
    String? currentPlayer,
    String? gameStatus,
    int? blueTimeRemaining,
    int? redTimeRemaining,
    String? winner,
    String? winReason,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return GameState(
      settings: settings ?? this.settings,
      board: board ?? this.board,
      tokens: tokens ?? this.tokens,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameStatus: gameStatus ?? this.gameStatus,
      blueTimeRemaining: blueTimeRemaining ?? this.blueTimeRemaining,
      redTimeRemaining: redTimeRemaining ?? this.redTimeRemaining,
      winner: winner ?? this.winner,
      winReason: winReason ?? this.winReason,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'settings': settings.toJson(),
      'board': board.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
      'tokens': tokens.map((token) => token.toJson()).toList(),
      'currentPlayer': currentPlayer,
      'gameStatus': gameStatus,
      'blueTimeRemaining': blueTimeRemaining,
      'redTimeRemaining': redTimeRemaining,
      'winner': winner,
      'winReason': winReason,
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    final settings = GameSettings.fromJson(json['settings'] as Map<String, dynamic>);
    final boardData = json['board'] as List;
    final board = boardData.map((row) {
      final rowData = row as List;
      return rowData.map((cell) => Cell.fromJson(cell as Map<String, dynamic>)).toList();
    }).toList();
    
    final tokensData = json['tokens'] as List;
    final tokens = tokensData.map((token) => Token.fromJson(token as Map<String, dynamic>)).toList();
    
    return GameState(
      settings: settings,
      board: board,
      tokens: tokens,
      currentPlayer: json['currentPlayer'] as String? ?? GameConstants.playerBlue,
      gameStatus: json['gameStatus'] as String? ?? GameConstants.statePlaying,
      blueTimeRemaining: json['blueTimeRemaining'] as int?,
      redTimeRemaining: json['redTimeRemaining'] as int?,
      winner: json['winner'] as String?,
      winReason: json['winReason'] as String?,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt'] as String) : null,
    );
  }
  
  @override
  String toString() {
    return 'GameState(size: $boardSize, currentPlayer: $currentPlayer, status: $gameStatus, tokens: ${tokens.length})';
  }
}

