import SwiftUI

struct PulsingModifier: ViewModifier {
    let isActive: Bool
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .opacity(isActive ? 1 : 0)
                    .scaleEffect(isActive ? 1.5 : 1)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                        value: isActive
                    )
            )
    }
}

extension View {
    func pulsing(isActive: Bool, color: Color) -> some View {
        modifier(PulsingModifier(isActive: isActive, color: color))
    }
} 