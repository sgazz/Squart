import SwiftUI

struct GameSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var game: Game
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    @State private var showingHelpView = false
    @State private var showAchievements = false
    @State private var showingSavedGameAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Dodatne opcije
                Section(header: Text("additional_options".localized)) {
                    SoundSection(settings: settings)
                    LanguageSection(settings: settings)
                    ThemeSection(settings: settings)
                }
                
                // Upravljanje igrom
                Section(header: Text("game_management".localized)) {
                    Button(action: { saveGame() }) {
                        Label("save".localized, systemImage: "square.and.arrow.down")
                    }
                    
                    Button(action: { loadGame() }) {
                        Label("load".localized, systemImage: "square.and.arrow.up")
                    }
                }
                
                // Pomoć i dostignuća
                Section(header: Text("help_and_achievements".localized)) {
                    Button(action: { showingHelpView = true }) {
                        Label("help".localized, systemImage: "questionmark.circle")
                    }
                    
                    Button(action: { showAchievements = true }) {
                        Label("achievements".localized, systemImage: "trophy.fill")
                    }
                }
                
                // Dugme za primenu
                Section {
                    Button(action: {
                        applySettingsAndResetGame()
                        dismiss()
                    }) {
                        Text("apply_and_new_game".localized)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .listRowBackground(Color.blue.opacity(0.2))
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingHelpView) {
            HelpView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .alert("game_saved".localized, isPresented: $showingSavedGameAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func saveGame() {
        do {
            try GameStorage.shared.saveGame(game)
            showingSavedGameAlert = true
            SoundManager.shared.playSound(.win)
        } catch {
            print("Greška pri čuvanju igre: \(error)")
        }
    }
    
    private func loadGame() {
        do {
            let savedGames = try GameStorage.shared.loadAllGames()
            if let latestGame = savedGames.first,
               let loadedGame = try GameStorage.shared.loadGame(forKey: latestGame.key) {
                game.board = loadedGame.board
                game.currentPlayer = loadedGame.currentPlayer
                game.blueScore = loadedGame.blueScore
                game.redScore = loadedGame.redScore
                game.isGameOver = loadedGame.isGameOver
                game.blueTimeRemaining = loadedGame.blueTimeRemaining
                game.redTimeRemaining = loadedGame.redTimeRemaining
                game.timerOption = loadedGame.timerOption
                
                if settings.aiEnabled {
                    game.initializeAI(difficulty: settings.aiDifficulty, team: settings.aiTeam)
                }
                dismiss()
            }
        } catch {
            print("Greška pri učitavanju igre: \(error)")
        }
    }
    
    private func applySettingsAndResetGame() {
        // Primeni veličinu table
        game.board = GameBoard(size: settings.boardSize)
        
        // Primeni podešavanja tajmera
        game.timerOption = settings.timerOption
        
        // Primeni AI podešavanja
        game.aiEnabled = settings.aiEnabled
        if settings.aiEnabled {
            game.aiVsAiMode = settings.aiVsAiMode
            game.secondAiDifficulty = settings.secondAiDifficulty
            game.initializeAI(difficulty: settings.aiDifficulty, team: settings.aiTeam)
        }
        
        // Postavi prvog igrača
        game.currentPlayer = settings.firstPlayer
        
        // Resetuj igru
        game.resetGame()
        
        // Ako je AI vs AI mod i AI je na potezu, pokreni prvi potez
        if settings.aiEnabled && game.aiVsAiMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                game.makeAIMove()
            }
        }
    }
}

#Preview {
    GameSettingsView(game: Game(), settings: GameSettingsManager.shared)
} 
