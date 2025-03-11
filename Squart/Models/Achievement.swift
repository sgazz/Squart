import Foundation

// Tipovi postignuća
enum AchievementType: String, Codable {
    case firstWin = "first_win"
    case winStreak = "win_streak"
    case beatHardAI = "beat_hard_ai"
    case quickWin = "quick_win"
    case cornerMaster = "corner_master"
    case blockingMaster = "blocking_master"
    case timeoutWin = "timeout_win"
    case perfectGame = "perfect_game"
    case aiVsAiWatcher = "ai_vs_ai_watcher"
    case playAllSizes = "play_all_sizes"
}

// Status postignuća
enum AchievementStatus: String, Codable {
    case locked
    case inProgress
    case completed
}

// Model postignuća
struct Achievement: Identifiable, Codable {
    let id: AchievementType
    var status: AchievementStatus
    var progress: Double // 0.0 - 1.0
    var dateCompleted: Date?
    
    // Metapodaci o postignuću
    var title: String {
        switch id {
        case .firstWin: return "first_win_title".localized
        case .winStreak: return "win_streak_title".localized
        case .beatHardAI: return "beat_hard_ai_title".localized
        case .quickWin: return "quick_win_title".localized
        case .cornerMaster: return "corner_master_title".localized
        case .blockingMaster: return "blocking_master_title".localized
        case .timeoutWin: return "timeout_win_title".localized
        case .perfectGame: return "perfect_game_title".localized
        case .aiVsAiWatcher: return "ai_vs_ai_watcher_title".localized
        case .playAllSizes: return "play_all_sizes_title".localized
        }
    }
    
    var description: String {
        switch id {
        case .firstWin: return "first_win_desc".localized
        case .winStreak: return "win_streak_desc".localized
        case .beatHardAI: return "beat_hard_ai_desc".localized
        case .quickWin: return "quick_win_desc".localized
        case .cornerMaster: return "corner_master_desc".localized
        case .blockingMaster: return "blocking_master_desc".localized
        case .timeoutWin: return "timeout_win_desc".localized
        case .perfectGame: return "perfect_game_desc".localized
        case .aiVsAiWatcher: return "ai_vs_ai_watcher_desc".localized
        case .playAllSizes: return "play_all_sizes_desc".localized
        }
    }
    
    var icon: String {
        switch id {
        case .firstWin: return "star.fill"
        case .winStreak: return "flame.fill"
        case .beatHardAI: return "trophy.fill"
        case .quickWin: return "bolt.fill"
        case .cornerMaster: return "square.grid.3x3.fill"
        case .blockingMaster: return "shield.fill"
        case .timeoutWin: return "clock.fill"
        case .perfectGame: return "crown.fill"
        case .aiVsAiWatcher: return "eye.fill"
        case .playAllSizes: return "square.stack.fill"
        }
    }
    
    // Uslovi za postignuća
    var requiredProgress: Double {
        switch id {
        case .firstWin: return 1
        case .winStreak: return 5 // 5 pobeda zaredom
        case .beatHardAI: return 1
        case .quickWin: return 1
        case .cornerMaster: return 10 // 10 pobeda kontrolom uglova
        case .blockingMaster: return 15 // 15 pobeda blokiranjem
        case .timeoutWin: return 3 // 3 pobede na vreme
        case .perfectGame: return 1
        case .aiVsAiWatcher: return 5 // Gledaj 5 AI vs AI partija
        case .playAllSizes: return 3 // Igraj na sve veličine table
        }
    }
    
    init(id: AchievementType) {
        self.id = id
        self.status = .locked
        self.progress = 0.0
        self.dateCompleted = nil
    }
}

// Proširenje za dodatne funkcionalnosti
extension Achievement {
    mutating func updateProgress(_ value: Double) {
        progress = min(max(0, value), requiredProgress)
        
        if progress == 0 {
            status = .locked
        } else if progress < requiredProgress {
            status = .inProgress
        } else {
            if status != .completed {
                status = .completed
                dateCompleted = Date()
            }
        }
    }
    
    func progressPercentage() -> Double {
        return (progress / requiredProgress) * 100
    }
} 