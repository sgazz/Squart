import Foundation
import SwiftUI

actor AsyncAIController {
    // MARK: - Properties
    private var isThinking: Bool = false
    private var currentTask: Task<Void, Never>?
    private let evaluator: AIEvaluator
    private let cache: AICache
    
    // MARK: - Progress Tracking
    @Published private(set) var thinkingProgress: Double = 0
    private var startTime: Date?
    private let maxThinkingTime: TimeInterval = 5.0 // 5 sekundi maksimalno
    
    // MARK: - Initialization
    init() {
        self.evaluator = AIEvaluator()
        self.cache = AICache(maxSize: 1000000)
    }
    
    // MARK: - Public Methods
    func makeMove(in game: Game, for player: Player, difficulty: AIDifficulty) async -> Position? {
        guard !isThinking else {
            print("AsyncAIController: Већ размишљам о потезу")
            return nil
        }
        
        isThinking = true
        startTime = Date()
        thinkingProgress = 0
        
        defer {
            isThinking = false
            startTime = nil
            thinkingProgress = 0
        }
        
        do {
            return try await findBestMove(in: game, for: player, difficulty: difficulty)
        } catch {
            print("AsyncAIController: Грешка приликом тражења потеза - \(error)")
            return nil
        }
    }
    
    func cancelThinking() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    // MARK: - Private Methods
    private func findBestMove(in game: Game, for player: Player, difficulty: AIDifficulty) async throws -> Position? {
        var bestMove: Position?
        var bestScore = Int.min
        
        let validMoves = game.board.getValidMoves(for: player)
        let totalMoves = validMoves.count
        
        for (index, move) in validMoves.enumerated() {
            // Проверавамо да ли је прошло максимално време
            if let startTime = startTime, 
               Date().timeIntervalSince(startTime) >= maxThinkingTime {
                print("AsyncAIController: Достигнуто максимално време размишљања")
                break
            }
            
            // Ажурирамо прогрес
            await MainActor.run {
                thinkingProgress = Double(index) / Double(totalMoves)
            }
            
            // Правимо копију игре за симулацију
            let gameCopy = game.copy()
            _ = gameCopy.makeMove(row: move.row, column: move.column)
            
            let score = try await evaluatePosition(gameCopy, 
                                                 depth: difficulty.maxDepth,
                                                 player: player)
            
            if score > bestScore {
                bestScore = score
                bestMove = Position(row: move.row, column: move.column)
            }
            
            // Проверавамо да ли је задатак отказан
            try Task.checkCancellation()
        }
        
        return bestMove
    }
    
    private func evaluatePosition(_ game: Game, depth: Int, player: Player) async throws -> Int {
        // Базни случај
        if depth == 0 || game.isGameOver {
            return AIEvaluator.evaluatePosition(game, for: player)
        }
        
        let validMoves = game.board.getValidMoves(for: player)
        if validMoves.isEmpty {
            return AIEvaluator.evaluatePosition(game, for: player)
        }
        
        var bestScore = player == game.currentPlayer ? Int.min : Int.max
        
        for move in validMoves {
            // Проверавамо отказивање
            try Task.checkCancellation()
            
            let gameCopy = game.copy()
            _ = gameCopy.makeMove(row: move.row, column: move.column)
            
            let score = try await evaluatePosition(gameCopy, 
                                                 depth: depth - 1,
                                                 player: player == .blue ? .red : .blue)
            
            if player == game.currentPlayer {
                bestScore = max(bestScore, score)
            } else {
                bestScore = min(bestScore, score)
            }
        }
        
        return bestScore
    }
} 