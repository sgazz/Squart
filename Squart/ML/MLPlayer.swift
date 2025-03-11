import Foundation

// Klasa koja implementira AI igrača sa podrškom za ML
class MLPlayer {
    private let difficulty: AIDifficulty
    
    // Indikator da li koristimo ML ili klasični pristup
    private let useML: Bool
    
    init(difficulty: AIDifficulty = .hard, useML: Bool = true) {
        self.difficulty = difficulty
        self.useML = useML && MLPositionEvaluator.shared.isMLReady
    }
    
    // Glavna funkcija koja određuje najbolji potez za AI
    func findBestMove(for game: Game) -> (row: Int, column: Int)? {
        // Ako je igra završena, nema validnih poteza
        if game.isGameOver {
            return nil
        }
        
        // Ako ML nije spreman ili je nivo težine lak, koristimo postojeći AI
        if !useML || difficulty == .easy {
            let classicAI = AIPlayer(difficulty: difficulty)
            return classicAI.findBestMove(for: game)
        }
        
        // Za srednji i teški nivo koristimo ML
        return findBestMoveWithML(for: game)
    }
    
    // Funkcija koja koristi ML za određivanje najboljih poteza
    private func findBestMoveWithML(for game: Game) -> (row: Int, column: Int)? {
        let validMoves = getValidMoves(for: game.board, player: game.currentPlayer)
        
        if validMoves.isEmpty {
            return nil
        }
        
        // Nasumični faktor (5% vremena igra slučajno)
        if Double.random(in: 0...1) < 0.05 {
            return validMoves.randomElement()
        }
        
        var bestMove: (row: Int, column: Int)? = nil
        var bestScore = Int.min
        
        // Prilagodimo dubinu prema težini
        let maxDepth: Int = difficulty == .medium ? 2 : 3
        
        // Postavljamo maksimalno vreme za razmišljanje
        let maxThinkingTime: TimeInterval = difficulty == .medium ? 2.0 : 4.0
        let startTime = Date()
        
        // Razmatramo sve poteze, ali prvo procenjujemo njihov kvalitet koristeći ML
        // kako bismo prvo istražili najobećavajuće poteze
        
        // Prvo rangiramo poteze pomoću ML brzom procenom
        var ratedMoves: [(move: (row: Int, column: Int), score: Int)] = []
        
        for move in validMoves {
            let clonedGame = cloneGame(game)
            _ = clonedGame.makeMove(row: move.row, column: move.column)
            
            // Koristimo ML evaluator za inicijalnu, brzu procenu
            let score = MLPositionEvaluator.shared.evaluatePosition(clonedGame, player: game.currentPlayer)
            ratedMoves.append((move, score))
        }
        
        // Sortiramo poteze od najboljeg ka najgorem
        ratedMoves.sort { $0.score > $1.score }
        
        // Određujemo koliko poteza ćemo detaljno analizirati
        let movesToAnalyze = min(8, ratedMoves.count)
        let movesToConsider = ratedMoves.prefix(movesToAnalyze).map { $0.move }
        
        // Definišemo početne alfa i beta vrednosti za alfa-beta odsecanje
        let alpha = Int.min
        let beta = Int.max
        
        for move in movesToConsider {
            // Proveravamo da li je isteklo vreme za razmišljanje
            if Date().timeIntervalSince(startTime) > maxThinkingTime {
                print("ML AI: Prekinuto razmišljanje zbog vremenskog ograničenja")
                break
            }
            
            let clonedGame = cloneGame(game)
            _ = clonedGame.makeMove(row: move.row, column: move.column)
            
            // Koristimo minimax sa ML evaluacijom
            let score = mlAlphaBeta(clonedGame, depth: maxDepth, alpha: alpha, beta: beta, maximizingPlayer: false, originalPlayer: game.currentPlayer)
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        // Ako nismo našli potez, vratimo se na klasični AI
        if bestMove == nil {
            let classicAI = AIPlayer(difficulty: difficulty)
            return classicAI.findBestMove(for: game)
        }
        
        // Snimamo poteze za treniranje
        if let move = bestMove {
            GameDataCollector.shared.recordMove(row: move.row, column: move.column)
        }
        
        return bestMove
    }
    
    // Alfa-beta algoritam koji koristi ML za evaluaciju
    private func mlAlphaBeta(_ game: Game, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayer: Player) -> Int {
        // Bazni slučaj: dostigli smo maksimalnu dubinu ili igra je završena
        if depth == 0 || game.isGameOver {
            return MLPositionEvaluator.shared.evaluatePosition(game, player: originalPlayer)
        }
        
        let currentPlayer = game.currentPlayer
        let validMoves = getValidMoves(for: game.board, player: currentPlayer)
        
        // Ako nema validnih poteza, igra je završena
        if validMoves.isEmpty {
            // Trenutni igrač je izgubio (nema validnih poteza)
            let playerWon = currentPlayer != originalPlayer
            return playerWon ? 1000 : -1000
        }
        
        if maximizingPlayer {
            var value = Int.min
            var currentAlpha = alpha
            
            for move in validMoves {
                let clonedGame = cloneGame(game)
                _ = clonedGame.makeMove(row: move.row, column: move.column)
                
                value = max(value, mlAlphaBeta(clonedGame, depth: depth - 1, alpha: currentAlpha, beta: beta, maximizingPlayer: false, originalPlayer: originalPlayer))
                
                if value >= beta {
                    break // Beta odsecanje
                }
                
                currentAlpha = max(currentAlpha, value)
            }
            
            return value
        } else {
            var value = Int.max
            var currentBeta = beta
            
            for move in validMoves {
                let clonedGame = cloneGame(game)
                _ = clonedGame.makeMove(row: move.row, column: move.column)
                
                value = min(value, mlAlphaBeta(clonedGame, depth: depth - 1, alpha: alpha, beta: currentBeta, maximizingPlayer: true, originalPlayer: originalPlayer))
                
                if value <= alpha {
                    break // Alfa odsecanje
                }
                
                currentBeta = min(currentBeta, value)
            }
            
            return value
        }
    }
    
    // Pomoćne funkcije preuzete iz AIPlayer klase
    
    // Pomoćna funkcija za prikupljanje svih validnih poteza
    private func getValidMoves(for board: GameBoard, player: Player) -> [(row: Int, column: Int)] {
        var validMoves: [(row: Int, column: Int)] = []
        
        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.isValidMove(row: row, column: column, player: player) {
                    validMoves.append((row, column))
                }
            }
        }
        
        return validMoves
    }
    
    // Kopira igru za simulaciju poteza
    private func cloneGame(_ original: Game) -> Game {
        let clone = Game(boardSize: original.board.size)
        
        // Kopiramo stanje table
        for row in 0..<original.board.size {
            for column in 0..<original.board.size {
                clone.board.cells[row][column].type = original.board.cells[row][column].type
            }
        }
        
        clone.currentPlayer = original.currentPlayer
        return clone
    }
} 