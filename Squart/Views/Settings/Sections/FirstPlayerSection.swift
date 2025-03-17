import SwiftUI

struct FirstPlayerSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        Picker("first_player".localized, selection: $settings.firstPlayer) {
            Text("blue".localized).tag(Player.blue)
            Text("red".localized).tag(Player.red)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

#Preview {
    FirstPlayerSection(settings: GameSettingsManager.shared)
        .padding()
} 