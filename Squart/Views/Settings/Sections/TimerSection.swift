import SwiftUI

struct TimerSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("timer".localized, selection: $settings.timerOption) {
                Text("no_timer".localized).tag(TimerOption.none)
                Text("1 min").tag(TimerOption.oneMinute)
                Text("3 min").tag(TimerOption.threeMinutes)
                Text("5 min").tag(TimerOption.fiveMinutes)
                Text("10 min").tag(TimerOption.tenMinutes)
            }
        }
    }
}

#Preview {
    TimerSection(settings: GameSettingsManager.shared)
        .padding()
} 