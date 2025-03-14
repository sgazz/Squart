import Foundation

// MARK: - Modeli podataka

/// Model podataka za praćenje istorije igara i poteza
struct GameHistory: Codable {
    let timestamp: Date
    let moveHistory: [MoveRecord]
    let outcome: GameOutcome
    let boardSize: Int
}

/// Model podataka za praćenje pojedinačnog poteza
struct MoveRecord: Codable, Equatable {
    let row: Int
    let column: Int
    let player: Player
    let boardState: [[CellType]]
    let score: Int // Procenjena vrednost poteza
}

/// Ishod igre
enum GameOutcome: Int, Codable {
    case blueWon = 0
    case redWon = 1
    case draw = 2
    
    var winner: Player? {
        switch self {
        case .blueWon: return .blue
        case .redWon: return .red
        case .draw: return nil
        }
    }
}

// MARK: - Manager za učenje

/// Menadžer za učenje iz prethodnih igara
class AILearningManager {
    private static let historyKey = "ai_game_history"
    private static let maxStoredGames = 100
    
    // Trenutna seansa - potezi koji se prate
    private static var currentGameMoves: [MoveRecord] = []
    
    /// Dosadašnja istorija igara
    static var gameHistory: [GameHistory] {
        get {
            guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [] }
            return (try? JSONDecoder().decode([GameHistory].self, from: data)) ?? []
        }
        set {
            // Ograničavamo broj sačuvanih igara
            let limitedHistory = Array(newValue.prefix(maxStoredGames))
            if let data = try? JSONEncoder().encode(limitedHistory) {
                UserDefaults.standard.set(data, forKey: historyKey)
            }
        }
    }
    
    /// Resetuje praćenje za novu igru
    static func startNewGameTracking() {
        currentGameMoves.removeAll()
    }
    
    /// Dodaje potez u trenutnu sesiju
    static func recordMove(row: Int, column: Int, player: Player, boardState: [[CellType]], score: Int) {
        let move = MoveRecord(
            row: row,
            column: column,
            player: player, 
            boardState: boardState,
            score: score
        )
        currentGameMoves.append(move)
    }
    
    /// Dodaje novu igru u istoriju
    static func finishGameTracking(boardSize: Int, outcome: GameOutcome) {
        var history = gameHistory
        let newHistory = GameHistory(
            timestamp: Date(),
            moveHistory: currentGameMoves,
            outcome: outcome,
            boardSize: boardSize
        )
        
        history.insert(newHistory, at: 0) // Dodajemo na početak da bi najnovije igre bile prve
        gameHistory = history
        
        // Resetujemo za sledeću igru
        startNewGameTracking()
    }
    
    /// Pronalazi slične poteze iz istorije
    static func findSimilarMoves(for boardState: [[CellType]], player: Player) -> [MoveRecord] {
        let history = gameHistory
        var similarMoves: [MoveRecord] = []
        
        // Prolazimo kroz istoriju igara
        for game in history {
            for move in game.moveHistory where move.player == player {
                // Jednostavno poređenje - da li su stanja table slična
                if isSimilarBoardState(boardState, move.boardState) {
                    similarMoves.append(move)
                }
            }
        }
        
        return similarMoves
    }
    
    /// Evaluira poteze na osnovu istorije
    static func evaluateMovesBasedOnHistory(moves: [(row: Int, column: Int)], 
                                           boardState: [[CellType]], 
                                           player: Player) -> [(move: (row: Int, column: Int), bonus: Int)] {
        
        var evaluatedMoves: [(move: (row: Int, column: Int), bonus: Int)] = []
        
        for move in moves {
            // Pronalazimo slične poteze iz istorije
            let similarPositions = findSimilarPositions(boardState: boardState, player: player)
            
            // Računamo bonus na osnovu uspešnosti poteza
            var bonusScore = 0
            
            for (historicalMove, outcome) in similarPositions {
                // Ako je potez sličan istorijskom potezu
                if historicalMove.row == move.row && historicalMove.column == move.column {
                    // Dodatni bonus ako je ishod bio pobeda igrača koji je napravio potez
                    if (outcome.winner == player) {
                        bonusScore += 50
                    } 
                    // Manji bonus za nerešen rezultat
                    else if outcome.winner == nil {
                        bonusScore += 10
                    }
                    // Negativni bonus za gubitak
                    else {
                        bonusScore -= 30
                    }
                }
            }
            
            evaluatedMoves.append((move: move, bonus: bonusScore))
        }
        
        return evaluatedMoves
    }
    
    /// Pronalazi slične pozicije iz istorije i njihove ishode
    private static func findSimilarPositions(boardState: [[CellType]], player: Player) -> [(move: MoveRecord, outcome: GameOutcome)] {
        let history = gameHistory
        var similarPositions: [(move: MoveRecord, outcome: GameOutcome)] = []
        
        for game in history {
            for move in game.moveHistory where move.player == player {
                if isSimilarBoardState(boardState, move.boardState) {
                    similarPositions.append((move: move, outcome: game.outcome))
                }
            }
        }
        
        return similarPositions
    }
    
    /// Osnovni metod za poređenje sličnosti stanja table
    private static func isSimilarBoardState(_ state1: [[CellType]], _ state2: [[CellType]]) -> Bool {
        // Ako su različite veličine, nisu slična
        guard state1.count == state2.count else { return false }
        
        // Za sada, prosta mera sličnosti - 80% ćelija se podudara
        var matchCount = 0
        var totalCount = 0
        
        for i in 0..<state1.count {
            guard i < state2.count && state1[i].count == state2[i].count else { return false }
            
            for j in 0..<state1[i].count {
                guard j < state2[i].count else { continue }
                
                totalCount += 1
                if state1[i][j] == state2[i][j] {
                    matchCount += 1
                }
            }
        }
        
        return Double(matchCount) / Double(totalCount) >= 0.8
    }
} 