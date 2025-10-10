/// Represents an AI move with evaluation score
class AIMove {
  final int row;
  final int col;
  final double score;
  final String? reasoning; // For debugging
  
  const AIMove({
    required this.row,
    required this.col,
    required this.score,
    this.reasoning,
  });
  
  @override
  String toString() {
    return 'AIMove(row: $row, col: $col, score: ${score.toStringAsFixed(2)}, reasoning: $reasoning)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIMove && 
      other.row == row && 
      other.col == col;
  }
  
  @override
  int get hashCode => Object.hash(row, col);
}

