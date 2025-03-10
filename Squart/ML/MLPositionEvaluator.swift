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
        if model == nil {
            // Prvo pokušavamo da učitamo realni model ako postoji
            loadRealModel()
            
            // Ako ne možemo učitati realni model, kreiramo mock model
            if model == nil {
                createMockModel()
                print("ML: Kreiran novi mock model")
            }
        }
    }
    
    // Funkcija koja pokušava da učita pravi CoreML model
    private func loadRealModel() {
        // Pokušavamo pronaći model u bundle-u
        guard let modelURL = Bundle.main.url(forResource: "SquartMLModel", withExtension: "mlmodelc") else {
            print("ML: CoreML model nije pronađen u bundle-u")
            return
        }
        
        // Pokušavamo učitati model
        do {
            // U stvarnoj implementaciji, ovde bismo učitali pravi model
            // let model = try MLModel(contentsOf: modelURL)
            print("ML: CoreML model pronađen na: \(modelURL.path)")
            
            // Za sada samo logujemo da smo našli model, ali i dalje koristimo mock
            createMockModel()
            print("ML: Koristi se mock model jer stvarni model još uvek nije implementiran")
        } catch {
            print("ML: Greška pri učitavanju CoreML modela: \(error)")
            model = nil
        }
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
        
        var score = 0
        
        // 1. Razlika u broju validnih poteza (najvažniji faktor)
        score += (playerMoves.count - opponentMoves.count) * 10
        
        // 2. Bonus za kontrolu ivica
        let playerEdges = countEdgeMoves(playerMoves, boardSize: board.size)
        let opponentEdges = countEdgeMoves(opponentMoves, boardSize: board.size)
        score += (playerEdges - opponentEdges) * 5
        
        // 3. Bonus za kontrolu ćoškova (još važniji)
        let playerCorners = countCornerMoves(playerMoves, boardSize: board.size)
        let opponentCorners = countCornerMoves(opponentMoves, boardSize: board.size)
        score += (playerCorners - opponentCorners) * 8
        
        // 4. Bonus za kontrolu centra (važniji na većim tablama)
        if board.size >= 7 {
            let playerCenter = countCenterMoves(playerMoves, boardSize: board.size)
            let opponentCenter = countCenterMoves(opponentMoves, boardSize: board.size)
            score += (playerCenter - opponentCenter) * 7
        }
        
        // 5. Faktor za blokiranje poteza protivnika
        let blockingFactor = calculateBlockingFactor(game, player: player)
        score += Int(blockingFactor)
        
        // 6. Mobilnost poteza (koliko slobode imamo za buduće poteze)
        let mobilityScore = calculateMobilityScore(game, player: player)
        score += mobilityScore
        
        // 7. Kontrola teritorije (više poteza u određenim delovima table)
        let territoryScore = calculateTerritoryControl(game, player: player)
        score += territoryScore
        
        return score
    }
    
    // Nova pomoćna funkcija za računanje mobilnosti poteza
    private func calculateMobilityScore(_ game: Game, player: Player) -> Int {
        let opponent = player == .blue ? Player.red : Player.blue
        let board = game.board
        
        var mobilityScore = 0
        
        // Proveravamo susedna polja za moje validne poteze
        let playerMoves = getValidMoves(for: board, player: player)
        
        for move in playerMoves {
            // Brojimo koliko susednih polja je prazno za svaki validni potez
            let neighbors = getNeighbors(move, boardSize: board.size)
            let emptyNeighbors = neighbors.filter { 
                let (r, c) = $0
                return r >= 0 && r < board.size && c >= 0 && c < board.size && 
                       board.cells[r][c].type == .empty 
            }
            
            mobilityScore += emptyNeighbors.count
        }
        
        // Oduzimamo mobilnost protivnika
        let opponentMoves = getValidMoves(for: board, player: opponent)
        
        for move in opponentMoves {
            let neighbors = getNeighbors(move, boardSize: board.size)
            let emptyNeighbors = neighbors.filter { 
                let (r, c) = $0
                return r >= 0 && r < board.size && c >= 0 && c < board.size && 
                       board.cells[r][c].type == .empty 
            }
            
            mobilityScore -= emptyNeighbors.count
        }
        
        return mobilityScore / 2  // Normalizujemo vrednost
    }
    
    // Nova pomoćna funkcija za računanje susednih polja
    private func getNeighbors(_ position: (row: Int, column: Int), boardSize: Int) -> [(Int, Int)] {
        let (row, col) = position
        
        // 8 mogućih suseda (gore, dole, levo, desno, dijagonale)
        return [
            (row-1, col-1), (row-1, col), (row-1, col+1),
            (row, col-1),                 (row, col+1),
            (row+1, col-1), (row+1, col), (row+1, col+1)
        ]
    }
    
    // Nova pomoćna funkcija za računanje kontrole teritorije
    private func calculateTerritoryControl(_ game: Game, player: Player) -> Int {
        let opponent = player == .blue ? Player.red : Player.blue
        let board = game.board
        
        // Definišemo četvrtine table kao teritorije
        let quarters = [
            // Gornja leva četvrtina
            (0..<board.size/2).flatMap { r in
                (0..<board.size/2).map { c in (r, c) }
            },
            // Gornja desna četvrtina
            (0..<board.size/2).flatMap { r in
                (board.size/2..<board.size).map { c in (r, c) }
            },
            // Donja leva četvrtina
            (board.size/2..<board.size).flatMap { r in
                (0..<board.size/2).map { c in (r, c) }
            },
            // Donja desna četvrtina
            (board.size/2..<board.size).flatMap { r in
                (board.size/2..<board.size).map { c in (r, c) }
            }
        ]
        
        var territoryScore = 0
        
        for (index, territory) in quarters.enumerated() {
            var playerCells = 0
            var opponentCells = 0
            
            for (r, c) in territory {
                if board.cells[r][c].type == .blue && player == .blue {
                    playerCells += 1
                } else if board.cells[r][c].type == .red && player == .red {
                    playerCells += 1
                } else if board.cells[r][c].type == .blue && player == .red {
                    opponentCells += 1
                } else if board.cells[r][c].type == .red && player == .blue {
                    opponentCells += 1
                }
            }
            
            // Dodajemo bonus za dominaciju u teritoriji
            let territoryDiff = playerCells - opponentCells
            territoryScore += territoryDiff * 3
            
            // Bonus za kontrolu centra je već računat u glavnoj funkciji
        }
        
        return territoryScore
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
        print("ML: Započinjem trening sa \(games.count) partija")
        
        // Ovde bismo pozivali Python skriptu za treniranje
        // Za sada samo simuliramo trening tako što ažuriramo težine mock modela
        
        if let mockModel = model as? [String: Float] {
            var updatedWeights = mockModel
            
            // Simuliramo "učenje" ažuriranjem težina na osnovu analize partija
            let gameFactor = min(Float(games.count) / 10.0, 2.0)
            
            // Analiza pobedničke strategije iz podataka
            var blueWins = 0
            var redWins = 0
            var moveCountSum = 0
            var edgeMovesSumWinner = 0
            var cornerMovesSumWinner = 0
            
            for game in games {
                moveCountSum += game.moves.count
                
                if game.winner == .blue {
                    blueWins += 1
                } else {
                    redWins += 1
                }
                
                // Brojimo ivice i ćoškove pobednika
                if let boardSize = game.boardStates.first?.count {
                    for move in game.moves {
                        let isWinnerMove = (game.currentPlayers[game.moves.firstIndex(of: move) ?? 0] == game.winner)
                        if isWinnerMove {
                            if move.row == 0 || move.row == boardSize - 1 || 
                               move.column == 0 || move.column == boardSize - 1 {
                                edgeMovesSumWinner += 1
                            }
                            
                            if (move.row == 0 && move.column == 0) ||
                               (move.row == 0 && move.column == boardSize - 1) ||
                               (move.row == boardSize - 1 && move.column == 0) ||
                               (move.row == boardSize - 1 && move.column == boardSize - 1) {
                                cornerMovesSumWinner += 1
                            }
                        }
                    }
                }
            }
            
            // Odlučujemo koju strategiju favorizujemo na osnovu analize
            let averageMoves = games.isEmpty ? 0 : Float(moveCountSum) / Float(games.count)
            let edgeRatio = games.isEmpty ? 0 : Float(edgeMovesSumWinner) / Float(moveCountSum)
            let cornerRatio = games.isEmpty ? 0 : Float(cornerMovesSumWinner) / Float(moveCountSum)
            
            // Ažuriramo težine prema analizi
            updatedWeights["move_advantage"] = (mockModel["move_advantage"] ?? 1.0) * gameFactor
            
            // Ako pobednici često igraju na ivicama, povećavamo težinu ivica
            if edgeRatio > 0.3 {
                updatedWeights["edge_control"] = (mockModel["edge_control"] ?? 1.0) * (1.0 + edgeRatio)
            }
            
            // Ako pobednici često igraju u ćoškovima, povećavamo težinu ćoškova
            if cornerRatio > 0.2 {
                updatedWeights["corner_control"] = (mockModel["corner_control"] ?? 1.0) * (1.0 + cornerRatio * 2)
            }
            
            // Ako su partije kratke, favorizujemo agresivniju strategiju
            if averageMoves < 15 {
                updatedWeights["blocking_factor"] = (mockModel["blocking_factor"] ?? 1.0) * 1.5
            } else {
                updatedWeights["center_control"] = (mockModel["center_control"] ?? 1.0) * 1.3
            }
            
            model = updatedWeights
            print("ML: Mock trening završen, ažurirane težine na osnovu analize \(games.count) partija")
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