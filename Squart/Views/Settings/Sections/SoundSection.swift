import SwiftUI

struct SoundSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $settings.soundEnabled) {
                Label {
                    Text("sound_effects".localized)
                } icon: {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }
            
            Toggle(isOn: $settings.hapticFeedbackEnabled) {
                Label {
                    Text("haptic_feedback".localized)
                } icon: {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                }
            }
        }
    }
}

#Preview {
    SoundSection(settings: GameSettingsManager.shared)
        .padding()
} 