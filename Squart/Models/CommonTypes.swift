import Foundation

/// Struktura za predstavljanje pozicije na tabli
/// Koristi se u celom projektu za referenciranje konkretne pozicije
public struct Position: Hashable, Codable {
    public let row: Int
    public let column: Int
    
    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
} 