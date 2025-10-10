import '../core/constants/game_constants.dart';

/// Represents a single cell on the game board
class Cell {
  final int row;
  final int col;
  final bool isBlack; // Black cells cannot be used
  String? occupiedBy; // null, BLUE, or RED
  String? tokenId; // ID of the token occupying this cell
  
  Cell({
    required this.row,
    required this.col,
    this.isBlack = false,
    this.occupiedBy,
    this.tokenId,
  });
  
  /// Check if cell is available for placement
  bool get isAvailable => !isBlack && occupiedBy == null;
  
  /// Check if cell is occupied by blue player
  bool get isBlue => occupiedBy == GameConstants.playerBlue;
  
  /// Check if cell is occupied by red player
  bool get isRed => occupiedBy == GameConstants.playerRed;
  
  /// Create a copy of this cell with modified properties
  Cell copyWith({
    int? row,
    int? col,
    bool? isBlack,
    String? occupiedBy,
    String? tokenId,
  }) {
    return Cell(
      row: row ?? this.row,
      col: col ?? this.col,
      isBlack: isBlack ?? this.isBlack,
      occupiedBy: occupiedBy ?? this.occupiedBy,
      tokenId: tokenId ?? this.tokenId,
    );
  }
  
  /// Convert cell to JSON
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'isBlack': isBlack,
      'occupiedBy': occupiedBy,
      'tokenId': tokenId,
    };
  }
  
  /// Create cell from JSON
  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
      row: json['row'] as int,
      col: json['col'] as int,
      isBlack: json['isBlack'] as bool? ?? false,
      occupiedBy: json['occupiedBy'] as String?,
      tokenId: json['tokenId'] as String?,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell && 
      other.row == row && 
      other.col == col &&
      other.isBlack == isBlack &&
      other.occupiedBy == occupiedBy &&
      other.tokenId == tokenId;
  }
  
  @override
  int get hashCode => Object.hash(row, col, isBlack, occupiedBy, tokenId);
  
  @override
  String toString() {
    return 'Cell(row: $row, col: $col, isBlack: $isBlack, occupiedBy: $occupiedBy)';
  }
}

