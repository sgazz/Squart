import SwiftUI

struct GameBoardView: View {
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    let cellSize: CGFloat
    let onNewGame: () -> Void
    let onShowQuickSetup: () -> Void
    
    var body: some View {
        ZStack {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                BoardView(game: game, cellSize: cellSize)
                    .padding()
            }
            .blur(radius: game.isGameOver ? 3 : 0)
            
            // Game over overlay
            if game.isGameOver {
                GameOverView(
                    game: game,
                    onPlayAgain: onNewGame,
                    onQuickSetup: onShowQuickSetup,
                    scoreText: "\("score".localized): \(game.blueScore) - \(game.redScore)",
                    quickSetupText: "quick_setup".localized,
                    playAgainText: "play_again".localized
                )
            }
        }
    }
}

#Preview {
    GameBoardView(
        game: Game(),
        cellSize: 50,
        onNewGame: { print("New game tapped") },
        onShowQuickSetup: { print("Quick setup tapped") }
    )
    .background(Color.gray)
} 