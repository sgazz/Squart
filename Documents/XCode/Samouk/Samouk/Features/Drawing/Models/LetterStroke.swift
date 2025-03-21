import Foundation
import PencilKit

struct LetterStroke {
    let points: [CGPoint]
    
    static let cyrillicStrokes: [String: [LetterStroke]] = [
        "А": [
            LetterStroke(points: [
                CGPoint(x: 0.5, y: 0.8),
                CGPoint(x: 0.5, y: 0.2)
            ]),
            LetterStroke(points: [
                CGPoint(x: 0.2, y: 0.5),
                CGPoint(x: 0.8, y: 0.5)
            ])
        ],
        "Б": [
            LetterStroke(points: [
                CGPoint(x: 0.2, y: 0.2),
                CGPoint(x: 0.8, y: 0.2),
                CGPoint(x: 0.8, y: 0.5),
                CGPoint(x: 0.8, y: 0.8),
                CGPoint(x: 0.2, y: 0.8)
            ])
        ]
        // TODO: Dodati ostala slova
    ]
    
    static let englishStrokes: [String: [LetterStroke]] = [
        "A": [
            LetterStroke(points: [
                CGPoint(x: 0.5, y: 0.8),
                CGPoint(x: 0.5, y: 0.2)
            ]),
            LetterStroke(points: [
                CGPoint(x: 0.2, y: 0.5),
                CGPoint(x: 0.8, y: 0.5)
            ])
        ],
        "B": [
            LetterStroke(points: [
                CGPoint(x: 0.2, y: 0.2),
                CGPoint(x: 0.8, y: 0.2),
                CGPoint(x: 0.8, y: 0.5),
                CGPoint(x: 0.8, y: 0.8),
                CGPoint(x: 0.2, y: 0.8)
            ])
        ]
        // TODO: Dodati ostala slova
    ]
    
    static let germanStrokes: [String: [LetterStroke]] = [
        "A": [
            LetterStroke(points: [
                CGPoint(x: 0.5, y: 0.8),
                CGPoint(x: 0.5, y: 0.2)
            ]),
            LetterStroke(points: [
                CGPoint(x: 0.2, y: 0.5),
                CGPoint(x: 0.8, y: 0.5)
            ])
        ],
        "B": [
            LetterStroke(points: [
                CGPoint(x: 0.2, y: 0.2),
                CGPoint(x: 0.8, y: 0.2),
                CGPoint(x: 0.8, y: 0.5),
                CGPoint(x: 0.8, y: 0.8),
                CGPoint(x: 0.2, y: 0.8)
            ])
        ]
        // TODO: Dodati ostala slova
    ]
    
    init(points: [CGPoint]) {
        self.points = points
    }
    
    func toPKStroke(in bounds: CGRect) -> PKStroke {
        var strokePoints: [PKStrokePoint] = []
        
        for (index, point) in points.enumerated() {
            let scaledPoint = CGPoint(
                x: bounds.minX + point.x * bounds.width,
                y: bounds.minY + point.y * bounds.height
            )
            
            let strokePoint = PKStrokePoint(
                location: scaledPoint,
                timeOffset: TimeInterval(index) * 0.1,
                size: CGSize(width: 20, height: 20),
                opacity: 1.0,
                force: 0.5,
                azimuth: 0,
                altitude: 0,
                secondaryScale: 1.0
            )
            strokePoints.append(strokePoint)
        }
        
        let path = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
        return PKStroke(ink: PKInk(.pen, color: .black), path: path)
    }
} 