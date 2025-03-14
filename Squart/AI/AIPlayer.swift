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
    
    /// Dubina pretrage za minimax algoritam
    var depth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
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
    private var isCancelled: Bool = false
    
    // MARK: - Helper Types
    /// Pomоćna struktura za predstavljanje pozicije na tabli
    private struct Position: Hashable {
        let row: Int
        let column: Int
    }
    
    // MARK: - Initialization
    /// Inicijalizuje novi AI igrač sa određenim nivoom težine
    /// - Parameter difficulty: Nivo težine AI igrača (default: .medium)
    init(difficulty: AIDifficulty = .medium) {
        self.difficulty = difficulty
        print("AI igrač inicijalizovan sa težinom: \(difficulty.description)")
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
    func findBestMove(for game: Game) -> (row: Int, column: Int)? {
        evaluationCount = 0
        cacheHitCount = 0
        transpositionTable.removeAll()
        
        let startTime = Date()
        
        // Прво проверавамо да ли је игра већ завршена
        if game.isGameOver {
            print("AI.findBestMove: Игра је већ завршена, нема валидних потеза")
            return nil
        }
        
        // Одмах добијамо све валидне потезе да бисмо знали да ли их уопште има
        let validMoves = getValidMoves(for: game.board, player: game.currentPlayer)
        
        if validMoves.isEmpty {
            print("AI.findBestMove: Нема валидних потеза за играча \(game.currentPlayer == .blue ? "плави" : "црвени")")
            return nil
        }
        
        // За сигурност одмах узимамо један насумични валидни потез као резерву
        let safetyMove = validMoves.randomElement()
        print("AI.findBestMove: Сигурносни потез припремљен: \(safetyMove?.row ?? -1), \(safetyMove?.column ?? -1)")
        
        var move: (row: Int, column: Int)?
        
        // Узимамо стратегију на основу нивоа тежине
        switch difficulty {
        case .easy:
            print("AI.findBestMove: Користим логику за лак ниво")
            move = findEasyMove(for: game)
        case .medium:
            print("AI.findBestMove: Користим логику за средњи ниво")
            move = findMediumMove(for: game)
        case .hard:
            print("AI.findBestMove: Користим логику за тежак ниво")
            move = findBestMoveMinMax(for: game)
        }
        
        // Ако стратегија није успела да нађе потез, враћамо сигурносни потез
        if move == nil {
            print("AI.findBestMove: Изабрана стратегија није нашла потез, користим сигурносни потез")
            move = safetyMove
        }
        
        let endTime = Date()
        let timeElapsed = endTime.timeIntervalSince(startTime)
        
        // Статистике за праћење перформанси
        print("AI.findBestMove: Евалуација завршена за \(String(format: "%.3f", timeElapsed))s")
        print("AI.findBestMove: Број евалуација: \(evaluationCount)")
        
        if evaluationCount > 0 {
            let cacheHitRate = Double(cacheHitCount) / Double(evaluationCount) * 100.0
            print("AI.findBestMove: Cache погоци: \(cacheHitCount) (\(String(format: "%.1f", cacheHitRate))%)")
            
            let movesPerSecond = Double(evaluationCount) / timeElapsed
            print("AI.findBestMove: Потеза по секунди: \(String(format: "%.1f", movesPerSecond))")
        }
        
        return move
    }
    
    // MARK: - Strategy Implementation
    /// Implementira strategiju za lak nivo (uglavnom nasumično sa malo strategije)
    private func findEasyMove(for game: Game) -> (row: Int, column: Int)? {
        print("findEasyMove: Тражим лак потез за играча \(game.currentPlayer == .blue ? "плави" : "црвени")")
        
        let validMoves = getValidMoves(for: game.board, player: game.currentPlayer)
        
        if validMoves.isEmpty {
            print("findEasyMove: Нема валидних потеза за играча \(game.currentPlayer == .blue ? "плави" : "црвени")")
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
        if !game.board.isValidMove(row: bestMove!.row, column: bestMove!.column, player: game.currentPlayer) {
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
        print("findMediumMove: Тражим потез средњег нивоа за играча \(game.currentPlayer == .blue ? "плави" : "црвени")")
        
        let board = game.board
        let currentPlayer = game.currentPlayer
        let validMoves = getValidMoves(for: game.board, player: currentPlayer)
        
        if validMoves.isEmpty {
            print("findMediumMove: Нема валидних потеза за играча \(currentPlayer == .blue ? "плави" : "црвени")")
            return nil
        }
        
        // Одмах узимамо сигурносни насумични потез
        let safetyMove = validMoves.randomElement()
        print("findMediumMove: Сигурносни потез припремљен: \(safetyMove?.row ?? -1), \(safetyMove?.column ?? -1)")
        
        print("findMediumMove: Пронађено \(validMoves.count) валидних потеза")
        
        // Насумични елемент који одређује да ли ћемо играти стратегијски или насумично
        // 25% времена играмо насумично (повећано са 10% за бржу игру)
        if Double.random(in: 0...1) < 0.25 {
            print("findMediumMove: Играм насумично (25% шанса)")
            return safetyMove
        }
        
        // Смањујемо учесталост коришћења минимакс алгоритма
        // 20% случајева користимо једноставни минимакс (смањено са 40%)
        if Double.random(in: 0...1) < 0.2 {
            print("findMediumMove: Користим поједностављени minimax (20% шанса)")
            let startTime = Date()
            let maxTime: TimeInterval = 1.0 // Ограничено на максимално 1 секунду
            
            // Ограничавамо број потеза за анализу
            let movesToConsider = validMoves.count > 5 ? Array(validMoves.prefix(5)) : validMoves
            
            var bestMove: (row: Int, column: Int)? = nil
            var bestScore = Int.min
            
            for move in movesToConsider {
                // Прекидамо ако је потрошено више од 70% времена
                if Date().timeIntervalSince(startTime) > maxTime * 0.7 {
                    print("findMediumMove: Прекидам minimax анализу јер је истекло време")
                    break
                }
                
                let clonedGame = cloneGame(game)
                if !clonedGame.makeMove(row: move.row, column: move.column) {
                    continue
                }
                
                // Користимо упрошћену евалуацију ради брзине
                let score = evaluatePosition(clonedGame, originalPlayer: currentPlayer)
                
                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            }
            
            if let miniMaxMove = bestMove {
                print("findMediumMove: Minimax потез: (\(miniMaxMove.row), \(miniMaxMove.column))")
                return miniMaxMove
            } else {
                print("findMediumMove: Нисам нашао добар потез, враћам сигурносни потез")
                return safetyMove
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
        if !game.board.isValidMove(row: bestMove.row, column: bestMove.column, player: game.currentPlayer) {
            print("findMediumMove: УПОЗОРЕЊЕ - Изабрани потез није валидан према табли!")
            return safetyMove
        }
        
        return bestMove
    }
    
    // MARK: - Hard Level Strategy
    /// Implementira strategiju za teški nivo (minimax sa alfa-beta odsecanjem)
    private func findBestMoveMinMax(for game: Game) -> (row: Int, column: Int)? {
        print("findBestMoveMinMax: Тражим најбољи потез за играча \(game.currentPlayer == .blue ? "плави" : "црвени")")
        
        // Ресетујемо индикатор отказивања
        resetCancelFlag()
        
        let validMoves = getValidMoves(for: game.board, player: game.currentPlayer)
        print("findBestMoveMinMax: Пронађено \(validMoves.count) валидних потеза")
        
        if validMoves.isEmpty {
            print("findBestMoveMinMax: Нема валидних потеза")
            return nil
        }
        
        // За сигурност одмах узимамо један насумични валидни потез за случај да не успемо да израчунамо најбољи
        let safetyMove = validMoves.randomElement()
        print("findBestMoveMinMax: Сигурносни потез припремљен: \(safetyMove?.row ?? -1), \(safetyMove?.column ?? -1)")
        
        // Додајемо случајни фактор - 5% времена играмо слабије да би игра била интересантнија
        if Double.random(in: 0...1) < 0.05 {
            print("findBestMoveMinMax: Намерно играм слабије (5% шанса)")
            return findMediumMove(for: game)
        }
        
        // Одређујемо максималну дубину на основу величине табле
        // Мање табле = већа дубина, веће табле = мања дубина
        let boardSize = game.board.size
        let maxDepth: Int
        
        switch boardSize {
        case 4...5: // Мале табле
            maxDepth = 6
        case 6: // Средња табла
            maxDepth = 5
        case 7: // Стандардна табла
            maxDepth = 4
        case 8...9: // Велике табле
            maxDepth = 3
        default: // Веома велике табле или веома мале
            maxDepth = boardSize <= 3 ? 7 : 2
        }
        
        print("findBestMoveMinMax: Користим максималну дубину \(maxDepth) за таблу величине \(boardSize)")
        
        // Одређујемо максимално време за размишљање на основу величине табле
        let maxThinkingTime: TimeInterval
        
        switch boardSize {
        case 4...5: // Мале табле - више времена није потребно
            maxThinkingTime = 3.0
        case 6: // Средња табла
            maxThinkingTime = 4.0
        case 7: // Стандардна табла
            maxThinkingTime = 5.0
        case 8...9: // Велике табле
            maxThinkingTime = 6.0
        default: // Веома велике табле или веома мале
            maxThinkingTime = boardSize <= 3 ? 2.0 : 8.0
        }
        
        print("findBestMoveMinMax: Максимално време размишљања: \(maxThinkingTime) секунди")
        
        // Време почетка размишљања
        let startTime = Date()
        
        // За веће табле ограничавамо разматрање потеза на стратешке позиције
        // (ћошкове, ивице, итд.) ради бољих перформанси
        var strategicMoves = validMoves
        
        if boardSize >= 7 && validMoves.count > 15 {
            // Издвајамо стратешке потезе
            let edgeMoves = validMoves.filter { isEdgeMove($0, boardSize: boardSize) }
            let cornerMoves = validMoves.filter { isCornerMove($0, boardSize: boardSize) }
            
            // Додајемо потезе у центру табле (за веће табле)
            let centerMoves = validMoves.filter { move in
                move.row >= boardSize/3 && move.row < boardSize*2/3 &&
                move.column >= boardSize/3 && move.column < boardSize*2/3
            }
            
            print("findBestMoveMinMax: Стратешки потези - ивице: \(edgeMoves.count), углови: \(cornerMoves.count), центар: \(centerMoves.count)")
            
            // Бирамо ограничени број стратешких потеза
            let maxMovesToConsider = 12 // Лимитирамо број потеза за разматрање
            
            // Приоритет:
            // 1. Углови (сви)
            // 2. Ивице (до лимита)
            // 3. Центар (до лимита)
            // 4. Остатак (до лимита)
            
            // Креирамо скуп стратешких потеза
            var consideredMoves = Set<Position>()
            
            // Додајемо све угаоне потезе
            for move in cornerMoves {
                consideredMoves.insert(Position(row: move.row, column: move.column))
            }
            
            // Додајемо ивичне потезе док не достигнемо лимит
            for move in edgeMoves {
                if consideredMoves.count >= maxMovesToConsider {
                    break
                }
                consideredMoves.insert(Position(row: move.row, column: move.column))
            }
            
            // Додајемо централне потезе док не достигнемо лимит
            for move in centerMoves {
                if consideredMoves.count >= maxMovesToConsider {
                    break
                }
                consideredMoves.insert(Position(row: move.row, column: move.column))
            }
            
            // Ако и даље немамо довољно потеза, додајемо насумичне преостале потезе
            if consideredMoves.count < maxMovesToConsider {
                // Мешамо преостале потезе да бисмо добили разнолико понашање
                let remainingMoves = validMoves.filter { move in
                    !consideredMoves.contains(Position(row: move.row, column: move.column))
                }.shuffled()
                
                for move in remainingMoves {
                    if consideredMoves.count >= maxMovesToConsider {
                        break
                    }
                    consideredMoves.insert(Position(row: move.row, column: move.column))
                }
            }
            
            // Претварамо скуп позиција назад у низ потеза
            strategicMoves = consideredMoves.map { ($0.row, $0.column) }
            
            print("findBestMoveMinMax: Разматрам \(strategicMoves.count) стратешких потеза од укупно \(validMoves.count)")
        }
        
        var bestMove: (row: Int, column: Int)? = nil
        var bestScore = Int.min
        
        // Анализирамо сваки потез
        for move in strategicMoves {
            // Прекидамо ако је затражено отказивање
            if checkCancellation() {
                print("findBestMoveMinMax: Размишљање отказано")
                return safetyMove
            }
            
            // Прекидамо анализу ако смо потрошили више од 95% времена
            if Date().timeIntervalSince(startTime) > maxThinkingTime * 0.95 {
                print("findBestMoveMinMax: Прекидам анализу јер се приближавамо временском ограничењу")
                break
            }
            
            let clonedGame = cloneGame(game)
            
            if !clonedGame.makeMove(row: move.row, column: move.column) {
                // Прескачемо ако је потез неважећи
                continue
            }
            
            // Зовемо alphaBetaMinimax са редукованом дубином за бржи одзив
            let score = alphaBetaMinimax(
                game: clonedGame, 
                depth: maxDepth - 1, 
                alpha: Int.min, 
                beta: Int.max, 
                maximizingPlayer: false,
                originalPlayer: game.currentPlayer,
                startTime: startTime,
                maxThinkingTime: maxThinkingTime
            )
            
            print("findBestMoveMinMax: Потез (\(move.row), \(move.column)) - оцена: \(score)")
            
            if score > bestScore {
                bestScore = score
                bestMove = move
                print("findBestMoveMinMax: Нови најбољи потез: (\(move.row), \(move.column)) са оценом \(score)")
            }
            
            // Ако је истекло 90% времена, прекидамо и враћамо најбољи досадашњи потез
            if Date().timeIntervalSince(startTime) > maxThinkingTime * 0.9 {
                print("findBestMoveMinMax: Досегнуто 90% временског ограничења, прекидам анализу")
                break
            }
        }
        
        // Ако нисмо успели да нађемо најбољи потез или је затражено отказивање, враћамо сигурносни потез
        if bestMove == nil || checkCancellation() {
            print("findBestMoveMinMax: Враћам сигурносни потез јер нисам нашао најбољи")
            return safetyMove
        }
        
        print("findBestMoveMinMax: Коначан најбољи потез: (\(bestMove!.row), \(bestMove!.column)) са оценом \(bestScore)")
        
        // Проверамо валидност најбољег потеза (за сигурност)
        if !game.board.isValidMove(row: bestMove!.row, column: bestMove!.column, player: game.currentPlayer) {
            print("findBestMoveMinMax: УПОЗОРЕЊЕ - Изабрани потез није валидан! Враћам сигурносни потез.")
            return safetyMove
        }
        
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
        clone.currentPlayer = game.currentPlayer
        clone.isGameOver = game.isGameOver
        clone.gameEndReason = game.gameEndReason
        
        // Не копирамо време јер није релевантно за симулације
        // Не копирамо бодове јер није релевантно за симулације
        
        return clone
    }
    
    // MARK: - Time Management
    /// Izračunava vreme razmišljanja za teški nivo
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
    
    /// Izračunava vreme razmišljanja za srednji nivo
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
        // Базни случај: досегли смо максималну дубину или игра је завршена
        if depth == 0 || game.isGameOver {
            return evaluatePosition(game, originalPlayer: originalPlayer)
        }
        
        // Директно користимо currentPlayer без guard let конструкције
        let currentPlayer = game.currentPlayer
        
        // Директно добављање валидних потеза без ослањања на кеш
        let validMoves = getValidMoves(for: game.board, player: currentPlayer)
        
        // Ако нема валидних потеза, игра је завршена
        if validMoves.isEmpty {
            // Тренутни играч је изгубио (нема валидних потеза)
            let playerWon = currentPlayer != originalPlayer
            let score = playerWon ? 1000 : -1000
            return score
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
        let movesToConsider = validMoves.count > 6 ? Array(validMoves.prefix(6)) : validMoves
        
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
    private func alphaBetaMinimax(
        game: Game,
        depth: Int,
        alpha: Int,
        beta: Int,
        maximizingPlayer: Bool,
        originalPlayer: Player,
        startTime: Date = Date(),
        maxThinkingTime: TimeInterval = 2.0
    ) -> Int {
        // Повећавамо број евалуација
        evaluationCount += 1
        
        // Прво проверавамо да ли је затражено отказивање размишљања
        if checkCancellation() {
            return evaluatePosition(game, originalPlayer: originalPlayer)
        }
        
        // Проверавамо да ли је време истекло
        if Date().timeIntervalSince(startTime) > maxThinkingTime * 0.9 {
            // Ако је време скоро истекло, прекидамо размишљање и враћамо тренутну процену
            return evaluatePosition(game, originalPlayer: originalPlayer)
        }
        
        // Базни случај: досегли смо максималну дубину или игра је завршена
        if depth == 0 || game.isGameOver {
            return evaluatePosition(game, originalPlayer: originalPlayer)
        }
        
        // Директно користимо currentPlayer без guard let конструкције
        let currentPlayer = game.currentPlayer
        
        // Директно добављање валидних потеза без ослањања на кеш
        let validMoves = getValidMoves(for: game.board, player: currentPlayer)
        
        // Ако нема валидних потеза, игра је завршена
        if validMoves.isEmpty {
            // Тренутни играч је изгубио (нема валидних потеза)
            let playerWon = currentPlayer != originalPlayer
            let score = playerWon ? 1000 : -1000
            return score
        }
        
        // Ако имамо превише потеза, узимамо само неке
        let movesToAnalyze = validMoves.count > 12 ? Array(validMoves.prefix(12)) : validMoves
        
        if maximizingPlayer {
            var value = Int.min
            var currentAlpha = alpha
            
            for move in movesToAnalyze {
                // Прекидамо ако је затражено отказивање размишљања
                if checkCancellation() {
                    break
                }
                
                // Прекидамо ако је време истекло
                if Date().timeIntervalSince(startTime) > maxThinkingTime * 0.95 {
                    break
                }
                
                // Креирамо копију игре и симулирамо потез
                let clonedGame = cloneGame(game)
                if !clonedGame.makeMove(row: move.row, column: move.column) {
                    // Ако потез није валидан, прескачемо
                    continue
                }
                
                // Рекурзивно позивамо alphaBetaMinimax
                let moveValue = alphaBetaMinimax(
                    game: clonedGame,
                    depth: depth - 1,
                    alpha: currentAlpha,
                    beta: beta,
                    maximizingPlayer: false,
                    originalPlayer: originalPlayer,
                    startTime: startTime,
                    maxThinkingTime: maxThinkingTime
                )
                value = max(value, moveValue)
                
                if value >= beta {
                    break // Beta odsecanje
                }
                
                currentAlpha = max(currentAlpha, value)
            }
            
            return value
        } else {
            var value = Int.max
            var currentBeta = beta
            
            for move in movesToAnalyze {
                // Прекидамо ако је затражено отказивање размишљања
                if checkCancellation() {
                    break
                }
                
                // Прекидамо ако је време истекло
                if Date().timeIntervalSince(startTime) > maxThinkingTime * 0.95 {
                    break
                }
                
                // Креирамо копију игре и симулирамо потез
                let clonedGame = cloneGame(game)
                if !clonedGame.makeMove(row: move.row, column: move.column) {
                    // Ако потез није валидан, прескачемо
                    continue
                }
                
                // Рекурзивно позивамо alphaBetaMinimax
                let moveValue = alphaBetaMinimax(
                    game: clonedGame,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: currentBeta,
                    maximizingPlayer: true,
                    originalPlayer: originalPlayer,
                    startTime: startTime,
                    maxThinkingTime: maxThinkingTime
                )
                value = min(value, moveValue)
                
                if value <= alpha {
                    break // Alfa odsecanje
                }
                
                currentBeta = min(currentBeta, value)
            }
            
            return value
        }
    }
    
    /// Ресетује заставицу за отказивање размишљања
    func resetCancelFlag() {
        print("AIPlayer.resetCancelFlag: Ресетујем заставицу за отказивање")
        isCancelled = false
    }
    
    /// Отказује тренутно размишљање AI-а
    func cancelThinking() {
        print("AIPlayer.cancelThinking: Отказујем тренутно размишљање")
        isCancelled = true
    }
    
    /// Проверава да ли је размишљање отказано
    private func checkCancellation() -> Bool {
        if isCancelled {
            print("AIPlayer.checkCancellation: Размишљање је отказано")
            return true
        }
        return false
    }
} 