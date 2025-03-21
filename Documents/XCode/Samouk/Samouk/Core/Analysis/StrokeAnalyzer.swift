import Foundation

struct StrokeFeedback {
    let message: String
    let type: FeedbackType
    
    enum FeedbackType {
        case success
        case warning
        case error
    }
}

class StrokeAnalyzer {
    private let modelStrokes: [Stroke]
    
    init(modelStrokes: [Stroke]) {
        self.modelStrokes = modelStrokes
    }
    
    func analyzeStroke(_ stroke: Stroke) async -> [StrokeFeedback] {
        // TODO: Implementirati analizu poteza
        return []
    }
} 