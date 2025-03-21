import PencilKit

extension PKStroke {
    var points: [CGPoint] {
        path.map { $0.location }
    }
    
    var color: UIColor {
        ink.color
    }
    
    var width: CGFloat {
        ink.width
    }
} 