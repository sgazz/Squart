import SwiftUI

struct GameStatusView: View {
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        HStack {
            PlayerScoreView(
                player: .blue,
                score: game.blueScore,
                isActive: !game.isGameOver && game.currentPlayer == .blue,
                isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .blue)
            )
            
            Spacer()
            
            PlayerScoreView(
                player: .red,
                score: game.redScore,
                isActive: !game.isGameOver && game.currentPlayer == .red,
                isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .red)
            )
        }
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
                
                ResetStatsSection(game: game)
                
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

// Nova sekcija za resetovanje rezultata
struct ResetStatsSection: View {
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        Section {
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.red)
                    Text("reset_stats".localized)
                        .foregroundColor(.red)
                }
            }
            .alert("reset_stats".localized, isPresented: $showingResetAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("reset".localized, role: .destructive) {
                    game.resetStats()
                }
            } message: {
                Text("reset_stats_message".localized)
            }
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
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 2, y: 2)
        }
    }
}

#Preview {
    GameStatusView(game: Game())
        .padding()
        .background(Color.black.opacity(0.8))
} 