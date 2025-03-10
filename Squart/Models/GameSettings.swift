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
    let aiTeam: Player
    let aiVsAiMode: Bool
    let secondAiDifficulty: AIDifficulty
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
    
    // Veličina table
    @Published var boardSize: Int {
        didSet {
            UserDefaults.standard.set(boardSize, forKey: "board_size")
        }
    }
    
    // Tema igre
    @Published var currentTheme: ThemeType {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "theme")
        }
    }
    
    // Timer opcija
    @Published var timerOption: TimerOption {
        didSet {
            UserDefaults.standard.set(timerOption.rawValue, forKey: "timer_option")
        }
    }
    
    // Zvučni efekti
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "sound_enabled")
        }
    }
    
    // Vibracije (haptic feedback)
    @Published var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: "haptic_feedback_enabled")
        }
    }
    
    // AI podešavanja
    @Published var aiEnabled: Bool {
        didSet {
            UserDefaults.standard.set(aiEnabled, forKey: "ai_enabled")
        }
    }
    
    @Published var aiDifficulty: AIDifficulty {
        didSet {
            UserDefaults.standard.set(aiDifficulty.rawValue, forKey: "ai_difficulty")
        }
    }
    
    @Published var aiTeam: Player {
        didSet {
            UserDefaults.standard.set(aiTeam == .blue ? "blue" : "red", forKey: "ai_team")
        }
    }
    
    @Published var aiVsAiMode: Bool {
        didSet {
            UserDefaults.standard.set(aiVsAiMode, forKey: "ai_vs_ai_mode")
        }
    }
    
    @Published var secondAiDifficulty: AIDifficulty {
        didSet {
            UserDefaults.standard.set(secondAiDifficulty.rawValue, forKey: "second_ai_difficulty")
        }
    }
    
    // ML podešavanja
    @Published var useMachineLearning: Bool {
        didSet {
            UserDefaults.standard.set(useMachineLearning, forKey: "use_machine_learning")
        }
    }
    
    @Published var showMLFeedback: Bool {
        didSet {
            UserDefaults.standard.set(showMLFeedback, forKey: "show_ml_feedback")
        }
    }
    
    private init() {
        // Učitaj boardSize iz korisničkih podešavanja ili koristi podrazumevanu vrednost
        self.boardSize = UserDefaults.standard.integer(forKey: "board_size")
        if self.boardSize < GameSettings.minBoardSize || self.boardSize > GameSettings.maxBoardSize {
            self.boardSize = GameSettings.defaultBoardSize
        }
        
        // Učitaj temu iz korisničkih podešavanja ili koristi podrazumevanu vrednost
        if let themeString = UserDefaults.standard.string(forKey: "theme"),
           let theme = ThemeType(rawValue: themeString) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .ocean
        }
        
        // Učitaj timer opciju iz korisničkih podešavanja ili koristi podrazumevanu vrednost
        let timerValue = UserDefaults.standard.integer(forKey: "timer_option")
        if let timer = TimerOption(rawValue: timerValue) {
            self.timerOption = timer
        } else {
            self.timerOption = .none
        }
        
        // Učitaj podešavanja za zvuk i vibraciju
        self.soundEnabled = UserDefaults.standard.bool(forKey: "sound_enabled")
        self.hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "haptic_feedback_enabled")
        
        // Učitaj AI podešavanja
        self.aiEnabled = UserDefaults.standard.bool(forKey: "ai_enabled")
        
        // Učitaj težinu AI-a
        let aiDifficultyValue = UserDefaults.standard.integer(forKey: "ai_difficulty")
        if let aiDifficulty = AIDifficulty(rawValue: aiDifficultyValue) {
            self.aiDifficulty = aiDifficulty
        } else {
            self.aiDifficulty = .medium
        }
        
        // Učitaj AI tim
        if let aiTeamString = UserDefaults.standard.string(forKey: "ai_team") {
            self.aiTeam = aiTeamString == "blue" ? .blue : .red
        } else {
            self.aiTeam = .red
        }
        
        // Učitaj AI vs AI mod
        self.aiVsAiMode = UserDefaults.standard.bool(forKey: "ai_vs_ai_mode")
        
        // Učitaj težinu drugog AI-a
        let secondAiDifficultyValue = UserDefaults.standard.integer(forKey: "second_ai_difficulty")
        if let secondAiDifficulty = AIDifficulty(rawValue: secondAiDifficultyValue) {
            self.secondAiDifficulty = secondAiDifficulty
        } else {
            self.secondAiDifficulty = .medium
        }
        
        // Učitaj ML podešavanja
        self.useMachineLearning = UserDefaults.standard.bool(forKey: "use_machine_learning")
        self.showMLFeedback = UserDefaults.standard.bool(forKey: "show_ml_feedback")
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