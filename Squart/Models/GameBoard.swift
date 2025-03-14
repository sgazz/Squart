import SwiftUI
import Foundation

// MARK: - Cell Structure Using GameModels CellType
typealias Cell = BoardCell

// MARK: - Game Board
class GameBoard: ObservableObject {
    // MARK: - Properties
    let size: Int
    @Published var cells: [[Cell]]
    @Published var currentPlayer: Player = .blue
    
    // Кеш за валидне потезе
    private var validMovesCache: [Player: Set<Position>] = [:]
    
    // Поништавамо кеш када се табла промени
    private func invalidateCache() {
        validMovesCache.removeAll()
    }
    
    // MARK: - Initialization
    init(size: Int) {
        self.size = size
        self.cells = []
        for row in 0..<size {
            var rowCells: [Cell] = []
            for col in 0..<size {
                rowCells.append(Cell(type: .empty, row: row, column: col))
            }
            cells.append(rowCells)
        }
        
        // Dodavanje blokiranih (crnih) polja (17-19% od ukupnog broja polja)
        let totalCells = size * size
        let blockedCount = Int(Double(totalCells) * Double.random(in: 0.17...0.19))
        var blockedPositions = Set<Int>()
        
        while blockedPositions.count < blockedCount {
            let position = Int.random(in: 0..<totalCells)
            blockedPositions.insert(position)
        }
        
        for position in blockedPositions {
            let row = position / size
            let column = position % size
            cells[row][column] = Cell(type: .blocked, row: row, column: column)
        }
    }
    
    /// Kreira kopiju trenutnog stanja table
    func clone() -> GameBoard {
        let clonedBoard = GameBoard(size: size)
        for row in 0..<size {
            for col in 0..<size {
                clonedBoard.cells[row][col] = Cell(type: cells[row][col].type, row: row, column: col)
            }
        }
        return clonedBoard
    }
    
    func isValidMove(row: Int, column: Int, player: Player) -> Bool {
        // Прво проверавамо кеш
        if let cachedMoves = validMovesCache[player] {
            return cachedMoves.contains(Position(row: row, column: column))
        }
        
        // Ако немамо кеш, правимо нови сет валидних потеза
        var validMoves = Set<Position>()
        
        for r in 0..<size {
            for c in 0..<size {
                if checkValidMove(row: r, column: c, player: player) {
                    validMoves.insert(Position(row: r, column: c))
                }
            }
        }
        
        // Чувамо у кешу
        validMovesCache[player] = validMoves
        
        return validMoves.contains(Position(row: row, column: column))
    }
    
    // Помоћна метода која проверава валидност потеза без кеширања
    private func checkValidMove(row: Int, column: Int, player: Player) -> Bool {
        guard row >= 0 && row < size && column >= 0 && column < size else { return false }
        guard cells[row][column].type == .empty else { return false }
        
        // За плавог проверавамо хоризонталу, за црвеног вертикалу
        let isHorizontal = player.isHorizontal
        
        // Број ћелија које треба повезати (3 или 4 зависно од величине табле)
        let connectCount = size <= 6 ? 3 : 4
        
        // Провера да ли је потез валидан
        // То значи да потез повезује одговарајући број ћелија истог играча
        if isHorizontal {
            // Провера хоризонтале (за плавог играча)
            let horizontalCount = countCellsInLine(row: row, column: column, rowDelta: 0, colDelta: 1, player: player)
            if horizontalCount >= connectCount {
                return true
            }
        } else {
            // Провера вертикале (за црвеног играча)
            let verticalCount = countCellsInLine(row: row, column: column, rowDelta: 1, colDelta: 0, player: player)
            if verticalCount >= connectCount {
                return true
            }
        }
        
        return false
    }
    
    // Броји колико узастопних ћелија истог типа има у линији почевши од (row, column)
    private func countCellsInLine(row: Int, column: Int, rowDelta: Int, colDelta: Int, player: Player) -> Int {
        var count = 1  // Укључујући и почетну ћелију
        let cellType = player.cellType
        
        // Бројимо у једном правцу
        var r = row + rowDelta
        var c = column + colDelta
        while r >= 0 && r < size && c >= 0 && c < size && cells[r][c].type == cellType {
            count += 1
            r += rowDelta
            c += colDelta
        }
        
        // Бројимо и у супротном правцу
        r = row - rowDelta
        c = column - colDelta
        while r >= 0 && r < size && c >= 0 && c < size && cells[r][c].type == cellType {
            count += 1
            r -= rowDelta
            c -= colDelta
        }
        
        return count
    }
    
    // MARK: - Game Play Methods
    func makeMove(row: Int, column: Int, player: Player) -> Bool {
        guard isValidMove(row: row, column: player.isHorizontal ? column - 1 : column, player: player) ||
              isValidMove(row: player.isHorizontal ? row : row - 1, column: column, player: player) ||
              isValidMove(row: row, column: player.isHorizontal ? column + 1 : column, player: player) ||
              isValidMove(row: player.isHorizontal ? row : row + 1, column: column, player: player) else {
            return false
        }
        
        // Постављамо ћелију
        cells[row][column] = Cell(type: player.cellType, row: row, column: column)
        
        // Поништавамо кеш када се табла промени
        invalidateCache()
        
        return true
    }
    
    // MARK: - Valid Moves Calculation
    func getValidMoves(for player: Player) -> [Position] {
        // Прво проверавамо кеш
        if let cachedMoves = validMovesCache[player] {
            return Array(cachedMoves)
        }
        
        var validMoves = Set<Position>()
        
        for row in 0..<size {
            for column in 0..<size {
                if checkValidMove(row: row, column: column, player: player) {
                    validMoves.insert(Position(row: row, column: column))
                }
            }
        }
        
        // Чувамо у кешу
        validMovesCache[player] = validMoves
        
        return Array(validMoves)
    }
    
    // Helper funkcija za proveru da li postoje validni potezi za igrača
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
    
    /// Враћа стање табле као матрицу CellType вредности
    func getCellTypeArray() -> [[CellType]] {
        var cellTypes = [[CellType]](repeating: [CellType](repeating: .empty, count: size), count: size)
        
        for row in 0..<size {
            for column in 0..<size {
                cellTypes[row][column] = cells[row][column].type
            }
        }
        
        return cellTypes
    }
    
    // Provera da li je tabla puna
    func isFull() -> Bool {
        for row in 0..<size {
            for column in 0..<size {
                if cells[row][column].type == .empty {
                    return false
                }
            }
        }
        return true
    }
    
    // Provera da li ima pobednika
    func checkForWinner() -> Player? {
        // Proveravamo da li ima validnih poteza za oba igrača
        let blueHasMoves = hasValidMoves(for: .blue)
        let redHasMoves = hasValidMoves(for: .red)
        
        // Ako nema validnih poteza za oba igrača, igra je završena
        if !blueHasMoves && !redHasMoves {
            // Pobednik je onaj koji je poslednji odigrao potez
            return currentPlayer == .blue ? .red : .blue
        }
        
        return nil
    }
    
    // MARK: - AI Helper Methods
    /// Postavlja oznaku na tablu
    func placeMark(at position: Position, for player: Player) -> Bool {
        guard position.row >= 0 && position.row < size && position.column >= 0 && position.column < size else {
            return false
        }
        
        cells[position.row][position.column].type = player.cellType
        
        if player.isHorizontal {
            if position.column + 1 < size {
                cells[position.row][position.column + 1].type = player.cellType
            }
        } else {
            if position.row + 1 < size {
                cells[position.row + 1][position.column].type = player.cellType
            }
        }
        
        invalidateCache()
        return true
    }
    
    /// Evaluira trenutnu poziciju na tabli
    func evaluateBoard(board: GameBoard, player: Player) -> Int {
        var score = 0
        
        // Brojimo validne poteze za oba igrača
        let myValidMoves = board.hasValidMoves(for: player)
        let opponentValidMoves = board.hasValidMoves(for: player == .blue ? .red : .blue)
        
        // Ako nema validnih poteza za protivnika, pobedili smo
        if !opponentValidMoves {
            return 1000
        }
        
        // Ako nema validnih poteza za nas, izgubili smo
        if !myValidMoves {
            return -1000
        }
        
        // Razlika u broju validnih poteza
        score += myValidMoves ? 5 : 0
        score -= opponentValidMoves ? 5 : 0
        
        return score
    }
} 