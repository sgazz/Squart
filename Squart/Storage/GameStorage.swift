import Foundation

struct GameState: Codable {
    let boardSize: Int
    let cells: [[CellType]]
    let currentPlayer: Player
    let blueScore: Int
    let redScore: Int
    let isGameOver: Bool
    let timerOption: TimerOption
    let blueTimeRemaining: Int
    let redTimeRemaining: Int
    let aiEnabled: Bool
    let aiDifficulty: AIDifficulty
    let aiTeam: Player
    let startingPlayer: Player
    let aiVsAiMode: Bool
    let secondAiDifficulty: AIDifficulty
    let timestamp: Date
    let name: String
    
    init(from game: Game, name: String = "Automatsko čuvanje") {
        self.boardSize = game.board.size
        self.cells = game.board.cells.map { row in
            row.map { $0.type }
        }
        self.currentPlayer = game.currentPlayer
        self.blueScore = game.blueScore
        self.redScore = game.redScore
        self.isGameOver = game.isGameOver
        self.timerOption = game.timerOption
        self.blueTimeRemaining = game.blueTimeRemaining
        self.redTimeRemaining = game.redTimeRemaining
        self.aiEnabled = game.aiEnabled
        self.aiDifficulty = game.aiDifficulty
        self.aiTeam = game.aiTeam
        self.startingPlayer = game.startingPlayer
        self.aiVsAiMode = game.aiVsAiMode
        self.secondAiDifficulty = game.secondAiDifficulty
        self.timestamp = Date()
        self.name = name
    }
}

class GameStorage {
    static let shared = GameStorage()
    
    private let defaultsStorage: UserDefaultsStorage
    private let fileStorage: FileStorage
    
    private init() {
        self.defaultsStorage = UserDefaultsStorage()
        do {
            self.fileStorage = try FileStorage()
        } catch {
            fatalError("Nije moguće inicijalizovati FileStorage: \(error)")
        }
    }
    
    // Čuvanje igre
    func saveGame(_ game: Game, name: String? = nil) throws {
        let gameState = GameState(from: game, name: name ?? "Automatsko čuvanje")
        let key = "game_\(Date().timeIntervalSince1970)"
        print("Чување игре под кључем: \(key)")
        print("Стање игре: величина табле=\(gameState.boardSize), тренутни играч=\(gameState.currentPlayer), AI=\(gameState.aiEnabled)")
        
        // Čuvamo u oba storage-a za redundansu
        try defaultsStorage.save(gameState, forKey: key)
        try fileStorage.save(gameState, forKey: key)
    }
    
    // Učitavanje igre
    func loadGame(forKey key: String) throws -> Game? {
        print("Учитавање игре са кључем: \(key)")
        
        // Prvo probamo iz file storage-a
        if let gameState: GameState = try fileStorage.load(forKey: key) {
            print("Игра успешно учитана из FileStorage")
            print("Учитано стање: величина табле=\(gameState.boardSize), тренутни играч=\(gameState.currentPlayer), AI=\(gameState.aiEnabled)")
            return createGame(from: gameState)
        }
        
        // Ako ne uspe, probamo iz defaults storage-a
        if let gameState: GameState = try defaultsStorage.load(forKey: key) {
            print("Игра успешно учитана из UserDefaults")
            print("Учитано стање: величина табле=\(gameState.boardSize), тренутни играч=\(gameState.currentPlayer), AI=\(gameState.aiEnabled)")
            return createGame(from: gameState)
        }
        
        print("Игра није пронађена ни у једном складишту")
        return nil
    }
    
    // Učitavanje svih sačuvanih igara
    func loadAllGames() throws -> [(key: String, game: GameState)] {
        print("Учитавање свих сачуваних игара...")
        
        // Kombinujemo igre iz oba storage-a
        var games = [String: GameState]()
        
        do {
            // Učitavamo iz file storage-a
            let fileGames: [String: GameState] = try fileStorage.loadAll(forKeys: fileStorage.allKeys)
            print("Пронађено \(fileGames.count) игара у FileStorage")
            games.merge(fileGames) { current, _ in current }
            
            // Učitavamo iz defaults storage-a
            let defaultsGames: [String: GameState] = try defaultsStorage.loadAll(forKeys: defaultsStorage.allKeys)
            print("Пронађено \(defaultsGames.count) игара у UserDefaults")
            games.merge(defaultsGames) { current, _ in current }
            
            let sortedGames = games.map { ($0.key, $0.value) }
                .sorted { $0.1.timestamp > $1.1.timestamp }
            print("Укупно пронађено \(sortedGames.count) игара")
            
            return sortedGames
        } catch {
            print("Грешка при учитавању игара: \(error)")
            throw error
        }
    }
    
    // Brisanje igre
    func deleteGame(forKey key: String) throws {
        try defaultsStorage.delete(forKey: key)
        try fileStorage.delete(forKey: key)
    }
    
    // Brisanje svih igara
    func deleteAllGames() throws {
        try defaultsStorage.clear()
        try fileStorage.clear()
    }
    
    // Helper metoda za kreiranje Game instance iz GameState
    private func createGame(from gameState: GameState) -> Game {
        let game = Game(boardSize: gameState.boardSize)
        
        // Rekonstrukcija table
        for (row, rowCells) in gameState.cells.enumerated() {
            for (column, cellType) in rowCells.enumerated() {
                if row < game.board.cells.count && column < game.board.cells[row].count {
                    game.board.cells[row][column].type = cellType
                }
            }
        }
        
        game.currentPlayer = gameState.currentPlayer
        game.blueScore = gameState.blueScore
        game.redScore = gameState.redScore
        game.isGameOver = gameState.isGameOver
        game.timerOption = gameState.timerOption
        game.blueTimeRemaining = gameState.blueTimeRemaining
        game.redTimeRemaining = gameState.redTimeRemaining
        
        // Rekonstrukcija AI podešavanja
        game.aiEnabled = gameState.aiEnabled
        game.aiDifficulty = gameState.aiDifficulty
        game.aiTeam = gameState.aiTeam
        game.startingPlayer = gameState.startingPlayer
        game.aiVsAiMode = gameState.aiVsAiMode
        game.secondAiDifficulty = gameState.secondAiDifficulty
        
        // Inicijalizacija AI ako je potrebno
        if game.aiEnabled {
            game.initializeAI(difficulty: game.aiDifficulty, team: gameState.aiTeam)
        }
        
        return game
    }
} 