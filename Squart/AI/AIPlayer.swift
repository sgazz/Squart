import Foundation

// MARK: - AI Difficulty Levels
/// Definiše različite nivoe težine za AI igrača
enum AIDifficulty: String, CaseIterable {
    case easy = "Лако"
    case medium = "Средње"
    case hard = "Тешко"
    
    var maxDepth: Int {
        switch self {
        case .easy: return 2
        case .medium: return 3
        case .hard: return 4
        }
    }
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
    private let difficulty: AIDifficulty
    private let aiTeam: Player
    private let cache: AICache
    private let evaluator: AIEvaluator
    private let search: AISearch
    
    // MARK: - Performance Tracking
    private var evaluationCount: Int = 0
    private var cacheHitCount: Int = 0
    private var lastMoveTime: TimeInterval = 0
    private var initialDepth: Int = 0
    private var currentDepth: Int = 0
    
    // MARK: - Caching
    /// Keš za edge i corner pozicije za različite veličine table
    private var edgePositionsCache: [Int: Set<Position>] = [:]
    private var cornerPositionsCache: [Int: Set<Position>] = [:]
    
    /// Табела транспозиције за оптимизацију минимакс алгоритма
    private var transpositionTable: [String: Int] = [:]
    
    // MARK: - Cancellation Support
    /// Заставица која означава да ли је размишљање отказано
    private var cancellationFlag: Bool = false
    
    // MARK: - Helper Types
    /// Pomоćna struktura za predstavljanje pozicije na tabli
    private struct Position: Hashable {
        let row: Int
        let column: Int
    }
    
    // MARK: - Initialization
    /// Inicijalizuje novi AI igrač sa određenim nivoom težine
    /// - Parameter difficulty: Nivo težine AI igrača (default: .medium)
    init(difficulty: AIDifficulty, aiTeam: Player) {
        self.difficulty = difficulty
        self.aiTeam = aiTeam
        
        print("AI igrač inicijalizovan sa težinom: \(difficulty.rawValue)")
        
        self.cache = AICache(maxSize: 1000000)
        self.evaluator = AIEvaluator()
        self.search = AISearch(
            maxDepth: difficulty.maxDepth,
            evaluator: evaluator,
            cache: cache
        )
    }
    
    // MARK: - Cache Management
    /// Inicijalizuje keš za tablu određene veličine ako već ne postoji
    /// - Parameter boardSize: Veličina table za koju se inicijalizuje keš
    private func initializeCacheIfNeeded(boardSize: Int) {
        // Ако већ имамо кеш за ову величину табле, прескачемо
        if edgePositionsCache[boardSize] != nil && cornerPositionsCache[boardSize] != nil {
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
        
        // Сигурно иницијализујемо речнике
        if edgePositionsCache[boardSize] == nil {
            edgePositionsCache[boardSize] = edges
        }
        
        if cornerPositionsCache[boardSize] == nil {
            cornerPositionsCache[boardSize] = corners
        }
    }
    
    // MARK: - Position Evaluation
    /// Proverava da li je potez na ivici table
    /// - Parameters:
    ///   - move: Potez koji se proverava
    ///   - boardSize: Veličina table
    /// - Returns: true ako je potez na ivici, false inače
    private func isEdgeMove(_ move: (row: Int, column: Int), boardSize: Int) -> Bool {
        guard boardSize > 0 else { return false }
        initializeCacheIfNeeded(boardSize: boardSize)
        
        // Директно проверимо да ли је позиција на ивици, чак и ако кеш није доступан
        if move.row == 0 || move.row == boardSize - 1 || move.column == 0 || move.column == boardSize - 1 {
            return true
        }
        
        // Сада проверимо кеш као додатну проверу
        if let edgeCache = edgePositionsCache[boardSize] {
            let position = Position(row: move.row, column: move.column)
            return edgeCache.contains(position)
        }
        
        return false
    }
    
    /// Proverava da li je potez u ćošku table
    /// - Parameters:
    ///   - move: Potez koji se proverava
    ///   - boardSize: Veličina table
    /// - Returns: true ako je potez u ćošku, false inače
    private func isCornerMove(_ move: (row: Int, column: Int), boardSize: Int) -> Bool {
        guard boardSize > 0 else { return false }
        initializeCacheIfNeeded(boardSize: boardSize)
        
        // Директно проверимо да ли је позиција у ћошку, чак и ако кеш није доступан
        if (move.row == 0 && move.column == 0) ||
           (move.row == 0 && move.column == boardSize - 1) ||
           (move.row == boardSize - 1 && move.column == 0) ||
           (move.row == boardSize - 1 && move.column == boardSize - 1) {
            return true
        }
        
        // Сада проверимо кеш као додатну проверу
        if let cornerCache = cornerPositionsCache[boardSize] {
            let position = Position(row: move.row, column: move.column)
            return cornerCache.contains(position)
        }
        
        return false
    }
    
    // MARK: - Move Selection
    /// Određuje najbolji potez za AI igrača
    /// - Parameter game: Trenutno stanje igre
    /// - Returns: Tuple sa redom i kolonom najboljeg poteza, ili nil ako nema validnih poteza
    func findBestMove(for game: Game) -> Position? {
        print("AIPlayer: Тражим најбољи потез за \(aiTeam == .blue ? "плавог" : "црвеног") играча")
        
        if game.currentPlayer != aiTeam {
            print("AIPlayer: Није AI на потезу")
            return nil
        }
        
        let move = search.findBestMove(for: game)
        
        if let move = move {
            print("AIPlayer: Нашао сам најбољи потез: (\(move.row), \(move.column))")
        } else {
            print("AIPlayer: Нема валидних потеза")
        }
        
        return move
    }
    
    // MARK: - Strategy Implementation
    /// Implementira strategiju za lak nivo (uglavnom nasumično sa malo strategije)
    private func findEasyMove(for game: Game) -> (row: Int, column: Int)? {
        print("findEasyMove: Тражим лак потез за играча \(aiTeam == .blue ? "плави" : "црвени")")
        
        let validMoves = getValidMoves(for: game.board, player: aiTeam)
        
        if validMoves.isEmpty {
            print("findEasyMove: Нема валидних потеза за играча \(aiTeam == .blue ? "плави" : "црвени")")
            return nil
        }
        
        // Одмах узимамо сигурносни насумични потез
        let safetyMove = validMoves.randomElement()
        print("findEasyMove: Сигурносни потез припремљен: \(safetyMove?.row ?? -1), \(safetyMove?.column ?? -1)")
        
        print("findEasyMove: Пронађено \(validMoves.count) валидних потеза")
        
        // 75% времена само играмо насумично (повећано са 60%)
        if Double.random(in: 0...1) < 0.75 {
            print("findEasyMove: Играм потпуно насумично (75% шанса)")
            return safetyMove
        }
        
        print("findEasyMove: Користим једноставну стратешку процену (25% шанса)")
        
        // Ограничавамо број потеза за анализу
        let movesToConsider = Array(validMoves.prefix(5))
        
        var bestMove: (row: Int, column: Int)? = nil
        var bestScore = Int.min
        
        // Фаворизујемо ћошкове и ивице када играмо стратешки
        for move in movesToConsider {
            let board = game.board
            
            // Једноставно бодовање - фаворизујемо ивице и ћошкове
            var score = 1 // Основни бод
            
            // Бонус за ивицу
            if isEdgeMove(move, boardSize: board.size) {
                score += 2
            }
            
            // Бонус за угао
            if isCornerMove(move, boardSize: board.size) {
                score += 3
            }
            
            // Додатни мали бонус за центар табле (само за веће табле)
            if board.size >= 7 &&
               move.row >= board.size/3 && move.row < board.size*2/3 &&
               move.column >= board.size/3 && move.column < board.size*2/3 {
                score += 1
            }
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        // Ако нисмо успели да проценимо ниједан потез, враћамо сигурносни потез
        if bestMove == nil {
            print("findEasyMove: Нема процењених потеза, враћам сигурносни потез")
            return safetyMove
        }
        
        // Додатна провера валидности
        if !game.board.isValidMove(row: bestMove!.row, column: bestMove!.column, player: aiTeam) {
            print("findEasyMove: УПОЗОРЕЊЕ - Изабрани потез није валидан! Враћам сигурносни потез.")
            return safetyMove
        }
        
        return bestMove
    }
    
    /// Враћа листу свих валидних потеза за датог играча на датој табли
    private func getValidMoves(for board: GameBoard, player: Player) -> [(row: Int, column: Int)] {
        print("AIPlayer.getValidMoves: Тражим валидне потезе за играча \(player == .blue ? "плави" : "црвени")")
        
        var validMoves: [(row: Int, column: Int)] = []
        
        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.isValidMove(row: row, column: column, player: player) {
                    validMoves.append((row, column))
                }
            }
        }
        
        print("AIPlayer.getValidMoves: Пронађено \(validMoves.count) валидних потеза")
        return validMoves
    }
    
    // MARK: - Medium Level Strategy
    /// Implementira strategiju za srednji nivo (kombinacija strategije i nasumičnosti)
    private func findMediumMove(for game: Game) -> (row: Int, column: Int)? {
        print("findMediumMove: Тражим потез средњег нивоа за играча \(aiTeam == .blue ? "плави" : "црвени")")
        
        let board = game.board
        let currentPlayer = aiTeam
        let validMoves = getValidMoves(for: game.board, player: currentPlayer)
        
        if validMoves.isEmpty {
            print("findMediumMove: Нема валидних потеза за играча \(currentPlayer == .blue ? "плави" : "црвени")")
            return nil
        }
        
        // Одмах узимамо сигурносни насумични потез
        let safetyMove = validMoves.randomElement()
        print("findMediumMove: Сигурносни потез припремљен: \(safetyMove?.row ?? -1), \(safetyMove?.column ?? -1)")
        
        print("findMediumMove: Пронађено \(validMoves.count) валидних потеза")
        
        // Смањујемо шансу за насумичан потез на 10%
        if Double.random(in: 0...1) < 0.1 {
            print("findMediumMove: Играм насумично (10% шанса)")
            return safetyMove
        }
        
        // Повећавамо шансу за коришћење минимакса на 50%
        if Double.random(in: 0...1) < 0.5 {
            print("findMediumMove: Користим поједностављени minimax (50% шанса)")
            let startTime = Date()
            let maxTime: TimeInterval = 2.0 // Повећавамо на 2 секунде
            
            // Разматрамо више потеза
            let movesToConsider = validMoves.count > 8 ? Array(validMoves.prefix(8)) : validMoves
            
            var bestMove: (row: Int, column: Int)? = nil
            var bestScore = Int.min
            
            for move in movesToConsider {
                // Прекидамо ако је истекло време за размишљање
                if Date().timeIntervalSince(startTime) > maxTime * 0.7 {
                    print("findMediumMove: Прекидам minimax анализу јер је истекло време")
                    break
                }
                
                let clonedGame = cloneGame(game)
                if !clonedGame.makeMove(row: move.row, column: move.column) {
                    continue
                }
                
                // Користимо дубљу претрагу
                let score = alphaBetaMinimax(
                    game: clonedGame,
                    depth: difficulty.maxDepth - 1,
                    alpha: Int.min,
                    beta: Int.max,
                    maximizingPlayer: false,
                    originalPlayer: currentPlayer,
                    startTime: startTime,
                    maxThinkingTime: maxTime
                )
                
                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            }
            
            if let miniMaxMove = bestMove {
                print("findMediumMove: Minimax потез: (\(miniMaxMove.row), \(miniMaxMove.column))")
                return miniMaxMove
            }
        }
        
        print("findMediumMove: Користим стратешку процену потеза")
        
        // Ограничавамо број потеза за процену
        let movesToRate = validMoves.count > 12 ? Array(validMoves.prefix(12)) : validMoves
        
        // Процењујемо сваки потез
        var ratedMoves: [(move: (row: Int, column: Int), score: Int)] = []
        let startTime = Date()
        let maxRatingTime: TimeInterval = 0.5 // Максимално пола секунде за процену
        
        for move in movesToRate {
            // Прекидамо ако је истекло 80% времена
            if Date().timeIntervalSince(startTime) > maxRatingTime * 0.8 {
                print("findMediumMove: Прекидам процену потеза због истека времена")
                break
            }
            
            // Симулирамо потез
            let clonedGame = cloneGame(game)
            if !clonedGame.makeMove(row: move.row, column: move.column) {
                continue
            }
            
            // Колико потеза блокирамо противнику овим потезом
            let blockedMoves = countBlockedMoves(clonedGame, originalPlayer: currentPlayer)
            
            // Добијамо више поена ако смо блокирали више противничких потеза
            let score = blockedMoves * 4
            
            // Бонус поени за потезе на ивицама (тежимо да контролишемо ивице)
            let edgeBonus = isEdgeMove(move, boardSize: board.size) ? 3 : 0
            
            // Бонус за ћошкове
            let cornerBonus = isCornerMove(move, boardSize: board.size) ? 4 : 0
            
            // Бонус за центар табле
            let centerBonus = board.size >= 7 && 
                          move.row >= board.size/3 && move.row < board.size*2/3 &&
                          move.column >= board.size/3 && move.column < board.size*2/3 ? 2 : 0
            
            // Упрошћена верзија процене предности у броју потеза (избегавамо спору рекурзију)
            let totalScore = score + edgeBonus + cornerBonus + centerBonus
            ratedMoves.append((move, totalScore))
        }
        
        // Ако нисмо успели да проценимо ниједан потез, враћамо сигурносни потез
        if ratedMoves.isEmpty {
            print("findMediumMove: Нема процењених потеза, враћам сигурносни потез")
            return safetyMove
        }
        
        // Сортирамо потезе по резултату (највећи прво)
        ratedMoves.sort { $0.score > $1.score }
        
        // Избор најбољег потеза, али са малом шансом за избор другог најбољег 
        // (како не би увек играо исто)
        let bestMove: (row: Int, column: Int)
        
        if ratedMoves.count > 1 && Double.random(in: 0...1) < 0.2 {
            // 20% шанса да изаберемо други најбољи потез
            bestMove = ratedMoves[1].move
            print("findMediumMove: Бирам други најбољи потез због разноврсности")
        } else {
            bestMove = ratedMoves.first!.move
        }
        
        print("findMediumMove: Најбољи потез: \(bestMove.row), \(bestMove.column)")
        
        // Додатна провера - да ли је изабрани потез валидан
        if !game.board.isValidMove(row: bestMove.row, column: bestMove.column, player: aiTeam) {
            print("findMediumMove: УПОЗОРЕЊЕ - Изабрани потез није валидан према табли!")
            return safetyMove
        }
        
        return bestMove
    }
    
    // MARK: - Search Depth Management
    /// Izračunava оптималну дубину претраге на основу величине табле
    private func calculateSearchDepth(boardSize: Int) -> Int {
        // Базна дубина зависи од тежине
        var depth = difficulty.maxDepth
        
        // Прилагођавамо дубину на основу величине табле
        switch boardSize {
        case 4...6: // Мале табле
            depth += 2 // Можемо дубље да претражујемо
        case 7...8: // Средње табле
            depth += 1
        case 9...10: // Веће табле
            depth = max(depth - 1, 4) // Смањујемо дубину али не испод 4
        default:
            depth = max(depth - 2, 3) // За веома велике табле, још више смањујемо
        }
        
        return depth
    }
    
    // MARK: - Hard Level Strategy
    /// Implementira strategiju za teški nivo (minimax sa alfa-beta odsecanjem)
    private func findBestMoveMinMax(for game: Game) -> (row: Int, column: Int)? {
        print("findBestMoveMinMax: Тражим најбољи потез за играча \(aiTeam == .blue ? "плави" : "црвени")")
        
        // Ресетујемо индикатор отказивања
        resetCancelFlag()
        
        let validMoves = getValidMoves(for: game.board, player: aiTeam)
        print("findBestMoveMinMax: Пронађено \(validMoves.count) валидних потеза")
        
        if validMoves.isEmpty {
            print("findBestMoveMinMax: Нема валидних потеза")
            return nil
        }
        
        // За сигурност одмах узимамо један насумични валидни потез за случај да не успемо да израчунамо најбољи
        let safetyMove = validMoves.randomElement()
        print("findBestMoveMinMax: Сигурносни потез припремљен: \(safetyMove?.row ?? -1), \(safetyMove?.column ?? -1)")
        
        // Одређујемо максималну дубину на основу величине табле и фазе игре
        let boardSize = game.board.size
        let maxDepth: Int
        let remainingMoves = validMoves.count
        let totalCells = boardSize * boardSize
        let gameProgress = Double(totalCells - remainingMoves) / Double(totalCells)
        
        switch boardSize {
        case 4...6: // Мале табле
            maxDepth = gameProgress > 0.7 ? 7 : 6 // Дубља претрага у завршници
        case 7...8: // Средње табле
            maxDepth = gameProgress > 0.7 ? 5 : 4
        case 9...10: // Веће табле
            maxDepth = gameProgress > 0.7 ? 4 : 3
        default:
            maxDepth = gameProgress > 0.7 ? 3 : 2
        }
        
        print("findBestMoveMinMax: Користим максималну дубину \(maxDepth) за таблу величине \(boardSize)")
        
        // Одређујемо максимално време за размишљање
        let maxThinkingTime = calculateThinkingTime(boardSize: boardSize)
        print("findBestMoveMinMax: Максимално време размишљања: \(maxThinkingTime) секунди")
        
        let startTime = Date()
        
        // За веће табле, фокусирамо се на стратешке потезе
        var strategicMoves = validMoves
        
        if boardSize >= 7 {
            // Издвајамо стратешке потезе
            let edgeMoves = validMoves.filter { isEdgeMove($0, boardSize: boardSize) }
            let cornerMoves = validMoves.filter { isCornerMove($0, boardSize: boardSize) }
            
            // Додајемо потезе у центру табле
            let centerMoves = validMoves.filter { move in
                let centerStart = boardSize/3
                let centerEnd = boardSize - centerStart
                return move.row >= centerStart && move.row < centerEnd &&
                       move.column >= centerStart && move.column < centerEnd
            }
            
            // Бирамо ограничени број стратешких потеза
            let maxMovesToConsider = min(10, validMoves.count) // Максимално 10 потеза
            
            var consideredMoves = Set<Position>()
            
            // Приоритет потеза:
            // 1. Углови (сви)
            for move in cornerMoves {
                consideredMoves.insert(Position(row: move.row, column: move.column))
                if consideredMoves.count >= maxMovesToConsider {
                    break
                }
            }
            
            // 2. Ивице (до лимита)
            if consideredMoves.count < maxMovesToConsider {
                for move in edgeMoves {
                    if consideredMoves.count >= maxMovesToConsider {
                        break
                    }
                    consideredMoves.insert(Position(row: move.row, column: move.column))
                }
            }
            
            // 3. Центар (до лимита)
            if consideredMoves.count < maxMovesToConsider {
                for move in centerMoves {
                    if consideredMoves.count >= maxMovesToConsider {
                        break
                    }
                    consideredMoves.insert(Position(row: move.row, column: move.column))
                }
            }
            
            // Филтрирамо потезе које ћемо разматрати
            strategicMoves = validMoves.filter { move in
                consideredMoves.contains(Position(row: move.row, column: move.column))
            }
        }
        
        var bestScore = Int.min
        var bestMove: (row: Int, column: Int)? = nil
        
        // Анализирамо сваки потез
        for move in strategicMoves {
            if isCancelled() {
                print("findBestMoveMinMax: Размишљање отказано")
                return safetyMove
            }
            
            if Date().timeIntervalSince(startTime) > maxThinkingTime * 0.95 {
                print("findBestMoveMinMax: Прекидам анализу због временског ограничења")
                break
            }
            
            let clonedGame = cloneGame(game)
            if !clonedGame.makeMove(row: move.row, column: move.column) {
                continue
            }
            
            let score = alphaBetaMinimax(
                game: clonedGame,
                depth: maxDepth - 1,
                alpha: Int.min,
                beta: Int.max,
                maximizingPlayer: false,
                originalPlayer: aiTeam,
                startTime: startTime,
                maxThinkingTime: maxThinkingTime
            )
            
            print("findBestMoveMinMax: Потез (\(move.row), \(move.column)) - оцена: \(score)")
            
            if score > bestScore {
                bestScore = score
                bestMove = move
                print("findBestMoveMinMax: Нови најбољи потез: (\(move.row), \(move.column)) са оценом \(score)")
            }
        }
        
        if bestMove == nil || isCancelled() {
            print("findBestMoveMinMax: Враћам сигурносни потез")
            return safetyMove
        }
        
        print("findBestMoveMinMax: Коначан најбољи потез: (\(bestMove!.row), \(bestMove!.column)) са оценом \(bestScore)")
        return bestMove
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
        if opponentValidMoves.isEmpty && aiTeam == opponent {
            return 100000 // Драстично повећавамо вредност победе
        }
        
        // Ako nema validnih poteza za nas, izgubili smo
        if myValidMoves.isEmpty && aiTeam == originalPlayer {
            return -100000 // Драстично повећавамо апсолутну вредност губитка
        }
        
        var score = 0
        
        // Мобилност - разлика u broју валидних потеза
        // Дајемо већи значај мобилности у раној и средњој фази игре
        let mobilityWeight = board.size >= 9 ? 25 : 20 // Повећавамо тежину мобилности
        let mobilityScore = (myValidMoves.count - opponentValidMoves.count) * mobilityWeight
        score += mobilityScore
        
        // Контрола ивица и ћошкова
        // На већим таблама, контрола ивица и ћошкова је важнија
        let edgeWeight = board.size >= 9 ? 8 : 6  // Дуплирамо тежине
        let cornerWeight = board.size >= 9 ? 12 : 10
        
        let edgeScore = (countEdgeMoves(myValidMoves, boardSize: board.size) * edgeWeight) -
                       (countEdgeMoves(opponentValidMoves, boardSize: board.size) * edgeWeight)
        score += edgeScore
        
        let cornerScore = (countCornerMoves(myValidMoves, boardSize: board.size) * cornerWeight) -
                         (countCornerMoves(opponentValidMoves, boardSize: board.size) * cornerWeight)
        score += cornerScore
        
        // Додајемо бонус за потезе који воде ка победи
        if opponentValidMoves.count <= 3 {
            score += (10 - opponentValidMoves.count) * 1000  // Велики бонус када смо близу победе
        }
        
        // Смањујемо случајност за јачу игру
        let randomRange = board.size >= 9 ? 2 : 3
        score += Int.random(in: -randomRange...randomRange)
        
        return score
    }
    
    // MARK: - Game Cloning
    /// Kreira kopiju igre za bezbedan rad sa AI simulacijama
    private func cloneGame(_ game: Game) -> Game {
        let clone = Game(boardSize: game.board.size)
        
        // Копирамо стање табле
        for row in 0..<game.board.size {
            for column in 0..<game.board.size {
                let cellType = game.board.cells[row][column].type
                if cellType != .empty {
                    // Постављамо токен директно на нову таблу
                    clone.board.cells[row][column].type = cellType
                }
            }
        }
        
        // Копирамо важне променљиве стања
        clone.currentPlayer = aiTeam
        clone.isGameOver = game.isGameOver
        clone.gameEndReason = game.gameEndReason
        
        // Не копирамо време јер није релевантно за симулације
        // Не копирамо бодове јер није релевантно за симулације
        
        return clone
    }
    
    // MARK: - Time Management
    /// Izračunava vreme razmišljanja za teški nivo
    private func calculateThinkingTime(boardSize: Int) -> TimeInterval {
        // Повећавамо базно време на 8 секунди
        let baseTime: TimeInterval = 8.0
        
        // Динамичко прилагођавање времена на основу величине табле и фазе игре
        switch boardSize {
        case 4...6: // Мале табле
            return baseTime * 2.0 // Више времена јер можемо дубље да претражујемо
        case 7...8: // Средње табле
            return baseTime * 1.5
        case 9...10: // Веће табле
            return baseTime * 1.2 // Повећавамо време за веће табле
        default:
            return baseTime
        }
    }
    
    /// Izračunava vreme razmišljanja za srednji nivo
    private func calculateMediumThinkingTime(boardSize: Int) -> TimeInterval {
        return calculateThinkingTime(boardSize: boardSize) * 0.6 // 60% времена тешког нивоа
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
    private func countCenterMoves(in board: GameBoard) -> Int {
        var centerMoves = 0
        let size = board.size
        let center = size / 2
        
        // Проверавамо централну ћелију
        if board.cells[center][center].type == .empty {
            centerMoves += 1
        }
        
        // Проверавамо суседне ћелије
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        for (dx, dy) in directions {
            let newRow = center + dx
            let newCol = center + dy
            
            if board.isValidPosition(row: newRow, column: newCol) &&
               board.cells[newRow][newCol].type == .empty {
                centerMoves += 1
            }
        }
        
        return centerMoves
    }
    
    /// Проверава да ли је размишљање отказано
    func isCancelled() -> Bool {
        if cancellationFlag {
            print("AIPlayer.isCancelled: Размишљање је отказано")
            return true
        }
        return false
    }
    
    /// Ресетује заставицу за отказивање размишљања
    func resetCancelFlag() {
        print("AIPlayer.resetCancelFlag: Ресетујем заставицу за отказивање")
        cancellationFlag = false
        search.resetCancelFlag()
    }
    
    /// Отказује тренутно размишљање AI-а
    func cancelThinking() {
        print("AIPlayer.cancelThinking: Отказујем тренутно размишљање")
        cancellationFlag = true
        search.cancel()
    }
    
    // MARK: - Minimax Algorithm
    /// Имплементира алфа-бета минимакс алгоритам за процену најбољег потеза
    private func alphaBetaMinimax(
        game: Game,
        depth: Int,
        alpha: Int,
        beta: Int,
        maximizingPlayer: Bool,
        originalPlayer: Player,
        startTime: Date,
        maxThinkingTime: TimeInterval
    ) -> Int {
        AIAnalytics.shared.visitNode(depth: depth)
        
        if depth == 0 || game.isGameOver {
            return evaluatePosition(game, originalPlayer: originalPlayer)
        }
        
        let currentPlayer = maximizingPlayer ? aiTeam : (aiTeam == .blue ? .red : .blue)
        let validMoves = getValidMoves(for: game.board, player: currentPlayer)
        
        if validMoves.isEmpty {
            return evaluatePosition(game, originalPlayer: originalPlayer)
        }
        
        if maximizingPlayer {
            var value = Int.min
            var currentAlpha = alpha
            
            for move in validMoves {
                let clonedGame = cloneGame(game)
                if !clonedGame.makeMove(row: move.row, column: move.column) {
                    continue
                }
                
                value = max(value, alphaBetaMinimax(
                    game: clonedGame,
                    depth: depth - 1,
                    alpha: currentAlpha,
                    beta: beta,
                    maximizingPlayer: false,
                    originalPlayer: originalPlayer,
                    startTime: startTime,
                    maxThinkingTime: maxThinkingTime
                ))
                
                if value >= beta {
                    AIAnalytics.shared.recordBetaCutoff()
                    break
                }
                currentAlpha = max(currentAlpha, value)
            }
            return value
        } else {
            var value = Int.max
            var currentBeta = beta
            
            for move in validMoves {
                let clonedGame = cloneGame(game)
                if !clonedGame.makeMove(row: move.row, column: move.column) {
                    continue
                }
                
                value = min(value, alphaBetaMinimax(
                    game: clonedGame,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: currentBeta,
                    maximizingPlayer: true,
                    originalPlayer: originalPlayer,
                    startTime: startTime,
                    maxThinkingTime: maxThinkingTime
                ))
                
                if value <= alpha {
                    AIAnalytics.shared.recordAlphaCutoff()
                    break
                }
                currentBeta = min(currentBeta, value)
            }
            return value
        }
    }
} 