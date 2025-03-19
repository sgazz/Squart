import SwiftUI

struct GameOverView: View {
    let game: Game
    let onPlayAgain: () -> Void
    let onQuickSetup: () -> Void
    let scoreText: String
    let quickSetupText: String
    let playAgainText: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Winner announcement
            Text(winnerText)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Score
            Text(scoreText)
                .font(.title2)
                .foregroundColor(.white)
            
            // Buttons
            HStack(spacing: 16) {
                Button(action: onQuickSetup) {
                    Text(quickSetupText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                }
                
                Button(action: onPlayAgain) {
                    Text(playAgainText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
        )
        .padding()
    }
    
    private var winnerText: String {
        if game.gameEndReason == .noValidMoves {
            if game.currentPlayer == .red {
                return "Blue wins - Red has no valid moves!"
            } else {
                return "Red wins - Blue has no valid moves!"
            }
        } else if game.gameEndReason == .blueTimeout {
            return "Red wins - Blue ran out of time!"
        } else if game.gameEndReason == .redTimeout {
            return "Blue wins - Red ran out of time!"
        } else {
            return "Game Over"
        }
    }
}

#Preview {
    GameOverView(
        game: Game(),
        onPlayAgain: {},
        onQuickSetup: {},
        scoreText: "Score: 0 - 0",
        quickSetupText: "Quick Setup",
        playAgainText: "Play Again"
    )
    .background(Color.gray)
} 