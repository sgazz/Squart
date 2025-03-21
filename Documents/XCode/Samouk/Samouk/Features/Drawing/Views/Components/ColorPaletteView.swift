import SwiftUI

struct ColorPaletteView: View {
    @Binding var selectedColor: Color
    
    private let colors: [Color] = [.black, .red, .blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                    )
                    .onTapGesture {
                        selectedColor = color
                    }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ColorPaletteView(selectedColor: .constant(.black))
} 