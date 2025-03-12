import AVFoundation
import UIKit
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    
    private var hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private init() {
        hapticGenerator.prepare()
    }
    
    enum Sound {
        case place
        case win
        case error
        
        var systemSoundID: SystemSoundID {
            switch self {
            case .place:
                return 1104 // Tock sound
            case .win:
                return 1025 // Completed sound
            case .error:
                return 1073 // Error sound
            }
        }
    }
    
    func playSound(_ sound: Sound) {
        guard GameSettings.soundEnabled else { return }
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }
    
    func triggerHaptic() {
        guard GameSettings.hapticFeedbackEnabled else { return }
        hapticGenerator.impactOccurred()
    }
} 