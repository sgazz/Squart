import SwiftUI

struct GameView: View {
    @StateObject private var game = Game()
    @State private var orientation = UIDevice.current.orientation
    @State private var showingSavedGameAlert = false
    @State private var showingLoadErrorAlert = false
    @State private var showingSaveErrorAlert = false
    @State private var loadErrorMessage = ""
    @State private var saveErrorMessage = ""
    @State private var showingSettings = false
    @State private var selectedBoardSize: Int = 7
    @ObservedObject private var settings = GameSettingsManager.shared
    @State private var timer: Timer? = nil
    @ObservedObject private var achievementManager = AchievementManager.shared
    @ObservedObject private var localization = Localization.shared
    
    // Pomocne promenljive za iPad optimizaciju
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var isInSplitView: Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return windowScene.interfaceOrientation.isPortrait && 
                   window.frame.width < UIScreen.main.bounds.width
        }
        return false
    }
    
    private var isInSlideOver: Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.frame.width < 400
        }
        return false
    }
    
    private var effectiveOrientation: UIDeviceOrientation {
        if isInSplitView || isInSlideOver {
            return .portrait
        }
        return orientation
    }
    
    private func iPadScaleFactor(for geometry: GeometryProxy) -> CGFloat {
        if !isPad { return 1.0 }
        
        let screenWidth = UIScreen.main.bounds.width
        
        // Razliciti faktori za razlicite iPad modele
        switch screenWidth {
        case 1024: // iPad 9.7" i 10.2"
            return isInSplitView ? 0.8 : 1.0
        case 1112: // iPad Pro 10.5"
            return isInSplitView ? 0.85 : 1.1
        case 1180: // iPad Pro 11"
            return isInSplitView ? 0.9 : 1.2
        case 1366: // iPad Pro 12.9"
            return isInSplitView ? 0.95 : 1.3
        default:
            return 1.0
        }
    }
    
    private var playerScoreBackground: some View {
        Color.black.opacity(0.2)
    }
    
    private var playerScoreOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
    }
    
    private func playerScoreShadow(isActive: Bool, player: Player) -> Color {
        isActive ? 
            (player == .blue ? Color.blue : Color.red).opacity(0.5) : 
            Color.black.opacity(0.3)
    }
    
    private func playerScoreStroke(isActive: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isActive ? Color.white : Color.clear, lineWidth: 2)
    }
    
    private func makePlayerScoreView(player: Player, score: Int, isActive: Bool, isAI: Bool) -> some View {
        PlayerScoreView(
            player: player,
            score: score,
            isActive: isActive,
            isAI: isAI
        )
        .padding()
        .background(playerScoreBackground)
        .cornerRadius(12)
        .overlay(playerScoreStroke(isActive: isActive))
        .shadow(
            color: playerScoreShadow(isActive: isActive, player: player),
            radius: 10
        )
    }
    
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
                Group {
                    if effectiveOrientation.isPortrait {
                        // Postojeći vertikalni raspored sa scale faktorom
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
                            
                            // Tabla
                            gameBoard(geometry: geometry)
                            
                            Spacer()
                            
                            // Dugmići za čuvanje/učitavanje i uputstvo
                            bottomButtons
                                .padding(.horizontal)
                        }
                        .scaleEffect(isInSlideOver ? 0.8 : 1.0)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                    } else {
                        // Horizontalni raspored sa prilagođenim širinama
                        HStack(spacing: 0) {
                            // Leva strana - plavi igrač
                            VStack {
                                Spacer()
                                
                                makePlayerScoreView(
                                    player: .blue,
                                    score: game.blueScore,
                                    isActive: !game.isGameOver && game.currentPlayer == .blue,
                                    isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .blue)
                                )
                                
                                Spacer()
                                
                                // Tajmer plavog igrača
                                if game.timerOption != .none {
                                    PlayerTimerView(
                                        remainingTime: game.blueTimeRemaining,
                                        isActive: !game.isGameOver && game.currentPlayer == .blue,
                                        player: .blue
                                    )
                                    .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.2 : 1.0)
                                }
                                
                                Spacer()
                                
                                // Leva dugmad
                                VStack(spacing: 12) {
                                    Button(action: {
                                        saveGame()
                                    }) {
                                        Text("save".localized)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .frame(width: 100)
                                            .background(Color.blue.opacity(0.3))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                    .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 2, y: 2)
                                    
                                    Button(action: {
                                        loadGame()
                                    }) {
                                        Text("load".localized)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .frame(width: 100)
                                            .background(Color.green.opacity(0.3))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                    .shadow(color: Color.green.opacity(0.3), radius: 3, x: 2, y: 2)
                                }
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal, 8)
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width * (isInSplitView ? 0.25 : 0.2))
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(16)
                            
                            // Centralna tabla
                            gameBoard(geometry: geometry)
                                .frame(width: geometry.size.width * (isInSplitView ? 0.5 : 0.6))
                            
                            // Desna strana - crveni igrač
                            VStack {
                                Spacer()
                                
                                makePlayerScoreView(
                                    player: .red,
                                    score: game.redScore,
                                    isActive: !game.isGameOver && game.currentPlayer == .red,
                                    isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .red)
                                )
                                
                                Spacer()
                                
                                // Tajmer crvenog igrača
                                if game.timerOption != .none {
                                    PlayerTimerView(
                                        remainingTime: game.redTimeRemaining,
                                        isActive: !game.isGameOver && game.currentPlayer == .red,
                                        player: .red
                                    )
                                    .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.2 : 1.0)
                                }
                                
                                Spacer()
                                
                                // Desna dugmad
                                VStack(spacing: 12) {
                                    Button(action: {
                                        showingSettings = true
                                    }) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                    .shadow(color: Color.white.opacity(0.3), radius: 3, x: 2, y: 2)
                                    
                                    Button(action: {
                                        withAnimation {
                                            game.resetGame()
                                        }
                                    }) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                    .shadow(color: Color.white.opacity(0.3), radius: 3, x: 2, y: 2)
                                }
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal, 8)
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width * (isInSplitView ? 0.25 : 0.2))
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(16)
                        }
                        .scaleEffect(iPadScaleFactor(for: geometry))
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                    }
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
            // Ažuriramo orijentaciju samo ako nismo u Split View ili Slide Over
            if !isInSplitView && !isInSlideOver {
                withAnimation(.easeInOut(duration: 0.3)) {
                    orientation = newOrientation
                }
            }
        }
        .onAppear {
            startTimer()
            selectedBoardSize = game.board.size
            
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
            SettingsView(selectedSize: $selectedBoardSize, game: game)
        }
        .alert(isPresented: $showingSavedGameAlert) {
            Alert(
                title: Text("Игра сачувана"),
                message: Text("Тренутно стање игре је успешно сачувано."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Грешка при чувању", isPresented: $showingSaveErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
        }
        .alert("Грешка при учитавању", isPresented: $showingLoadErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(loadErrorMessage)
        }
        .animation(.easeInOut(duration: 0.3), value: orientation.isPortrait)
    }
    
    private func calculateCellSize(for geometry: GeometryProxy) -> CGFloat {
        let isPortrait = effectiveOrientation.isPortrait
        
        // Prilagođeni padding-i za različite iPad modele i modove
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        
        if isPad {
            if isInSlideOver {
                horizontalPadding = 20
                verticalPadding = 160
            } else if isInSplitView {
                horizontalPadding = 40
                verticalPadding = 180
            } else {
                horizontalPadding = 60
                verticalPadding = 240
            }
        } else {
            horizontalPadding = 40
            verticalPadding = 200
        }
        
        let availableWidth = geometry.size.width - (isPortrait ? horizontalPadding : geometry.size.width * (isInSplitView ? 0.5 : 0.4))
        let availableHeight = geometry.size.height - (isPortrait ? verticalPadding : 80)
        
        let maxCellsInRow = CGFloat(game.board.size)
        
        // Prilagođene veličine ćelija za različite iPad modove
        let maxCellSize: CGFloat
        let minCellSize: CGFloat
        
        if isPad {
            if isInSlideOver {
                maxCellSize = 45
                minCellSize = 25
            } else if isInSplitView {
                maxCellSize = 50
                minCellSize = 30
            } else {
                maxCellSize = 60
                minCellSize = 35
            }
        } else {
            maxCellSize = 50
            minCellSize = 30
        }
        
        let scaleFactor = iPadScaleFactor(for: geometry)
        let desiredCellSize = isPortrait ? 
            min(availableWidth / maxCellsInRow, maxCellSize) :
            min(min(availableHeight / maxCellsInRow, availableWidth / maxCellsInRow), maxCellSize)
        
        return max(desiredCellSize, minCellSize) * scaleFactor
    }
    
    private func saveGame() {
        do {
            try GameStorage.shared.saveGame(game)
            showingSavedGameAlert = true
            SoundManager.shared.playSound(.win)
        } catch {
            saveErrorMessage = "Грешка при чувању игре: \(error.localizedDescription)"
            showingSaveErrorAlert = true
        }
    }
    
    private func loadGame() {
        do {
            let savedGames = try GameStorage.shared.loadAllGames()
            
            guard !savedGames.isEmpty else {
                loadErrorMessage = "Нема сачуваних игара."
                showingLoadErrorAlert = true
                return
            }
            
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
                game.aiEnabled = loadedGame.aiEnabled
                game.aiDifficulty = loadedGame.aiDifficulty
                game.aiTeam = loadedGame.aiTeam
                game.startingPlayer = loadedGame.startingPlayer
                game.aiVsAiMode = loadedGame.aiVsAiMode
                game.secondAiDifficulty = loadedGame.secondAiDifficulty
                
                // Inicijalizacija AI ako je uključen
                if loadedGame.aiEnabled {
                    game.initializeAI(difficulty: loadedGame.aiDifficulty, team: loadedGame.aiTeam)
                }
            } else {
                loadErrorMessage = "Грешка при учитавању игре."
                showingLoadErrorAlert = true
            }
        } catch {
            loadErrorMessage = "Грешка: \(error.localizedDescription)"
            showingLoadErrorAlert = true
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
    
    // Izdvojena tabla za igru
    @ViewBuilder
    private func gameBoard(geometry: GeometryProxy) -> some View {
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
            .opacity(game.isGameOver ? 0.7 : 1.0) // Благо затамњујемо таблу
            
            // Game Over порука
            if game.isGameOver {
                let winner = game.currentPlayer == .blue ? Player.red : Player.blue
                let winnerColor = winner == .blue ? Color.blue : Color.red
                
                VStack(spacing: 16) {
                    Text("winner_announcement".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(winnerColor.opacity(0.85))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: winnerColor.opacity(0.5), radius: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // Izdvojena donja dugmad za portrait mod
    private var bottomButtons: some View {
        HStack {
            Button(action: {
                saveGame()
            }) {
                Text("save".localized)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(width: 100)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 2, y: 2)
            
            Spacer()
            
            Button(action: {
                loadGame()
            }) {
                Text("load".localized)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(width: 100)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .shadow(color: Color.green.opacity(0.3), radius: 3, x: 2, y: 2)
        }
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