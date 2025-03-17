import SwiftUI

struct GameStatusView: View {
    let game: Game
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        VStack(spacing: 8) {
            PlayerScoreView(game: game)
            
            Text(statusMessage)
                .font(.headline)
                .foregroundColor(.white)
            
            if game.timerOption != .none {
                ChessClockView(game: game)
            }
        }
    }
    
    private var statusMessage: String {
        if game.isGameOver {
            return gameOverMessage
        } else {
            return "\("current_player".localized): \(game.currentPlayer == .blue ? "blue".localized : "red".localized)"
        }
    }
    
    private var gameOverMessage: String {
        switch game.gameEndReason {
        case .noValidMoves: return "no_valid_moves".localized
        case .blueTimeout: return "blue_timeout".localized
        case .redTimeout: return "red_timeout".localized
        case .none: return "game_over".localized
        }
    }
}

#Preview {
    GameStatusView(game: Game())
        .background(Color.gray)
        .padding()
} 