import SwiftUI

struct OpponentSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $settings.aiEnabled) {
                Text("enable_ai".localized)
            }
            
            if settings.aiEnabled {
                Picker("ai_team".localized, selection: $settings.aiTeam) {
                    Text("blue".localized).tag(Player.blue)
                    Text("red".localized).tag(Player.red)
                }
                
                Picker("ai_difficulty".localized, selection: $settings.aiDifficulty) {
                    Text("easy".localized).tag(AIDifficulty.easy)
                    Text("medium".localized).tag(AIDifficulty.medium)
                    Text("hard".localized).tag(AIDifficulty.hard)
                }
                
                Toggle(isOn: $settings.aiVsAiMode) {
                    Text("ai_vs_ai".localized)
                }
                
                if settings.aiVsAiMode {
                    Picker("second_ai_difficulty".localized, selection: $settings.secondAiDifficulty) {
                        Text("easy".localized).tag(AIDifficulty.easy)
                        Text("medium".localized).tag(AIDifficulty.medium)
                        Text("hard".localized).tag(AIDifficulty.hard)
                    }
                }
            }
        }
    }
}

#Preview {
    OpponentSection(settings: GameSettingsManager.shared)
        .padding()
} 