/// AI difficulty levels
enum AIDifficulty {
  easy,
  medium,
  hard;
  
  /// Get display name
  String get displayName {
    switch (this) {
      case AIDifficulty.easy:
        return 'Easy';
      case AIDifficulty.medium:
        return 'Medium';
      case AIDifficulty.hard:
        return 'Hard';
    }
  }
  
  /// Get description
  String get description {
    switch (this) {
      case AIDifficulty.easy:
        return 'Good for beginners';
      case AIDifficulty.medium:
        return 'Balanced challenge';
      case AIDifficulty.hard:
        return 'Expert level';
    }
  }
  
  /// Get thinking delay range in milliseconds
  (int, int) get thinkingDelayRange {
    switch (this) {
      case AIDifficulty.easy:
        return (500, 1000);
      case AIDifficulty.medium:
        return (1000, 1500);
      case AIDifficulty.hard:
        return (1500, 2000);
    }
  }
  
  /// Get minimax depth
  int get minimaxDepth {
    switch (this) {
      case AIDifficulty.easy:
        return 1; // Very shallow, almost random
      case AIDifficulty.medium:
        return 3; // Moderate lookahead
      case AIDifficulty.hard:
        return 5; // Deep lookahead
    }
  }
  
  /// Convert to string for storage
  String toStorageString() => name;
  
  /// Create from storage string
  static AIDifficulty fromStorageString(String value) {
    return AIDifficulty.values.firstWhere(
      (d) => d.name == value,
      orElse: () => AIDifficulty.medium,
    );
  }
}

