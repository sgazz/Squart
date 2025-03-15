import Foundation

/// Класа која управља претрагом најбољег потеза користећи alpha-beta алгоритма
class AISearch {
    private let maxDepth: Int
    private let evaluator: AIEvaluator
    private let cache: AICache
    private var isCancelled: Bool = false
    
    init(maxDepth: Int, evaluator: AIEvaluator, cache: AICache) {
        self.maxDepth = maxDepth
        self.evaluator = evaluator
        self.cache = cache
    }
    
    /// Проналази најбољи потез за тренутну позицију
    func findBestMove(for game: Game) -> Position? {
        isCancelled = false
        let validMoves = game.board.getValidMoves(for: game.currentPlayer)
        
        if validMoves.isEmpty {
            return nil
        }
        
        var bestScore = Int.min
        var bestMove: Position?
        
        for move in validMoves {
            if isCancelled {
                print("AISearch: Претрага је прекинута")
                return nil
            }
            
            let score = alphaBetaMinimax(
                game: game,
                depth: maxDepth - 1,
                alpha: Int.min,
                beta: Int.max,
                isMaximizing: false,
                currentPlayer: game.currentPlayer
            )
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        return bestMove
    }
    
    /// Имплементација alpha-beta алгоритма
    private func alphaBetaMinimax(
        game: Game,
        depth: Int,
        alpha: Int,
        beta: Int,
        isMaximizing: Bool,
        currentPlayer: Player
    ) -> Int {
        if isCancelled {
            return 0
        }
        
        // Проверавамо кеш
        let cacheKey = "\(game.board.description)_\(depth)_\(isMaximizing)_\(currentPlayer)"
        if let cached = cache.get(key: cacheKey) {
            return cached.score
        }
        
        // Базни случај
        if depth == 0 {
            let score = AIEvaluator.evaluatePosition(game, for: currentPlayer)
            cache.set(key: cacheKey, value: (score, nil))
            return score
        }
        
        let validMoves = game.board.getValidMoves(for: currentPlayer)
        if validMoves.isEmpty {
            let score = AIEvaluator.evaluatePosition(game, for: currentPlayer)
            cache.set(key: cacheKey, value: (score, nil))
            return score
        }
        
        if isMaximizing {
            var maxScore = Int.min
            for move in validMoves {
                if isCancelled {
                    return maxScore
                }
                
                let newGame = game.copy()
                _ = newGame.makeMove(row: move.row, column: move.column)
                
                let score = alphaBetaMinimax(
                    game: newGame,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: beta,
                    isMaximizing: false,
                    currentPlayer: currentPlayer == .blue ? .red : .blue
                )
                
                maxScore = max(maxScore, score)
                alpha = max(alpha, score)
                
                if beta <= alpha {
                    break
                }
            }
            
            cache.set(key: cacheKey, value: (maxScore, nil))
            return maxScore
        } else {
            var minScore = Int.max
            for move in validMoves {
                if isCancelled {
                    return minScore
                }
                
                let newGame = game.copy()
                _ = newGame.makeMove(row: move.row, column: move.column)
                
                let score = alphaBetaMinimax(
                    game: newGame,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: beta,
                    isMaximizing: true,
                    currentPlayer: currentPlayer == .blue ? .red : .blue
                )
                
                minScore = min(minScore, score)
                beta = min(beta, score)
                
                if beta <= alpha {
                    break
                }
            }
            
            cache.set(key: cacheKey, value: (minScore, nil))
            return minScore
        }
    }
    
    /// Прекида претрагу
    func cancel() {
        isCancelled = true
    }
    
    /// Ресетује флаг за прекид
    func resetCancelFlag() {
        isCancelled = false
    }
} 