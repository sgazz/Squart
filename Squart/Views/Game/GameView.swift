import SwiftUI

struct GameView: View {
    @StateObject private var game = Game()
    @State private var orientation = UIDevice.current.orientation
    @State private var showingSavedGameAlert = false
    @State private var showingHelpView = false
    @State private var showAchievements = false
    @State private var showingSettings = false
    @ObservedObject private var settings = GameSettingsManager.shared
    @State private var timer: Timer? = nil
    @ObservedObject private var achievementManager = AchievementManager.shared
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        ZStack {
            // Gradijent pozadine baziran na trenutnoj temi
            LinearGradient(
                gradient: Gradient(colors: settings.currentTheme.colors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    // Status igre i kontrole
                    VStack(spacing: 16) {
                        // Rezultat
                        GameStatusView(game: game)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                        
                        // Tajmeri i kontrole (ako su aktivni)
                        if game.timerOption != .none {
                            ChessClockView(game: game, showingSettings: $showingSettings)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Tabla za igru sa efektom staklene pozadine
                    ZStack {
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            BoardView(game: game, cellSize: calculateCellSize(for: geometry))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                        .blur(radius: 2)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                )
                        }
                        .blur(radius: game.isGameOver ? 3 : 0)
                        
                        // Game Over poruka
                        if game.isGameOver {
                            VStack(spacing: 16) {
                                Text(gameOverMessage)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(winnerMessage)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    withAnimation {
                                        game.resetGame()
                                    }
                                }) {
                                    Text("new_game".localized)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.blue.opacity(0.3))
                                        .cornerRadius(8)
                                }
                                .padding(.top, 8)
                            }
                            .padding(24)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(16)
                            .transition(.opacity)
                        }
                    }
                    
                    Spacer()
                    
                    // Dugmići za čuvanje/učitavanje i uputstvo
                    HStack {
                        Button(action: {
                            saveGame()
                        }) {
                            Text("save".localized)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingHelpView = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.purple.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showAchievements = true
                        }) {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.orange.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            loadGame()
                        }) {
                            Text("load".localized)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Prikaz animacije za otključavanje postignuća
            if achievementManager.showUnlockAnimation,
               let achievement = achievementManager.lastUnlockedAchievement {
                AchievementUnlockView(
                    achievement: achievement,
                    isPresented: .init(
                        get: { achievementManager.showUnlockAnimation },
                        set: { achievementManager.showUnlockAnimation = $0 }
                    )
                )
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
        .onAppear {
            startTimer()
            
            // Inicijalizacija AI ako je uključen u podešavanjima
            if settings.aiEnabled {
                game.initializeAI(difficulty: settings.aiDifficulty, team: settings.aiTeam)
            }
        }
        .onChange(of: game.currentPlayer) { oldValue, newValue in
            // Nema potrebe da resetujemo tajmer kod promene igrača kod šahovskog sata
        }
        .onChange(of: settings.timerOption) { oldValue, newValue in
            resetGameWithNewSettings()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(selectedSize: .constant(game.board.size), game: game)
        }
        .sheet(isPresented: $showingHelpView) {
            HelpView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .alert(isPresented: $showingSavedGameAlert) {
            Alert(
                title: Text("Igra sačuvana"),
                message: Text("Trenutno stanje igre je uspešno sačuvano."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func calculateCellSize(for geometry: GeometryProxy) -> CGFloat {
        let isPortrait = orientation.isPortrait
        let availableWidth = geometry.size.width - 40 // padding
        let availableHeight = geometry.size.height - 200 // controls and spacing
        
        let maxCellsInRow = CGFloat(game.board.size)
        let desiredCellSize = isPortrait ? 
            min(availableWidth / maxCellsInRow, 50) :
            min(availableHeight / maxCellsInRow, 50)
        
        return max(desiredCellSize, 30) // minimum cell size
    }
    
    private func saveGame() {
        GameStorage.shared.saveGame(game)
        showingSavedGameAlert = true
        SoundManager.shared.playSound(.win)
    }
    
    private func loadGame() {
        if let loadedGame = GameStorage.shared.loadGame() {
            game.board = loadedGame.board
            game.currentPlayer = loadedGame.currentPlayer
            game.blueScore = loadedGame.blueScore
            game.redScore = loadedGame.redScore
            game.isGameOver = loadedGame.isGameOver
            game.blueTimeRemaining = loadedGame.blueTimeRemaining
            game.redTimeRemaining = loadedGame.redTimeRemaining
            game.timerOption = loadedGame.timerOption
            
            // Inicijalizacija AI ako je uključen
            if settings.aiEnabled {
                game.initializeAI(difficulty: settings.aiDifficulty, team: settings.aiTeam)
            }
            
            SoundManager.shared.playSound(.place)
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = nil
        
        if game.timerOption != .none && !game.isGameOver {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                game.updateTimer()
            }
        }
    }
    
    private func resetGameWithNewSettings() {
        timer?.invalidate()
        timer = nil
        
        // Ažuriramo opciju tajmera u igri
        game.timerOption = settings.timerOption
        game.resetGame()
        
        startTimer()
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

// Šahovski sat za oba igrača
struct ChessClockView: View {
    @ObservedObject var game: Game
    @Binding var showingSettings: Bool
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        HStack {
            // Tajmer plavog igrača
            PlayerTimerView(
                remainingTime: game.blueTimeRemaining,
                isActive: !game.isGameOver && game.currentPlayer == .blue,
                player: .blue
            )
            
            Spacer()
            
            // Kontrole
            HStack(spacing: 16) {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    withAnimation {
                        game.resetGame()
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Tajmer crvenog igrača
            PlayerTimerView(
                remainingTime: game.redTimeRemaining,
                isActive: !game.isGameOver && game.currentPlayer == .red,
                player: .red
            )
        }
    }
}

// Helper za detekciju rotacije
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

#Preview {
    GameView()
} 