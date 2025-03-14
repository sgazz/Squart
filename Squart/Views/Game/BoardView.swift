import SwiftUI

// MARK: - Enums
enum TokenOrientation: Equatable {
    case horizontal
    case vertical
}

// MARK: - Board View
struct BoardView: View {
    @ObservedObject var game: Game
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<game.board.size, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<game.board.size, id: \.self) { column in
                        makeCellView(row: row, column: column)
                            .onTapGesture {
                                handleCellTap(row: row, column: column)
                            }
                    }
                }
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
        .overlay(
            // Overlay za vizualizaciju AI "razmišljanja"
            showAIThinkingOverlay() 
        )
    }
    
    private func makeCellView(row: Int, column: Int) -> some View {
        let cell = game.board.cells[row][column]
        let boardCell = BoardCell(type: cell.type, row: cell.row, column: cell.column)
        return CellView(
            cell: boardCell,
            size: cellSize,
            isFirstCellOfToken: isFirstCellOfToken(row: row, column: column),
            tokenOrientation: tokenOrientation(row: row, column: column)
        )
    }
    
    private func isFirstCellOfToken(row: Int, column: Int) -> Bool {
        let cell = game.board.cells[row][column]
        guard cell.type != .empty && cell.type != .blocked else { return false }
        
        if cell.type == .blue {
            return column == 0 || game.board.cells[row][column - 1].type != .blue
        } else {
            return row == 0 || game.board.cells[row - 1][column].type != .red
        }
    }
    
    private func tokenOrientation(row: Int, column: Int) -> TokenOrientation {
        let cell = game.board.cells[row][column]
        
        if cell.type == .blue {
            return .horizontal
        } else {
            return .vertical
        }
    }
    
    private func handleCellTap(row: Int, column: Int) {
        guard !game.isGameOver else { return }
        
        // Samo ako trenutni igrač nije AI
        if game.aiEnabled {
            if game.aiVsAiMode {
                // U AI vs AI modu, ignorišemo tapove
                return
            } else if game.currentPlayer == game.aiTeam {
                // Ako je AI na potezu, ignorišemo tap
                return
            }
        }
        
        // Ako je igrač na potezu, izvršavamo potez
        _ = game.makeMove(row: row, column: column)
        
        // Ako je AI uključen i na potezu, pokrećemo AI potez
        if game.aiEnabled && !game.isGameOver && game.currentPlayer == game.aiTeam {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                game.makeAIMove()
            }
        }
    }
    
    // MARK: - AI Thinking Visualization
    
    @ViewBuilder
    private func showAIThinkingOverlay() -> some View {
        if game.showAIThinking && !game.aiConsideredMoves.isEmpty {
            GeometryReader { geo in
                ForEach(game.aiConsideredMoves, id: \.move) { consideredMove in
                    let heatLevel = calculateHeatLevel(score: consideredMove.score)
                    let position = calculatePosition(
                        row: consideredMove.move.row,
                        column: consideredMove.move.column,
                        geometry: geo
                    )
                    
                    // Kreiramo "heatmap" indikator
                    Circle()
                        .fill(heatColor(level: heatLevel))
                        .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                        .opacity(0.8)
                        .position(position)
                        .overlay(
                            Text("\(consideredMove.score)")
                                .font(.system(size: max(8, cellSize * 0.2)))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .position(position)
                        )
                }
            }
        } else {
            EmptyView()
        }
    }
    
    private func calculatePosition(row: Int, column: Int, geometry: GeometryProxy) -> CGPoint {
        let cellWidth = (geometry.size.width - 6 * 2 - CGFloat(game.board.size - 1) * 2) / CGFloat(game.board.size)
        let cellHeight = (geometry.size.height - 6 * 2 - CGFloat(game.board.size - 1) * 2) / CGFloat(game.board.size)
        
        let x = 6 + CGFloat(column) * (cellWidth + 2) + cellWidth / 2
        let y = 6 + CGFloat(row) * (cellHeight + 2) + cellHeight / 2
        
        return CGPoint(x: x, y: y)
    }
    
    private func calculateHeatLevel(score: Int) -> Double {
        // Normalizujemo score na skalu od 0 do 1
        // Pretpostavljamo da je maksimalni score oko 1000 (pobeda)
        let absScore = abs(score)
        let normalizedScore = Double(min(absScore, 1000)) / 1000.0
        return normalizedScore
    }
    
    private func heatColor(level: Double) -> Color {
        // Kreiramo prelaz boja od zelene (loš potez) do crvene (dobar potez)
        let r = min(1.0, level * 2)
        let g = min(1.0, 2 - level * 2)
        let b = 0.0
        
        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
        BoardView(game: Game(boardSize: 7), cellSize: 44)
            .padding()
    }
} 