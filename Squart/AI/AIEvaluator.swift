import Foundation

/// Класа која управља евалуацијом позиција
class AIEvaluator {
    /// Евалуира позицију за датог играча
    static func evaluatePosition(_ game: Game, for player: Player) -> Int {
        var score = 0
        
        // Бројимо потезе у центру
        score += countCenterMoves(game, for: player) * 10
        
        // Бројимо потезе у угловима
        score += countCornerMoves(game, for: player) * 5
        
        // Бројимо све потезе
        score += game.board.getValidMoves(for: player).count * 2
        
        // Додајемо бонус за контролу центра
        if game.board.cells[3][3].type == .blue && player == .blue {
            score += 20
        } else if game.board.cells[3][3].type == .red && player == .red {
            score += 20
        }
        
        return score
    }
    
    /// Броји потезе у центру табле
    static func countCenterMoves(_ game: Game, for player: Player) -> Int {
        var count = 0
        let center = game.board.size / 2
        
        // Проверавамо централну ћелију
        if game.board.cells[center][center].type == .empty {
            count += 1
        }
        
        // Проверавамо суседне ћелије
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        for (dx, dy) in directions {
            let newRow = center + dx
            let newCol = center + dy
            
            if game.board.isValidPosition(row: newRow, column: newCol) &&
               game.board.cells[newRow][newCol].type == .empty {
                count += 1
            }
        }
        
        return count
    }
    
    /// Броји потезе у угловима табле
    static func countCornerMoves(_ game: Game, for player: Player) -> Int {
        var count = 0
        let size = game.board.size
        
        // Проверавамо све углове
        let corners = [(0, 0), (0, size-1), (size-1, 0), (size-1, size-1)]
        for (row, col) in corners {
            if game.board.cells[row][col].type == .empty {
                count += 1
            }
        }
        
        return count
    }
} 