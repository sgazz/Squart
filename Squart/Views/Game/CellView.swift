import SwiftUI

// MARK: - Constants
private enum CellConstants {
    static let cornerRadius: CGFloat = 4
    static let tokenPadding: CGFloat = 2
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
}

// MARK: - CellView
struct CellView: View, Equatable {
    let cell: BoardCell
    let size: CGFloat
    let isFirstCellOfToken: Bool
    let tokenOrientation: TokenOrientation?
    
    // State се не укључује у Equatable поређење
    @State private var scale: CGFloat = CellConstants.initialScale
    @State private var rotation: Double = 0
    
    // Equatable имплементација
    static func == (lhs: CellView, rhs: CellView) -> Bool {
        lhs.cell.type == rhs.cell.type &&
        lhs.size == rhs.size &&
        lhs.isFirstCellOfToken == rhs.isFirstCellOfToken &&
        lhs.tokenOrientation == rhs.tokenOrientation
    }
    
    var body: some View {
        ZStack {
            backgroundCell
            tokenContent
        }
        .animation(.spring(response: GameSettings.moveAnimationDuration, dampingFraction: 0.6), value: scale)
        .onAppear {
            scale = CellConstants.normalScale
        }
        .onChange(of: cell.type) { oldValue, newValue in
            if newValue != .empty && newValue != .blocked {
                animateTokenPlacement()
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var backgroundCell: some View {
        Rectangle()
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .cornerRadius(CellConstants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CellConstants.cornerRadius)
                    .stroke(Color.white.opacity(CellConstants.strokeOpacity), 
                           lineWidth: CellConstants.strokeWidth)
            )
            .shadow(
                color: Color.black.opacity(CellConstants.shadowOpacity),
                radius: CellConstants.shadowRadius,
                x: 1,
                y: 1
            )
    }
    
    @ViewBuilder
    private var tokenContent: some View {
        if cell.type == .blue || cell.type == .red {
            Rectangle()
                .fill(tokenColor)
                .cornerRadius(CellConstants.cornerRadius)
                .padding(CellConstants.tokenPadding)
                .overlay(
                    RoundedRectangle(cornerRadius: CellConstants.cornerRadius - 1)
                        .stroke(Color.white.opacity(CellConstants.tokenStrokeOpacity),
                               lineWidth: CellConstants.strokeWidth)
                        .padding(CellConstants.tokenPadding)
                )
                .shadow(
                    color: tokenShadowColor,
                    radius: CellConstants.shadowRadius + 1,
                    x: 2,
                    y: 2
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
        }
    }
    
    // MARK: - Helper Properties
    private var backgroundColor: Color {
        switch cell.type {
        case .empty, .blue, .red:
            return .white
        case .blocked:
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
    }
    
    private var tokenColor: Color {
        (cell.type == .blue ? Color.blue : Color.red)
            .opacity(CellConstants.tokenOpacity)
    }
    
    private var tokenShadowColor: Color {
        (cell.type == .blue ? Color.blue : Color.red)
            .opacity(CellConstants.tokenShadowOpacity)
    }
    
    // MARK: - Animation
    private func animateTokenPlacement() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = CellConstants.popScale
            rotation = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + CellConstants.popDelay) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                scale = CellConstants.normalScale
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
        HStack {
            CellView(cell: BoardCell(type: .empty, row: 0, column: 0),
                    size: 44, isFirstCellOfToken: false, tokenOrientation: nil)
            CellView(cell: BoardCell(type: .blocked, row: 0, column: 1),
                    size: 44, isFirstCellOfToken: false, tokenOrientation: nil)
            CellView(cell: BoardCell(type: .blue, row: 0, column: 2),
                    size: 44, isFirstCellOfToken: true, tokenOrientation: .horizontal)
            CellView(cell: BoardCell(type: .red, row: 0, column: 3),
                    size: 44, isFirstCellOfToken: true, tokenOrientation: .vertical)
        }
        .padding()
    }
} 