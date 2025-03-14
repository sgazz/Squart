import SwiftUI

// MARK: - Enums
enum TokenOrientation: Equatable {
    case horizontal
    case vertical
}

// MARK: - Board View
struct BoardView: View {
    @ObservedObject var game: Game
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<game.board.size, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<game.board.size, id: \.self) { column in
                        makeCellView(row: row, column: column)
                            .onTapGesture {
                                handleCellTap(row: row, column: column)
                            }
                    }
                }
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func makeCellView(row: Int, column: Int) -> some View {
        CellView(
            cell: game.board.cells[row][column],
            size: cellSize,
            isFirstCellOfToken: isFirstCellOfToken(row: row, column: column),
            tokenOrientation: tokenOrientation(row: row, column: column)
        )
    }
    
    private func isFirstCellOfToken(row: Int, column: Int) -> Bool {
        let cell = game.board.cells[row][column]
        guard cell.type != .empty && cell.type != .blocked else { return false }
        
        if cell.type == .blue {
            return column == 0 || game.board.cells[row][column - 1].type != .blue
        } else {
            return row == 0 || game.board.cells[row - 1][column].type != .red
        }
    }
    
    private func tokenOrientation(row: Int, column: Int) -> TokenOrientation? {
        let cell = game.board.cells[row][column]
        guard cell.type != .empty && cell.type != .blocked else { return nil }
        return cell.type == .blue ? .horizontal : .vertical
    }
    
    private func handleCellTap(row: Int, column: Int) {
        guard !game.isGameOver else { 
            print("handleCellTap: Игра је завршена, додир игнорисан")
            return 
        }
        
        print("handleCellTap: Покушај додира на позицији (\(row), \(column))")
        print("handleCellTap: Тренутни тип ћелије: \(game.board.cells[row][column].type)")
        print("handleCellTap: Тренутни играч: \(game.currentPlayer == .blue ? "плави" : "црвени")")
        print("handleCellTap: AI мод: \(game.aiEnabled), AI vs AI: \(game.aiVsAiMode), AI тим: \(game.aiTeam == .blue ? "плави" : "црвени")")
        
        if game.aiEnabled && game.aiVsAiMode {
            print("handleCellTap: AI vs AI мод је активан, додир игнорисан")
            return
        }
        
        if game.aiEnabled && game.currentPlayer == game.aiTeam {
            print("handleCellTap: На потезу је AI тим, додир игнорисан")
            return
        }
        
        let result = game.makeMove(row: row, column: column)
        print("handleCellTap: Резултат потеза: \(result ? "успешно" : "неуспешно")")
        
        if result {
            SoundManager.shared.playSound(.place)
            SoundManager.shared.triggerHaptic()
            
            if game.aiEnabled && !game.isGameOver {
                print("handleCellTap: Планирање AI потеза за 0.5 секунди")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("handleCellTap: Покретање AI потеза")
                    game.makeAIMove()
                }
            }
        } else {
            SoundManager.shared.playSound(.error)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
        BoardView(game: Game(boardSize: 7), cellSize: 44)
            .padding()
    }
} 