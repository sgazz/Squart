import SwiftUI

enum Theme: String, CaseIterable {
    case system
    case light
    case dark
    case white
    case black
    case blue
    case green
    case red
    case purple
    case orange
    case yellow
    case pink
    case teal
    case indigo
    case mint
    case brown
    case gray
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .white: return "White"
        case .black: return "Black"
        case .blue: return "Blue"
        case .green: return "Green"
        case .red: return "Red"
        case .purple: return "Purple"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .pink: return "Pink"
        case .teal: return "Teal"
        case .indigo: return "Indigo"
        case .mint: return "Mint"
        case .brown: return "Brown"
        case .gray: return "Gray"
        }
    }
    
    var color: Color {
        switch self {
        case .system: return .primary
        case .light: return .white
        case .dark: return .black
        case .white: return .white
        case .black: return .black
        case .blue: return .blue
        case .green: return .green
        case .red: return .red
        case .purple: return .purple
        case .orange: return .orange
        case .yellow: return .yellow
        case .pink: return .pink
        case .teal: return .teal
        case .indigo: return .indigo
        case .mint: return .mint
        case .brown: return .brown
        case .gray: return .gray
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .system: return Color(.systemBackground)
        case .light: return .white
        case .dark: return .black
        case .white: return .white
        case .black: return .black
        case .blue: return .blue.opacity(0.1)
        case .green: return .green.opacity(0.1)
        case .red: return .red.opacity(0.1)
        case .purple: return .purple.opacity(0.1)
        case .orange: return .orange.opacity(0.1)
        case .yellow: return .yellow.opacity(0.1)
        case .pink: return .pink.opacity(0.1)
        case .teal: return .teal.opacity(0.1)
        case .indigo: return .indigo.opacity(0.1)
        case .mint: return .mint.opacity(0.1)
        case .brown: return .brown.opacity(0.1)
        case .gray: return .gray.opacity(0.1)
        }
    }
    
    var textColor: Color {
        switch self {
        case .system: return Color(.label)
        case .light: return .black
        case .dark: return .white
        case .white: return .black
        case .black: return .white
        case .blue: return .blue
        case .green: return .green
        case .red: return .red
        case .purple: return .purple
        case .orange: return .orange
        case .yellow: return .black
        case .pink: return .pink
        case .teal: return .teal
        case .indigo: return .indigo
        case .mint: return .mint
        case .brown: return .brown
        case .gray: return .gray
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        self.currentTheme = Theme(rawValue: savedTheme ?? "") ?? .system
    }
} 