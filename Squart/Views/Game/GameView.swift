import SwiftUI

struct GameView: View {
    @StateObject private var game = Game()
    @State private var orientation = UIDevice.current.orientation
    @State private var showingSettings = false
    @ObservedObject private var settings = GameSettingsManager.shared
    @State private var timer: Timer? = nil
    @ObservedObject private var achievementManager = AchievementManager.shared
    @ObservedObject private var localization = Localization.shared
    
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
            
            // Settings dugme
            VStack {
                HStack {
                    Spacer()
                    GameButton(icon: "gearshape.fill", color: .gray) {
                        showingSettings = true
                    }
                    .frame(width: 44)
                }
                .padding()
                Spacer()
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
        VStack {
            Spacer()
            
            GameStatusView(game: game)
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal)
            
            Spacer()
            
            GameBoardView(
                game: game,
                cellSize: GameLayout.calculateCellSize(
                    for: geometry,
                    boardSize: game.board.size,
                    isPortrait: effectiveOrientation.isPortrait
                ),
                onNewGame: { game.resetGame() }
            )
            .scaleEffect(GameLayout.boardScaleFactor(for: geometry, boardSize: game.board.size))
            
            Spacer()
        }
        .scaleEffect(GameLayout.isInSlideOver ? 0.8 : 1.0)
    }
    
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            
            VStack {
                Spacer()
                
                GameStatusView(game: game)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                GameBoardView(
                    game: game,
                    cellSize: GameLayout.calculateCellSize(
                        for: geometry,
                        boardSize: game.board.size,
                        isPortrait: effectiveOrientation.isPortrait
                    ),
                    onNewGame: { game.resetGame() }
                )
                .scaleEffect(GameLayout.boardScaleFactor(for: geometry, boardSize: game.board.size))
                
                Spacer()
            }
            
            Spacer()
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
    GameView()
} 