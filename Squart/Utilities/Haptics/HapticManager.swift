import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Lagani tap
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Srednji tap
    func mediumTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Jaki tap
    func heavyTap() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Uspeh
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    // Greška
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // Upozorenje
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    // Selekcija
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
} 