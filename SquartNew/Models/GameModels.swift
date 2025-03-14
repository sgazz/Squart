import Foundation
import SwiftUI
import Combine

// MARK: - Енумерације

/// Типови ћелија на табли
enum CellType: Int, Codable {
    case empty = 0
    case blue = 1
    case red = 2
    case blocked = 3
    
    var color: Color {
        switch self {
        case .empty:
            return Color.clear
        case .blue:
            return Color.blue
        case .red:
            return Color.red
        case .blocked:
            return Color.gray
        }
    }
}

/// Играчи у игри
enum Player: Int, Codable {
    case blue = 1
    case red = 2
    
    var color: Color {
        switch self {
        case .blue:
            return Color.blue
        case .red:
            return Color.red
        }
    }
    
    var cellType: CellType {
        switch self {
        case .blue:
            return .blue
        case .red:
            return .red
        }
    }
    
    var opponent: Player {
        switch self {
        case .blue:
            return .red
        case .red:
            return .blue
        }
    }
    
    var name: String {
        switch self {
        case .blue:
            return "Плави"
        case .red:
            return "Црвени"
        }
    }
}

/// Типови табле
enum BoardType: Int, Codable {
    case regular = 0
    case triangular = 1
    case hexagonal = 2
    
    var name: String {
        switch self {
        case .regular:
            return "Регуларна"
        case .triangular:
            return "Троугаона"
        case .hexagonal:
            return "Шестоугаона"
        }
    }
}

// MARK: - Структуре

/// Ћелија на табли
struct BoardCell: Equatable, Codable {
    var type: CellType
    
    init(type: CellType = .empty) {
        self.type = type
    }
    
    static func == (lhs: BoardCell, rhs: BoardCell) -> Bool {
        return lhs.type == rhs.type
    }
}

/// Позиција на табли
struct Position: Equatable, Hashable, Codable {
    var row: Int
    var column: Int
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

// MARK: - Класе

/// Класа за управљање игром
class Game: ObservableObject {
    @Published var board: GameBoard
    @Published var currentPlayer: Player = .blue
    @Published var blueScore: Int = 0
    @Published var redScore: Int = 0
    @Published var gameOver: Bool = false
    @Published var winner: Player?
    
    var boardSize: Int
    var boardType: BoardType
    
    init(boardSize: Int = 8, boardType: BoardType = .regular) {
        self.boardSize = boardSize
        self.boardType = boardType
        
        switch boardType {
        case .regular:
            self.board = GameBoard(size: boardSize)
        case .triangular:
            self.board = TriangularBoard(size: boardSize)
        case .hexagonal:
            self.board = HexagonalBoard(size: boardSize)
        }
        
        resetGame()
    }
    
    func resetGame() {
        // Креирај нову таблу
        switch boardType {
        case .regular:
            self.board = GameBoard(size: boardSize)
        case .triangular:
            self.board = TriangularBoard(size: boardSize)
        case .hexagonal:
            self.board = HexagonalBoard(size: boardSize)
        }
        
        // Ресетуј стање игре
        currentPlayer = .blue
        blueScore = 0
        redScore = 0
        gameOver = false
        winner = nil
        
        // Постави почетне блокиране ћелије
        setupBlockedCells()
        
        // Израчунај почетне резултате
        updateScores()
    }
    
    func setupBlockedCells() {
        // Постави неколико блокираних ћелија насумично
        let numberOfBlockedCells = Int(Double(boardSize * boardSize) * 0.1)
        var blockedPositions = Set<Position>()
        
        while blockedPositions.count < numberOfBlockedCells {
            let row = Int.random(in: 0..<boardSize)
            let column = Int.random(in: 0..<boardSize)
            let position = Position(row: row, column: column)
            
            // Избегавај блокирање ћелија у угловима
            if (row == 0 && column == 0) ||
               (row == 0 && column == boardSize - 1) ||
               (row == boardSize - 1 && column == 0) ||
               (row == boardSize - 1 && column == boardSize - 1) {
                continue
            }
            
            blockedPositions.insert(position)
        }
        
        for position in blockedPositions {
            board.cells[position.row][position.column].type = .blocked
        }
    }
    
    func makeMove(at position: Position) -> Bool {
        guard !gameOver else { return false }
        
        if board.isValidMove(row: position.row, column: position.column, player: currentPlayer) {
            board.makeMove(row: position.row, column: position.column, player: currentPlayer)
            updateScores()
            
            // Провери да ли је игра завршена
            if !board.hasValidMoves(for: currentPlayer.opponent) {
                gameOver = true
                determineWinner()
                return true
            }
            
            // Промени играча
            currentPlayer = currentPlayer.opponent
            
            // Провери да ли тренутни играч има валидне потезе
            if !board.hasValidMoves(for: currentPlayer) {
                // Ако нема, врати се на претходног играча
                currentPlayer = currentPlayer.opponent
                
                // Провери да ли је игра завршена
                if !board.hasValidMoves(for: currentPlayer) {
                    gameOver = true
                    determineWinner()
                }
            }
            
            return true
        }
        
        return false
    }
    
    func updateScores() {
        blueScore = 0
        redScore = 0
        
        for row in 0..<boardSize {
            for column in 0..<boardSize {
                let cell = board.cells[row][column]
                switch cell.type {
                case .blue:
                    blueScore += 1
                case .red:
                    redScore += 1
                default:
                    break
                }
            }
        }
    }
    
    func determineWinner() {
        if blueScore > redScore {
            winner = .blue
        } else if redScore > blueScore {
            winner = .red
        } else {
            // Нерешено
            winner = nil
        }
    }
}

/// Основна класа за таблу игре
class GameBoard: ObservableObject {
    @Published var cells: [[BoardCell]]
    var size: Int
    
    init(size: Int) {
        self.size = size
        self.cells = Array(repeating: Array(repeating: BoardCell(), count: size), count: size)
    }
    
    func isValidMove(row: Int, column: Int, player: Player) -> Bool {
        // Провери да ли је ћелија у границама табле
        guard row >= 0 && row < size && column >= 0 && column < size else {
            return false
        }
        
        // Провери да ли је ћелија празна
        guard cells[row][column].type == .empty else {
            return false
        }
        
        // Дефиниши све могуће правце (хоризонтално, вертикално, дијагонално)
        let directions = [
            (-1, 0), // горе
            (1, 0),  // доле
            (0, -1), // лево
            (0, 1),  // десно
            (-1, -1), // горе-лево
            (-1, 1),  // горе-десно
            (1, -1),  // доле-лево
            (1, 1)    // доле-десно
        ]
        
        let opponentCellType = player.opponent.cellType
        let playerCellType = player.cellType
        
        // Провери сваки правац
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            
            // Прескочи ако је први корак ван граница
            if x < 0 || x >= size || y < 0 || y >= size {
                continue
            }
            
            // Прескочи ако први корак није противнички
            if cells[x][y].type != opponentCellType {
                continue
            }
            
            // Настави у истом правцу
            var foundOpponent = false
            
            while x >= 0 && x < size && y >= 0 && y < size {
                if cells[x][y].type == opponentCellType {
                    foundOpponent = true
                } else if cells[x][y].type == playerCellType {
                    // Ако смо нашли противника и затим нашу ћелију, потез је валидан
                    if foundOpponent {
                        return true
                    }
                    break
                } else {
                    // Празна или блокирана ћелија
                    break
                }
                
                x += dx
                y += dy
            }
        }
        
        return false
    }
    
    func makeMove(row: Int, column: Int, player: Player) {
        guard isValidMove(row: row, column: column, player: player) else {
            return
        }
        
        // Постави ћелију на тип играча
        cells[row][column].type = player.cellType
        
        // Дефиниши све могуће правце
        let directions = [
            (-1, 0), // горе
            (1, 0),  // доле
            (0, -1), // лево
            (0, 1),  // десно
            (-1, -1), // горе-лево
            (-1, 1),  // горе-десно
            (1, -1),  // доле-лево
            (1, 1)    // доле-десно
        ]
        
        let opponentCellType = player.opponent.cellType
        let playerCellType = player.cellType
        
        // Провери сваки правац
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            
            // Прескочи ако је први корак ван граница
            if x < 0 || x >= size || y < 0 || y >= size {
                continue
            }
            
            // Прескочи ако први корак није противнички
            if cells[x][y].type != opponentCellType {
                continue
            }
            
            // Настави у истом правцу и памти позиције за промену
            var positionsToFlip = [(x, y)]
            x += dx
            y += dy
            
            while x >= 0 && x < size && y >= 0 && y < size {
                if cells[x][y].type == opponentCellType {
                    positionsToFlip.append((x, y))
                } else if cells[x][y].type == playerCellType {
                    // Ако смо нашли нашу ћелију, промени све противничке ћелије између
                    for (fx, fy) in positionsToFlip {
                        cells[fx][fy].type = playerCellType
                    }
                    break
                } else {
                    // Празна или блокирана ћелија
                    break
                }
                
                x += dx
                y += dy
            }
        }
    }
    
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

/// Троугаона табла
class TriangularBoard: GameBoard {
    override func isValidMove(row: Int, column: Int, player: Player) -> Bool {
        // Провери да ли је ћелија у границама табле
        guard row >= 0 && row < size && column >= 0 && column < size else {
            return false
        }
        
        // Провери да ли је ћелија празна
        guard cells[row][column].type == .empty else {
            return false
        }
        
        // Дефиниши правце у зависности од играча
        var directions: [(Int, Int)] = []
        
        if player == .blue {
            // Плави играч се креће дијагонално горе-лево и горе-десно
            directions = [
                (-1, -1), // горе-лево
                (-1, 1)   // горе-десно
            ]
        } else {
            // Црвени играч се креће дијагонално доле-лево и доле-десно
            directions = [
                (1, -1),  // доле-лево
                (1, 1)    // доле-десно
            ]
        }
        
        let opponentCellType = player.opponent.cellType
        let playerCellType = player.cellType
        
        // Провери сваки правац
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            
            // Прескочи ако је први корак ван граница
            if x < 0 || x >= size || y < 0 || y >= size {
                continue
            }
            
            // Прескочи ако први корак није противнички
            if cells[x][y].type != opponentCellType {
                continue
            }
            
            // Настави у истом правцу
            var foundOpponent = false
            
            while x >= 0 && x < size && y >= 0 && y < size {
                if cells[x][y].type == opponentCellType {
                    foundOpponent = true
                } else if cells[x][y].type == playerCellType {
                    // Ако смо нашли противника и затим нашу ћелију, потез је валидан
                    if foundOpponent {
                        return true
                    }
                    break
                } else {
                    // Празна или блокирана ћелија
                    break
                }
                
                x += dx
                y += dy
            }
        }
        
        return false
    }
    
    override func makeMove(row: Int, column: Int, player: Player) {
        guard isValidMove(row: row, column: column, player: player) else {
            return
        }
        
        // Постави ћелију на тип играча
        cells[row][column].type = player.cellType
        
        // Дефиниши правце у зависности од играча
        var directions: [(Int, Int)] = []
        
        if player == .blue {
            // Плави играч се креће дијагонално горе-лево и горе-десно
            directions = [
                (-1, -1), // горе-лево
                (-1, 1)   // горе-десно
            ]
        } else {
            // Црвени играч се креће дијагонално доле-лево и доле-десно
            directions = [
                (1, -1),  // доле-лево
                (1, 1)    // доле-десно
            ]
        }
        
        let opponentCellType = player.opponent.cellType
        let playerCellType = player.cellType
        
        // Провери сваки правац
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            
            // Прескочи ако је први корак ван граница
            if x < 0 || x >= size || y < 0 || y >= size {
                continue
            }
            
            // Прескочи ако први корак није противнички
            if cells[x][y].type != opponentCellType {
                continue
            }
            
            // Настави у истом правцу и памти позиције за промену
            var positionsToFlip = [(x, y)]
            x += dx
            y += dy
            
            while x >= 0 && x < size && y >= 0 && y < size {
                if cells[x][y].type == opponentCellType {
                    positionsToFlip.append((x, y))
                } else if cells[x][y].type == playerCellType {
                    // Ако смо нашли нашу ћелију, промени све противничке ћелије између
                    for (fx, fy) in positionsToFlip {
                        cells[fx][fy].type = playerCellType
                    }
                    break
                } else {
                    // Празна или блокирана ћелија
                    break
                }
                
                x += dx
                y += dy
            }
        }
    }
}

/// Шестоугаона табла
class HexagonalBoard: GameBoard {
    override func isValidMove(row: Int, column: Int, player: Player) -> Bool {
        // Провери да ли је ћелија у границама табле
        guard row >= 0 && row < size && column >= 0 && column < size else {
            return false
        }
        
        // Провери да ли је ћелија празна
        guard cells[row][column].type == .empty else {
            return false
        }
        
        // Дефиниши све могуће правце за шестоугаону таблу
        let directions = [
            (-1, 0),  // горе
            (1, 0),   // доле
            (0, -1),  // лево
            (0, 1),   // десно
            (-1, -1), // горе-лево
            (-1, 1),  // горе-десно
            (1, -1),  // доле-лево
            (1, 1),   // доле-десно
            (-2, 0),  // два горе
            (2, 0),   // два доле
            (0, -2),  // два лево
            (0, 2)    // два десно
        ]
        
        let opponentCellType = player.opponent.cellType
        let playerCellType = player.cellType
        
        // Провери сваки правац
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            
            // Прескочи ако је први корак ван граница
            if x < 0 || x >= size || y < 0 || y >= size {
                continue
            }
            
            // Прескочи ако први корак није противнички
            if cells[x][y].type != opponentCellType {
                continue
            }
            
            // Настави у истом правцу
            var foundOpponent = false
            
            while x >= 0 && x < size && y >= 0 && y < size {
                if cells[x][y].type == opponentCellType {
                    foundOpponent = true
                } else if cells[x][y].type == playerCellType {
                    // Ако смо нашли противника и затим нашу ћелију, потез је валидан
                    if foundOpponent {
                        return true
                    }
                    break
                } else {
                    // Празна или блокирана ћелија
                    break
                }
                
                x += dx
                y += dy
            }
        }
        
        return false
    }
    
    override func makeMove(row: Int, column: Int, player: Player) {
        guard isValidMove(row: row, column: column, player: player) else {
            return
        }
        
        // Постави ћелију на тип играча
        cells[row][column].type = player.cellType
        
        // Дефиниши све могуће правце за шестоугаону таблу
        let directions = [
            (-1, 0),  // горе
            (1, 0),   // доле
            (0, -1),  // лево
            (0, 1),   // десно
            (-1, -1), // горе-лево
            (-1, 1),  // горе-десно
            (1, -1),  // доле-лево
            (1, 1),   // доле-десно
            (-2, 0),  // два горе
            (2, 0),   // два доле
            (0, -2),  // два лево
            (0, 2)    // два десно
        ]
        
        let opponentCellType = player.opponent.cellType
        let playerCellType = player.cellType
        
        // Провери сваки правац
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            
            // Прескочи ако је први корак ван граница
            if x < 0 || x >= size || y < 0 || y >= size {
                continue
            }
            
            // Прескочи ако први корак није противнички
            if cells[x][y].type != opponentCellType {
                continue
            }
            
            // Настави у истом правцу и памти позиције за промену
            var positionsToFlip = [(x, y)]
            x += dx
            y += dy
            
            while x >= 0 && x < size && y >= 0 && y < size {
                if cells[x][y].type == opponentCellType {
                    positionsToFlip.append((x, y))
                } else if cells[x][y].type == playerCellType {
                    // Ако смо нашли нашу ћелију, промени све противничке ћелије између
                    for (fx, fy) in positionsToFlip {
                        cells[fx][fy].type = playerCellType
                    }
                    break
                } else {
                    // Празна или блокирана ћелија
                    break
                }
                
                x += dx
                y += dy
            }
        }
    }
} 