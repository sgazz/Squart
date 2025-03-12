import SwiftUI

struct CellView: View {
    let cell: BoardCell
    let size: CGFloat
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Pozadina ćelije
            Rectangle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
            
            // Sadržaj ćelije - žetoni su sada obojeni pravougaonici koji zauzimaju ćeliju
            if cell.type == .blue {
                Rectangle()
                    .fill(Color.blue.opacity(0.9))
                    .cornerRadius(4)
                    .padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            .padding(2)
                    )
                    .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 2, y: 2)
            } else if cell.type == .red {
                Rectangle()
                    .fill(Color.red.opacity(0.9))
                    .cornerRadius(4)
                    .padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            .padding(2)
                    )
                    .shadow(color: Color.red.opacity(0.3), radius: 3, x: 2, y: 2)
            }
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .animation(.spring(response: GameSettings.moveAnimationDuration, dampingFraction: 0.6), value: scale)
        .animation(.spring(response: GameSettings.moveAnimationDuration, dampingFraction: 0.6), value: rotation)
        .onAppear {
            scale = 1.0
        }
        .onChange(of: cell.type) { oldValue, newValue in
            if newValue != .empty && newValue != .blocked {
                // Animacija za postavljanje žetona
                scale = 1.2
                rotation = 0 // Bez rotacije za pravougaonike
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scale = 1.0
                }
            }
        }
    }
    
    private var backgroundColor: Color {
        switch cell.type {
        case .empty:
            return Color.white
        case .blocked:
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        case .blue, .red:
            return Color.white
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
        HStack {
            CellView(cell: BoardCell(type: .empty, row: 0, column: 0), size: 44)
            CellView(cell: BoardCell(type: .blocked, row: 0, column: 1), size: 44)
            CellView(cell: BoardCell(type: .blue, row: 0, column: 2), size: 44)
            CellView(cell: BoardCell(type: .red, row: 0, column: 3), size: 44)
        }
        .padding()
    }
} 