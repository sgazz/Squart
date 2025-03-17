import SwiftUI

struct ThemeSection: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject private var localization = Localization.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("theme".localized)
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ThemeType.allCases, id: \.self) { theme in
                        Button(action: {
                            settings.currentTheme = theme
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: theme.colors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(settings.currentTheme == theme ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .shadow(radius: settings.currentTheme == theme ? 5 : 0)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    ThemeSection(settings: GameSettingsManager.shared)
        .padding()
} 