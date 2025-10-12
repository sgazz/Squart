import '../core/constants/game_constants.dart';
import 'ai_difficulty.dart';

/// Game settings and configuration
class GameSettings {
  final int boardSize; // 5 to 20
  final int timePerPlayer; // seconds, 0 = unlimited
  final String gameMode; // PVP or PVE
  final AIDifficulty? aiDifficulty; // AI difficulty level (only for PVE)
  final String startingPlayer; // BLUE or RED
  final bool showHints;
  final bool soundEnabled;
  final bool vibrationEnabled;
  
  GameSettings({
    this.boardSize = GameConstants.defaultBoardSize,
    this.timePerPlayer = GameConstants.timerUnlimited,
    this.gameMode = GameConstants.modePlayerVsPlayer,
    this.aiDifficulty,
    this.startingPlayer = GameConstants.playerBlue,
    this.showHints = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  }) : assert(
    boardSize >= GameConstants.minBoardSize && 
    boardSize <= GameConstants.maxBoardSize,
    'Board size must be between ${GameConstants.minBoardSize} and ${GameConstants.maxBoardSize}',
  ), assert(
    gameMode == GameConstants.modePlayerVsPlayer || 
    gameMode == GameConstants.modePlayerVsAI,
    'Game mode must be PVP or PVE',
  ), assert(
    gameMode == GameConstants.modePlayerVsPlayer || aiDifficulty != null,
    'AI difficulty must be set for PVE mode',
  );
  
  /// Check if game is Player vs AI
  bool get isPlayerVsAI => gameMode == GameConstants.modePlayerVsAI;
  
  /// Get AI player (opposite of starting player in PvE mode)
  String get aiPlayer {
    if (!isPlayerVsAI) return '';
    return startingPlayer == GameConstants.playerBlue 
        ? GameConstants.playerRed 
        : GameConstants.playerBlue;
  }
  
  /// Get human player in PvE mode
  String get humanPlayer {
    if (!isPlayerVsAI) return '';
    return startingPlayer;
  }
  
  /// Check if timer is enabled
  bool get hasTimer => timePerPlayer > 0;
  
  /// Get timer label
  String get timerLabel => GameConstants.getTimerLabel(timePerPlayer);
  
  /// Create a copy with modified properties
  GameSettings copyWith({
    int? boardSize,
    int? timePerPlayer,
    String? gameMode,
    AIDifficulty? aiDifficulty,
    String? startingPlayer,
    bool? showHints,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return GameSettings(
      boardSize: boardSize ?? this.boardSize,
      timePerPlayer: timePerPlayer ?? this.timePerPlayer,
      gameMode: gameMode ?? this.gameMode,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      startingPlayer: startingPlayer ?? this.startingPlayer,
      showHints: showHints ?? this.showHints,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'boardSize': boardSize,
      'timePerPlayer': timePerPlayer,
      'gameMode': gameMode,
      'aiDifficulty': aiDifficulty?.toStorageString(),
      'startingPlayer': startingPlayer,
      'showHints': showHints,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }
  
  /// Create from JSON
  factory GameSettings.fromJson(Map<String, dynamic> json) {
    final aiDifficultyStr = json['aiDifficulty'] as String?;
    return GameSettings(
      boardSize: json['boardSize'] as int? ?? GameConstants.defaultBoardSize,
      timePerPlayer: json['timePerPlayer'] as int? ?? GameConstants.timerUnlimited,
      gameMode: json['gameMode'] as String? ?? GameConstants.modePlayerVsPlayer,
      aiDifficulty: aiDifficultyStr != null 
        ? AIDifficulty.fromStorageString(aiDifficultyStr)
        : null,
      startingPlayer: json['startingPlayer'] as String? ?? GameConstants.playerBlue,
      showHints: json['showHints'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameSettings &&
      other.boardSize == boardSize &&
      other.timePerPlayer == timePerPlayer &&
      other.gameMode == gameMode &&
      other.aiDifficulty == aiDifficulty &&
      other.startingPlayer == startingPlayer &&
      other.showHints == showHints &&
      other.soundEnabled == soundEnabled &&
      other.vibrationEnabled == vibrationEnabled;
  }
  
  @override
  int get hashCode => Object.hash(
    boardSize,
    timePerPlayer,
    gameMode,
    aiDifficulty,
    startingPlayer,
    showHints,
    soundEnabled,
    vibrationEnabled,
  );
  
  @override
  String toString() {
    return 'GameSettings(boardSize: $boardSize, timePerPlayer: $timePerPlayer, gameMode: $gameMode)';
  }
}

