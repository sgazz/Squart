import SwiftUI

struct ChessClockView: View {
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        HStack {
            Spacer()
            
            // Tajmer plavog igrača
            PlayerTimerView(
                remainingTime: Int(game.blueTimeRemaining),
                isActive: !game.isGameOver && game.currentPlayer == .blue,
                player: .blue
            )
            
            Spacer()
            
            // Tajmer crvenog igrača
            PlayerTimerView(
                remainingTime: Int(game.redTimeRemaining),
                isActive: !game.isGameOver && game.currentPlayer == .red,
                player: .red
            )
            
            Spacer()
        }
    }
}

#Preview {
    ChessClockView(game: Game())
        .background(Color.gray)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
} 