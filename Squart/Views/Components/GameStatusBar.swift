import SwiftUI

struct GameStatusBar: View {
    @ObservedObject var game: Game
    let isLandscape: Bool
    let side: GameStatusSide // Nova enumeracija za stranu
    
    var body: some View {
        if isLandscape {
            // Horizontalni layout za landscape - prikazuje samo jedan indikator
            VStack {
                if side == .left {
                    // Crveni igrač (leva strana)
                    PlayerStatusView(
                        player: .red,
                        score: game.redScore,
                        remainingTime: Int(game.redTimeRemaining),
                        isActive: !game.isGameOver && game.currentPlayer == .red,
                        isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .red),
                        isVertical: true,
                        alignment: .leading,
                        position: .left
                    )
                } else {
                    // Plavi igrač (desna strana)
                    PlayerStatusView(
                        player: .blue,
                        score: game.blueScore,
                        remainingTime: Int(game.blueTimeRemaining),
                        isActive: !game.isGameOver && game.currentPlayer == .blue,
                        isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .blue),
                        isVertical: true,
                        alignment: .trailing,
                        position: .right
                    )
                }
            }
        } else {
            // Horizontalni layout za portrait - prikazuje oba indikatora
            HStack {
                Spacer()
                
                PlayerStatusView(
                    player: .blue,
                    score: game.blueScore,
                    remainingTime: Int(game.blueTimeRemaining),
                    isActive: !game.isGameOver && game.currentPlayer == .blue,
                    isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .blue),
                    isVertical: false,
                    alignment: .center,
                    position: .center
                )
                
                Spacer()
                    .frame(width: 30)
                
                PlayerStatusView(
                    player: .red,
                    score: game.redScore,
                    remainingTime: Int(game.redTimeRemaining),
                    isActive: !game.isGameOver && game.currentPlayer == .red,
                    isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .red),
                    isVertical: false,
                    alignment: .center,
                    position: .center
                )
                
                Spacer()
            }
            .frame(height: 60)
        }
    }
}

// Strana na kojoj se prikazuje status bar
enum GameStatusSide {
    case left
    case right
}

// Pozicija indikatora
enum IndicatorPosition {
    case left
    case right
    case center
}

struct PlayerStatusView: View {
    let player: Player
    let score: Int
    let remainingTime: Int
    let isActive: Bool
    let isAI: Bool
    let isVertical: Bool
    let alignment: HorizontalAlignment
    let position: IndicatorPosition
    
    private var shouldPulse: Bool {
        isActive && remainingTime <= 10
    }
    
    private var pulseColor: Color {
        player == .blue ? Color.blue : Color.red
    }
    
    var body: some View {
        Group {
            if isVertical {
                VStack(alignment: alignment, spacing: 20) {
                    scoreText
                    timeText
                }
                .frame(width: 100, height: 100)
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            } else {
                VStack(spacing: 12) {
                    scoreText
                    timeText
                }
                .frame(width: 100, height: 100)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(player == .blue ? Color.blue.opacity(0.9) : Color.red.opacity(0.9))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    private var scoreText: some View {
        Text("\(score)")
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 2)
    }
    
    private var timeText: some View {
        Text(formatTime(remainingTime))
            .font(.system(size: 28, design: .monospaced))
            .foregroundColor(isActive ? .white : .white.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .center)
            .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 2)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    VStack {
        GameStatusBar(game: Game(), isLandscape: false, side: .left)
        GameStatusBar(game: Game(), isLandscape: true, side: .left)
        GameStatusBar(game: Game(), isLandscape: true, side: .right)
    }
    .background(Color.black.opacity(0.8))
} 