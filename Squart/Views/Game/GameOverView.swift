import SwiftUI

struct GameOverView: View {
    let game: Game
    let onPlayAgain: () -> Void
    let onQuickSetup: () -> Void
    @Binding var isPresented: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        VStack(spacing: horizontalSizeClass == .regular ? 12 : 16) {
            // Winner announcement
            Text(winnerText)
                .font(horizontalSizeClass == .regular ? .headline.bold() : .title3.bold())
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: {
                    isPresented = false
                    onQuickSetup()
                }) {
                    Text("Quick Setup")
                        .font(horizontalSizeClass == .regular ? .callout : .headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: horizontalSizeClass == .regular ? 32 : 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(horizontalSizeClass == .regular ? .callout : .headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: horizontalSizeClass == .regular ? 32 : 44)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? 12 : 16)
        }
        .padding(horizontalSizeClass == .regular ? 16 : 20)
        .frame(width: horizontalSizeClass == .regular ? 260 : 300)
        .background(Color(.systemGray6).opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var winnerText: String {
        if game.gameEndReason == .noValidMoves {
            if game.currentPlayer == .red {
                return "Blue wins!\nRed has no valid moves"
            } else {
                return "Red wins!\nBlue has no valid moves"
            }
        } else if game.gameEndReason == .blueTimeout {
            return "Red wins!\nBlue ran out of time"
        } else if game.gameEndReason == .redTimeout {
            return "Blue wins!\nRed ran out of time"
        } else {
            return "Game Over"
        }
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView(
            game: Game(),
            onPlayAgain: {},
            onQuickSetup: {},
            isPresented: .constant(true)
        )
        .background(Color.gray)
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDisplayName("Game Over")
    }
} 