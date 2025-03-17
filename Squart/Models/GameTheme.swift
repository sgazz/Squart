import SwiftUI

enum GameTheme: String, CaseIterable, Identifiable {
    case classic
    case dark
    case light
    case ocean
    case forest
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .classic: return "classic_theme"
        case .dark: return "dark_theme"
        case .light: return "light_theme"
        case .ocean: return "ocean_theme"
        case .forest: return "forest_theme"
        }
    }
    
    var colors: [Color] {
        switch self {
        case .classic:
            return [Color(red: 0.2, green: 0.2, blue: 0.2),
                   Color(red: 0.4, green: 0.4, blue: 0.4)]
        case .dark:
            return [Color(red: 0.1, green: 0.1, blue: 0.1),
                   Color(red: 0.3, green: 0.3, blue: 0.3)]
        case .light:
            return [Color(red: 0.9, green: 0.9, blue: 0.9),
                   Color(red: 0.7, green: 0.7, blue: 0.7)]
        case .ocean:
            return [Color(red: 0.0, green: 0.2, blue: 0.4),
                   Color(red: 0.0, green: 0.4, blue: 0.6)]
        case .forest:
            return [Color(red: 0.2, green: 0.4, blue: 0.2),
                   Color(red: 0.3, green: 0.5, blue: 0.3)]
        }
    }
} 