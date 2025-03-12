import SwiftUI

struct PlayerScoreView: View {
    let player: Player
    let score: Int
    let isActive: Bool
    let isAI: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if player == .blue {
                tokenPair
                scoreText
            } else {
                scoreText
                tokenPair
            }
        }
        .padding(8)
        .opacity(isActive ? 1.0 : 0.7)
    }
    
    private var tokenPair: some View {
        HStack(spacing: 2) {
            tokenSquare
            
            if player == .blue {
                tokenSquare
            } else {
                VStack(spacing: 2) {
                    tokenSquare
                }
            }
        }
    }
    
    private var tokenSquare: some View {
        ZStack {
            Rectangle()
                .fill(tokenColor)
                .frame(width: 20, height: 20)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 2)
            
            if isAI {
                Image(systemName: "cpu")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var tokenColor: Color {
        player == .blue ? Color.blue : Color.red
    }
    
    private var scoreText: some View {
        Text("\(score)")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
} 