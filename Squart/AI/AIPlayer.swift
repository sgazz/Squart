import Foundation

// Različiti nivoi težine za AI
enum AIDifficulty: Int, CaseIterable, Codable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    // Ovo ćemo koristiti samo za kompatibilnost sa starim kodom
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
    
    // Кеш за edge и corner позиције
    private var edgePositionsCache: [Int: Set<Position>] = [:]
    private var cornerPositionsCache: [Int: Set<Position>] = [:]
    
    // Помоћна структура за позиције
    private struct Position: Hashable {
        let row: Int
        let column: Int
    }
    
    init(difficulty: AIDifficulty = .medium) {
        self.difficulty = difficulty
    }
    
    // Иницијализација кеша за таблу одређене величине
    private func initializeCacheIfNeeded(boardSize: Int) {
        // Ако већ имамо кеш за ову величину табле, прескачемо
        if edgePositionsCache[boardSize] != nil {
            return
        }
        
        var edges = Set<Position>()
        var corners = Set<Position>()
        
        // Додајемо све ивичне позиције
        for i in 0..<boardSize {
            edges.insert(Position(row: 0, column: i))
            edges.insert(Position(row: boardSize - 1, column: i))
            edges.insert(Position(row: i, column: 0))
            edges.insert(Position(row: i, column: boardSize - 1))
        }
        
        // Додајемо ћошкове
        corners.insert(Position(row: 0, column: 0))
        corners.insert(Position(row: 0, column: boardSize - 1))
        corners.insert(Position(row: boardSize - 1, column: 0))
        corners.insert(Position(row: boardSize - 1, column: boardSize - 1))
        
        edgePositionsCache[boardSize] = edges
        cornerPositionsCache[boardSize] = corners
    }
    
    // Оптимизована провера за ивичне потезе
    private func isEdgeMove(_ move: (row: Int, column: Int), boardSize: Int) -> Bool {
        initializeCacheIfNeeded(boardSize: boardSize)
        let position = Position(row: move.row, column: move.column)
        return edgePositionsCache[boardSize]?.contains(position) ?? false
    }
    
    // Оптимизована провера за ћошкове
    private func isCornerMove(_ move: (row: Int, column: Int), boardSize: Int) -> Bool {
        initializeCacheIfNeeded(boardSize: boardSize)
        let position = Position(row: move.row, column: move.column)
        return cornerPositionsCache[boardSize]?.contains(position) ?? false
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
            // Za lak nivo, odmah vraćamo nasumični potez
            return findRandomMove(for: game)
        case .medium:
            // Za srednji nivo, kraće razmišljamo
            return findMediumMove(for: game)
        case .hard:
            // Za težak nivo, duže razmišljamo
            return findBestMoveMinMax(for: game)
        }
    }
    
    // Najjednostavniji AI - bira nasumični validni potez
    private func findRandomMove(for game: Game) -> (row: Int, column: Int)? {
        return getValidMoves(for: game.board, player: game.currentPlayer).randomElement()
    }
    
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
    
    // Srednji nivo - kombinuje nasumičnost sa nekom strategijom
    private func findMediumMove(for game: Game) -> (row: Int, column: Int)? {
        let board = game.board
        let currentPlayer = game.currentPlayer
        let validMoves = getValidMoves(for: board, player: currentPlayer)
        
        if validMoves.isEmpty {
            return nil
        }
        
        // Nasumični element koji određuje da li ćemo igrati strategijski ili nasumično
        // 90% vremena igramo strategijski, 10% nasumično (dodatno poboljšano)
        if Double.random(in: 0...1) < 0.1 {
            return validMoves.randomElement()
        }
        
        // U 40% slučajeva koristimo jednostavni minimax sa malom dubinom
        // za dodavanje naprednog razmišljanja (što čini igru izazovnijom)
        if Double.random(in: 0...1) < 0.4 {
            return findSimplifiedMinimaxMove(for: game)
        }
        
        // Procenjujemo svaki potez
        var ratedMoves: [(move: (row: Int, column: Int), score: Int)] = []
        
        for move in validMoves {
            // Simuliramo potez
            let clonedGame = cloneGame(game)
            _ = clonedGame.makeMove(row: move.row, column: move.column)
            
            // Koliko poteza blokiramo protivniku ovim potezom
            let blockedMoves = countBlockedMoves(clonedGame, originalPlayer: currentPlayer)
            
            // Dobijamo više poena ako smo blokirali više protivničkih poteza
            let score = blockedMoves * 4 // Povećan faktor sa 3 na 4
            
            // Bonus poeni za poteze na ivicama (težimo da kontrolišemo ivice)
            let edgeBonus = isEdgeMove(move, boardSize: board.size) ? 3 : 0 // Povećan sa 2 na 3
            
            // Bonus za ćoškove
            let cornerBonus = isCornerMove(move, boardSize: board.size) ? 4 : 0 // Povećan sa 3 na 4
            
            // Bonus za centar table
            let centerBonus = board.size >= 7 && 
                           move.row >= board.size/3 && move.row < board.size*2/3 &&
                           move.column >= board.size/3 && move.column < board.size*2/3 ? 2 : 0 // Povećan sa 1 na 2
            
            // Unapređeni algoritam za procenu poteza (sličnije teškom nivou)
            let opponent = currentPlayer == .blue ? Player.red : Player.blue
            let myMoves = getValidMoves(for: clonedGame.board, player: currentPlayer)
            let opponentMoves = getValidMoves(for: clonedGame.board, player: opponent)
            
            // Dodatni bonus: razlika u broju validnih poteza nakon ovog poteza (povećan faktor)
            let moveAdvantageBonus = (myMoves.count - opponentMoves.count) * 2 // Dodali smo množilac 2
            
            ratedMoves.append((move, score + edgeBonus + cornerBonus + centerBonus + moveAdvantageBonus))
        }
        
        // Sortiramo poteze po rezultatu (najveći prvo)
        ratedMoves.sort { $0.score > $1.score }
        
        // Izaberemo najbolji potez (smanjeno sa 2 na 1 za još veću preciznost)
        return ratedMoves.first?.move
    }
    
    // Функција за одређивање времена размишљања за средњи ниво
    private func calculateMediumThinkingTime(boardSize: Int) -> TimeInterval {
        // Базно време је 1 секунда
        let baseTime: TimeInterval = 1.0
        
        // За мање табле дајемо више времена јер су прорачуни лакши
        if boardSize <= 8 {
            return baseTime
        } else if boardSize <= 12 {
            return baseTime * 0.6
        } else {
            return baseTime * 0.4
        }
    }

    // Pojednostavljeni minimax za srednji nivo težine
    private func findSimplifiedMinimaxMove(for game: Game) -> (row: Int, column: Int)? {
        let validMoves = getValidMoves(for: game.board, player: game.currentPlayer)
        
        if validMoves.isEmpty {
            return nil
        }
        
        var bestMove: (row: Int, column: Int)? = nil
        var bestScore = Int.min
        
        // Smanjujemo dubinu za srednji nivo
        let maxDepth = 2
        
        // Користимо динамичко време за размишљање
        let maxThinkingTime = calculateMediumThinkingTime(boardSize: game.board.size)
        let startTime = Date()
        
        // Razmatramo samo deo poteza za bolje performanse
        let movesToConsider = validMoves.prefix(6)
        
        for move in movesToConsider {
            // Proveravamo da li je isteklo vreme za razmišljanje
            if Date().timeIntervalSince(startTime) > maxThinkingTime {
                print("AI (Medium): Prekinuto razmišljanje zbog vremenskog ograničenja")
                break
            }
            
            let clonedGame = cloneGame(game)
            _ = clonedGame.makeMove(row: move.row, column: move.column)
            
            let score = limitedAlphaBeta(clonedGame, depth: maxDepth, alpha: Int.min, beta: Int.max, maximizingPlayer: false, originalPlayer: game.currentPlayer)
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        return bestMove ?? validMoves.randomElement()
    }
    
    // Ograničeni alfa-beta za srednji nivo (pojednostavljena verzija)
    private func limitedAlphaBeta(_ game: Game, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayer: Player) -> Int {
        // Bazni slučaj: dostigli smo maksimalnu dubinu ili igra je završena
        if depth == 0 || game.isGameOver {
            return evaluatePosition(game, originalPlayer: originalPlayer)
        }
        
        let currentPlayer = game.currentPlayer
        let validMoves = getValidMoves(for: game.board, player: currentPlayer)
        
        // Ako nema validnih poteza, igra je završena
        if validMoves.isEmpty {
            // Trenutni igrač je izgubio (nema validnih poteza)
            let playerWon = currentPlayer != originalPlayer
            return playerWon ? 1000 : -1000
        }
        
        // Za srednji nivo, uzimamo samo nekoliko poteza u obzir za bolje performanse
        let movesToConsider = validMoves.prefix(max(5, validMoves.count / 3))
        
        if maximizingPlayer {
            var value = Int.min
            var currentAlpha = alpha
            
            for move in movesToConsider {
                let clonedGame = cloneGame(game)
                _ = clonedGame.makeMove(row: move.row, column: move.column)
                
                value = max(value, limitedAlphaBeta(clonedGame, depth: depth - 1, alpha: currentAlpha, beta: beta, maximizingPlayer: false, originalPlayer: originalPlayer))
                
                if value >= beta {
                    break // Beta odsecanje
                }
                
                currentAlpha = max(currentAlpha, value)
            }
            
            return value
        } else {
            var value = Int.max
            var currentBeta = beta
            
            for move in movesToConsider {
                let clonedGame = cloneGame(game)
                _ = clonedGame.makeMove(row: move.row, column: move.column)
                
                value = min(value, limitedAlphaBeta(clonedGame, depth: depth - 1, alpha: alpha, beta: currentBeta, maximizingPlayer: true, originalPlayer: originalPlayer))
                
                if value <= alpha {
                    break // Alfa odsecanje
                }
                
                currentBeta = min(currentBeta, value)
            }
            
            return value
        }
    }
    
    // Broji koliko validnih poteza je blokirano protivniku
    private func countBlockedMoves(_ game: Game, originalPlayer: Player) -> Int {
        let opponent = originalPlayer == .blue ? Player.red : Player.blue
        let validMovesOpponent = getValidMoves(for: game.board, player: opponent)
        return validMovesOpponent.count
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
    
    // Функција за одређивање времена размишљања базирано на величини табле
    private func calculateThinkingTime(boardSize: Int) -> TimeInterval {
        // Базно време је 2 секунде
        let baseTime: TimeInterval = 2.0
        
        // За мање табле дајемо више времена јер су прорачуни лакши
        if boardSize <= 8 {
            return baseTime
        } else if boardSize <= 12 {
            return baseTime * 0.8
        } else {
            return baseTime * 0.6
        }
    }

    // Напредни AI - користи minmax алгоритам за тражење најбољег потеза
    private func findBestMoveMinMax(for game: Game) -> (row: Int, column: Int)? {
        let validMoves = getValidMoves(for: game.board, player: game.currentPlayer)
        
        if validMoves.isEmpty {
            return nil
        }
        
        // Насумични фактор за тешки ниво - 5% времена игра слабије (смањено са 10%)
        if Double.random(in: 0...1) < 0.05 {
            return findMediumMove(for: game)
        }
        
        var bestMove: (row: Int, column: Int)? = nil
        var bestScore = Int.min
        
        // Прилагодимо дубину према величини табле
        let boardSize = game.board.size
        let maxDepth: Int
        
        // За веће табле користимо мању дубину
        if boardSize > 15 {
            maxDepth = 2
        } else if boardSize > 10 {
            maxDepth = 3
        } else {
            maxDepth = 3
        }
        
        // Користимо динамичко време за размишљање
        let maxThinkingTime = calculateThinkingTime(boardSize: boardSize)
        let startTime = Date()
        
        // Razmatramo samo deo poteza na većim tablama
        let movesToConsider: [((row: Int, column: Int))] = {
            if validMoves.count > 8 {
                // Na velikim tablama, razmotrimo samo ivične i nekoliko nasumičnih poteza
                var edgeMoves = validMoves.filter { isEdgeMove($0, boardSize: boardSize) }
                let remainingMoves = validMoves.filter { !isEdgeMove($0, boardSize: boardSize) }
                
                if edgeMoves.count < 6 {
                    edgeMoves.append(contentsOf: Array(remainingMoves.shuffled().prefix(6 - edgeMoves.count)))
                }
                return edgeMoves
            } else {
                return validMoves
            }
        }()
        
        for move in movesToConsider {
            // Proveravamo da li je isteklo vreme za razmišljanje
            if Date().timeIntervalSince(startTime) > maxThinkingTime {
                print("AI: Prekinuto razmišljanje zbog vremenskog ograničenja")
                break
            }
            
            let clonedGame = cloneGame(game)
            _ = clonedGame.makeMove(row: move.row, column: move.column)
            
            let score = alphaBetaMinimax(clonedGame, depth: maxDepth, alpha: Int.min, beta: Int.max, maximizingPlayer: false, originalPlayer: game.currentPlayer)
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        // Ako zbog vremenskog ograničenja nismo našli najbolji potez, koristimo srednji nivo
        return bestMove ?? findMediumMove(for: game)
    }
    
    // Alfa-beta minimax algoritam za evaluaciju poteza u dubinu
    private func alphaBetaMinimax(_ game: Game, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayer: Player) -> Int {
        // Bazni slučaj: dostigli smo maksimalnu dubinu ili igra je završena
        if depth == 0 || game.isGameOver {
            return evaluatePosition(game, originalPlayer: originalPlayer)
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
                
                value = max(value, alphaBetaMinimax(clonedGame, depth: depth - 1, alpha: currentAlpha, beta: beta, maximizingPlayer: false, originalPlayer: originalPlayer))
                
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
                
                value = min(value, alphaBetaMinimax(clonedGame, depth: depth - 1, alpha: alpha, beta: currentBeta, maximizingPlayer: true, originalPlayer: originalPlayer))
                
                if value <= alpha {
                    break // Alfa odsecanje
                }
                
                currentBeta = min(currentBeta, value)
            }
            
            return value
        }
    }
    
    // Minimax algoritam za evaluaciju poteza u dubinu (backup funkcija)
    private func minimax(_ game: Game, depth: Int, maximizingPlayer: Bool, originalPlayer: Player) -> Int {
        // Bazni slučaj: dostigli smo maksimalnu dubinu ili igra je završena
        if depth == 0 || game.isGameOver {
            return evaluatePosition(game, originalPlayer: originalPlayer)
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
            var maxScore = Int.min
            
            for move in validMoves {
                let clonedGame = cloneGame(game)
                _ = clonedGame.makeMove(row: move.row, column: move.column)
                
                let score = minimax(clonedGame, depth: depth - 1, maximizingPlayer: false, originalPlayer: originalPlayer)
                maxScore = max(maxScore, score)
            }
            
            return maxScore
        } else {
            var minScore = Int.max
            
            for move in validMoves {
                let clonedGame = cloneGame(game)
                _ = clonedGame.makeMove(row: move.row, column: move.column)
                
                let score = minimax(clonedGame, depth: depth - 1, maximizingPlayer: true, originalPlayer: originalPlayer)
                minScore = min(minScore, score)
            }
            
            return minScore
        }
    }
    
    // Funkcija za procenu pozicije na tabli
    private func evaluatePosition(_ game: Game, originalPlayer: Player) -> Int {
        let opponent = originalPlayer == .blue ? Player.red : Player.blue
        let board = game.board
        
        // Brojimo validne poteze za oba igrača
        let myValidMoves = getValidMoves(for: board, player: originalPlayer)
        let opponentValidMoves = getValidMoves(for: board, player: opponent)
        
        // Ako nema validnih poteza za protivnika, pobedili smo
        if opponentValidMoves.isEmpty && game.currentPlayer == opponent {
            return 1000
        }
        
        // Ako nema validnih poteza za nas, izgubili smo
        if myValidMoves.isEmpty && game.currentPlayer == originalPlayer {
            return -1000
        }
        
        var score = 0
        
        // Razlika u broju validnih poteza - što više poteza imamo u odnosu na protivnika, to bolje
        score += (myValidMoves.count - opponentValidMoves.count) * 5
        
        // Bonus za kontrolu ivica
        score += countEdgeMoves(myValidMoves, boardSize: board.size) * 2
        score -= countEdgeMoves(opponentValidMoves, boardSize: board.size) * 2
        
        // Bonus za kontrolu ćoškova
        score += countCornerMoves(myValidMoves, boardSize: board.size) * 3
        score -= countCornerMoves(opponentValidMoves, boardSize: board.size) * 3
        
        // Bonus za kontrolu centra (važniji na većim tablama)
        if board.size >= 7 {
            score += countCenterMoves(myValidMoves, boardSize: board.size) * 2
            score -= countCenterMoves(opponentValidMoves, boardSize: board.size) * 2
        }
        
        // Faktor koji uzima u obzir da li blokiramo protivničke poteze
        let blockedMoves = countBlockedMovesFromLastMove(game, originalPlayer: originalPlayer)
        score += blockedMoves * 3
        
        return score
    }
    
    // Broji poteze na ivicama
    private func countEdgeMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        return moves.filter { isEdgeMove($0, boardSize: boardSize) }.count
    }
    
    // Broji poteze u ćoškovima
    private func countCornerMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        return moves.filter { isCornerMove($0, boardSize: boardSize) }.count
    }
    
    // Broji poteze u centru table
    private func countCenterMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        let centerStart = boardSize / 3
        let centerEnd = boardSize - centerStart
        
        return moves.filter { move in
            move.row >= centerStart && move.row < centerEnd &&
            move.column >= centerStart && move.column < centerEnd
        }.count
    }
    
    // Procenjuje koliko poteza smo blokirali protivniku
    private func countBlockedMovesFromLastMove(_ game: Game, originalPlayer: Player) -> Int {
        // Procenjujemo koliko poteza protivnik ne može da igra
        let opponent = originalPlayer == .blue ? Player.red : Player.blue
        
        // Brojimo koliko polja je blokirano za protivnika
        var blockedCount = 0
        let board = game.board
        
        // Prolazimo kroz sva polja
        for row in 0..<board.size {
            for column in 0..<board.size {
                // Ako je polje prazno, proveravamo da li bi protivnik mogao da igra tu
                if board.cells[row][column].type == .empty {
                    if opponent.isHorizontal && column + 1 < board.size {
                        if board.cells[row][column + 1].type != .empty {
                            blockedCount += 1
                        }
                    } else if !opponent.isHorizontal && row + 1 < board.size {
                        if board.cells[row + 1][column].type != .empty {
                            blockedCount += 1
                        }
                    }
                }
            }
        }
        
        return blockedCount
    }
} 