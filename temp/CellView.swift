import SwiftUI

struct CellView: View, Equatable {
    // Константе за стилизацију
    private let cornerRadius: CGFloat = 4
    private let shadowRadius: CGFloat = 2
    private let tokenPadding: CGFloat = 4
    private let animationDuration: Double = 0.3
    
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