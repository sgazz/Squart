import SwiftUI

struct PlayerTimerView: View {
    let remainingTime: Int
    let isActive: Bool
    let player: Player
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundColor(.white)
                .opacity(isActive ? 1.0 : 0.5)
            
            Text(timeString(from: remainingTime))
                .font(.headline)
                .foregroundColor(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundForPlayer)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(isActive ? 0.8 : 0.3), lineWidth: isActive ? 2 : 1)
        )
    }
    
    private var backgroundForPlayer: Color {
        let baseColor = player == .blue ? Color.blue : Color.red
        
        if remainingTime < 10 {
            return baseColor.opacity(0.7)
        } else if remainingTime < 30 {
            return baseColor.opacity(0.5)
        } else {
            return baseColor.opacity(0.3)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = max(0, seconds / 60)
        let remainingSeconds = max(0, seconds % 60)
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
} 