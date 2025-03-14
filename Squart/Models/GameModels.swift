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

/// Struktura za ćelije na tabli koja se koristi u UI-u
struct BoardCell {
    var type: CellType
    var row: Int
    var column: Int
    
    init(type: CellType, row: Int, column: Int) {
        self.type = type
        self.row = row
        self.column = column
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
    @Published var secondAiDifficulty: AIDifficulty = .medium
    private var aiPlayer: AIPlayer?
    private var secondAiPlayer: AIPlayer?
    @Published var isAIThinking: Bool = false
    
    // Određuje tim koji igra AI (podrazumevano crveni)
    @Published var aiTeam: Player = .red
    
    // Podrška za drugi AI u AI vs AI modu
    @Published var aiVsAiMode: Bool = false
    @Published var isAIGame = false
    @Published var isSecondAITurn = false
    
    // Opcija za vizualizaciju AI "razmišljanja"
    @Published var showAIThinking = false
    @Published var consideredMoves: [(row: Int, column: Int, score: Int)] = []
    @Published var aiConsideredMoves: [(move: Position, score: Int)] = []
    
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
    
    // Pobednik igre
    @Published var winner: Player?
    
    // Lista AI igrača
    private var aiPlayers: [AIPlayer] {
        var players: [AIPlayer] = []
        if let aiPlayer = aiPlayer {
            players.append(aiPlayer)
        }
        if let secondAiPlayer = secondAiPlayer {
            players.append(secondAiPlayer)
        }
        return players
    }
    
    init(boardSize: Int = 7) {
        self.board = GameBoard(size: boardSize)
        let timerOpt = GameSettingsManager.shared.timerOption
        self.timerOption = timerOpt
        self.blueTimeRemaining = timerOpt.rawValue
        self.redTimeRemaining = timerOpt.rawValue
    }
    
    /// Kreira kopiju trenutnog stanja igre
    func clone() -> Game {
        let clonedGame = Game(boardSize: board.size)
        clonedGame.board = board.clone()
        clonedGame.currentPlayer = currentPlayer
        clonedGame.blueScore = blueScore
        clonedGame.redScore = redScore
        clonedGame.isGameOver = isGameOver
        clonedGame.blueTimeRemaining = blueTimeRemaining
        clonedGame.redTimeRemaining = redTimeRemaining
        clonedGame.timerOption = timerOption
        clonedGame.aiEnabled = aiEnabled
        clonedGame.aiDifficulty = aiDifficulty
        clonedGame.secondAiDifficulty = secondAiDifficulty
        clonedGame.aiTeam = aiTeam
        clonedGame.aiVsAiMode = aiVsAiMode
        clonedGame.isAIGame = isAIGame
        clonedGame.isSecondAITurn = isSecondAITurn
        clonedGame.showAIThinking = showAIThinking
        clonedGame.consideredMoves = consideredMoves
        clonedGame.startingPlayer = startingPlayer
        clonedGame.gameEndReason = gameEndReason
        clonedGame.winner = winner
        return clonedGame
    }
    
    func makeMove(row: Int, column: Int) -> Bool {
        guard !isGameOver else { return false }
        
        if board.isValidMove(row: row, column: column, player: currentPlayer) {
            board.makeMove(row: row, column: column, player: currentPlayer)
            
            if let winningPlayer = board.checkForWinner() {
                winner = winningPlayer
                isGameOver = true
                return true
            }
            
            if board.isFull() {
                isGameOver = true
                return true
            }
            
            currentPlayer = currentPlayer == .blue ? .red : .blue
            
            // Resetujemo isSecondAITurn kada se vrati na plavog igrača
            if currentPlayer == .blue {
                isSecondAITurn = false
            }
            
            // U AI vs AI modu, treba automatski da pokrenemo sledeći AI potez nakon promene igrača
            if aiVsAiMode && !isGameOver {
                // Odložimo malo potez za bolji vizuelni efekat
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self, !self.isGameOver else { return }
                    self.makeAIMove()
                }
            }
            // U standardnom AI modu, pokrećemo AI potez samo ako je AI na potezu
            else if aiEnabled && currentPlayer == aiTeam && !isGameOver {
                // Odložimo malo potez za bolji vizuelni efekat
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self, !self.isGameOver else { return }
                    self.makeAIMove()
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
            winner = .red
        } else {
            gameEndReason = .redTimeout
            blueScore += 1  // Plavi igrač pobeđuje
            winner = .blue
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
        isSecondAITurn = false // Resetujemo isSecondAITurn
        
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
            isAIGame = true // Postavlja se isAIGame na true kada je AI vs AI
            secondAiDifficulty = GameSettingsManager.shared.secondAiDifficulty
            secondAiPlayer = AIPlayer(difficulty: secondAiDifficulty)
            print("AI vs AI mod inicijalizovan - Prvi AI: \(difficulty), Drugi AI: \(secondAiDifficulty)")
        } else {
            aiVsAiMode = false
            isAIGame = false
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
                consideredMoves.removeAll()
                
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
                                self.consideredMoves = [(bestMove.row, bestMove.column, 0)]
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
        guard !isGameOver else { return }
        
        showAIThinking = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Koristimo odgovarajućeg AI igrača u zavisnosti od trenutnog igrača
            let difficulty = self.currentPlayer == .blue ? self.aiDifficulty : self.secondAiDifficulty
            let aiPlayer = self.currentPlayer == .blue ? self.aiPlayer : self.secondAiPlayer
            
            if let aiPlayer = aiPlayer {
                print("AI igrač \(self.currentPlayer == .blue ? "plavi" : "crveni") razmišlja sa težinom: \(difficulty)")
                
                // Kratka pauza za UI pre nego što AI odigra potez
                Thread.sleep(forTimeInterval: 0.5)
                
                let move = aiPlayer.makeMove(for: self, difficulty: difficulty)
                
                DispatchQueue.main.async {
                    print("AI igrač \(self.currentPlayer == .blue ? "plavi" : "crveni") odigrao potez na: (\(move.row), \(move.column))")
                    
                    // Ako je uključena opcija za AI razmišljanje, prikažemo razmatrane poteze
                    if self.showAIThinking {
                        self.consideredMoves = [(move.row, move.column, 0)]
                    }
                    
                    _ = self.makeMove(row: move.row, column: move.column)
                    self.showAIThinking = false
                }
            } else {
                DispatchQueue.main.async {
                    self.showAIThinking = false
                    print("Nema AI igrača za \(self.currentPlayer == .blue ? "plavog" : "crvenog") igrača")
                }
            }
        }
    }
} 