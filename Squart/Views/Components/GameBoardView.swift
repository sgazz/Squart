import SwiftUI

struct GameBoardView: View {
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    @State private var showGameOver = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let cellSize: CGFloat
    let onNewGame: () -> Void
    let onShowQuickSetup: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    BoardView(game: game, cellSize: adjustedCellSize(for: geometry))
                        .padding(isLandscape && horizontalSizeClass == .compact ? 2 : 8)
                }
                .blur(radius: game.isGameOver ? 3 : 0)
                
                // Game over overlay
                if game.isGameOver {
                    GameOverView(
                        game: game,
                        onPlayAgain: onNewGame,
                        onQuickSetup: onShowQuickSetup,
                        isPresented: $showGameOver
                    )
                }
            }
        }
        .onChange(of: game.isGameOver) { newValue in
            showGameOver = newValue
        }
    }
    
    private func adjustedCellSize(for geometry: GeometryProxy) -> CGFloat {
        let isLandscape = geometry.size.width > geometry.size.height
        let minDimension = min(geometry.size.width, geometry.size.height)
        
        if horizontalSizeClass == .compact && isLandscape {
            // За iPhone у landscape оријентацији, максимално искористи простор
            return max(minDimension / CGFloat(game.board.size) - 1, cellSize)
        } else {
            // За остале случајеве користимо оригиналну величину
            return cellSize
        }
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameBoardView(
                game: Game(),
                cellSize: 50,
                onNewGame: { print("New game tapped") },
                onShowQuickSetup: { print("Quick setup tapped") }
            )
            .previewDisplayName("Portrait")
            
            GameBoardView(
                game: Game(),
                cellSize: 50,
                onNewGame: { print("New game tapped") },
                onShowQuickSetup: { print("Quick setup tapped") }
            )
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Landscape")
        }
    }
} 