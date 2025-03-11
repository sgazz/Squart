import Foundation
import SwiftUI

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published private(set) var achievements: [Achievement]
    @Published var showUnlockAnimation: Bool = false
    @Published var lastUnlockedAchievement: Achievement?
    
    private let saveKey = "squart_achievements"
    
    private init() {
        // Učitaj sačuvana postignuća ili kreiraj nova
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = decoded
        } else {
            // Inicijalizuj sva moguća postignuća
            self.achievements = AchievementType.allCases.map { Achievement(id: $0) }
            saveAchievements()
        }
    }
    
    // MARK: - Javne metode
    
    func checkFirstWin() {
        updateProgress(for: .firstWin, value: 1)
    }
    
    func updateWinStreak(currentStreak: Int) {
        updateProgress(for: .winStreak, value: Double(currentStreak))
    }
    
    func checkBeatHardAI() {
        updateProgress(for: .beatHardAI, value: 1)
    }
    
    func checkQuickWin(moveCount: Int) {
        if moveCount <= 10 { // Ako je pobeda postignuta u 10 ili manje poteza
            updateProgress(for: .quickWin, value: 1)
        }
    }
    
    func updateCornerMasterProgress(cornerMovesCount: Int) {
        if cornerMovesCount >= 3 { // Ako je igrač koristio bar 3 ugaona polja u pobedi
            let current = achievement(for: .cornerMaster)?.progress ?? 0
            updateProgress(for: .cornerMaster, value: current + 1)
        }
    }
    
    func updateBlockingMasterProgress(blockingMovesCount: Int) {
        if blockingMovesCount >= 4 { // Ako je igrač blokirao protivnika bar 4 puta
            let current = achievement(for: .blockingMaster)?.progress ?? 0
            updateProgress(for: .blockingMaster, value: current + 1)
        }
    }
    
    func checkTimeoutWin() {
        let current = achievement(for: .timeoutWin)?.progress ?? 0
        updateProgress(for: .timeoutWin, value: current + 1)
    }
    
    func checkPerfectGame(opponentMoveCount: Int) {
        if opponentMoveCount <= 3 { // Ako je protivnik imao 3 ili manje poteza
            updateProgress(for: .perfectGame, value: 1)
        }
    }
    
    func updateAIVsAIWatcher() {
        let current = achievement(for: .aiVsAiWatcher)?.progress ?? 0
        updateProgress(for: .aiVsAiWatcher, value: current + 1)
    }
    
    func checkPlayAllSizes(size: Int) {
        var playedSizes = Set<Int>()
        if let data = UserDefaults.standard.object(forKey: "played_board_sizes") as? [Int] {
            playedSizes = Set(data)
        }
        playedSizes.insert(size)
        UserDefaults.standard.set(Array(playedSizes), forKey: "played_board_sizes")
        
        updateProgress(for: .playAllSizes, value: Double(playedSizes.count))
    }
    
    // MARK: - Pomoćne metode
    
    private func achievement(for type: AchievementType) -> Achievement? {
        return achievements.first { $0.id == type }
    }
    
    private func updateProgress(for type: AchievementType, value: Double) {
        guard var achievement = achievement(for: type) else { return }
        let oldStatus = achievement.status
        
        achievement.updateProgress(value)
        
        if let index = achievements.firstIndex(where: { $0.id == type }) {
            achievements[index] = achievement
            
            // Ako je postignuće upravo otključano, prikaži animaciju
            if oldStatus != .completed && achievement.status == .completed {
                lastUnlockedAchievement = achievement
                showUnlockAnimation = true
                
                // Vibracija i zvuk za otključavanje
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            saveAchievements()
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
} 