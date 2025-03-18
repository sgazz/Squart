import SwiftUI

struct PlayerTimerView: View {
    let remainingTime: Int
    let isActive: Bool
    let player: Player
    
    private var shouldPulse: Bool {
        isActive && remainingTime <= 10
    }
    
    private var pulseColor: Color {
        player == .blue ? Color.blue : Color.red
    }
    
    var body: some View {
        VStack {
            Text(formatTime(remainingTime))
                .font(.system(.title, design: .monospaced))
                .foregroundColor(isActive ? .white : .gray)
            
            Text(player == .blue ? "Plavi" : "Crveni")
                .font(.caption)
                .foregroundColor(isActive ? .white : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive ? Color.white.opacity(0.2) : Color.clear)
        )
        .pulsing(isActive: shouldPulse, color: pulseColor)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    HStack {
        PlayerTimerView(remainingTime: 120, isActive: true, player: .blue)
        PlayerTimerView(remainingTime: 60, isActive: false, player: .red)
    }
    .padding()
    .background(Color.gray)
} 