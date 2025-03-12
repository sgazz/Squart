import Foundation
import AVFoundation

enum SoundEffect: String {
    case move = "move"
    case capture = "capture"
    case win = "win"
    case lose = "lose"
    case draw = "draw"
    case error = "error"
    case achievement = "achievement"
    
    var filename: String {
        return "\(rawValue).wav"
    }
    
    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "wav")
    }
    
    var player: AVAudioPlayer? {
        guard let url = url else { return nil }
        return try? AVAudioPlayer(contentsOf: url)
    }
} 