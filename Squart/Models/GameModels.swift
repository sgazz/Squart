import Foundation

enum CellType: Codable {
    case empty
    case blocked
    case blue
    case red
}

enum Player: Codable {
    case blue
    case red
    
    var cellType: CellType {
        switch self {
        case .blue: return .blue
        case .red: return .red
        }
    }
    
    var isHorizontal: Bool {
        switch self {
        case .blue: return true
        case .red: return false
        }
    }
}

struct BoardCell: Identifiable {
    let id = UUID()
    var type: CellType
    let row: Int
    let column: Int
}

class GameBoard: ObservableObject {
    @Published var cells: [[BoardCell]]
    let size: Int
    
    init(size: Int) {
        self.size = size
        self.cells = []
        
        // Inicijalizacija prazne table
        for row in 0..<size {
            var rowCells: [BoardCell] = []
            for column in 0..<size {
                rowCells.append(BoardCell(type: .empty, row: row, column: column))
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
            cells[row][column].type = .blocked
        }
    }
    
    func isValidMove(row: Int, column: Int, player: Player) -> Bool {
        // Provera osnovnih uslova za početno polje
        guard row >= 0 && row < size && column >= 0 && column < size else { return false }
        guard cells[row][column].type == .empty else { return false }
        
        if player.isHorizontal {
            // Plavi igrač - horizontalno postavljanje (s leva na desno)
            // Provera desnog polja
            if column + 1 < size && cells[row][column + 1].type == .empty {
                return true
            }
            return false
            
        } else {
            // Crveni igrač - vertikalno postavljanje (odozgo prema dole)
            // Provera donjeg polja
            if row + 1 < size && cells[row + 1][column].type == .empty {
                return true
            }
            return false
        }
    }
    
    func makeMove(row: Int, column: Int, player: Player) -> Bool {
        guard isValidMove(row: row, column: column, player: player) else { return false }
        
        cells[row][column].type = player.cellType
        
        if player.isHorizontal {
            // Plavi igrač - horizontalno postavljanje (s leva na desno)
            cells[row][column + 1].type = player.cellType
        } else {
            // Crveni igrač - vertikalno postavljanje (odozgo prema dole)
            cells[row + 1][column].type = player.cellType
        }
        
        return true
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
}

class Game: ObservableObject {
    @Published var board: GameBoard
    @Published var currentPlayer: Player = .blue
    @Published var blueScore: Int = 0
    @Published var redScore: Int = 0
    @Published var isGameOver: Bool = false
    
    // Tajmeri za igrače
    @Published var blueTimeRemaining: Int
    @Published var redTimeRemaining: Int
    @Published var timerOption: TimerOption
    
    // Razlog završetka igre
    enum GameEndReason {
        case noValidMoves  // Nema validnih poteza
        case blueTimeout   // Plavi igrač je ostao bez vremena
        case redTimeout    // Crveni igrač je ostao bez vremena
        case none          // Igra nije završena
    }
    
    @Published var gameEndReason: GameEndReason = .none
    
    init(boardSize: Int = 7) {
        self.board = GameBoard(size: boardSize)
        let timerOpt = GameSettingsManager.shared.timerOption
        self.timerOption = timerOpt
        self.blueTimeRemaining = timerOpt.rawValue
        self.redTimeRemaining = timerOpt.rawValue
    }
    
    func makeMove(row: Int, column: Int) -> Bool {
        guard !isGameOver else { return false }
        
        if board.makeMove(row: row, column: column, player: currentPlayer) {
            // Promena igrača
            currentPlayer = currentPlayer == .blue ? .red : .blue
            
            // Provera da li sledeći igrač ima validne poteze
            if !board.hasValidMoves(for: currentPlayer) {
                isGameOver = true
                gameEndReason = .noValidMoves
                // Pobeđuje prethodni igrač (onaj koji je upravo odigrao potez)
                if currentPlayer == .red { // ako je sledeći crveni, znači da je plavi pobedio
                    blueScore += 1
                } else {
                    redScore += 1
                }
            }
            
            return true
        }
        return false
    }
    
    func updateTimer() {
        guard !isGameOver else { return }
        guard timerOption != .none else { return }
        
        // Umanjujemo vreme trenutnom igraču
        if currentPlayer == .blue {
            blueTimeRemaining -= 1
            if blueTimeRemaining <= 0 {
                timeOut(for: .blue)
            }
        } else {
            redTimeRemaining -= 1
            if redTimeRemaining <= 0 {
                timeOut(for: .red)
            }
        }
    }
    
    func timeOut(for player: Player) {
        isGameOver = true
        
        if player == .blue {
            gameEndReason = .blueTimeout
            redScore += 1  // Crveni igrač pobeđuje
        } else {
            gameEndReason = .redTimeout
            blueScore += 1  // Plavi igrač pobeđuje
        }
    }
    
    func resetGame() {
        board = GameBoard(size: board.size)
        currentPlayer = .blue
        isGameOver = false
        gameEndReason = .none
        
        // Resetovanje tajmera
        timerOption = GameSettingsManager.shared.timerOption
        blueTimeRemaining = timerOption.rawValue
        redTimeRemaining = timerOption.rawValue
    }
} 