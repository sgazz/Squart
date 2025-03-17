import SwiftUI

struct LanguageSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("language".localized)
                .font(.headline)
            
            HStack(spacing: 16) {
                Button(action: {
                    settings.language = .english
                }) {
                    VStack {
                        Image("flag_en")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                        Text("English")
                            .font(.caption)
                    }
                    .opacity(settings.language == .english ? 1.0 : 0.5)
                }
                
                Button(action: {
                    settings.language = .serbian
                }) {
                    VStack {
                        Image("flag_sr")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                        Text("Српски")
                            .font(.caption)
                    }
                    .opacity(settings.language == .serbian ? 1.0 : 0.5)
                }
            }
        }
    }
}

#Preview {
    LanguageSection(settings: GameSettingsManager.shared)
        .padding()
} 