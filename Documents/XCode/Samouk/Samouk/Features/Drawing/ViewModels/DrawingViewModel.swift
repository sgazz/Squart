import SwiftUI
import PencilKit

@MainActor
class DrawingViewModel: ObservableObject {
    @Published var currentLetter: String = "А"
    @Published var selectedLanguage: Language = .cyrillic
    @Published var selectedColor: Color = Constants.Drawing.defaultStrokeColor
    @Published var strokeWidth: CGFloat = Constants.Drawing.defaultStrokeWidth
    @Published var strokes: [Stroke] = []
    @Published var strokeFeedback: [StrokeFeedback]?
    @Published var isAnalyzing = false
    
    private var strokeAnalyzer: StrokeAnalyzer?
    
    var modelStrokes: [PKStroke] {
        switch selectedLanguage {
        case .cyrillic:
            return LetterStroke.cyrillicStrokes[currentLetter]?.map { $0.toPKStroke(in: .zero) } ?? []
        case .english:
            return LetterStroke.englishStrokes[currentLetter]?.map { $0.toPKStroke(in: .zero) } ?? []
        case .german:
            return LetterStroke.germanStrokes[currentLetter]?.map { $0.toPKStroke(in: .zero) } ?? []
        }
    }
    
    func addStroke(_ stroke: Stroke) {
        strokes.append(stroke)
        analyzeStroke(stroke)
    }
    
    func clearCanvas() {
        strokes.removeAll()
        strokeFeedback = nil
    }
    
    func changeLetter() {
        let letters = selectedLanguage.availableLetters
        if let currentIndex = letters.firstIndex(of: currentLetter),
           currentIndex < letters.count - 1 {
            currentLetter = letters[currentIndex + 1]
        } else {
            currentLetter = letters[0]
        }
        clearCanvas()
    }
    
    private func analyzeStroke(_ stroke: Stroke) {
        isAnalyzing = true
        
        Task {
            let feedback = await strokeAnalyzer?.analyzeStroke(stroke)
            await MainActor.run {
                strokeFeedback = feedback
                isAnalyzing = false
            }
        }
    }
} 