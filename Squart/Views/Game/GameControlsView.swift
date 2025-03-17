import SwiftUI

struct PlayerScoreView: View {
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        HStack {
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
    }
}

struct PlayerScoreItemView: View {
    let player: Player
    let score: Int
    let isActive: Bool
    let isAI: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(player == .blue ? Color.blue : Color.red)
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 3)
                
                if isAI {
                    Image(systemName: "cpu")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
            
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(8)
    }
}

#Preview {
    PlayerScoreView(game: Game())
        .padding()
        .background(Color.black.opacity(0.8))
} 
