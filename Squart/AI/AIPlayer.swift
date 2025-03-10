import Foundation

// Različiti nivoi težine za AI
enum AIDifficulty: Int, CaseIterable, Codable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    var description: String {
        switch self {
        case .easy:
            return "Lako"
        case .medium:
            return "Srednje"
        case .hard:
            return "Teško"
        }
    }
}

// Klasa koja implementira logiku AI igrača
class AIPlayer {
    private let difficulty: AIDifficulty
    
    init(difficulty: AIDifficulty = .medium) {
        self.difficulty = difficulty
    }
    
    // Glavna funkcija koja određuje najbolji potez za AI
    func findBestMove(for game: Game) -> (row: Int, column: Int)? {
        // Ako je igra završena, nema validnih poteza
        if game.isGameOver {
            return nil
        }
        
        // Implementacija zavisi od težine
        switch difficulty {
        case .easy:
            return findRandomMove(for: game)
        case .medium:
            return findMediumMove(for: game)
        case .hard:
            return findBestMoveMinMax(for: game)
        }
    }
    
    // Najjednostavniji AI - bira nasumični validni potez
    private func findRandomMove(for game: Game) -> (row: Int, column: Int)? {
        let board = game.board
        let player = game.currentPlayer
        
        // Prikupljamo sve validne poteze
        var validMoves: [(row: Int, column: Int)] = []
        
        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.isValidMove(row: row, column: column, player: player) {
                    validMoves.append((row, column))
                }
            }
        }
        
        // Ako nema validnih poteza, vraćamo nil
        if validMoves.isEmpty {
            return nil
        }
        
        // Biramo nasumični potez iz validnih
        let randomIndex = Int.random(in: 0..<validMoves.count)
        return validMoves[randomIndex]
    }
    
    // Srednji nivo - kombinuje nasumičnost sa nekom strategijom
    private func findMediumMove(for game: Game) -> (row: Int, column: Int)? {
        // IMPLEMENTACIJA KASNIJE
        // Za sada koristimo nasumični potez
        return findRandomMove(for: game)
    }
    
    // Napredni AI - koristi minmax algoritam za traženje najboljeg poteza
    private func findBestMoveMinMax(for game: Game) -> (row: Int, column: Int)? {
        // IMPLEMENTACIJA KASNIJE
        // Za sada koristimo nasumični potez
        return findRandomMove(for: game)
    }
} 