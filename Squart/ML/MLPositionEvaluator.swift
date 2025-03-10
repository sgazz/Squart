import Foundation
import CoreML

// Klasa koja implementira ML pristup za evaluaciju pozicije u igri Squart
class MLPositionEvaluator {
    
    // Singleton instanca
    static let shared = MLPositionEvaluator()
    
    // Privatni inicijalizator za singleton
    private init() {
        // Mock model za testiranje da simuliramo ML
        createMockModel()
    }
    
    // Trenutni ML model (biće učitan kasnije)
    private var model: Any? = nil
    
    // Indikator da li je ML spreman za korišćenje
    var isMLReady: Bool {
        return model != nil
    }
    
    // Kreira mock model za testiranje ML funkcionalnosti
    private func createMockModel() {
        // Simuliramo model jednostavnim rečnikom težina
        let mockWeights = [
            "board_value": 1.0,
            "edge_control": 2.0,
            "corner_control": 3.0,
            "center_control": 1.5,
            "move_advantage": 4.0,
            "blocking_factor": 2.5
        ]
        
        self.model = mockWeights
        print("ML: Mock model kreiran za testiranje")
    }
    
    // Metoda za pripremu i učitavanje ML modela
    func prepareModel() {
        // Prvo proverimo da li već imamo model
        if isMLReady {
            print("ML: Model je već spreman")
            return
        }
        
        // U pravoj implementaciji, ovde bismo učitali CoreML model
        // Trenutno koristimo mock model za testiranje
        if model == nil {
            createMockModel()
            print("ML: Kreiran novi mock model")
        }
        
        // TODO: Implementirati pravi CoreML model
        // Primer koda za učitavanje CoreML modela:
        /*
        do {
            let modelConfig = MLModelConfiguration()
            let model = try SquartPositionEvaluator(configuration: modelConfig)
            self.model = model
            print("ML: Model uspešno učitan")
        } catch {
            print("ML greška: Nije moguće učitati model: \(error)")
            self.model = nil
        }
        */
    }
    
    // Metoda za konverziju stanja igre u format prihvatljiv za ML model
    private func convertGameStateToMLInput(_ game: Game) -> [Float] {
        let board = game.board
        var input: [Float] = []
        
        // Konvertujemo stanje table u niz brojeva
        for row in 0..<board.size {
            for column in 0..<board.size {
                let cell = board.cells[row][column]
                let value: Float
                
                switch cell.type {
                case .empty: value = 0.0
                case .blocked: value = -1.0
                case .blue: value = 1.0
                case .red: value = 2.0
                }
                
                input.append(value)
            }
        }
        
        // Dodajemo informaciju o trenutnom igraču
        input.append(game.currentPlayer == .blue ? 1.0 : 2.0)
        
        return input
    }
    
    // Hibridna funkcija za evaluaciju pozicije - kombinuje ML i heuristike
    func evaluatePosition(_ game: Game, player: Player) -> Int {
        // Ako ML model nije spreman, vratimo tradicionalnu heurističku procenu
        if !isMLReady {
            return fallbackEvaluatePosition(game, player: player)
        }
        
        // Konvertujemo stanje igre u ML input
        let mlInput = convertGameStateToMLInput(game)
        
        // Simuliramo ML inferencu za mock model
        if let mockModel = model as? [String: Float] {
            return mockEvaluatePosition(game, player: player, weights: mockModel)
        }
        
        // TODO: Implementirati poziv pravog ML modela za evaluaciju
        // Za sada koristimo fallback metod
        return fallbackEvaluatePosition(game, player: player)
    }
    
    // Simulirana ML evaluacija pomoću mock težina
    private func mockEvaluatePosition(_ game: Game, player: Player, weights: [String: Float]) -> Int {
        let opponent = player == .blue ? Player.red : Player.blue
        let board = game.board
        
        // Dobijamo validne poteze za oba igrača
        let playerMoves = getValidMoves(for: board, player: player)
        let opponentMoves = getValidMoves(for: board, player: opponent)
        
        // Pobeda/gubitak su najvažniji
        if opponentMoves.isEmpty && game.currentPlayer == opponent {
            return 1000  // Pobeda
        }
        
        if playerMoves.isEmpty && game.currentPlayer == player {
            return -1000  // Gubitak
        }
        
        var score: Float = 0.0
        
        // 1. Prednost u broju poteza
        let moveAdvantage = Float(playerMoves.count - opponentMoves.count)
        score += moveAdvantage * (weights["move_advantage"] ?? 1.0)
        
        // 2. Kontrola ivica
        let playerEdges = countEdgeMoves(playerMoves, boardSize: board.size)
        let opponentEdges = countEdgeMoves(opponentMoves, boardSize: board.size)
        score += Float(playerEdges - opponentEdges) * (weights["edge_control"] ?? 1.0)
        
        // 3. Kontrola ćoškova
        let playerCorners = countCornerMoves(playerMoves, boardSize: board.size)
        let opponentCorners = countCornerMoves(opponentMoves, boardSize: board.size)
        score += Float(playerCorners - opponentCorners) * (weights["corner_control"] ?? 1.0)
        
        // 4. Kontrola centra (važnija na većim tablama)
        if board.size >= 7 {
            let playerCenter = countCenterMoves(playerMoves, boardSize: board.size)
            let opponentCenter = countCenterMoves(opponentMoves, boardSize: board.size)
            score += Float(playerCenter - opponentCenter) * (weights["center_control"] ?? 1.0)
        }
        
        // 5. Blokiranje protivnika
        let blockingFactor = calculateBlockingFactor(game, player: player)
        score += blockingFactor * (weights["blocking_factor"] ?? 1.0)
        
        // Konvertujemo u Int i vraćamo ocenu
        return Int(score * 10)  // Množimo sa 10 za bolju rezoluciju ocene
    }
    
    // Fallback metoda koja koristi tradicionalne heuristike
    private func fallbackEvaluatePosition(_ game: Game, player: Player) -> Int {
        let opponent = player == .blue ? Player.red : Player.blue
        let board = game.board
        
        // Brojimo validne poteze za oba igrača
        let playerMoves = getValidMoves(for: board, player: player)
        let opponentMoves = getValidMoves(for: board, player: opponent)
        
        // Pobeda/gubitak su najvažniji
        if opponentMoves.isEmpty && game.currentPlayer == opponent {
            return 1000  // Pobeda
        }
        
        if playerMoves.isEmpty && game.currentPlayer == player {
            return -1000  // Gubitak
        }
        
        var score = 0
        
        // 1. Razlika u broju validnih poteza
        score += (playerMoves.count - opponentMoves.count) * 5
        
        // 2. Bonus za kontrolu ivica
        score += countEdgeMoves(playerMoves, boardSize: board.size) * 2
        score -= countEdgeMoves(opponentMoves, boardSize: board.size) * 2
        
        // 3. Bonus za kontrolu ćoškova
        score += countCornerMoves(playerMoves, boardSize: board.size) * 3
        score -= countCornerMoves(opponentMoves, boardSize: board.size) * 3
        
        // 4. Bonus za kontrolu centra (važniji na većim tablama)
        if board.size >= 7 {
            score += countCenterMoves(playerMoves, boardSize: board.size) * 2
            score -= countCenterMoves(opponentMoves, boardSize: board.size) * 2
        }
        
        // 5. Faktor za blokiranje poteza
        score += calculateBlockingFactor(game, player: player)
        
        return score
    }
    
    // Pomoćne metode za evaluaciju
    
    // Računa faktor blokiranja protivnika
    private func calculateBlockingFactor(_ game: Game, player: Player) -> Float {
        let opponent = player == .blue ? Player.red : Player.blue
        let board = game.board
        
        var blockingFactor: Float = 0
        
        // Težina blokiranja za protivnika
        for row in 0..<board.size {
            for column in 0..<board.size {
                // Ako je polje prazno
                if board.cells[row][column].type == .empty {
                    // Proveravamo da li bi protivnik mogao da igra tu
                    if opponent.isHorizontal && column + 1 < board.size {
                        if board.cells[row][column + 1].type != .empty {
                            blockingFactor += 1
                        }
                    } else if !opponent.isHorizontal && row + 1 < board.size {
                        if board.cells[row + 1][column].type != .empty {
                            blockingFactor += 1
                        }
                    }
                }
            }
        }
        
        return blockingFactor * 3
    }
    
    // Prikuplja validne poteze
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
    
    // Broji poteze na ivicama
    private func countEdgeMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        return moves.filter { move in
            move.row == 0 || move.row == boardSize - 1 ||
            move.column == 0 || move.column == boardSize - 1
        }.count
    }
    
    // Broji poteze u ćoškovima
    private func countCornerMoves(_ moves: [(row: Int, column: Int)], boardSize: Int) -> Int {
        return moves.filter { move in
            (move.row == 0 && move.column == 0) ||
            (move.row == 0 && move.column == boardSize - 1) ||
            (move.row == boardSize - 1 && move.column == 0) ||
            (move.row == boardSize - 1 && move.column == boardSize - 1)
        }.count
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
    
    // Funkcija za trening modela (koristiće se offline)
    func trainModel(withGameData games: [GameRecord]) {
        // TODO: Implementirati offline trening na osnovu snimljenih partija
        // Ovo će biti poseban proces koji će generisati CoreML model
        print("ML: Započinjem trening sa \(games.count) partija")
        
        // Ovde bismo pozivali Python skriptu za treniranje
        // Za sada samo simuliramo trening tako što ažuriramo težine mock modela
        
        if let mockModel = model as? [String: Float] {
            var updatedWeights = mockModel
            
            // Simuliramo "učenje" povećavajući težine na osnovu broja partija
            let factor = min(Float(games.count) / 10.0, 2.0)
            
            updatedWeights["move_advantage"] = (mockModel["move_advantage"] ?? 1.0) * factor
            updatedWeights["blocking_factor"] = (mockModel["blocking_factor"] ?? 1.0) * factor
            
            model = updatedWeights
            print("ML: Mock trening završen, ažurirane težine")
        }
    }
}

// Struktura koja predstavlja snimljenu partiju za trening
struct GameRecord {
    let moves: [(row: Int, column: Int)]
    let winner: Player
    let boardSize: Int
    let boardStates: [[CellType]]
    let currentPlayers: [Player]
    
    // Inicijalizator sa minimalnim podacima
    init(moves: [(row: Int, column: Int)], winner: Player, boardSize: Int) {
        self.moves = moves
        self.winner = winner
        self.boardSize = boardSize
        self.boardStates = []
        self.currentPlayers = []
    }
    
    // Inicijalizator sa svim podacima
    init(moves: [(row: Int, column: Int)], winner: Player, boardSize: Int, boardStates: [[CellType]], currentPlayers: [Player]) {
        self.moves = moves
        self.winner = winner
        self.boardSize = boardSize
        self.boardStates = boardStates
        self.currentPlayers = currentPlayers
    }
    
    // Funkcija za serijalizaciju u JSON za skladištenje
    func toJSON() -> [String: Any] {
        var jsonMoves: [[String: Int]] = []
        for move in moves {
            jsonMoves.append(["row": move.row, "column": move.column])
        }
        
        // Konvertujemo stanja table u JSON-kompatibilan format
        var jsonBoardStates: [[[Int]]] = []
        for boardState in boardStates {
            var jsonBoard: [[Int]] = []
            for row in boardState {
                var jsonRow: [Int] = []
                for cellType in row {
                    let value: Int
                    switch cellType {
                    case .empty: value = 0
                    case .blocked: value = -1
                    case .blue: value = 1
                    case .red: value = 2
                    }
                    jsonRow.append(value)
                }
                jsonBoard.append(jsonRow)
            }
            jsonBoardStates.append(jsonBoard)
        }
        
        // Konvertujemo igrače u JSON-kompatibilan format
        let jsonPlayers = currentPlayers.map { $0 == .blue ? "blue" : "red" }
        
        return [
            "moves": jsonMoves,
            "winner": winner == .blue ? "blue" : "red",
            "boardSize": boardSize,
            "boardStates": jsonBoardStates,
            "currentPlayers": jsonPlayers
        ]
    }
    
    // Funkcija za deserijalizaciju iz JSON
    static func fromJSON(_ json: [String: Any]) -> GameRecord? {
        guard let jsonMoves = json["moves"] as? [[String: Int]],
              let winnerString = json["winner"] as? String,
              let boardSize = json["boardSize"] as? Int else {
            return nil
        }
        
        let winner: Player = winnerString == "blue" ? .blue : .red
        var moves: [(row: Int, column: Int)] = []
        
        for jsonMove in jsonMoves {
            if let row = jsonMove["row"], let column = jsonMove["column"] {
                moves.append((row, column))
            }
        }
        
        // Pokušavamo učitati stanja table ako postoje
        var boardStates: [[CellType]] = []
        if let jsonBoardStates = json["boardStates"] as? [[[Int]]] {
            for jsonBoard in jsonBoardStates {
                var boardState: [CellType] = []
                for jsonRow in jsonBoard {
                    for value in jsonRow {
                        let cellType: CellType
                        switch value {
                        case -1: cellType = .blocked
                        case 1: cellType = .blue
                        case 2: cellType = .red
                        default: cellType = .empty
                        }
                        boardState.append(cellType)
                    }
                }
                boardStates.append(boardState)
            }
        }
        
        // Pokušavamo učitati trenutne igrače ako postoje
        var currentPlayers: [Player] = []
        if let jsonPlayers = json["currentPlayers"] as? [String] {
            currentPlayers = jsonPlayers.map { $0 == "blue" ? .blue : .red }
        }
        
        return GameRecord(
            moves: moves,
            winner: winner,
            boardSize: boardSize,
            boardStates: boardStates,
            currentPlayers: currentPlayers
        )
    }
} 