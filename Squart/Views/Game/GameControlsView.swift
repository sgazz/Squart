import SwiftUI

struct GameControlsView: View {
    @ObservedObject var game: Game
    @State private var showingSettings = false
    @State private var selectedSize = GameSettings.defaultBoardSize
    @State private var showConfetti = false
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Status igre
            GameStatusView(game: game, showConfetti: $showConfetti)
            
            // Kontrole
            GameButtonsView(game: game, showingSettings: $showingSettings, showConfetti: $showConfetti)
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
}

// Izdvojena komponenta za prikaz statusa igre
struct GameStatusView: View {
    @ObservedObject var game: Game
    @Binding var showConfetti: Bool
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
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
                Text(game.aiEnabled ? 
                     (game.aiVsAiMode ? 
                      "\("turn".localized): AI \(game.currentPlayer == .blue ? "blue".localized : "red".localized)" : 
                      (game.currentPlayer == game.aiTeam ? 
                       "\("turn".localized): AI \(game.aiTeam == .blue ? "blue".localized : "red".localized)" : 
                       "\("turn".localized): \("your_turn".localized) (\(game.currentPlayer == .blue ? "blue".localized : "red".localized))")) :
                     "\("turn".localized): \(game.currentPlayer == .blue ? "blue".localized : "red".localized)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(game.currentPlayer == .blue ? Color.blue.opacity(0.3) : Color.red.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        game.aiEnabled && game.isAIThinking ? 
                        Text("ai_thinking".localized)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                            .offset(y: 20) : nil
                    )
            }
            Spacer()
            PlayerScoreView(player: .red, score: game.redScore)
        }
    }
    
    // Poruka za kraj igre u zavisnosti od razloga završetka
    private var gameOverMessage: String {
        switch game.gameEndReason {
        case .noValidMoves:
            return "no_valid_moves".localized
        case .blueTimeout:
            return "blue_timeout".localized
        case .redTimeout:
            return "red_timeout".localized
        case .none:
            return "game_over".localized
        }
    }
    
    // Poruka o pobedniku
    private var winnerMessage: String {
        let lastPlayer = game.currentPlayer == .blue ? Player.red : Player.blue
        return "\("winner".localized): \(lastPlayer == .blue ? "blue".localized : "red".localized)"
    }
}

// Izdvojena komponenta za dugmiće
struct GameButtonsView: View {
    @ObservedObject var game: Game
    @Binding var showingSettings: Bool
    @Binding var showConfetti: Bool
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                showingSettings = true
            }) {
                Text("settings".localized)
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
                Text("new_game".localized)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
        }
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
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        NavigationView {
            Form {
                BoardSizeSection(selectedSize: $selectedSize)
                
                ThemeSection(settings: settings)
                
                TimerSection(settings: settings)
                
                OpponentSection(game: game, settings: settings)
                
                SoundSection(settings: settings)
                
                LanguageSection(settings: settings)
                
                ApplySettingsSection(selectedSize: selectedSize, game: game, settings: settings, dismiss: dismiss)
            }
            .navigationTitle("settings".localized)
            .navigationBarItems(trailing: Button("close".localized) {
                dismiss()
            })
        }
    }
}

// Izdvojena sekcija za veličinu table
struct BoardSizeSection: View {
    @Binding var selectedSize: Int
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Section(header: Text("board_size".localized)) {
            Picker("board_size".localized, selection: $selectedSize) {
                ForEach(GameSettings.minBoardSize...GameSettings.maxBoardSize, id: \.self) { size in
                    Text("\(size)x\(size)")
                }
            }
        }
    }
}

// Izdvojena sekcija za temu
struct ThemeSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Section(header: Text("appearance".localized)) {
            Picker("theme".localized, selection: $settings.currentTheme) {
                ForEach(ThemeType.allCases, id: \.self) { theme in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: theme.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 50, height: 24)
                        Text(themeLocalizedName(theme))
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private func themeLocalizedName(_ theme: ThemeType) -> String {
        switch theme {
        case .ocean: return "ocean".localized
        case .sunset: return "sunset".localized
        case .forest: return "forest".localized
        case .galaxy: return "galaxy".localized
        case .classic: return "classic".localized
        }
    }
}

// Izdvojena sekcija za tajmer
struct TimerSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Section(header: Text("time_limit".localized)) {
            Picker("time_limit_option".localized, selection: $settings.timerOption) {
                ForEach(TimerOption.allCases, id: \.self) { option in
                    Text(timerOptionLocalizedDescription(option))
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private func timerOptionLocalizedDescription(_ option: TimerOption) -> String {
        switch option {
        case .none: return "no_limit".localized
        case .oneMinute: return "1 \("minute".localized)"
        case .twoMinutes: return "2 \("minutes".localized)"
        case .threeMinutes: return "3 \("minutes".localized)"
        case .fiveMinutes: return "5 \("minutes".localized)"
        case .tenMinutes: return "10 \("minutes".localized)"
        }
    }
}

// Izdvojena sekcija za protivnika (AI)
struct OpponentSection: View {
    @ObservedObject var game: Game
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Section(header: Text("opponent".localized)) {
            Toggle("play_against_computer".localized, isOn: $settings.aiEnabled)
            
            if settings.aiEnabled {
                Picker("difficulty".localized, selection: $settings.aiDifficulty) {
                    ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficultyLocalizedDescription(difficulty))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("ai_team".localized, selection: $settings.aiTeam) {
                    Text("blue".localized).tag(Player.blue)
                    Text("red".localized).tag(Player.red)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle("ai_vs_ai".localized, isOn: $settings.aiVsAiMode)
                
                if settings.aiVsAiMode {
                    Picker("second_ai_difficulty".localized, selection: $settings.secondAiDifficulty) {
                        ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficultyLocalizedDescription(difficulty))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Text("\("first_move".localized): \(game.startingPlayer == .blue ? "blue".localized : "red".localized)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
    
    private func difficultyLocalizedDescription(_ difficulty: AIDifficulty) -> String {
        switch difficulty {
        case .easy: return "easy".localized
        case .medium: return "medium".localized
        case .hard: return "hard".localized
        }
    }
}

// Izdvojena sekcija za zvuk
struct SoundSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Section(header: Text("sound_vibration".localized)) {
            Toggle("sound_effects".localized, isOn: $settings.soundEnabled)
            Toggle("vibration".localized, isOn: $settings.hapticFeedbackEnabled)
        }
    }
}

// Nova sekcija za izbor jezika
struct LanguageSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Section(header: Text("language".localized)) {
            Picker("language".localized, selection: $settings.language) {
                ForEach(Language.allCases, id: \.self) { language in
                    HStack {
                        Text(language.flag)
                        Text(language.rawValue)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

// Izdvojena sekcija za primenu podešavanja
struct ApplySettingsSection: View {
    let selectedSize: Int
    @ObservedObject var game: Game
    @ObservedObject var settings: GameSettingsManager
    var dismiss: DismissAction
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Section {
            Button("apply_start_new".localized) {
                game.board = GameBoard(size: selectedSize)
                
                // Inicijalizacija AI ako je uključen
                if settings.aiEnabled {
                    game.aiVsAiMode = settings.aiVsAiMode
                    game.secondAiDifficulty = settings.secondAiDifficulty
                    game.initializeAI(difficulty: settings.aiDifficulty, team: settings.aiTeam)
                    
                    // Za AI vs AI mod, odmah pokrećemo igru ako je AI na potezu
                    if game.aiVsAiMode {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            game.makeAIMove()
                        }
                    }
                }
                
                game.resetGame()
                dismiss()
            }
            .foregroundColor(.blue)
        }
    }
}

#Preview {
    GameControlsView(game: Game())
        .padding()
        .background(Color.black.opacity(0.8))
} 