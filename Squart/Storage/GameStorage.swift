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
    
    init(from game: Game) {
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
    }
}

class GameStorage {
    static let shared = GameStorage()
    private let defaults = UserDefaults.standard
    private let gameStateKey = "squart_game_state"
    
    private init() {}
    
    func saveGame(_ game: Game) {
        let gameState = GameState(from: game)
        if let encoded = try? JSONEncoder().encode(gameState) {
            defaults.set(encoded, forKey: gameStateKey)
        }
    }
    
    func loadGame() -> Game? {
        guard let data = defaults.data(forKey: gameStateKey),
              let gameState = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        
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
        
        // Inicijalizacija AI ako je potrebno
        if game.aiEnabled {
            game.initializeAI(difficulty: game.aiDifficulty)
        }
        
        return game
    }
    
    func clearSavedGame() {
        defaults.removeObject(forKey: gameStateKey)
    }
} 