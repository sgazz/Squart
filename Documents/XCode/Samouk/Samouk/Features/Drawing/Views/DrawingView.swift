import SwiftUI
import PencilKit

struct DrawingView: View {
    @StateObject private var viewModel = DrawingViewModel()
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack(spacing: Constants.UI.padding) {
            // Gornji deo - Izbor jezika
            LanguageSelectorView(selectedLanguage: $viewModel.selectedLanguage)
            
            // Srednji deo - Model slova i dugme za promenu
            HStack {
                Text(viewModel.currentLetter)
                    .font(.system(size: 100))
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .cornerRadius(Constants.UI.cornerRadius)
                
                Button(action: viewModel.changeLetter) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                        .frame(width: Constants.UI.buttonSize, height: Constants.UI.buttonSize)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.cornerRadius)
                }
            }
            
            // Paleta boja
            ColorPaletteView(selectedColor: $viewModel.selectedColor)
            
            // Canvas za crtanje
            CanvasView(canvasView: $canvasView, viewModel: viewModel)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Constants.Drawing.canvasBackgroundColor)
                .cornerRadius(Constants.UI.cornerRadius)
            
            // Donji deo - Kontrolna tabla
            ControlPanelView(viewModel: viewModel)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    DrawingView()
} 