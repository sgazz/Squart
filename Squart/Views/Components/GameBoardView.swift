import SwiftUI

struct GameBoardView: View {
    let game: Game
    let cellSize: CGFloat
    let onNewGame: () -> Void
    
    var body: some View {
        ZStack {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                BoardView(game: game, cellSize: cellSize)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
            }
            .blur(radius: game.isGameOver ? 3 : 0)
            
            if game.isGameOver {
                GameOverView(game: game, onNewGame: onNewGame)
            }
        }
    }
}

#Preview {
    GameBoardView(game: Game(), cellSize: 50) {
        print("New game tapped")
    }
    .background(Color.gray)
} 