import SwiftUI

// MARK: - Enums
enum TokenOrientation {
    case horizontal
    case vertical
    case diagonal
    case none
}

// MARK: - Board View
struct BoardView: View {
    @ObservedObject var game: Game
    var onCellTap: (Position) -> Void
    
    // Константе за стилизацију
    private let cellSpacing: CGFloat = 2
    private let boardPadding: CGFloat = 10
    private let boardCornerRadius: CGFloat = 8
    private let boardShadowRadius: CGFloat = 5
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - (boardPadding * 2)
            let cellSize = (availableWidth - (CGFloat(game.boardSize - 1) * cellSpacing)) / CGFloat(game.boardSize)
            
            VStack(spacing: cellSpacing) {
                ForEach(0..<game.boardSize, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        ForEach(0..<game.boardSize, id: \.self) { column in
                            CellView(cell: game.board.cells[row][column])
                                .frame(width: cellSize, height: cellSize)
                                .onTapGesture {
                                    onCellTap(Position(row: row, column: column))
                                }
                        }
                    }
                }
            }
            .padding(boardPadding)
            .background(Color(UIColor.systemBackground).opacity(0.8))
            .cornerRadius(boardCornerRadius)
            .shadow(radius: boardShadowRadius)
        }
    }
    
    // Помоћна функција за одређивање оријентације токена
    func tokenOrientation(for player: Player) -> TokenOrientation {
        switch game.boardType {
        case .regular:
            return player == .blue ? .horizontal : .vertical
        case .triangular:
            return player == .blue ? .diagonal : .diagonal
        case .hexagonal:
            return .none
        }
    }
}

// MARK: - Preview
struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            BoardView(game: Game(boardSize: 8, boardType: .regular), onCellTap: { _ in })
                .padding()
        }
    }
} 