import Foundation
import SwiftUI

// MARK: - AI Difficulty
enum AIDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    
    var description: String {
        switch self {
        case .easy: return "Lako"
        case .medium: return "Srednje"
        case .hard: return "Teško"
        }
    }
    
    var depth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

// MARK: - Struktura za tabelu transformacija
/// Ključ za heširanje stanja igre za tabelu transformacija
struct TranspositionKey: Hashable {
    let boardState: [[CellType]]
    let currentPlayer: Player
    
    init(game: Game) {
        var state: [[CellType]] = []
        for row in 0..<game.board.size {
            var rowState: [CellType] = []
            for col in 0..<game.board.size {
                rowState.append(game.board.cells[row][col].type)
            }
            state.append(rowState)
        }
        self.boardState = state
        self.currentPlayer = game.currentPlayer
    }
    
    /// String reprezentacija ključa za korišćenje u tabeli transformacija
    var description: String {
        var result = ""
        for row in boardState {
            for cell in row {
                switch cell {
                case .empty: result += "."
                case .blocked: result += "#"
                case .blue: result += "B"
                case .red: result += "R"
                }
            }
        }
        result += currentPlayer == .blue ? "B" : "R"
        return result
    }
}

/// Vrednost koja se čuva u tabeli transformacija
struct TranspositionValue {
    let score: Int
    let depth: Int
    let type: TranspositionValueType
}

/// Tip vrednosti u tabeli transformacija
enum TranspositionValueType {
    case exact      // Tačna vrednost
    case lowerBound // Donja granica (alfa)
    case upperBound // Gornja granica (beta)
}

// MARK: - AI Player
/// Implementira logiku AI igrača za igru Squart
/// 
/// Ova klasa upravlja svim aspektima AI igrača, uključujući:
/// - Različite nivoe težine (lako, srednje, teško)
/// - Strategije za svaki nivo
/// - Evaluaciju pozicija
/// - Minimax algoritam
/// - Keširanje za optimizaciju performansi
class AIPlayer {
    // MARK: - Properties
    /// Težina AI igrača
    let difficulty: AIDifficulty
    
    // MARK: - Performance Tracking
    private(set) var evaluationCount: Int = 0
    private(set) var cacheHitCount: Int = 0
    private(set) var lastMoveTime: TimeInterval = 0
    private(set) var nodes: Int = 0
    private(set) var currentDepth: Int = 0
    private(set) var initialDepth: Int = 0
    
    // MARK: - Caching
    /// Keš za edge i corner pozicije za različite veličine table
    private var edgePositionsCache: [Int: Set<Position>] = [:]
    private var cornerPositionsCache: [Int: Set<Position>] = [:]
    private var centerPositionsCache: [Int: Set<Position>] = [:]
    
    // Tabela transformacija za mehanizam učenja i optimizaciju
    private var transpositionTable: [String: Int] = [:]
    
    // Tragovi za vizualizaciju razmišljanja
    private(set) var consideredMoves: [(row: Int, column: Int, score: Int)] = []
    
    // MARK: - Initialization
    /// Inicijalizuje novog AI igrača
    /// - Parameter difficulty: Težina AI igrača
    init(difficulty: AIDifficulty = .medium) {
        self.difficulty = difficulty
        print("AI igrač inicijalizovan sa težinom: \(difficulty.description)")
    }
    
    // MARK: - AI Move Methods
    /// Pronalazi najbolji potez za trenutno stanje igre
    /// - Parameter game: Trenutno stanje igre
    /// - Returns: Najbolji potez ili nil ako nema validnih poteza
    func findBestMove(for game: Game) -> Position? {
        let startTime = Date()
        nodes = 0
        evaluationCount = 0
        cacheHitCount = 0
        currentDepth = 0
        initialDepth = difficulty.depth
        
        // Resetujemo tabelu transformacija
        transpositionTable.removeAll()
        
        // Pronalazimo sve validne poteze
        let validMoves = getValidMoves(for: game)
        guard !validMoves.isEmpty else { return nil }
        
        // Ako je samo jedan validan potez, vraćamo ga odmah
        if validMoves.count == 1 {
            return validMoves[0]
        }
        
        // Inicijalizujemo varijable za alfa-beta odsecanje
        var bestScore = Int.min
        var bestMove = validMoves[0]
        
        // Evaluacija svakog validnog poteza
        for move in validMoves {
            // Simuliramo potez
            let simulatedGame = game.clone()
            _ = simulatedGame.makeMove(row: move.row, column: move.column)
            
            // Evaluacija pozicije nakon poteza
            let score = minimax(game: simulatedGame, depth: initialDepth - 1, alpha: Int.min, beta: Int.max, isMaximizing: false)
            
            // Ažuriramo najbolji potez ako je potrebno
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        // Beležimo statistiku
        lastMoveTime = Date().timeIntervalSince(startTime)
        
        return bestMove
    }
    
    /// Izvršava AI potez za trenutno stanje igre
    /// - Parameters:
    ///   - game: Trenutno stanje igre
    ///   - difficulty: Težina AI igrača
    /// - Returns: Pozicija na koju je odigran potez
    func makeMove(for game: Game, difficulty: AIDifficulty) -> Position {
        if let bestMove = findBestMove(for: game) {
            return bestMove
        }
        
        // Ako nema najboljeg poteza, vratimo prvi validan potez
        let validMoves = getValidMoves(for: game)
        return validMoves[0]
    }
    
    // MARK: - Helper Methods
    /// Vraća listu validnih poteza za trenutno stanje igre
    private func getValidMoves(for game: Game) -> [Position] {
        var moves: [Position] = []
        for row in 0..<game.board.size {
            for col in 0..<game.board.size {
                if game.board.isValidMove(row: row, column: col, player: game.currentPlayer) {
                    moves.append(Position(row: row, column: col))
                }
            }
        }
        return moves
    }
    
    /// Implementacija minimax algoritma sa alfa-beta odsecanjem
    private func minimax(game: Game, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        nodes += 1
        
        // Provera kraja igre ili maksimalne dubine
        if game.isGameOver || depth == 0 {
            evaluationCount += 1
            return evaluatePosition(game)
        }
        
        // Provera tabele transformacija
        let key = TranspositionKey(game: game)
        if let cachedValue = transpositionTable[key.description] {
            cacheHitCount += 1
            return cachedValue
        }
        
        let validMoves = getValidMoves(for: game)
        if validMoves.isEmpty {
            return 0
        }
        
        if isMaximizing {
            var maxScore = Int.min
            var currentAlpha = alpha
            for move in validMoves {
                let simulatedGame = game.clone()
                _ = simulatedGame.makeMove(row: move.row, column: move.column)
                
                let score = minimax(game: simulatedGame, depth: depth - 1, alpha: currentAlpha, beta: beta, isMaximizing: false)
                maxScore = max(maxScore, score)
                currentAlpha = max(currentAlpha, score)
                
                if beta <= currentAlpha {
                    break
                }
            }
            
            // Čuvamo rezultat u tabeli transformacija
            transpositionTable[key.description] = maxScore
            return maxScore
        } else {
            var minScore = Int.max
            var currentBeta = beta
            for move in validMoves {
                let simulatedGame = game.clone()
                _ = simulatedGame.makeMove(row: move.row, column: move.column)
                
                let score = minimax(game: simulatedGame, depth: depth - 1, alpha: alpha, beta: currentBeta, isMaximizing: true)
                minScore = min(minScore, score)
                currentBeta = min(currentBeta, score)
                
                if currentBeta <= alpha {
                    break
                }
            }
            
            // Čuvamo rezultat u tabeli transformacija
            transpositionTable[key.description] = minScore
            return minScore
        }
    }
    
    /// Evaluira trenutnu poziciju na tabli
    private func evaluatePosition(_ game: Game) -> Int {
        var score = 0
        
        // Provera pobednika
        if let winner = game.board.checkForWinner() {
            return winner == game.currentPlayer ? Int.max : Int.min
        }
        
        // Provera nerešenog rezultata
        if game.board.isFull() {
            return 0
        }
        
        // Evaluacija centra
        let centerScore = evaluateCenter(game)
        score += centerScore
        
        // Evaluacija ivica
        let edgeScore = evaluateEdges(game)
        score += edgeScore
        
        // Evaluacija uglova
        let cornerScore = evaluateCorners(game)
        score += cornerScore
        
        // Evaluacija mogućnosti za blokiranje
        let blockingScore = evaluateBlockingOpportunities(game)
        score += blockingScore
        
        // Evaluacija mogućnosti za napad
        let attackingScore = evaluateAttackingOpportunities(game)
        score += attackingScore
        
        return score
    }
    
    /// Evaluira kontrolu centra
    private func evaluateCenter(_ game: Game) -> Int {
        let center = game.board.size / 2
        var score = 0
        
        // Centar
        if game.board.cells[center][center].type == game.currentPlayer.cellType {
            score += 3
        } else if game.board.cells[center][center].type != .empty {
            score -= 3
        }
        
        // Polja oko centra
        let adjacentPositions = [
            (center - 1, center), (center + 1, center),
            (center, center - 1), (center, center + 1)
        ]
        
        for (row, col) in adjacentPositions {
            if row >= 0 && row < game.board.size && col >= 0 && col < game.board.size {
                if game.board.cells[row][col].type == game.currentPlayer.cellType {
                    score += 2
                } else if game.board.cells[row][col].type != .empty {
                    score -= 2
                }
            }
        }
        
        return score
    }
    
    /// Evaluira kontrolu ivica
    private func evaluateEdges(_ game: Game) -> Int {
        var score = 0
        let size = game.board.size
        
        // Gornja i donja ivica
        for col in 0..<size {
            if game.board.cells[0][col].type == game.currentPlayer.cellType {
                score += 1
            } else if game.board.cells[0][col].type != .empty {
                score -= 1
            }
            
            if game.board.cells[size-1][col].type == game.currentPlayer.cellType {
                score += 1
            } else if game.board.cells[size-1][col].type != .empty {
                score -= 1
            }
        }
        
        // Leva i desna ivica
        for row in 0..<size {
            if game.board.cells[row][0].type == game.currentPlayer.cellType {
                score += 1
            } else if game.board.cells[row][0].type != .empty {
                score -= 1
            }
            
            if game.board.cells[row][size-1].type == game.currentPlayer.cellType {
                score += 1
            } else if game.board.cells[row][size-1].type != .empty {
                score -= 1
            }
        }
        
        return score
    }
    
    /// Evaluira kontrolu uglova
    private func evaluateCorners(_ game: Game) -> Int {
        let size = game.board.size
        var score = 0
        
        let corners = [
            (0, 0), (0, size-1),
            (size-1, 0), (size-1, size-1)
        ]
        
        for (row, col) in corners {
            if game.board.cells[row][col].type == game.currentPlayer.cellType {
                score += 2
            } else if game.board.cells[row][col].type != .empty {
                score -= 2
            }
        }
        
        return score
    }
    
    /// Evaluira mogućnosti za blokiranje protivničkih poteza
    private func evaluateBlockingOpportunities(_ game: Game) -> Int {
        var score = 0
        let opponent = game.currentPlayer == .blue ? Player.red : .blue
        
        // Provera svih mogućih poteza protivnika
        for row in 0..<game.board.size {
            for col in 0..<game.board.size {
                if game.board.isValidMove(row: row, column: col, player: opponent) {
                    let simulatedGame = game.clone()
                    _ = simulatedGame.makeMove(row: row, column: col)
                    
                    if let winner = simulatedGame.board.checkForWinner(), winner == opponent {
                        score -= 5
                    }
                }
            }
        }
        
        return score
    }
    
    /// Evaluira mogućnosti za napad
    private func evaluateAttackingOpportunities(_ game: Game) -> Int {
        var score = 0
        
        // Provera svih mogućih poteza
        for row in 0..<game.board.size {
            for col in 0..<game.board.size {
                if game.board.isValidMove(row: row, column: col, player: game.currentPlayer) {
                    let simulatedGame = game.clone()
                    _ = simulatedGame.makeMove(row: row, column: col)
                    
                    if let winner = simulatedGame.board.checkForWinner(), winner == game.currentPlayer {
                        score += 5
                    }
                }
            }
        }
        
        return score
    }
}
