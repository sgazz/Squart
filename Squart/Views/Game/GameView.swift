import SwiftUI

struct GameView: View {
    @StateObject private var game = Game()
    @State private var orientation = UIDevice.current.orientation
    @Binding var showingSettings: Bool
    @State private var showingQuickSetup = true
    @ObservedObject private var settings = GameSettingsManager.shared
    @State private var timer: Timer? = nil
    @ObservedObject private var achievementManager = AchievementManager.shared
    @ObservedObject private var localization = Localization.shared
    
    init(showingSettings: Binding<Bool>) {
        self._showingSettings = showingSettings
    }
    
    private var effectiveOrientation: UIDeviceOrientation {
        if GameLayout.isInSplitView || GameLayout.isInSlideOver {
            return .portrait
        }
        return orientation
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            GeometryReader { geometry in
                Group {
                    if effectiveOrientation.isPortrait {
                        portraitLayout(geometry: geometry)
                    } else {
                        landscapeLayout(geometry: geometry)
                    }
                }
            }
            
            // Quick Setup Overlay
            if showingQuickSetup {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                QuickSetupView(isPresented: $showingQuickSetup, game: game)
                    .transition(.move(edge: .trailing))
            }
        }
        .sheet(isPresented: $showingSettings) {
            GameSettingsView(game: game, settings: settings)
                .modifier(PresentationDetentsModifier())
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        stopTimer() // Prvo zaustavimo postojeći tajmer ako postoji
        
        // Kreiramo novi tajmer koji se okida svake sekunde
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            game.updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: settings.currentTheme.colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private func portraitLayout(geometry: GeometryProxy) -> some View {
        let scaleFactor = GameLayout.boardScaleFactor(for: geometry, boardSize: game.board.size)
        let scaledBoardSize = GameLayout.fixedBoardSize * scaleFactor
        let availableSpace = geometry.size.height - scaledBoardSize
        let topSpace = availableSpace * 0.1 // Smanjujemo na 10%
        
        return VStack {
            Spacer()
            
            // Status bar i Settings dugme
            HStack {
                Spacer()
                
                PlayerStatusView(
                    player: .blue,
                    score: game.blueScore,
                    remainingTime: Int(game.blueTimeRemaining),
                    isActive: !game.isGameOver && game.currentPlayer == .blue,
                    isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .blue),
                    isVertical: false,
                    alignment: .center,
                    position: .center
                )
                
                Spacer()
                    .frame(width: 30)
                
                settingsButton
                    .padding(.horizontal, 8)
                
                Spacer()
                    .frame(width: 30)
                
                PlayerStatusView(
                    player: .red,
                    score: game.redScore,
                    remainingTime: Int(game.redTimeRemaining),
                    isActive: !game.isGameOver && game.currentPlayer == .red,
                    isAI: game.aiEnabled && (game.aiVsAiMode || game.aiTeam == .red),
                    isVertical: false,
                    alignment: .center,
                    position: .center
                )
                
                Spacer()
            }
            
            // Manji razmak između indikatora i table
            Spacer()
                .frame(height: topSpace)
            
            // Tabla u centru
            GameBoardView(
                game: game,
                cellSize: GameLayout.calculateCellSize(
                    for: geometry,
                    boardSize: game.board.size,
                    isPortrait: effectiveOrientation.isPortrait
                ),
                onNewGame: { game.resetGame() },
                onShowQuickSetup: { showingQuickSetup = true }
            )
            .scaleEffect(scaleFactor)
            
            Spacer()
        }
    }
    
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        ZStack {
            HStack(spacing: 0) {
                // Crveni igrač (leva strana)
                GameStatusBar(game: game, isLandscape: true, side: .left)
                    .frame(width: geometry.size.width * 0.15)
                    .padding(.horizontal, 8)
                    .padding(.trailing, 16)
                
                // Tabla u centru
                GameBoardView(
                    game: game,
                    cellSize: GameLayout.calculateCellSize(
                        for: geometry,
                        boardSize: game.board.size,
                        isPortrait: effectiveOrientation.isPortrait
                    ),
                    onNewGame: { game.resetGame() },
                    onShowQuickSetup: { showingQuickSetup = true }
                )
                .scaleEffect(GameLayout.boardScaleFactor(for: geometry, boardSize: game.board.size))
                
                // Plavi igrač (desna strana)
                GameStatusBar(game: game, isLandscape: true, side: .right)
                    .frame(width: geometry.size.width * 0.15)
                    .padding(.horizontal, 8)
                    .padding(.leading, 16)
            }
            .padding(.horizontal)
            
            // Settings dugme u gornjem desnom uglu
            VStack {
                HStack {
                    Spacer()
                    settingsButton
                        .padding()
                }
                Spacer()
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
        }
    }
}

struct PresentationDetentsModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.large])
        } else {
            content
        }
    }
}

#Preview {
    GameView(showingSettings: .constant(false))
} 
