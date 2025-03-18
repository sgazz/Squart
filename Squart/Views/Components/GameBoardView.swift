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