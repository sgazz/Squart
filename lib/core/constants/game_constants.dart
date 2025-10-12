/// Game rules and constants for Squart
class GameConstants {
  GameConstants._();

  // ========== Board Size ==========
  
  /// Minimum board size
  static const int minBoardSize = 5;
  
  /// Maximum board size (absolute maximum, may be limited by screen size)
  static const int maxBoardSize = 20;
  
  /// Default board size
  static const int defaultBoardSize = 7;
  
  /// Calculate maximum board size based on screen width
  /// This ensures cells never go below minCellSize (20px)
  static int getMaxBoardSizeForScreen(double screenWidth) {
    const double minCellSize = 20.0;
    const double boardPadding = 16.0 * 2; // AppSizes.boardPadding * 2
    const double cellGap = 2.0; // AppSizes.cellGap
    
    // Available width for board
    final double availableWidth = screenWidth - boardPadding;
    
    // Calculate max board size that keeps cells >= minCellSize
    // Formula: (availableWidth - (size - 1) * cellGap) / size >= minCellSize
    // Simplified: size <= (availableWidth + cellGap) / (minCellSize + cellGap)
    final int calculatedMax = ((availableWidth + cellGap) / (minCellSize + cellGap)).floor();
    
    // Clamp between minBoardSize and maxBoardSize
    return calculatedMax.clamp(minBoardSize, maxBoardSize);
  }
  
  /// Minimum percentage of black cells
  static const double minBlackCellsPercent = 0.17; // 17%
  
  /// Maximum percentage of black cells
  static const double maxBlackCellsPercent = 0.19; // 19%
  
  // ========== Players ==========
  
  /// Blue player (Horizontal tokens)
  static const String playerBlue = 'BLUE';
  
  /// Red player (Vertical tokens)
  static const String playerRed = 'RED';
  
  // ========== Token Orientation ==========
  
  static const String orientationHorizontal = 'HORIZONTAL';
  static const String orientationVertical = 'VERTICAL';
  
  // ========== Timer Options (in seconds) ==========
  
  static const int timer1Min = 60;
  static const int timer3Min = 180;
  static const int timer5Min = 300;
  static const int timer10Min = 600;
  static const int timerUnlimited = 0; // 0 means unlimited
  
  /// Timer warning threshold (seconds)
  static const int timerWarningThreshold = 10;
  
  // ========== Timer Labels ==========
  
  static const String timer1MinLabel = '1 min';
  static const String timer3MinLabel = '3 min';
  static const String timer5MinLabel = '5 min';
  static const String timer10MinLabel = '10 min';
  static const String timerUnlimitedLabel = 'Unlimited';
  
  /// Available timer options
  static const List<int> timerOptions = [
    timer1Min,
    timer3Min,
    timer5Min,
    timer10Min,
    timerUnlimited,
  ];
  
  /// Get timer label from seconds
  static String getTimerLabel(int seconds) {
    switch (seconds) {
      case timer1Min:
        return timer1MinLabel;
      case timer3Min:
        return timer3MinLabel;
      case timer5Min:
        return timer5MinLabel;
      case timer10Min:
        return timer10MinLabel;
      case timerUnlimited:
        return timerUnlimitedLabel;
      default:
        return '${seconds ~/ 60} min';
    }
  }
  
  // ========== AI Difficulty ==========
  
  static const String aiEasy = 'EASY';
  static const String aiMedium = 'MEDIUM';
  static const String aiHard = 'HARD';
  
  static const List<String> aiDifficulties = [aiEasy, aiMedium, aiHard];
  
  /// AI thinking delay ranges (milliseconds)
  static const int aiEasyMinDelay = 500;
  static const int aiEasyMaxDelay = 1000;
  static const int aiMediumMinDelay = 1000;
  static const int aiMediumMaxDelay = 1500;
  static const int aiHardMinDelay = 1500;
  static const int aiHardMaxDelay = 2000;
  
  // ========== Game Mode ==========
  
  static const String modePlayerVsPlayer = 'PVP';
  static const String modePlayerVsAI = 'PVE';
  
  // ========== Storage Keys ==========
  
  static const String keyCurrentGame = 'current_game';
  static const String keySettings = 'settings';
  static const String keyTheme = 'theme';
  static const String keyShowHints = 'show_hints';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyFirstLaunch = 'first_launch';
  
  // ========== Game States ==========
  
  static const String stateSetup = 'SETUP';
  static const String statePlaying = 'PLAYING';
  static const String statePaused = 'PAUSED';
  static const String stateFinished = 'FINISHED';
  
  // ========== Win Conditions ==========
  
  static const String winNoMoves = 'NO_MOVES'; // Opponent has no valid moves
  static const String winTimeout = 'TIMEOUT'; // Opponent ran out of time
  
  // ========== Audio Files ==========
  
  static const String soundTokenPlace = 'sounds/token_place.mp3';
  static const String soundWin = 'sounds/win.mp3';
  static const String soundLose = 'sounds/lose.mp3';
  static const String soundInvalid = 'sounds/invalid.mp3';
  static const String soundTick = 'sounds/tick.mp3';
}

