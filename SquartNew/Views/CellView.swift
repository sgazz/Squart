import SwiftUI

// MARK: - Constants
private enum CellConstants {
    static let cornerRadius: CGFloat = 4
    static let tokenPadding: CGFloat = 4
    static let strokeWidth: CGFloat = 1
    static let shadowRadius: CGFloat = 2
    static let tokenOpacity: Double = 0.9
    static let strokeOpacity: Double = 0.2
    static let tokenStrokeOpacity: Double = 0.5
    static let shadowOpacity: Double = 0.2
    static let tokenShadowOpacity: Double = 0.3
    static let initialScale: CGFloat = 0.5
    static let normalScale: CGFloat = 1.0
    static let popScale: CGFloat = 1.2
    static let popDelay: Double = 0.1
    static let animationDuration: Double = 0.3
}

// MARK: - CellView
struct CellView: View, Equatable {
    // Константе за стилизацију
    private let cornerRadius: CGFloat = CellConstants.cornerRadius
    private let shadowRadius: CGFloat = CellConstants.shadowRadius
    private let tokenPadding: CGFloat = CellConstants.tokenPadding
    private let animationDuration: Double = CellConstants.animationDuration
    
    let cell: BoardCell
    
    var body: some View {
        ZStack {
            backgroundCell
            tokenContent
        }
    }
    
    private var backgroundCell: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(cell.type == .blocked ? Color.gray : Color(UIColor.secondarySystemBackground))
            .shadow(radius: shadowRadius)
    }
    
    private var tokenContent: some View {
        Group {
            if cell.type != .empty && cell.type != .blocked {
                RoundedRectangle(cornerRadius: cornerRadius - 2)
                    .fill(cell.type.color)
                    .padding(tokenPadding)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: animationDuration), value: cell.type)
    }
    
    static func == (lhs: CellView, rhs: CellView) -> Bool {
        return lhs.cell.type == rhs.cell.type
    }
}

// MARK: - Preview
struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                CellView(cell: BoardCell(type: .empty))
                CellView(cell: BoardCell(type: .blocked))
            }
            HStack {
                CellView(cell: BoardCell(type: .blue))
                CellView(cell: BoardCell(type: .red))
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 