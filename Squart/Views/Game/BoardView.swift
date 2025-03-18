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
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func handleCellTap(row: Int, column: Int) {
        guard !game.isGameOver else { return }
        
        // Ako je AI uključen i trenutni igrač je AI tim, ignorišemo klikove korisnika
        if game.aiEnabled && game.currentPlayer == game.aiTeam {
            return
        }
        
        if game.makeMove(row: row, column: column) {
            SoundManager.shared.playSound(.place)
            SoundManager.shared.triggerHaptic()
            
            // Ako je AI uključen i nije kraj igre, neka AI odigra svoj potez
            if game.aiEnabled && !game.isGameOver {
                // Malo odlažemo AI potez da izgleda više prirodno
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    game.makeAIMove()
                }
            }
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