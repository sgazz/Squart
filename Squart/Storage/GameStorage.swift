import Foundation

// MARK: - Move Suggestion
struct MoveSuggestion: Codable {
    let row: Int
    let column: Int
    let score: Int
}

// MARK: - Game State
struct GameState: Codable {
    let boardSize: Int
    let cells: [[CellType]]
    let currentPlayer: Player
    let isGameOver: Bool
    let winner: Player?
    let aiDifficulty: AIDifficulty
    let secondAiDifficulty: AIDifficulty
    let isAIGame: Bool
    let isSecondAITurn: Bool
    let showAIThinking: Bool
    let consideredMoves: [MoveSuggestion]
    
    init(from game: Game) {
        self.boardSize = game.board.size
        self.cells = game.board.getCellTypeArray()
        self.currentPlayer = game.currentPlayer
        self.isGameOver = game.isGameOver
        self.winner = game.winner
        self.aiDifficulty = game.aiDifficulty
        self.secondAiDifficulty = game.secondAiDifficulty
        self.isAIGame = game.isAIGame
        self.isSecondAITurn = game.isSecondAITurn
        self.showAIThinking = game.showAIThinking
        self.consideredMoves = game.consideredMoves.map { MoveSuggestion(row: $0.row, column: $0.column, score: $0.score) }
    }
}

// MARK: - Game Storage
class GameStorage {
    static let shared = GameStorage()
    private let defaults = UserDefaults.standard
    private let gameStateKey = "savedGameState"
    
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
        game.board.cells = gameState.cells.enumerated().map { row, rowCells in
            rowCells.enumerated().map { col, cellType in
                Cell(type: cellType, row: row, column: col)
            }
        }
        game.currentPlayer = gameState.currentPlayer
        game.isGameOver = gameState.isGameOver
        game.winner = gameState.winner
        game.aiDifficulty = gameState.aiDifficulty
        game.secondAiDifficulty = gameState.secondAiDifficulty
        game.isAIGame = gameState.isAIGame
        game.isSecondAITurn = gameState.isSecondAITurn
        game.showAIThinking = gameState.showAIThinking
        game.consideredMoves = gameState.consideredMoves.map { (row: $0.row, column: $0.column, score: $0.score) }
        
        return game
    }
    
    func clearSavedGame() {
        defaults.removeObject(forKey: gameStateKey)
    }
} 