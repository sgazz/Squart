import SwiftUI

enum Constants {
    enum Drawing {
        static let defaultStrokeWidth: CGFloat = 2.0
        static let defaultStrokeColor: Color = .black
        static let canvasBackgroundColor: Color = .white
        static let feedbackDelay: Double = 1.0
    }
    
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let buttonSize: CGFloat = 44
    }
    
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springDamping: Double = 0.7
        static let springResponse: Double = 0.3
    }
} 