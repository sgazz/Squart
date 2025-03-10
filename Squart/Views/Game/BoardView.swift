import SwiftUI

struct BoardView: View {
    @ObservedObject var game: Game
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<game.board.size, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<game.board.size, id: \.self) { column in
                        CellView(cell: game.board.cells[row][column], size: cellSize)
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
    
    private func handleCellTap(row: Int, column: Int) {
        guard !game.isGameOver else { return }
        
        if game.makeMove(row: row, column: column) {
            SoundManager.shared.playSound(.place)
            SoundManager.shared.triggerHaptic()
        } else {
            SoundManager.shared.playSound(.error)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
        BoardView(game: Game(boardSize: 7), cellSize: 44)
            .padding()
    }
} 