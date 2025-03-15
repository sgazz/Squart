import Foundation

enum CellType: Codable {
    case empty
    case blocked
    case blue
    case red
}

enum Player: Codable {
    case blue
    case red
    
    var cellType: CellType {
        switch self {
        case .blue: return .blue
        case .red: return .red
        }
    }
    
    var isHorizontal: Bool {
        switch self {
        case .blue: return true
        case .red: return false
        }
    }
}

struct BoardCell {
    var type: CellType
    let row: Int
    let column: Int
}

struct Position: Hashable {
    let row: Int
    let column: Int
}

class GameBoard: ObservableObject {
    @Published var cells: [[BoardCell]]
    let size: Int
    
    // Кеш за валидне потезе
    private var validMovesCache: [Player: Set<Position>] = [:]
    
    // Поништавамо кеш када се табла промени
    private func invalidateCache() {
        validMovesCache.removeAll()
    }
    
    init(size: Int) {
        self.size = size
        self.cells = []
        
        // Inicijalizacija prazne table
        for row in 0..<size {
            var rowCells: [BoardCell] = []
            for column in 0..<size {
                rowCells.append(BoardCell(type: .empty, row: row, column: column))
            }
            cells.append(rowCells)
        }
        
        // Dodavanje blokiranih (crnih) polja (17-19% od ukupnog broja polja)
        let totalCells = size * size
        let blockedCount = Int(Double(totalCells) * Double.random(in: 0.17...0.19))
        var blockedPositions = Set<Int>()
        
        while blockedPositions.count < blockedCount {
            let position = Int.random(in: 0..<totalCells)
            blockedPositions.insert(position)
        }
        
        for position in blockedPositions {
            let row = position / size
            let column = position % size
            cells[row][column].type = .blocked
        }
    }
    
    func isValidMove(row: Int, column: Int, player: Player) -> Bool {
        // Додајемо дијагностичке поруке
        print("isValidMove: Провера потеза на (\(row), \(column)) за играча \(player == .blue ? "плави" : "црвени")")
        
        // Директно користимо checkValidMove уместо кеша који има проблеме
        let result = checkValidMove(row: row, column: column, player: player)
        print("isValidMove: Резултат провере: \(result ? "валидан" : "неваљан")")
        return result
    }
    
    // Помоћна метода која проверава валидност потеза без кеширања
    private func checkValidMove(row: Int, column: Int, player: Player) -> Bool {
        // Провера граница табле
        guard row >= 0 && row < size && column >= 0 && column < size else { 
            print("checkValidMove: Позиција (\(row), \(column)) је изван граница табле \(size)x\(size)")
            return false 
        }
        
        // Провера да ли је поље празно
        guard cells[row][column].type == .empty else { 
            print("checkValidMove: Поље на (\(row), \(column)) није празно, тип: \(cells[row][column].type)")
            return false 
        }
        
        // Провера суседног поља у зависности од оријентације играча
        if player.isHorizontal {
            // Плави играч - хоризонтална оријентација
            guard column + 1 < size else {
                print("checkValidMove: Хоризонтални потез на (\(row), \(column)) би изашао изван табле")
                return false
            }
            
            guard cells[row][column + 1].type == .empty else {
                print("checkValidMove: Суседно хоризонтално поље на (\(row), \(column+1)) није празно, тип: \(cells[row][column+1].type)")
                return false
            }
            
            print("checkValidMove: Хоризонтални потез на (\(row), \(column)) је валидан")
            return true
        } else {
            // Црвени играч - вертикална оријентација
            guard row + 1 < size else {
                print("checkValidMove: Вертикални потез на (\(row), \(column)) би изашао изван табле")
                return false
            }
            
            guard cells[row + 1][column].type == .empty else {
                print("checkValidMove: Суседно вертикално поље на (\(row+1), \(column)) није празно, тип: \(cells[row+1][column].type)")
                return false
            }
            
            print("checkValidMove: Вертикални потез на (\(row), \(column)) је валидан")
            return true
        }
    }
    
    func makeMove(row: Int, column: Int, player: Player) -> Bool {
        print("makeMove(GameBoard): Покушај потеза на (\(row), \(column)) за играча \(player == .blue ? "плави" : "црвени")")
        
        guard isValidMove(row: row, column: column, player: player) else {
            print("makeMove(GameBoard): Потез није валидан")
            return false
        }
        
        print("makeMove(GameBoard): Постављање токена на (\(row), \(column))")
        cells[row][column].type = player.cellType
        
        if player.isHorizontal {
            print("makeMove(GameBoard): Постављање хоризонталног токена на (\(row), \(column+1))")
            cells[row][column + 1].type = player.cellType
        } else {
            print("makeMove(GameBoard): Постављање вертикалног токена на (\(row+1), \(column))")
            cells[row + 1][column].type = player.cellType
        }
        
        // Поништавамо кеш јер се табла променила
        invalidateCache()
        print("makeMove(GameBoard): Потез успешно извршен")
        return true
    }
    
    // Helper funkcija za proveru da li postoje validni potezi za igrača
    func hasValidMoves(for player: Player) -> Bool {
        print("hasValidMoves: Провера да ли играч \(player == .blue ? "плави" : "црвени") има валидне потезе")
        
        for row in 0..<size {
            for column in 0..<size {
                if isValidMove(row: row, column: column, player: player) {
                    print("hasValidMoves: Пронађен валидан потез на (\(row), \(column))")
                    return true
                }
            }
        }
        
        print("hasValidMoves: Нема валидних потеза за играча \(player == .blue ? "плави" : "црвени")")
        return false
    }
    
    /// Враћа листу свих валидних потеза за датог играча
    func getValidMoves(for player: Player) -> [(row: Int, column: Int)] {
        print("GameBoard.getValidMoves: Тражим валидне потезе за играча \(player == .blue ? "плави" : "црвени")")
        
        var validMoves: [(row: Int, column: Int)] = []
        
        for row in 0..<size {
            for column in 0..<size {
                if isValidMove(row: row, column: column, player: player) {
                    validMoves.append((row, column))
                }
            }
        }
        
        print("GameBoard.getValidMoves: Пронађено \(validMoves.count) валидних потеза")
        return validMoves
    }
}

class Game: ObservableObject {
    @Published var board: GameBoard
    @Published var currentPlayer: Player = .blue
    @Published var blueScore: Int = 0
    @Published var redScore: Int = 0
    @Published var isGameOver: Bool = false
    
    // Tajmeri za igrače
    @Published var blueTimeRemaining: Int
    @Published var redTimeRemaining: Int
    @Published var timerOption: TimerOption
    
    // AI podrška
    @Published var aiEnabled: Bool = false
    @Published var aiDifficulty: AIDifficulty = .medium
    private var asyncAIController: AsyncAIController?
    @Published var isAIThinking: Bool = false
    @Published var aiThinkingProgress: Double = 0
    
    // AI vs AI podrška
    @Published var aiVsAiMode: Bool = false
    @Published var secondAiDifficulty: AIDifficulty = .medium
    private var secondAsyncAIController: AsyncAIController?
    
    // Određuje tim koji igra AI (podrazumevano crveni)
    @Published var aiTeam: Player = .red
    
    // Praćenje koji igrač je prvi na potezu (za naizmenično smenjivanje)
    @Published var startingPlayer: Player = .blue
    
    // Razlog završetka igre
    enum GameEndReason {
        case noValidMoves  // Nema validnih poteza
        case blueTimeout   // Plavi igrač je ostao bez vremena
        case redTimeout    // Crveni igrač je ostao bez vremena
        case none          // Igra nije završena
    }
    
    @Published var gameEndReason: GameEndReason = .none
    
    /// Одређује победника и ажурира резултат
    private func odrediPobednika(razlog: GameEndReason) {
        print("odrediPobednika: Одређујем победника за разлог: \(razlog)")
        
        DispatchQueue.main.async {
            self.isGameOver = true
            self.gameEndReason = razlog
            
            switch razlog {
            case .noValidMoves:
                // Победио је претходни играч (онај који је последњи одigрао валидан потез)
                if self.currentPlayer == .red {
                    self.blueScore += 1
                    print("odrediPobednika: Плави је победио - нема валидних потеза")
                } else {
                    self.redScore += 1
                    print("odrediPobednika: Црвени је победио - нема валидних потеза")
                }
                
            case .blueTimeout:
                self.redScore += 1
                print("odrediPobednika: Црвени је победио - плави је остао без времена")
                
            case .redTimeout:
                self.blueScore += 1
                print("odrediPobednika: Плави је победио - црвени је остао без времена")
                
            case .none:
                print("odrediPobednika: Игра још није завршена")
                break
            }
        }
    }
    
    init(boardSize: Int = 7) {
        let timerOpt = GameSettingsManager.shared.timerOption
        self.board = GameBoard(size: boardSize)
        self.timerOption = timerOpt
        self.blueTimeRemaining = timerOpt.rawValue
        self.redTimeRemaining = timerOpt.rawValue
        
        // Сада можемо безбедно да користимо self у затварању
        DispatchQueue.main.async {
            // Ажурирамо вредности на главној нити
            self.timerOption = timerOpt
            self.blueTimeRemaining = timerOpt.rawValue
            self.redTimeRemaining = timerOpt.rawValue
        }
    }
    
    func makeMove(row: Int, column: Int) -> Bool {
        guard !isGameOver else { 
            print("makeMove: Игра је већ завршена, не могу да направим потез")
            return false 
        }
        
        print("makeMove: Покушавам да направим потез на (\(row), \(column)) за играча \(currentPlayer == .blue ? "плави" : "црвени")")
        
        if board.makeMove(row: row, column: column, player: currentPlayer) {
            print("makeMove: Потез је успешно направљен")
            
            // Промена играча
            DispatchQueue.main.async {
                self.currentPlayer = self.currentPlayer == .blue ? .red : .blue
            }
            
            // Provera da li sledeći igrač ima validne poteze
            if !board.hasValidMoves(for: currentPlayer) {
                print("makeMove: Следећи играч (\(currentPlayer == .blue ? "плави" : "црвени")) нема валидних потеза. Игра је завршена.")
                odrediPobednika(razlog: .noValidMoves)
            }
            
            return true
        } else {
            print("makeMove: Потез није валидан")
            return false
        }
    }
    
    func updateTimer() {
        guard !isGameOver else { return }
        guard timerOption != .none else { return }
        
        // Umanjujemo vreme trenutnom igraču (bez obzira da li AI razmišlja)
        if currentPlayer == .blue {
            DispatchQueue.main.async {
                self.blueTimeRemaining -= 1
            }
            
            // Проверавамо да ли је време критично (мање од 5 секунди)
            if blueTimeRemaining <= 5 && isAIThinking {
                print("updateTimer: Плави играч (AI) - критично време! Преостало: \(blueTimeRemaining)s")
                
                // Отказујемо AI размишљање ако је AI играч
                if aiVsAiMode || (aiEnabled && aiTeam == .blue) {
                    print("updateTimer: Отказујем размишљање за AI плавог играча због критичног времена")
                    otkaziRazmisljanjeAI()
                }
            }
            
            if blueTimeRemaining <= 0 {
                timeOut(for: .blue)
            }
        } else {
            DispatchQueue.main.async {
                self.redTimeRemaining -= 1
            }
            
            // Проверавамо да ли је време критично (мање од 5 секунди)
            if redTimeRemaining <= 5 && isAIThinking {
                print("updateTimer: Црвени играч (AI) - критично време! Преостало: \(redTimeRemaining)s")
                
                // Отказујемо AI размишљање ако је AI играч
                if aiVsAiMode || (aiEnabled && aiTeam == .red) {
                    print("updateTimer: Отказујем размишљање за AI црвеног играча због критичног времена")
                    otkaziRazmisljanjeAI()
                }
            }
            
            if redTimeRemaining <= 0 {
                timeOut(for: .red)
            }
        }
    }
    
    func timeOut(for player: Player) {
        odrediPobednika(razlog: player == .blue ? .blueTimeout : .redTimeout)
    }
    
    /// Ресетује стање AI играча
    private func resetAIPlayers() {
        print("resetAIPlayers: Ресетујем стање AI играча")
        
        // Ресетујемо стање размишљања
        DispatchQueue.main.async {
            self.isAIThinking = false
        }
        
        // Ресетујемо AI играче
        if let ai = asyncAIController {
            print("resetAIPlayers: Ресетујем главног AI играча")
            ai.resetCancelFlag()
        }
        
        if let secondAi = secondAsyncAIController {
            print("resetAIPlayers: Ресетујем другог AI играча")
            secondAi.resetCancelFlag()
        }
        
        // Поново иницијализујемо AI играче са тренутним подешавањима
        initializeAIPlayers()
    }
    
    func resetGame() {
        // Прво ресетујемо AI играче
        resetAIPlayers()
        
        let newBoard = GameBoard(size: self.board.size)
        let newStartingPlayer = self.startingPlayer == .blue ? Player.red : Player.blue
        let newTimerOption = GameSettingsManager.shared.timerOption
        
        DispatchQueue.main.async {
            self.board = newBoard
            self.startingPlayer = newStartingPlayer
            self.currentPlayer = newStartingPlayer
            
            self.isGameOver = false
            self.gameEndReason = .none
            
            // Resetovanje tajmera
            self.timerOption = newTimerOption
            self.blueTimeRemaining = newTimerOption.rawValue
            self.redTimeRemaining = newTimerOption.rawValue
        }
        
        // AI logika nakon resetovanja igre
        if aiEnabled {
            // Za AI vs AI mod, uvek pokrećemo AI potez, bez obzira koji igrač je trenutno
            if aiVsAiMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.makeAIMove()
                }
            }
            // Za standardni mod, pokrećemo AI potez samo ako je AI tim na potezu
            else if newStartingPlayer == aiTeam {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.makeAIMove()
                }
            }
        }
    }
    
    func resetStats() {
        DispatchQueue.main.async {
            self.blueScore = 0
            self.redScore = 0
        }
    }
    
    // AI funkcionalnosti
    
    // Inicijalizacija AI igrača
    func initializeAI(difficulty: AIDifficulty = .medium, team: Player = .red) {
        DispatchQueue.main.async {
            self.aiEnabled = true
            self.aiDifficulty = difficulty
            self.aiTeam = team
        }
        
        // Kreiranje glavnog AI igrača
        asyncAIController = AsyncAIController()
        
        // Proveravamo AI vs AI mod
        if GameSettingsManager.shared.aiVsAiMode {
            DispatchQueue.main.async {
                self.aiVsAiMode = true
                self.secondAiDifficulty = GameSettingsManager.shared.secondAiDifficulty
            }
            
            // Kreiramo i drugog AI igrača - plavi ako je prvi crveni, i obrnuto
            secondAsyncAIController = AsyncAIController()
            
            print("AI vs AI mod aktiviran:")
            print("Prvi AI (plavi): \(aiDifficulty)")
            print("Drugi AI (crveni): \(secondAiDifficulty)")
        } else {
            DispatchQueue.main.async {
                self.aiVsAiMode = false
            }
            secondAsyncAIController = nil
            print("Standardni mod aktiviran: AI igra kao \(team == .blue ? "plavi" : "crveni") tim, težina: \(difficulty)")
        }
    }
    
    // Metoda za AI potez
    func makeAIMove() {
        guard aiEnabled else {
            print("makeAIMove: AI није укључен")
            return
        }
        
        if aiVsAiMode {
            makeAIMoveForCurrentPlayer()
        } else if currentPlayer == aiTeam {
            print("makeAIMove: Стандардни мод: AI тим је \(aiTeam == .blue ? "плави" : "црвени"), тренутни играч је \(currentPlayer == .blue ? "плави" : "црвени")")
            makeAIMoveForCurrentPlayer()
        } else {
            print("makeAIMove: Стандардни мод: Тренутни играч \(currentPlayer == .blue ? "плави" : "црвени") није AI тим (\(aiTeam == .blue ? "плави" : "црвени"))")
        }
    }
    
    private func makeAIMoveForCurrentPlayer() {
        guard aiEnabled else {
            print("makeAIMoveForCurrentPlayer: Није AI на потезу")
            return
        }
        
        guard board.hasValidMoves(for: currentPlayer) else {
            print("makeAIMoveForCurrentPlayer: Нема валидних потеза за тренутног играча")
            return
        }
        
        // Inicijalizujemo AI kontroler ako ne postoji
        if asyncAIController == nil {
            asyncAIController = AsyncAIController()
        }
        
        // Postavljamo flag da AI razmišlja
        isAIThinking = true
        
        // Pokrećemo asinhrono razmišljanje
        Task {
            if let move = await asyncAIController?.makeMove(
                in: self,
                for: currentPlayer,
                difficulty: currentPlayer == aiTeam ? aiDifficulty : secondAiDifficulty
            ) {
                await MainActor.run {
                    print("makeAIMoveForCurrentPlayer: AI \(self.currentPlayer == .blue ? "плави" : "црвени") избор потеза: (\(move.row), \(move.column))")
                    
                    // Primenjujemo potez
                    if self.makeMove(row: move.row, column: move.column) {
                        // Ako je AI vs AI mod, planiramo sledeći potez
                        if self.aiVsAiMode && !self.isGameOver {
                            print("makeAIMoveForCurrentPlayer: Планирање следећег AI потеза за играча: \(self.currentPlayer == .blue ? "плави" : "црвени")")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.makeAIMove()
                            }
                        }
                    }
                    
                    // Resetujemo flag
                    self.isAIThinking = false
                }
            } else {
                await MainActor.run {
                    print("makeAIMoveForCurrentPlayer: AI \(self.currentPlayer == .blue ? "плави" : "црвени") није могао да пронађе валидни потез")
                    self.isAIThinking = false
                }
            }
        }
    }
    
    /// Отказује тренутно размишљање AI играча
    func otkaziRazmisljanjeAI() {
        print("otkaziRazmisljanjeAI: Отказујем размишљање AI играча")
        
        // Отказујемо тренутног AI играча
        if aiVsAiMode {
            if currentPlayer == .blue {
                asyncAIController?.cancelThinking()
            } else {
                secondAsyncAIController?.cancelThinking()
            }
        } else {
            asyncAIController?.cancelThinking()
        }
        
        DispatchQueue.main.async {
            self.isAIThinking = false
        }
    }
    
    /// Јавна метода за отказивање AI размишљања (може се позвати из UI)
    func cancelAIThinking() {
        print("cancelAIThinking: Захтев за отказивање AI размишљања")
        
        if !isAIThinking {
            print("cancelAIThinking: AI тренутно не размишља, нема шта да се откаже")
            return
        }
        
        // Користимо исту логику као и за отказивање због истека времена
        otkaziRazmisljanjeAI()
    }
    
    /// Иницијализује AI играче према тренутним подешавањима
    func initializeAIPlayers() {
        // Иницијализујемо главног AI играча
        if aiEnabled && asyncAIController == nil {
            print("initializeAIPlayers: Иницијализујем главног AI играча са тежином \(aiDifficulty.description)")
            asyncAIController = AsyncAIController()
        }
        
        // Иницијализујемо другог AI играча за AI vs AI мод
        if aiVsAiMode && secondAsyncAIController == nil {
            print("initializeAIPlayers: Иницијализујем другог AI играча са тежином \(secondAiDifficulty.description)")
            secondAsyncAIController = AsyncAIController()
        }
        
        // Подешавамо максимално време размишљања на основу опције тајмера
        if timerOption != .none {
            // Ако имамо тајмер, максимално време размишљања је 1/3 укупног времена, али не више од 10 секунди
            aiThinkingProgress = 0
        } else {
            // Ако немамо тајмер, максимално време размишљања је 10 секунди
            aiThinkingProgress = 1.0
        }
        
        print("initializeAIPlayers: Максимално време размишљања AI-а: \(aiThinkingProgress * 100)%")
    }
    
    /// Ажурира подешавања AI играча
    func updateAISettings(enabled: Bool, difficulty: AIDifficulty, team: Player, aiVsAi: Bool = false, secondDifficulty: AIDifficulty = .medium) {
        print("updateAISettings: Ажурирам подешавања AI играча")
        print("- AI укључен: \(enabled)")
        print("- Тежина: \(difficulty.description)")
        print("- Тим: \(team == .blue ? "плави" : "црвени")")
        print("- AI vs AI мод: \(aiVsAi)")
        if aiVsAi {
            print("- Тежина другог AI: \(secondDifficulty.description)")
        }
        
        // Ажурирамо основна подешавања
        DispatchQueue.main.async {
            self.aiEnabled = enabled
            self.aiDifficulty = difficulty
            self.aiTeam = team
            
            // Ажурирамо AI vs AI подешавања
            self.aiVsAiMode = aiVsAi
            self.secondAiDifficulty = secondDifficulty
        }
        
        // Ресетујемо AI играче да би се применила нова подешавања
        resetAIPlayers()
        
        // Ако је AI укључен и тренутни играч је AI, одмах покрећемо AI потез
        if aiEnabled {
            if aiVsAiMode {
                // У AI vs AI моду, увеk покрећемо AI потез
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeAIMove()
                }
            } else if currentPlayer == aiTeam {
                // У standardnom моду, покрећемо AI потез само ако је AI тим на потезу
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeAIMove()
                }
            }
        }
    }
    
    /// Креира копију тренутног стања игре за симулације
    func cloneGame() -> Game {
        print("cloneGame: Креирам копију игре")
        
        let clone = Game(boardSize: board.size)
        
        // Копирамо стање табле
        for row in 0..<board.size {
            for column in 0..<board.size {
                clone.board.cells[row][column].type = board.cells[row][column].type
            }
        }
        
        // Копирамо остале важне параметре
        clone.currentPlayer = currentPlayer
        clone.isGameOver = isGameOver
        clone.gameEndReason = gameEndReason
        clone.blueScore = blueScore
        clone.redScore = redScore
        clone.timerOption = timerOption
        clone.blueTimeRemaining = blueTimeRemaining
        clone.redTimeRemaining = redTimeRemaining
        
        // Копирамо AI подешавања
        clone.aiEnabled = aiEnabled
        clone.aiDifficulty = aiDifficulty
        clone.aiTeam = aiTeam
        clone.aiVsAiMode = aiVsAiMode
        clone.secondAiDifficulty = secondAiDifficulty
        
        print("cloneGame: Копија игре успешно креирана")
        return clone
    }
} 