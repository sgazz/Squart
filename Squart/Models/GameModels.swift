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
    private var aiPlayer: AIPlayer?
    @Published var isAIThinking: Bool = false
    
    // Праћење времена размишљања AI-а
    private var aiThinkingStartTime: Date?
    private var aiMaxThinkingTime: TimeInterval = 10.0 // Максимално 10 секунди размишљања
    
    // Određuje tim koji igra AI (podrazumevano crveni)
    @Published var aiTeam: Player = .red
    
    // Podrška za drugi AI u AI vs AI modu
    @Published var aiVsAiMode: Bool = false
    @Published var secondAiDifficulty: AIDifficulty = .medium
    private var secondAiPlayer: AIPlayer?
    
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
    
    init(boardSize: Int = 7) {
        self.board = GameBoard(size: boardSize)
        let timerOpt = GameSettingsManager.shared.timerOption
        self.timerOption = timerOpt
        self.blueTimeRemaining = timerOpt.rawValue
        self.redTimeRemaining = timerOpt.rawValue
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
            currentPlayer = currentPlayer == .blue ? .red : .blue
            
            // Provera da li sledeći igrač ima validne poteze
            if !board.hasValidMoves(for: currentPlayer) {
                print("makeMove: Следећи играч (\(currentPlayer == .blue ? "плави" : "црвени")) нема валидних потеза. Игра је завршена.")
                isGameOver = true
                gameEndReason = .noValidMoves
                // Pobeđuje prethodni igrač (onaj koji je upravo odigrao potez)
                if currentPlayer == .red { // ako je sledeći crveni, znači da je plavi pobedio
                    blueScore += 1
                    print("makeMove: Плави је победио!")
                } else {
                    redScore += 1
                    print("makeMove: Црвени је победио!")
                }
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
            blueTimeRemaining -= 1
            
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
            redTimeRemaining -= 1
            
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
        isGameOver = true
        
        if player == .blue {
            gameEndReason = .blueTimeout
            redScore += 1  // Crveni igrač pobeđuje
        } else {
            gameEndReason = .redTimeout
            blueScore += 1  // Plavi igrač pobeđuje
        }
    }
    
    /// Ресетује стање AI играча
    private func resetAIPlayers() {
        print("resetAIPlayers: Ресетујем стање AI играча")
        
        // Ресетујемо стање размишљања
        isAIThinking = false
        aiThinkingStartTime = nil
        
        // Ресетујемо AI играче
        if let ai = aiPlayer {
            print("resetAIPlayers: Ресетујем главног AI играча")
            ai.resetCancelFlag()
        }
        
        if let secondAi = secondAiPlayer {
            print("resetAIPlayers: Ресетујем другог AI играча")
            secondAi.resetCancelFlag()
        }
        
        // Поново иницијализујемо AI играче са тренутним подешавањима
        initializeAIPlayers()
    }
    
    func resetGame() {
        // Прво ресетујемо AI играче
        resetAIPlayers()
        
        board = GameBoard(size: board.size)
        
        // Наizmenično menjanje prvog igrača
        startingPlayer = startingPlayer == .blue ? .red : .blue
        currentPlayer = startingPlayer
        
        isGameOver = false
        gameEndReason = .none
        
        // Resetovanje tajmera
        timerOption = GameSettingsManager.shared.timerOption
        blueTimeRemaining = timerOption.rawValue
        redTimeRemaining = timerOption.rawValue
        
        // AI logika nakon resetovanja igre
        if aiEnabled {
            // Za AI vs AI mod, uvek pokrećemo AI potez, bez obzira koji igrač je trenutno
            if aiVsAiMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.makeAIMove()
                }
            }
            // Za standardni mod, pokrećemo AI potez samo ako je AI tim na potezu
            else if currentPlayer == aiTeam {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.makeAIMove()
                }
            }
        }
    }
    
    func resetStats() {
        blueScore = 0
        redScore = 0
    }
    
    // AI funkcionalnosti
    
    // Inicijalizacija AI igrača
    func initializeAI(difficulty: AIDifficulty = .medium, team: Player = .red) {
        aiEnabled = true
        aiDifficulty = difficulty
        aiTeam = team
        
        // Kreiranje glavnog AI igrača
        aiPlayer = AIPlayer(difficulty: difficulty)
        
        // Proveravamo AI vs AI mod
        if GameSettingsManager.shared.aiVsAiMode {
            aiVsAiMode = true
            secondAiDifficulty = GameSettingsManager.shared.secondAiDifficulty
            
            // Kreiramo i drugog AI igrača - plavi ako je prvi crveni, i obrnuto
            secondAiPlayer = AIPlayer(difficulty: secondAiDifficulty)
            
            print("AI vs AI mod aktiviran:")
            print("Prvi AI (plavi): \(aiDifficulty)")
            print("Drugi AI (crveni): \(secondAiDifficulty)")
        } else {
            aiVsAiMode = false
            secondAiPlayer = nil
            print("Standardni mod aktiviran: AI igra kao \(team == .blue ? "plavi" : "crveni") tim, težina: \(difficulty)")
        }
    }
    
    // Metoda za AI potez
    func makeAIMove() {
        guard !isGameOver else { return }
        
        // Иницијализујемо AI играче ако нису већ иницијализовани
        initializeAIPlayers()
        
        if aiVsAiMode {
            // U AI vs AI modu, oba igrača su AI
            makeAIMoveForCurrentPlayer()
        } else if aiEnabled && currentPlayer == aiTeam {
            // U standardnom modu, samo jedan tim je AI
            print("makeAIMove: Стандардни мод: AI тим је \(aiTeam == .blue ? "плави" : "црвени"), тренутни играч је \(currentPlayer == .blue ? "плави" : "црвени")")
            
            isAIThinking = true
            
            // Постављамо време почетка размишљања
            aiThinkingStartTime = Date()
            
            print("makeAIMove: Стандардни мод: AI \(currentPlayer == .blue ? "плави" : "црвени") размишља...")
            
            // Prebacujemo AI razmišljanje на background thread
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                
                // Додајемо проверу времена размишљања
                let checkThinkingTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    guard let self = self, let startTime = self.aiThinkingStartTime else {
                        timer.invalidate()
                        return
                    }
                    
                    let thinkingTime = Date().timeIntervalSince(startTime)
                    if thinkingTime > self.aiMaxThinkingTime {
                        print("makeAIMove: AI размишља предуго (\(String(format: "%.1f", thinkingTime))s), прекидам размишљање")
                        self.cancelAIThinking()
                        timer.invalidate()
                    }
                }
                
                // AI razmišlja i nalazi najbolji potez
                if let bestMove = self.aiPlayer?.findBestMove(for: self) {
                    // Заустављамо тајмер за проверу времена
                    checkThinkingTime.invalidate()
                    
                    // Vraćamo se na main thread za ažuriranje UI
                    DispatchQueue.main.async {
                        self.isAIThinking = false
                        self.aiThinkingStartTime = nil
                        
                        print("makeAIMove: Стандардни мод: AI одиграо потез на: (\(bestMove.row), \(bestMove.column))")
                        
                        let moveResult = self.makeMove(row: bestMove.row, column: bestMove.column)
                        print("makeAIMove: Резултат AI потеза: \(moveResult ? "успешно" : "неуспешно")")
                    }
                } else {
                    // Заустављамо тајмер за проверу времена
                    checkThinkingTime.invalidate()
                    
                    DispatchQueue.main.async {
                        self.isAIThinking = false
                        self.aiThinkingStartTime = nil
                        
                        print("makeAIMove: Стандардни мод: AI није могао да пронађе валидни потез")
                        
                        // Ако AI не може да нађе потез, то значи да нема валидних потеза
                        // Означавамо игру као завршену
                        if !self.isGameOver {
                            print("makeAIMove: Нема валидних потеза, игра је завршена")
                            self.isGameOver = true
                            self.gameEndReason = .noValidMoves
                            
                            // Победио је претходни играч
                            if self.currentPlayer == .red { // ако је следећи црвени, значи да је плави победио
                                self.blueScore += 1
                                print("makeAIMove: Плави је победио!")
                            } else {
                                self.redScore += 1
                                print("makeAIMove: Црвени је победио!")
                            }
                        }
                    }
                }
            }
        } else {
            print("makeAIMove: Стандардни мод: Тренутни играч \(currentPlayer == .blue ? "плави" : "црвени") није AI тим (\(aiTeam == .blue ? "плави" : "црвени"))")
        }
    }
    
    // Pomoćna metoda za AI vs AI mod
    func makeAIMoveForCurrentPlayer() {
        guard !isGameOver else { 
            print("makeAIMoveForCurrentPlayer: Игра је завршена, не могу да направим AI потез")
            return 
        }
        
        // Иницијализујемо AI играче ако нису већ иницијализовани
        initializeAIPlayers()
        
        let activeAI: AIPlayer?
        
        if aiVsAiMode {
            // U AI vs AI modu, biramo AI na osnovu trenutnog igrača
            activeAI = currentPlayer == .blue ? aiPlayer : secondAiPlayer
            print("makeAIMoveForCurrentPlayer: AI vs AI мод, активан AI за \(currentPlayer == .blue ? "плави" : "црвени") тим")
        } else {
            // U standardnom modu, samo tim AI ima AI igrača
            activeAI = currentPlayer == aiTeam ? aiPlayer : nil
            print("makeAIMoveForCurrentPlayer: Стандардни мод, активан AI за \(aiTeam == .blue ? "плави" : "црвени") тим")
        }
        
        if let ai = activeAI {
            isAIThinking = true
            
            // Постављамо време почетка размишљања
            aiThinkingStartTime = Date()
            
            print("makeAIMoveForCurrentPlayer: AI \(currentPlayer == .blue ? "плави" : "црвени") размишља...")
            
            // Prebacujemo AI razmišljanje на background thread sa visokim prioritetom
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                
                // Додајемо проверу времена размишљања
                let checkThinkingTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    guard let self = self, let startTime = self.aiThinkingStartTime else {
                        timer.invalidate()
                        return
                    }
                    
                    let thinkingTime = Date().timeIntervalSince(startTime)
                    if thinkingTime > self.aiMaxThinkingTime {
                        print("makeAIMoveForCurrentPlayer: AI размишља предуго (\(String(format: "%.1f", thinkingTime))s), прекидам размишљање")
                        self.cancelAIThinking()
                        timer.invalidate()
                    }
                }
                
                // AI razmišlja i nalazi najbolji potez
                if let bestMove = ai.findBestMove(for: self) {
                    // Заустављамо тајмер за проверу времена
                    checkThinkingTime.invalidate()
                    
                    // Vraćamo se na main thread za ažuriranje UI
                    DispatchQueue.main.async {
                        print("makeAIMoveForCurrentPlayer: AI \(self.currentPlayer == .blue ? "плави" : "црвени") избор потеза: (\(bestMove.row), \(bestMove.column))")
                        self.isAIThinking = false
                        self.aiThinkingStartTime = nil
                        
                        let moveResult = self.makeMove(row: bestMove.row, column: bestMove.column)
                        print("makeAIMoveForCurrentPlayer: Резултат AI потеза: \(moveResult ? "успешно" : "неуспешно")")
                        
                        // Ako igra nije završena, planiramo sledeći AI potez sa malim odlaganjem
                        if !self.isGameOver {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("makeAIMoveForCurrentPlayer: Планирање следећег AI потеза за играча: \(self.currentPlayer == .blue ? "плави" : "црвени")")
                                self.makeAIMove()
                            }
                        }
                    }
                } else {
                    // Заустављамо тајмер за проверу времена
                    checkThinkingTime.invalidate()
                    
                    DispatchQueue.main.async {
                        print("makeAIMoveForCurrentPlayer: AI \(self.currentPlayer == .blue ? "плави" : "црвени") није могао да пронађе валидни потез")
                        self.isAIThinking = false
                        self.aiThinkingStartTime = nil
                        
                        // Ако AI не може да нађе потез, то значи да нема валидних потеза
                        // Означавамо игру као завршену
                        if !self.isGameOver {
                            print("makeAIMoveForCurrentPlayer: Нема валидних потеза, игра је завршена")
                            self.isGameOver = true
                            self.gameEndReason = .noValidMoves
                            
                            // Победио је претходни играч
                            if self.currentPlayer == .red { // ако је следећи црвени, значи да је плави победио
                                self.blueScore += 1
                                print("makeAIMoveForCurrentPlayer: Плави је победио!")
                            } else {
                                self.redScore += 1
                                print("makeAIMoveForCurrentPlayer: Црвени је победио!")
                            }
                        }
                    }
                }
            }
        } else {
            print("makeAIMoveForCurrentPlayer: Нема активног AI за тренутног играча \(currentPlayer == .blue ? "плави" : "црвени")")
        }
    }
    
    /// Насилно отказује активно AI размишљање у случају критичног времена
    private func otkaziRazmisljanjeAI() {
        // Прво одређујемо који AI је активан
        let activeAI: AIPlayer?
        
        if aiVsAiMode {
            // У AI vs AI моду бирамо AI на основу тренутног играча
            activeAI = currentPlayer == .blue ? aiPlayer : secondAiPlayer
        } else {
            // У стандардном моду само ако је тренутни играч AI
            activeAI = currentPlayer == aiTeam ? aiPlayer : nil
        }
        
        // Ако смо нашли активни AI, заказујемо насумични потез
        if let ai = activeAI {
            // Кажемо AI-у да прекине размишљање
            ai.cancelThinking()
            
            // Одмах након тога, планирамо насумични потез у главној нити
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self, !self.isGameOver else { return }
                
                print("otkaziRazmisljanjeAI: Планирам насумични потез због истека времена")
                
                // Одређујемо валидне потезе
                let validMoves = self.board.getValidMoves(for: self.currentPlayer)
                if !validMoves.isEmpty {
                    // Бирамо насумични потез
                    if let randomMove = validMoves.randomElement() {
                        print("otkaziRazmisljanjeAI: Играм насумични потез (\(randomMove.row), \(randomMove.column))")
                        self.isAIThinking = false
                        
                        // Извршавамо потез
                        let moveResult = self.makeMove(row: randomMove.row, column: randomMove.column)
                        print("otkaziRazmisljanjeAI: Резултат насумичног потеза: \(moveResult ? "успешно" : "неуспешно")")
                        
                        // Ако игра није завршена, планирамо следећи AI потез с малим одлагањем
                        if !self.isGameOver && (self.aiVsAiMode || (self.aiEnabled && self.currentPlayer == self.aiTeam)) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("otkaziRazmisljanjeAI: Планирам следећи AI потез")
                                self.makeAIMove()
                            }
                        }
                    }
                } else {
                    // Нема валидних потеза, завршавамо игру
                    print("otkaziRazmisljanjeAI: Нема валидних потеза, играч губи")
                    self.isAIThinking = false
                    
                    if !self.isGameOver {
                        self.isGameOver = true
                        self.gameEndReason = .noValidMoves
                        
                        // Победник је претходни играч
                        if self.currentPlayer == .red {
                            self.blueScore += 1
                            print("otkaziRazmisljanjeAI: Плави је победио!")
                        } else {
                            self.redScore += 1
                            print("otkaziRazmisljanjeAI: Црвени је победио!")
                        }
                    }
                }
            }
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
        if aiEnabled && aiPlayer == nil {
            print("initializeAIPlayers: Иницијализујем главног AI играча са тежином \(aiDifficulty.description)")
            aiPlayer = AIPlayer(difficulty: aiDifficulty)
        }
        
        // Иницијализујемо другог AI играча за AI vs AI мод
        if aiVsAiMode && secondAiPlayer == nil {
            print("initializeAIPlayers: Иницијализујем другог AI играча са тежином \(secondAiDifficulty.description)")
            secondAiPlayer = AIPlayer(difficulty: secondAiDifficulty)
        }
        
        // Подешавамо максимално време размишљања на основу опције тајмера
        if timerOption != .none {
            // Ако имамо тајмер, максимално време размишљања је 1/3 укупног времена, али не више од 10 секунди
            aiMaxThinkingTime = min(Double(timerOption.rawValue) / 3.0, 10.0)
        } else {
            // Ако немамо тајмер, максимално време размишљања је 10 секунди
            aiMaxThinkingTime = 10.0
        }
        
        print("initializeAIPlayers: Максимално време размишљања AI-а: \(aiMaxThinkingTime) секунди")
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
        aiEnabled = enabled
        aiDifficulty = difficulty
        aiTeam = team
        
        // Ажурирамо AI vs AI подешавања
        aiVsAiMode = aiVsAi
        secondAiDifficulty = secondDifficulty
        
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
                // У стандардном моду, покрећемо AI потез само ако је AI тим на потезу
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