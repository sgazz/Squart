import SwiftUI

struct AchievementUnlockView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: achievement.icon)
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("achievement_unlocked".localized)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(achievement.title)
                .font(.headline)
            
            Text(achievement.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.1, green: 0.2, blue: 0.45))
                .shadow(color: .black.opacity(0.3), radius: 20)
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1
                opacity = 1
            }
            
            // Automatski sakrij nakon 3 sekunde
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    scale = 0.7
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                }
            }
        }
    }
}

// Preview provider
struct AchievementUnlockView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementUnlockView(
            achievement: Achievement(id: .firstWin),
            isPresented: .constant(true)
        )
        .preferredColorScheme(.dark)
    }
} 