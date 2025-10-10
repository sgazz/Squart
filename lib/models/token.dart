import '../core/constants/game_constants.dart';

/// Represents a token placed on the board
class Token {
  final String id;
  final String player; // BLUE or RED
  final String orientation; // HORIZONTAL or VERTICAL
  final int row; // Starting row
  final int col; // Starting column
  final DateTime placedAt;
  
  Token({
    required this.id,
    required this.player,
    required this.orientation,
    required this.row,
    required this.col,
    DateTime? placedAt,
  }) : placedAt = placedAt ?? DateTime.now();
  
  /// Check if token is horizontal (2 cells wide)
  bool get isHorizontal => orientation == GameConstants.orientationHorizontal;
  
  /// Check if token is vertical (2 cells tall)
  bool get isVertical => orientation == GameConstants.orientationVertical;
  
  /// Check if token belongs to blue player
  bool get isBlue => player == GameConstants.playerBlue;
  
  /// Check if token belongs to red player
  bool get isRed => player == GameConstants.playerRed;
  
  /// Get the two cells occupied by this token
  List<(int, int)> getOccupiedCells() {
    if (isHorizontal) {
      return [(row, col), (row, col + 1)];
    } else {
      return [(row, col), (row + 1, col)];
    }
  }
  
  /// Create a copy of this token with modified properties
  Token copyWith({
    String? id,
    String? player,
    String? orientation,
    int? row,
    int? col,
    DateTime? placedAt,
  }) {
    return Token(
      id: id ?? this.id,
      player: player ?? this.player,
      orientation: orientation ?? this.orientation,
      row: row ?? this.row,
      col: col ?? this.col,
      placedAt: placedAt ?? this.placedAt,
    );
  }
  
  /// Convert token to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player': player,
      'orientation': orientation,
      'row': row,
      'col': col,
      'placedAt': placedAt.toIso8601String(),
    };
  }
  
  /// Create token from JSON
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'] as String,
      player: json['player'] as String,
      orientation: json['orientation'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      placedAt: DateTime.parse(json['placedAt'] as String),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Token && 
      other.id == id &&
      other.player == player &&
      other.orientation == orientation &&
      other.row == row &&
      other.col == col;
  }
  
  @override
  int get hashCode => Object.hash(id, player, orientation, row, col);
  
  @override
  String toString() {
    return 'Token(id: $id, player: $player, orientation: $orientation, row: $row, col: $col)';
  }
}

