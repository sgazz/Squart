import PencilKit

struct Stroke: Identifiable {
    let id = UUID()
    let points: [CGPoint]
    let color: Color
    let width: CGFloat
    
    init(from pkStroke: PKStroke) {
        self.points = pkStroke.path.map { $0.location }
        self.color = Color(pkStroke.ink.color)
        self.width = pkStroke.width
    }
    
    init(points: [CGPoint], color: Color = .black, width: CGFloat = 2.0) {
        self.points = points
        self.color = color
        self.width = width
    }
} 