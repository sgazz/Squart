import SwiftUI

struct AIThinkingView: View {
    let progress: Double
    let player: Player
    
    private var playerColor: Color {
        player == .blue ? Color.blue : Color.red
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("AI размишља...")
                .font(.headline)
                .foregroundColor(.white)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: playerColor))
                .frame(width: 200)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(playerColor.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: playerColor.opacity(0.3), radius: 10)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
        AIThinkingView(progress: 0.7, player: .blue)
    }
} 