import SwiftUI

struct GameView: View {
    @StateObject private var game = Game()
    @State private var orientation = UIDevice.current.orientation
    @State private var showingSavedGameAlert = false
    @State private var showingHelpView = false
    @ObservedObject private var settings = GameSettingsManager.shared
    @State private var timer: Timer? = nil
    
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
                    
                    // Tajmeri za igrače (ako su aktivni)
                    if game.timerOption != .none {
                        ChessClockView(game: game)
                            .padding(.horizontal)
                    }
                    
                    GameControlsView(game: game)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Tabla za igru sa efektom staklene pozadine
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
                    
                    Spacer()
                    
                    // Dugmići za čuvanje/učitavanje i uputstvo
                    HStack {
                        Button(action: {
                            saveGame()
                        }) {
                            Text("Sačuvaj")
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
                            Text("Uputstvo")
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.purple.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            loadGame()
                        }) {
                            Text("Učitaj")
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .alert(isPresented: $showingSavedGameAlert) {
                    Alert(
                        title: Text("Igra sačuvana"),
                        message: Text("Trenutno stanje igre je uspešno sačuvano."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showingHelpView) {
                    HelpView()
                }
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
}

// Šahovski sat za oba igrača
struct ChessClockView: View {
    @ObservedObject var game: Game
    
    var body: some View {
        HStack {
            // Tajmer plavog igrača
            PlayerTimerView(
                remainingTime: game.blueTimeRemaining,
                isActive: !game.isGameOver && game.currentPlayer == .blue,
                player: .blue
            )
            
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

// Prikaz tajmera za jednog igrača
struct PlayerTimerView: View {
    let remainingTime: Int
    let isActive: Bool
    let player: Player
    
    var body: some View {
        VStack(spacing: 4) {
            Text(player == .blue ? "PLAVI" : "CRVENI")
                .font(.caption)
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .foregroundColor(.white)
                    .opacity(isActive ? 1.0 : 0.5)
                
                Text(timeString(from: remainingTime))
                    .font(.headline)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundForPlayer)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(isActive ? 0.8 : 0.3), lineWidth: isActive ? 2 : 1)
            )
        }
    }
    
    private var backgroundForPlayer: Color {
        let baseColor = player == .blue ? Color.blue : Color.red
        
        if remainingTime < 10 {
            return baseColor.opacity(0.7)
        } else if remainingTime < 30 {
            return baseColor.opacity(0.5)
        } else {
            return baseColor.opacity(0.3)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = max(0, seconds / 60)
        let remainingSeconds = max(0, seconds % 60)
        return String(format: "%02d:%02d", minutes, remainingSeconds)
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