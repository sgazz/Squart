import SwiftUI

struct GameControlsView: View {
    @ObservedObject var game: Game
    @State private var showingSettings = false
    @State private var selectedSize = GameSettings.defaultBoardSize
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Status igre
            HStack {
                PlayerScoreView(player: .blue, score: game.blueScore)
                Spacer()
                if game.isGameOver {
                    VStack(spacing: 4) {
                        Text(gameOverMessage)
                            .font(.headline)
                            .foregroundColor(.white)
                            
                        Text(winnerMessage)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        showConfetti ? ConfettiView() : nil
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                showConfetti = true
                            }
                        }
                    }
                } else {
                    Text("Na potezu: \(game.currentPlayer == .blue ? "Plavi" : "Crveni")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(game.currentPlayer == .blue ? Color.blue.opacity(0.3) : Color.red.opacity(0.3))
                        .cornerRadius(8)
                }
                Spacer()
                PlayerScoreView(player: .red, score: game.redScore)
            }
            
            // Kontrole
            HStack(spacing: 30) {
                Button(action: {
                    showingSettings = true
                }) {
                    Text("Podešavanja")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    withAnimation {
                        showConfetti = false
                        game.resetGame()
                    }
                }) {
                    Text("Nova igra")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingSettings) {
            SettingsView(selectedSize: $selectedSize, game: game)
        }
    }
    
    // Poruka za kraj igre u zavisnosti od razloga završetka
    private var gameOverMessage: String {
        switch game.gameEndReason {
        case .noValidMoves:
            return "Nema validnih poteza!"
        case .blueTimeout:
            return "Isteklo vreme plavom igraču!"
        case .redTimeout:
            return "Isteklo vreme crvenom igraču!"
        case .none:
            return "Igra je završena!"
        }
    }
    
    // Poruka o pobedniku
    private var winnerMessage: String {
        let lastPlayer = game.currentPlayer == .blue ? Player.red : Player.blue
        return "Pobednik: \(lastPlayer == .blue ? "Plavi" : "Crveni")"
    }
}

struct PlayerScoreView: View {
    let player: Player
    let score: Int
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(player == .blue ? Color.blue : Color.red)
                .frame(width: 30, height: 30)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 3)
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    init() {
        // Kreiraj inicijalne čestice
        var initialParticles: [ConfettiParticle] = []
        for _ in 0..<50 {
            initialParticles.append(ConfettiParticle.random(colors: colors))
        }
        _particles = State(initialValue: initialParticles)
    }
    
    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                ConfettiParticleView(particle: particles[index], isAnimating: isAnimating)
            }
        }
        .allowsHitTesting(false) // Ignorišemo dodire
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isAnimating = true
            }
        }
    }
}

struct ConfettiParticle {
    let position: CGPoint
    let color: Color
    let rotation: Double
    let scale: CGFloat
    
    static func random(colors: [Color]) -> ConfettiParticle {
        let randomX = CGFloat.random(in: 0...1)
        let randomY = CGFloat.random(in: -0.1...0.1)
        let randomRotation = Double.random(in: 0...360)
        let randomScale = CGFloat.random(in: 0.4...1.0)
        let randomColor = colors.randomElement() ?? .blue
        
        return ConfettiParticle(
            position: CGPoint(x: randomX, y: randomY),
            color: randomColor,
            rotation: randomRotation,
            scale: randomScale
        )
    }
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    let isAnimating: Bool
    
    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: 5, height: 10)
            .scaleEffect(particle.scale)
            .position(
                x: particle.position.x * UIScreen.main.bounds.width,
                y: isAnimating ? 
                    UIScreen.main.bounds.height * (1 + particle.position.y) : 
                    -10
            )
            .rotationEffect(.degrees(isAnimating ? particle.rotation + 360 : particle.rotation))
            .opacity(isAnimating ? 0 : 1)
    }
}

struct SettingsView: View {
    @Binding var selectedSize: Int
    @ObservedObject var game: Game
    @ObservedObject var settings = GameSettingsManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Veličina table")) {
                    Picker("Veličina", selection: $selectedSize) {
                        ForEach(GameSettings.minBoardSize...GameSettings.maxBoardSize, id: \.self) { size in
                            Text("\(size)x\(size)")
                        }
                    }
                }
                
                Section(header: Text("Izgled")) {
                    Picker("Tema", selection: $settings.currentTheme) {
                        ForEach(ThemeType.allCases, id: \.self) { theme in
                            HStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: theme.colors),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: 50, height: 24)
                                Text(theme.rawValue)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Vreme za potez")) {
                    Picker("Ograničenje vremena", selection: $settings.timerOption) {
                        ForEach(TimerOption.allCases, id: \.self) { option in
                            Text(option.description)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Protivnik")) {
                    Toggle("Igraj protiv računara", isOn: $settings.aiEnabled)
                    
                    if settings.aiEnabled {
                        Picker("Težina", selection: $settings.aiDifficulty) {
                            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.description)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("Zvuk i vibracija")) {
                    Toggle("Zvučni efekti", isOn: $settings.soundEnabled)
                    Toggle("Vibracija", isOn: $settings.hapticFeedbackEnabled)
                }
                
                Section {
                    Button("Primeni i započni novu igru") {
                        game.board = GameBoard(size: selectedSize)
                        
                        // Inicijalizacija AI ako je uključen
                        if settings.aiEnabled {
                            game.initializeAI(difficulty: settings.aiDifficulty)
                        }
                        
                        game.resetGame()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Podešavanja")
            .navigationBarItems(trailing: Button("Zatvori") {
                dismiss()
            })
        }
    }
}

#Preview {
    GameControlsView(game: Game())
        .padding()
        .background(Color.black.opacity(0.8))
} 