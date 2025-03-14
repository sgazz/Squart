import Foundation

// MARK: - AI Difficulty Levels
/// Definiše različite nivoe težine za AI igrača
enum AIDifficulty: Int, CaseIterable, Codable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    /// Opis težine na srpskom jeziku
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
    
    // MARK: - Caching
    /// Keš za edge i corner pozicije za različite veličine table
    private var edgePositionsCache: [Int: Set<Position>] = [:]
    private var cornerPositionsCache: [Int: Set<Position>] = [:]
    private var centerPositionsCache: [Int: Set<Position>] = [:]
    
    // Tabela transformacija za mehanizam učenja i optimizaciju
    private var transpositionTable: [String: Int] = [:]
    
    // Tragovi za vizualizaciju razmišljanja
    private(set) var consideredMoves: [(row: Int, column: Int, score: Int)] = []
    
    // MARK: - Helper Types
    /// Pomoćna struktura za predstavljanje pozicije na tabli
    private struct Position: Hashable {
        let row: Int
        let column: Int
    }
    
    // MARK: - Initialization
    /// Inicijalizuje novog AI igrača
    /// - Parameter difficulty: Težina AI igrača
    init(difficulty: AIDifficulty = .medium) {
        self.difficulty = difficulty
        print("AI igrač inicijalizovan sa težinom: \(difficulty.description)")
    }
    
    // MARK: - Cache Management
    /// Inicijalizuje keš za tablu određene veličine ako već ne postoji
    /// - Parameter boardSize: Veličina table za koju se inicijalizuje keš
    private func initializeCacheIfNeeded(boardSize: Int) {
        // Ako već imamo keš za ovu veličinu table, ne radimo ništa
        if edgePositionsCache[boardSize] != nil {
            return
        }
        
        var edges = Set<Position>()
        var corners = Set<Position>()
        var centers = Set<Position>()
        
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                let position = Position(row: i, column: j)
                
                // Ćoškovi
                if (i == 0 && j == 0) ||
                   (i == 0 && j == boardSize - 1) ||
                   (i == boardSize - 1 && j == 0) ||
                   (i == boardSize - 1 && j == boardSize - 1) {
                    corners.insert(position)
                }
                // Ivice
                else if i == 0 || i == boardSize - 1 || j == 0 || j == boardSize - 1 {
                    edges.insert(position)
                }
                // Centar
                else if i >= boardSize/3 && i < boardSize*2/3 && j >= boardSize/3 && j < boardSize*2/3 {
                    centers.insert(position)
                }
            }
        }
        
        edgePositionsCache[boardSize] = edges
        cornerPositionsCache[boardSize] = corners
        centerPositionsCache[boardSize] = centers
    }
    
    // MARK: - Position Evaluation
    /// Proverava da li je potez na ivici table
    /// - Parameters:
    ///   - move: Potez koji se proverava
    ///   - boardSize: Veličina table
    /// - Returns: true ako je potez na ivici, false inače
    private func isEdgeMove(_ move: (row: Int, column: Int), boardSize: Int) -> Bool {
        initializeCacheIfNeeded(boardSize: boardSize)
        let position = Position(row: move.row, column: move.column)
        return edgePositionsCache[boardSize]?.contains(position) ?? false
    }
    
    /// Proverava da li je potez u ćošku table
    /// - Parameters:
    ///   - move: Potez koji se proverava
    ///   - boardSize: Veličina table
    /// - Returns: true ako je potez u ćošku, false inače
    private func isCornerMove(_ move: (row: Int, column: Int), boardSize: Int) -> Bool {
        initializeCacheIfNeeded(boardSize: boardSize)
        let position = Position(row: move.row, column: move.column)
        return cornerPositionsCache[boardSize]?.contains(position) ?? false
    }
    
    // MARK: - Move Selection
    /// Određuje najbolji potez za AI igrača
    /// - Parameter game: Trenutno stanje igre
    /// - Returns: Tuple sa redom i kolonom najboljeg poteza, ili nil ako nema validnih poteza
    func findBestMove(for game: Game) -> (row: Int, column: Int)? {
        // Resetujemo brojače
        evaluationCount = 0
        cacheHitCount = 0
        consideredMoves.removeAll()
        let startTime = Date()
        
        // Ako je igra završena, nema validnih poteza
        if game.isGameOver {
            return nil
        }
        
        // Implementacija zavisi od težine
        let move: (row: Int, column: Int)?
        switch difficulty {
        case .easy:
            move = findRandomMove(for: game)
        case .medium:
            move = findMediumMove(for: game)
        case .hard:
            move = findBestMoveMinMax(for: game)
        }
        
        // Računamo vreme razmišljanja
        lastMoveTime = Date().timeIntervalSince(startTime)
        
        // Poboljšano logovanje statistike
        let movesPerSecond = Double(evaluationCount) / lastMoveTime
        
        print("\n=== AI Performanse (\(difficulty.description)) ===")
        print("Vreme razmišljanja: \(String(format: "%.3f", lastMoveTime))s")
        print("Broj evaluacija: \(evaluationCount)")
        print("Evaluacije po sekundi: \(String(format: "%.0f", movesPerSecond))")
        
        return move
    }
    
    // MARK: - Strategy Implementation
    /// Implementira strategiju za laki nivo (nasumični potezi)
    private func findRandomMove(for game: Game) -> (row: Int, column: Int)? {
        let validMoves = getValidMoves(for: game.board, player: game.currentPlayer)
        return validMoves.randomElement()
    }
    
    /// Prikuplja sve validne poteze za trenutnog igrača
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
    
    // MARK: - Medium Level Strategy
    /// Implementira strategiju za srednji nivo (kombinacija strategije i nasumičnosti)
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
    
    // MARK: - Hard Level Strategy
    /// Implementira strategiju za teški nivo (minimax sa alfa-beta odsecanjem)
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
        
        // Optimizaciја: избегавамо стварање свих могућих потеза на почетку
        // Уместо тога, динамично ћемо их генерисати и сортирати по потенцијалу
        var possibleMoves: [(row: Int, column: Int, potentialValue: Int)] = []
        
        // Проналазимо све могуће потезе и процењујемо њихов потенцијал
        for row in 0..<boardSize {
            for column in 0..<boardSize {
                if game.board.cells[row][column].type == .empty {
                    var tempBoard = game.board
                    _ = tempBoard.placeMark(at: Position(row: row, column: column), for: game.currentPlayer)
                    let potentialValue = evaluateBoard(board: tempBoard, player: game.currentPlayer)
                    possibleMoves.append((row: row, column: column, potentialValue: potentialValue))
                }
            }
        }
        
        // Сортирамо потезе тако да прво оцењујемо најобећавајуће
        if game.currentPlayer == .blue {
            possibleMoves.sort { $0.potentialValue > $1.potentialValue } // За максимизујућег играча, већи потенцијал прво
        } else {
            possibleMoves.sort { $0.potentialValue < $1.potentialValue } // За минимизујућег играча, мањи потенцијал прво
        }
        
        for moveInfo in possibleMoves {
            let move = moveInfo.move
            var tempBoard = game.board
            _ = tempBoard.placeMark(at: Position(row: move.row, column: move.column), for: game.currentPlayer)
            
            // Додајемо бонус из историје учења
            var bonusFromHistory = moveInfo.potentialValue
            
            // Ограничавамо утицај историје - не може превазићи вредност гарантоване победе/пораза
            bonusFromHistory = min(bonusFromHistory, 500)
            bonusFromHistory = max(bonusFromHistory, -500)
            
            // Израчунавамо резултат за овај потез путем minimax алгоритма
            let score: Int
            if game.currentPlayer == .blue {
                score = alphaBetaMinimax(board: tempBoard, depth: maxDepth - 1, alpha: Int.min, beta: Int.max, isMaximizingPlayer: false) + bonusFromHistory
                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            } else {
                score = alphaBetaMinimax(board: tempBoard, depth: maxDepth - 1, alpha: Int.min, beta: Int.max, isMaximizingPlayer: true) - bonusFromHistory
                if score < bestScore {
                    bestScore = score
                    bestMove = move
                }
            }
            
            // Додајемо овај потез у листу размотрених потеза
            consideredMoves.append((row: move.row, column: move.column, score: score))
        }
        
        // Ako zbog vremenskog ograničenja nismo našli najbolji potez, koristimo srednji nivo
        return bestMove ?? findMediumMove(for: game)
    }
    
    // MARK: - Game Analysis
    /// Broji koliko poteza blokiramo protivniku
    private func countBlockedMoves(_ game: Game, originalPlayer: Player) -> Int {
        let opponent = originalPlayer == .blue ? Player.red : Player.blue
        let validMovesOpponent = getValidMoves(for: game.board, player: opponent)
        return validMovesOpponent.count
    }
    
    /// Evaluira trenutnu poziciju na tabli
    private func evaluatePosition(_ game: Game, originalPlayer: Player) -> Int {
        evaluationCount += 1
        
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
    
    // MARK: - Game Cloning
    /// Kreira kopiju igre za simulaciju poteza
    private func cloneGame(_ game: Game) -> Game {
        let clone = Game(boardSize: game.board.size)
        
        // Kopiramo stanje table
        for row in 0..<game.board.size {
            for column in 0..<game.board.size {
                clone.board.cells[row][column].type = game.board.cells[row][column].type
            }
        }
        
        clone.currentPlayer = game.currentPlayer
        return clone
    }
    
    // MARK: - Time Management
    /// Izračunava vreme razmišljanja za teški nivo
    private func calculateThinkingTime(boardSize: Int) -> TimeInterval {
        // Prilagođeno vreme za različite veličine table
        return min(1.0 + Double(boardSize) * 0.05, 3.0)
    }
    
    /// Izračunava vreme razmišljanja za srednji nivo
    private func calculateMediumThinkingTime(boardSize: Int) -> TimeInterval {
        // Kraće vreme za srednji nivo
        return min(0.5 + Double(boardSize) * 0.03, 1.5)
    }
    
    // MARK: - Helper Functions
    /// Broji poteze na ivicama
    private func countEdgeMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        return moves.filter { isEdgeMove($0, boardSize: boardSize) }.count
    }
    
    /// Broji poteze u ćoškovima
    private func countCornerMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        return moves.filter { isCornerMove($0, boardSize: boardSize) }.count
    }
    
    /// Broji poteze u centru table
    private func countCenterMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        let centerStart = boardSize / 3
        let centerEnd = boardSize - centerStart
        
        return moves.filter { move in
            move.row >= centerStart && move.row < centerEnd &&
            move.column >= centerStart && move.column < centerEnd
        }.count
    }
    
    /// Procenjuje koliko poteza smo blokirali protivniku
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
    
    // MARK: - Hard Level Strategy Helper Functions
    /// Ograničeni alfa-beta za srednji nivo (pojednostavljena verzija)
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
    
    /// Pojednostavljeni minimax za srednji nivo težine
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
    
    /// Alfa-beta minimax algoritam za evaluaciju poteza u dubinu
    private func alphaBetaMinimax(board: GameBoard, depth: Int, alpha: Int, beta: Int, isMaximizingPlayer: Bool) -> Int {
        // Увећавамо бројач чворова и тренутну дубину
        nodes += 1
        currentDepth = max(currentDepth, initialDepth - depth)
        
        // Креирамо хеш кључ за транспозициону табелу
        let boardKey = createBoardHash(for: board)
        
        // Проверавамо да ли смо већ израчунали вредност за ово стање
        if let cachedScore = transpositionTable[boardKey] {
            return cachedScore
        }
        
        // Проверавамо да ли смо достигли максималну дубину или крај игре
        if depth == 0 || board.checkForWinner() != nil || board.isFull() {
            let score = evaluateBoard(board: board, player: isMaximizingPlayer ? .red : .blue)
            
            // Чувамо резултат у транспозиционој табели
            transpositionTable[boardKey] = score
            
            return score
        }
        
        // Оптимизација: избегавамо стварање свих могућих потеза на почетку
        // Уместо тога, динамично ћемо их генерисати и сортирати по потенцијалу
        var possibleMoves: [(row: Int, column: Int, potentialValue: Int)] = []
        
        // Проналазимо све могуће потезе и процењујемо њихов потенцијал
        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.cells[row][column].type == .empty {
                    var tempBoard = board
                    _ = tempBoard.placeMark(at: Position(row: row, column: column), for: isMaximizingPlayer ? .blue : .red)
                    let potentialValue = evaluateBoard(board: tempBoard, player: isMaximizingPlayer ? .blue : .red)
                    possibleMoves.append((row: row, column: column, potentialValue: potentialValue))
                }
            }
        }
        
        // Сортирамо потезе тако да прво оцењујемо најобећавајуће
        if isMaximizingPlayer {
            possibleMoves.sort { $0.potentialValue > $1.potentialValue } // За максимизујућег играча, већи потенцијал прво
        } else {
            possibleMoves.sort { $0.potentialValue < $1.potentialValue } // За минимизујућег играча, мањи потенцијал прво
        }
        
        var currentAlpha = alpha
        var currentBeta = beta
        
        if isMaximizingPlayer {
            var maxEval = Int.min
            
            for move in possibleMoves {
                var tempBoard = board
                _ = tempBoard.placeMark(at: Position(row: move.row, column: move.column), for: .blue)
                
                let eval = alphaBetaMinimax(board: tempBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizingPlayer: false)
                maxEval = max(maxEval, eval)
                currentAlpha = max(currentAlpha, eval)
                
                if currentBeta <= currentAlpha {
                    break // Beta одсецање
                }
            }
            
            // Чувамо резултат у транспозиционој табели
            transpositionTable[boardKey] = maxEval
            
            return maxEval
        } else {
            var minEval = Int.max
            
            for move in possibleMoves {
                var tempBoard = board
                _ = tempBoard.placeMark(at: Position(row: move.row, column: move.column), for: .red)
                
                let eval = alphaBetaMinimax(board: tempBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizingPlayer: true)
                minEval = min(minEval, eval)
                currentBeta = min(currentBeta, eval)
                
                if currentBeta <= currentAlpha {
                    break // Alpha одсецање
                }
            }
            
            // Чувамо резултат у транспозиционој табели
            transpositionTable[boardKey] = minEval
            
            return minEval
        }
    }
    
    // MARK: - Pomoćna funkcija za ređanje poteza
    /// Ređa poteze po potencijalnom kvalitetu za bolju efikasnost alfa-beta odsecanja
    private func sortMoves(_ moves: [(row: Int, column: Int)], game: Game, player: Player) -> [(row: Int, column: Int)] {
        var scoredMoves: [(move: (row: Int, column: Int), score: Int)] = []
        
        for move in moves {
            var score = 0
            
            // Bonus za ivice
            if isEdgeMove(move, boardSize: game.board.size) {
                score += 3
            }
            
            // Bonus za ćoškove
            if isCornerMove(move, boardSize: game.board.size) {
                score += 5
            }
            
            // Bonus za centar
            if game.board.size >= 7 &&
               move.row >= game.board.size/3 && move.row < game.board.size*2/3 &&
               move.column >= game.board.size/3 && move.column < game.board.size*2/3 {
                score += 2
            }
            
            scoredMoves.append((move: move, score: score))
        }
        
        // Sortiramo poteze po skorovima (najviši prvo)
        scoredMoves.sort { $0.score > $1.score }
        
        // Vraćamo samo poteze
        return scoredMoves.map { $0.move }
    }
    
    /// Čišćenje tabele transformacija kako ne bi zauzimala previše memorije
    func clearTranspositionTable() {
        transpositionTable.removeAll()
    }
    
    // MARK: - New Method
    mutating func findBestMove(on board: GameBoard, for player: Player, considerDepth: Int) -> (row: Int, column: Int, score: Int) {
        self.nodes = 0
        self.currentDepth = 0
        
        // Креирамо листу могућих потеза
        var possibleMoves: [(row: Int, column: Int)] = []
        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.cells[row][column].type == .empty {
                    possibleMoves.append((row: row, column: column))
                }
            }
        }
        
        // Додајемо учење из историје ако имамо претходне потезе
        var evaluatedMoves = AILearningManager.evaluateMovesBasedOnHistory(
            moves: possibleMoves,
            boardState: board.getCellTypeArray(),
            player: player
        )
        
        // Примењујемо minimax алгоритам за сваки могући потез
        var bestMove: (row: Int, column: Int, score: Int) = (-1, -1, player == .blue ? Int.min : Int.max)
        var alpha = Int.min
        var beta = Int.max
        
        // Сортирамо потезе на основу бонуса из историје
        evaluatedMoves.sort { $0.bonus > $1.bonus }
        
        for moveInfo in evaluatedMoves {
            let move = moveInfo.move
            var tempBoard = board
            _ = tempBoard.placeMark(at: Position(row: move.row, column: move.column), for: player)
            
            // Додајемо бонус из историје учења
            var bonusFromHistory = moveInfo.bonus
            
            // Ограничавамо утицај историје - не може превазићи вредност гарантоване победе/пораза
            bonusFromHistory = min(bonusFromHistory, 500)
            bonusFromHistory = max(bonusFromHistory, -500)
            
            // Израчунавамо резултат за овај потез путем minimax алгоритма
            let score: Int
            if player == .blue {
                score = alphaBetaMinimax(board: tempBoard, depth: considerDepth - 1, alpha: alpha, beta: beta, isMaximizingPlayer: false) + bonusFromHistory
                if score > bestMove.score {
                    bestMove = (move.row, move.column, score)
                }
                alpha = max(alpha, score)
            } else {
                score = alphaBetaMinimax(board: tempBoard, depth: considerDepth - 1, alpha: alpha, beta: beta, isMaximizingPlayer: true) - bonusFromHistory
                if score < bestMove.score {
                    bestMove = (move.row, move.column, score)
                }
                beta = min(beta, score)
            }
            
            // Додајемо овај потез у листу размотрених потеза
            Game.shared.consideredMoves.append((row: move.row, column: move.column, score: score))
        }
        
        // Памтимо најбољи потез у историји учења
        if bestMove.row >= 0 && bestMove.column >= 0 {
            AILearningManager.recordMove(
                row: bestMove.row,
                column: bestMove.column,
                player: player,
                boardState: board.getCellTypeArray(),
                score: bestMove.score
            )
        }
        
        print("AI је размотрио \(nodes) чворова пре избора потеза \(bestMove.row), \(bestMove.column) са оценом \(bestMove.score)")
        return bestMove
    }
    
    // Оптимизовани minimax алгоритам са alpha-beta одсецањем и транспозиционом табелом
    private func alphaBetaMinimax(board: GameBoard, depth: Int, alpha: Int, beta: Int, isMaximizingPlayer: Bool) -> Int {
        // Увећавамо бројач чворова и тренутну дубину
        nodes += 1
        currentDepth = max(currentDepth, initialDepth - depth)
        
        // Креирамо хеш кључ за транспозициону табелу
        let boardKey = createBoardHash(for: board)
        
        // Проверавамо да ли смо већ израчунали вредност за ово стање
        if let cachedScore = transpositionTable[boardKey] {
            return cachedScore
        }
        
        // Проверавамо да ли смо достигли максималну дубину или крај игре
        if depth == 0 || board.checkForWinner() != nil || board.isFull() {
            let score = evaluateBoard(board: board, player: isMaximizingPlayer ? .red : .blue)
            
            // Чувамо резултат у транспозиционој табели
            transpositionTable[boardKey] = score
            
            return score
        }
        
        // Оптимизација: избегавамо стварање свих могућих потеза на почетку
        // Уместо тога, динамично ћемо их генерисати и сортирати по потенцијалу
        var possibleMoves: [(row: Int, column: Int, potentialValue: Int)] = []
        
        // Проналазимо све могуће потезе и процењујемо њихов потенцијал
        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.cells[row][column].type == .empty {
                    var tempBoard = board
                    _ = tempBoard.placeMark(at: Position(row: row, column: column), for: isMaximizingPlayer ? .blue : .red)
                    let potentialValue = evaluateBoard(board: tempBoard, player: isMaximizingPlayer ? .blue : .red)
                    possibleMoves.append((row: row, column: column, potentialValue: potentialValue))
                }
            }
        }
        
        // Сортирамо потезе тако да прво оцењујемо најобећавајуће
        if isMaximizingPlayer {
            possibleMoves.sort { $0.potentialValue > $1.potentialValue } // За максимизујућег играча, већи потенцијал прво
        } else {
            possibleMoves.sort { $0.potentialValue < $1.potentialValue } // За минимизујућег играча, мањи потенцијал прво
        }
        
        var currentAlpha = alpha
        var currentBeta = beta
        
        if isMaximizingPlayer {
            var maxEval = Int.min
            
            for move in possibleMoves {
                var tempBoard = board
                _ = tempBoard.placeMark(at: Position(row: move.row, column: move.column), for: .blue)
                
                let eval = alphaBetaMinimax(board: tempBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizingPlayer: false)
                maxEval = max(maxEval, eval)
                currentAlpha = max(currentAlpha, eval)
                
                if currentBeta <= currentAlpha {
                    break // Beta одсецање
                }
            }
            
            // Чувамо резултат у транспозиционој табели
            transpositionTable[boardKey] = maxEval
            
            return maxEval
        } else {
            var minEval = Int.max
            
            for move in possibleMoves {
                var tempBoard = board
                _ = tempBoard.placeMark(at: Position(row: move.row, column: move.column), for: .red)
                
                let eval = alphaBetaMinimax(board: tempBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizingPlayer: true)
                minEval = min(minEval, eval)
                currentBeta = min(currentBeta, eval)
                
                if currentBeta <= currentAlpha {
                    break // Alpha одсецање
                }
            }
            
            // Чувамо резултат у транспозиционој табели
            transpositionTable[boardKey] = minEval
            
            return minEval
        }
    }
    
    // Функција за креирање хеш кључа за стање табле
    private func createBoardHash(for board: GameBoard) -> String {
        var hashKey = ""
        for row in 0..<board.size {
            for column in 0..<board.size {
                let cell = board.cells[row][column]
                switch cell.type {
                case .empty: hashKey += "E"
                case .blocked: hashKey += "B"
                case .blue: hashKey += "L"
                case .red: hashKey += "R"
                }
            }
        }
        return hashKey
    }
} 