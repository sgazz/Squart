import SwiftUI

struct GameButton: View {
    let title: String?
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(title: String? = nil, icon: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                
                if let title = title {
                    Text(title)
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(GameButtonStyle())
    }
}

struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        GameButton(title: "Save Game", icon: "square.and.arrow.down", color: .blue) {}
        GameButton(icon: "gearshape.fill", color: .gray) {}
    }
    .padding()
    .background(Color.black)
} 