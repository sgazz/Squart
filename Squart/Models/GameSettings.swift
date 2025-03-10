import Foundation
import SwiftUI

// Definicija tema za igru
enum ThemeType: String, CaseIterable, Codable {
    case ocean = "Okean"
    case sunset = "Zalazak sunca"
    case forest = "Šuma"
    case galaxy = "Galaksija"
    case classic = "Klasična"
    
    var colors: [Color] {
        switch self {
        case .ocean:
            return [
                Color(red: 0.1, green: 0.2, blue: 0.45),
                Color(red: 0.3, green: 0.4, blue: 0.6),
                Color(red: 0.1, green: 0.5, blue: 0.7)
            ]
        case .sunset:
            return [
                Color(red: 0.7, green: 0.2, blue: 0.3),
                Color(red: 0.8, green: 0.4, blue: 0.2),
                Color(red: 0.9, green: 0.6, blue: 0.1)
            ]
        case .forest:
            return [
                Color(red: 0.1, green: 0.3, blue: 0.2),
                Color(red: 0.2, green: 0.5, blue: 0.3),
                Color(red: 0.3, green: 0.6, blue: 0.2)
            ]
        case .galaxy:
            return [
                Color(red: 0.1, green: 0.0, blue: 0.2),
                Color(red: 0.2, green: 0.0, blue: 0.4),
                Color(red: 0.4, green: 0.1, blue: 0.5)
            ]
        case .classic:
            return [
                Color(red: 0.1, green: 0.1, blue: 0.1),
                Color(red: 0.25, green: 0.25, blue: 0.25),
                Color(red: 0.4, green: 0.4, blue: 0.4)
            ]
        }
    }
}

// Opcije za tajmer
enum TimerOption: Int, CaseIterable, Codable {
    case none = 0
    case oneMinute = 60
    case twoMinutes = 120
    case threeMinutes = 180
    case fiveMinutes = 300
    case tenMinutes = 600
    
    var description: String {
        switch self {
        case .none:
            return "Bez ograničenja"
        case .oneMinute:
            return "1 minut"
        case .twoMinutes:
            return "2 minuta"
        case .threeMinutes:
            return "3 minuta"
        case .fiveMinutes:
            return "5 minuta"
        case .tenMinutes:
            return "10 minuta"
        }
    }
    
    static var defaultOption: TimerOption {
        return .oneMinute
    }
}

// Model podataka za čuvanje podešavanja
struct SettingsData: Codable {
    let currentTheme: ThemeType
    let timerOption: TimerOption
    let soundEnabled: Bool
    let hapticFeedbackEnabled: Bool
    let aiEnabled: Bool
    let aiDifficulty: AIDifficulty
}

// Glavna klasa za podešavanja
class GameSettingsManager: ObservableObject {
    static let shared = GameSettingsManager()
    
    // Konstantne vrednosti
    static let defaultBoardSize = 7
    static let minBoardSize = 5
    static let maxBoardSize = 30
    static let blockedCellsPercentageRange: ClosedRange<Double> = 0.17...0.19
    static let moveAnimationDuration: Double = 0.3
    static let gameOverAnimationDuration: Double = 0.5
    
    @Published var currentTheme: ThemeType = .ocean {
        didSet {
            save()
        }
    }
    
    @Published var timerOption: TimerOption = TimerOption.defaultOption {
        didSet {
            save()
        }
    }
    
    @Published var soundEnabled: Bool = true {
        didSet {
            save()
        }
    }
    
    @Published var hapticFeedbackEnabled: Bool = true {
        didSet {
            save()
        }
    }
    
    @Published var aiEnabled: Bool = false {
        didSet {
            save()
        }
    }
    
    @Published var aiDifficulty: AIDifficulty = .medium {
        didSet {
            save()
        }
    }
    
    private init() {
        load()
    }
    
    private func save() {
        let settings = SettingsData(
            currentTheme: currentTheme,
            timerOption: timerOption,
            soundEnabled: soundEnabled,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            aiEnabled: aiEnabled,
            aiDifficulty: aiDifficulty
        )
        
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "squart_settings")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: "squart_settings"),
           let settings = try? JSONDecoder().decode(SettingsData.self, from: data) {
            self.currentTheme = settings.currentTheme
            self.timerOption = settings.timerOption
            self.soundEnabled = settings.soundEnabled
            self.hapticFeedbackEnabled = settings.hapticFeedbackEnabled
            self.aiEnabled = settings.aiEnabled
            self.aiDifficulty = settings.aiDifficulty
        }
    }
}

// Konstante igre
struct GameSettings {
    static let defaultBoardSize = GameSettingsManager.defaultBoardSize
    static let minBoardSize = GameSettingsManager.minBoardSize
    static let maxBoardSize = GameSettingsManager.maxBoardSize
    
    static let blockedCellsPercentageRange = GameSettingsManager.blockedCellsPercentageRange
    
    // Zvuk
    static var soundEnabled: Bool {
        GameSettingsManager.shared.soundEnabled
    }
    
    static var hapticFeedbackEnabled: Bool {
        GameSettingsManager.shared.hapticFeedbackEnabled
    }
    
    // Animacije
    static let moveAnimationDuration = GameSettingsManager.moveAnimationDuration
    static let gameOverAnimationDuration = GameSettingsManager.gameOverAnimationDuration
    
    // Boje (imena boja iz Asset kataloga)
    struct Colors {
        static let boardBackground = "BoardBackground"
        static let cellEmpty = "CellEmpty"
        static let cellBlue = "CellBlue"
        static let cellRed = "CellRed"
        static let cellBlocked = "CellBlocked"
    }
} 