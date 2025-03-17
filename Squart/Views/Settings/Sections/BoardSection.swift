import SwiftUI

struct BoardSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    private let boardSizes = [7, 9, 11]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("board_size".localized)
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(boardSizes, id: \.self) { size in
                    Button(action: {
                        settings.boardSize = size
                    }) {
                        Text("\(size)x\(size)")
                            .font(.headline)
                            .foregroundColor(settings.boardSize == size ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(settings.boardSize == size ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    BoardSection(settings: GameSettingsManager.shared)
        .padding()
} 