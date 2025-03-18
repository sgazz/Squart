import SwiftUI

struct WelcomeView: View {
    @State private var isGameStarted = false
    @State private var showingSettings = false
    @State private var titleScale: CGFloat = 1.0
    @State private var titleOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background pattern
            GeometryReader { geometry in
                Image("board_pattern")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width * 1, height: geometry.size.height * 1)
                    .rotationEffect(.degrees(15))
                    .scaleEffect(1.8)
                    .blur(radius: 15)
                    .opacity(0.7)
                    .transformEffect(CGAffineTransform(a: 1, b: 0, c: 0, d: 0.7, tx: 0, ty: geometry.size.height * 0.3))
            }
            .ignoresSafeArea()
            
            // Overlay gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.red.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Naslov
            Text("Squart")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .scaleEffect(titleScale)
                .opacity(titleOpacity)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isGameStarted = true
            }
        }
        .onAppear {
            // Animacija pojavljivanja naslova
            withAnimation(.easeOut(duration: 1.0)) {
                titleOpacity = 1.0
            }
            
            // Kontinuirana animacija naslova
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                titleScale = 1.1
            }
        }
        .fullScreenCover(isPresented: $isGameStarted) {
            GameView(showingSettings: $showingSettings)
        }
    }
}

#Preview {
    WelcomeView()
} 
