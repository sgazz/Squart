import SwiftUI

struct LanguageSelectorView: View {
    @Binding var selectedLanguage: Language
    
    var body: some View {
        Picker("Jezik", selection: $selectedLanguage) {
            ForEach(Language.allCases) { language in
                Text(language.displayName)
                    .tag(language)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

#Preview {
    LanguageSelectorView(selectedLanguage: .constant(.cyrillic))
} 