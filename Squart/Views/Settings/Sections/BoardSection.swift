import SwiftUI

struct BoardSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject var game: Game
    @ObservedObject private var localization = Localization.shared
    
    private let boardSizes = Array(5...20)
    
    var body: some View {
        Picker("board_size".localized, selection: Binding(
            get: { settings.boardSize },
            set: { newSize in
                settings.boardSize = newSize
                game.board = GameBoard(size: newSize)
            }
        )) {
            ForEach(boardSizes, id: \.self) { size in
                Text("\(size)x\(size)")
                    .tag(size)
            }
        }
        .pickerStyle(.menu)
    }
}

#Preview {
    BoardSection(settings: GameSettingsManager.shared, game: Game())
        .padding()
} 