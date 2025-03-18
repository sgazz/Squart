import SwiftUI

struct PlayerScoreView: View {
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        HStack(spacing: 20) {
            PlayerScoreItemView(
                player: .blue,
                score: game.blueScore,
                isActive: !game.isGameOver && game.currentPlayer == .blue,
                isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .blue)
            )
            
            Spacer()
            
            PlayerScoreItemView(
                player: .red,
                score: game.redScore,
                isActive: !game.isGameOver && game.currentPlayer == .red,
                isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .red)
            )
        }
        .frame(height: 50) // Fiksna visina od 50px
    }
}

struct PlayerScoreItemView: View {
    let player: Player
    let score: Int
    let isActive: Bool
    let isAI: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Indikator igrača i AI status
            ZStack {
                Rectangle()
                    .fill(player == .blue ? Color.blue : Color.red)
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1)
                    )
                
                if isAI {
                    Image(systemName: "cpu")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            
            // Rezultat
            Text("\(score)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(minWidth: 30, alignment: .center)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    PlayerScoreView(game: Game())
        .padding()
        .background(Color.black.opacity(0.8))
} 
