import SwiftUI

struct GameOverView: View {
    let game: Game
    let onNewGame: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(gameOverMessage)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(winnerMessage)
                .font(.title3)
                .foregroundColor(.white)
            
            GameButton(title: "new_game".localized, icon: "arrow.counterclockwise", color: .blue) {
                withAnimation {
                    onNewGame()
                }
            }
            .frame(maxWidth: 200)
        }
        .padding(24)
        .background(Color.black.opacity(0.7))
        .cornerRadius(16)
    }
    
    private var gameOverMessage: String {
        switch game.gameEndReason {
        case .noValidMoves: return "no_valid_moves".localized
        case .blueTimeout: return "blue_timeout".localized
        case .redTimeout: return "red_timeout".localized
        case .none: return "game_over".localized
        }
    }
    
    private var winnerMessage: String {
        let lastPlayer = game.currentPlayer == .blue ? Player.red : Player.blue
        return "\("winner".localized): \(lastPlayer == .blue ? "blue".localized : "red".localized)"
    }
}

#Preview {
    GameOverView(game: Game()) {
        print("New game tapped")
    }
    .background(Color.gray)
} 