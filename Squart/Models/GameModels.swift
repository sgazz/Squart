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
        // Прво проверавамо кеш
        if let cachedMoves = validMovesCache[player] {
            return cachedMoves.contains(Position(row: row, column: column))
        }
        
        // Ако немамо кеш, правимо нови сет валидних потеза
        var validMoves = Set<Position>()
        
        for r in 0..<size {
            for c in 0..<size {
                if checkValidMove(row: r, column: c, player: player) {
                    validMoves.insert(Position(row: r, column: c))
                }
            }
        }
        
        // Чувамо у кешу
        validMovesCache[player] = validMoves
        
        return validMoves.contains(Position(row: row, column: column))
    }
    
    // Помоћна метода која проверава валидност потеза без кеширања
    private func checkValidMove(row: Int, column: Int, player: Player) -> Bool {
        guard row >= 0 && row < size && column >= 0 && column < size else { return false }
        guard cells[row][column].type == .empty else { return false }
        
        if player.isHorizontal {
            guard column + 1 < size && cells[row][column + 1].type == .empty else { return false }
            return true
        } else {
            guard row + 1 < size && cells[row + 1][column].type == .empty else { return false }
            return true
        }
    }
    
    func makeMove(row: Int, column: Int, player: Player) -> Bool {
        guard isValidMove(row: row, column: column, player: player) else { return false }
        
        cells[row][column].type = player.cellType
        
        if player.isHorizontal {
            cells[row][column + 1].type = player.cellType
        } else {
            cells[row + 1][column].type = player.cellType
        }
        
        // Поништавамо кеш јер се табла променила
        invalidateCache()
        return true
    }
    
    // Helper funkcija za proveru da li postoje validni potezi za igrača
    func hasValidMoves(for player: Player) -> Bool {
        for row in 0..<size {
            for column in 0..<size {
                if isValidMove(row: row, column: column, player: player) {
                    return true
                }
            }
        }
        return false
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
    
    // Određuje tim koji igra AI (podrazumevano crveni)
    @Published var aiTeam: Player = .red
    
    // Podrška za drugi AI u AI vs AI modu
    @Published var aiVsAiMode: Bool = false
    @Published var secondAiDifficulty: AIDifficulty = .medium
    private var secondAiPlayer: AIPlayer?
    
    // Opcija za vizualizaciju AI "razmišljanja"
    @Published var showAIThinking: Bool = false
    @Published var aiConsideredMoves: [(move: (row: Int, column: Int), score: Int)] = []
    
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
    
    // Додајемо нове променљиве за праћење размотрених потеза АИ-а
    @Published var consideredMoves: [(row: Int, column: Int, score: Int)] = []
    
    init(boardSize: Int = 7) {
        self.board = GameBoard(size: boardSize)
        let timerOpt = GameSettingsManager.shared.timerOption
        self.timerOption = timerOpt
        self.blueTimeRemaining = timerOpt.rawValue
        self.redTimeRemaining = timerOpt.rawValue
    }
    
    func makeMove(row: Int, column: Int) -> Bool {
        guard !isGameOver else { return false }
        
        if board.makeMove(row: row, column: column, player: currentPlayer) {
            // Promena igrača
            currentPlayer = currentPlayer == .blue ? .red : .blue
            
            // Provera da li sledeći igrač ima validne poteze
            if !board.hasValidMoves(for: currentPlayer) {
                isGameOver = true
                gameEndReason = .noValidMoves
                // Pobeđuje prethodni igrač (onaj koji je upravo odigrao potez)
                if currentPlayer == .red { // ako je sledeći crveni, znači da je plavi pobedio
                    blueScore += 1
                } else {
                    redScore += 1
                }
            }
            
            return true
        }
        return false
    }
    
    func updateTimer() {
        guard !isGameOver else { return }
        guard timerOption != .none else { return }
        
        // Umanjujemo vreme trenutnom igraču (bez obzira da li AI razmišlja)
        if currentPlayer == .blue {
            blueTimeRemaining -= 1
            if blueTimeRemaining <= 0 {
                timeOut(for: .blue)
            }
        } else {
            redTimeRemaining -= 1
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
    
    // Иницијализујемо праћење игре када почиње нова партија
    func resetGame(initializedByUser: Bool = true) {
        board = GameBoard(size: board.size)
        
        // Naizmenično menjanje prvog igrača
        startingPlayer = startingPlayer == .blue ? .red : .blue
        currentPlayer = startingPlayer
        
        isGameOver = false
        gameEndReason = .none
        
        // Resetovanje tajmera
        timerOption = GameSettingsManager.shared.timerOption
        blueTimeRemaining = timerOption.rawValue
        redTimeRemaining = timerOption.rawValue
        
        // Poništavamo sve tekuće operacije AI-a
        isAIThinking = false
        
        // Ресет система за учење
        consideredMoves.removeAll()
        AILearningManager.startNewGameTracking()
        
        // AI logika nakon resetovanja igre - sa odloženim izvršavanjem
        if aiEnabled {
            print("Igra resetovana, AI je \(aiEnabled ? "uključen" : "isključen"), AI vs AI mod: \(aiVsAiMode)")
            
            // Odložimo pokretanje AI-a da bismo dali vremena UI-u da se ažurira
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Provera da nije igra u međuvremenu završena iz nekog razloga
                guard !self.isGameOver else { return }
                
                // Za AI vs AI mod, uvek pokrećemo AI potez, bez obzira koji igrač je trenutno
                if self.aiVsAiMode {
                    print("Pokretanje AI vs AI igre...")
                    self.makeAIMove()
                }
                // Za standardni mod, pokrećemo AI potez samo ako je AI tim na potezu
                else if self.currentPlayer == self.aiTeam {
                    print("Pokretanje AI poteza nakon resetovanja igre...")
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
        aiPlayer = AIPlayer(difficulty: difficulty)
        
        // Provera podešavanja AI vs AI moda
        if GameSettingsManager.shared.aiVsAiMode {
            aiVsAiMode = true
            secondAiDifficulty = GameSettingsManager.shared.secondAiDifficulty
            secondAiPlayer = AIPlayer(difficulty: secondAiDifficulty)
            print("AI vs AI mod inicijalizovan - Prvi AI: \(difficulty), Drugi AI: \(secondAiDifficulty)")
        } else {
            aiVsAiMode = false
            secondAiPlayer = nil
            print("Standardni AI mod inicijalizovan - AI tim: \(team), težina: \(difficulty)")
        }
        
        // Ako je AI vs AI mod i igra je u toku, pokrenimo AI odmah
        if aiVsAiMode && !isGameOver {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeAIMove()
            }
        }
    }
    
    // Metoda za AI potez
    func makeAIMove() {
        guard aiEnabled, !isGameOver else { 
            print("AI potez preskočen: aiEnabled=\(aiEnabled), isGameOver=\(isGameOver)")
            return 
        }
        
        if aiVsAiMode {
            // U AI vs AI modu, uvek imamo AI igrača za oba tima
            print("AI vs AI: AI \(currentPlayer == .blue ? "plavi" : "crveni") razmišlja...")
            makeAIMoveForCurrentPlayer()
        } else {
            // U standardnom modu, AI igra samo za svoj tim
            if currentPlayer == aiTeam, let aiPlayer = aiPlayer {
                print("Standardni mod: AI za \(aiTeam == .blue ? "plavi" : "crveni") tim razmišlja...")
                isAIThinking = true
                
                // Čistimo prethodno razmatrane poteze
                aiConsideredMoves.removeAll()
                
                // Prebacujemo AI razmišljanje na background thread sa visokim prioritetom
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    guard let self = self else { return }
                    
                    // AI razmišlja i nalazi najbolji potez
                    if let bestMove = aiPlayer.findBestMove(for: self) {
                        // Vraćamo se na main thread za ažuriranje UI
                        DispatchQueue.main.async {
                            self.isAIThinking = false
                            
                            // Čuvamo razmatrne poteze za vizualizaciju ako je opcija uključena
                            if self.showAIThinking {
                                self.aiConsideredMoves = aiPlayer.consideredMoves
                            }
                            
                            _ = self.makeMove(row: bestMove.row, column: bestMove.column)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isAIThinking = false
                            print("AI nije uspeo da pronađe validan potez.")
                        }
                    }
                }
            } else if currentPlayer != aiTeam {
                print("Čekanje na ljudski potez za \(currentPlayer == .blue ? "plavi" : "crveni") tim...")
            }
        }
    }
    
    // Бележимо исход игре када се она заврши
    func registerGameResult(winner: Player? = nil) {
        // Бележимо исход у систем за учење
        var outcome: GameOutcome
        if let winner = winner {
            outcome = winner == .blue ? .blueWon : .redWon
        } else {
            outcome = .draw
        }
        
        AILearningManager.finishGameTracking(boardSize: board.size, outcome: outcome)
    }
    
    // Интегришемо са функцијом за проверу краја игре
    func checkGameStatus() -> Bool {
        if let winner = board.checkForWinner() {
            isGameOver = true
            self.winner = winner
            registerGameResult(winner: winner)
            return true
        } else if board.isFull() {
            isGameOver = true
            self.winner = nil
            registerGameResult() // Нерешено
            return true
        }
        return false
    }
    
    func makeAIMoveForCurrentPlayer() {
        // Ресетујемо размотрене потезе
        consideredMoves.removeAll()
        
        // Омогућавамо праћење размишљања
        if showAIThinking {
            objectWillChange.send()
        }
        
        // Покрећемо АИ размишљање у позадини да не блокирамо UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, !self.isGameOver else { return }
            
            // Проналазимо најбољи потез
            var aiPlayer = self.aiPlayers[self.currentPlayer == .blue ? 0 : 1]
            let difficulty = self.aiDifficulty[self.currentPlayer == .blue ? 0 : 1]
            let bestMove = aiPlayer.makeMove(for: self, difficulty: difficulty)
            
            // Примењујемо потез у главној нити
            DispatchQueue.main.async {
                guard let self = self, !self.isGameOver else { return }
                
                // Правимо потез
                if bestMove.row >= 0 && bestMove.column >= 0 {
                    self.makeMove(row: bestMove.row, column: bestMove.column)
                } else {
                    print("АИ није могао да одлучи о потезу!")
                }
            }
        }
    }
} 