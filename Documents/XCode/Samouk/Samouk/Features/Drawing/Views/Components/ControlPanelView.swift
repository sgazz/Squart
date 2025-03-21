import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var viewModel: DrawingViewModel
    
    var body: some View {
        HStack(spacing: Constants.UI.padding) {
            // Dugme za brisanje
            Button(action: viewModel.clearCanvas) {
                Image(systemName: "trash")
                    .font(.title)
                    .frame(width: Constants.UI.buttonSize, height: Constants.UI.buttonSize)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.UI.cornerRadius)
            }
            
            // Slider za debljinu poteza
            VStack {
                Text("Debljina")
                    .font(.caption)
                Slider(value: $viewModel.strokeWidth, in: 1...10)
                    .frame(width: 100)
            }
            
            // Dugme za analizu
            Button(action: {
                // Implementirati analizu
            }) {
                Image(systemName: "checkmark.circle")
                    .font(.title)
                    .frame(width: Constants.UI.buttonSize, height: Constants.UI.buttonSize)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.UI.cornerRadius)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

#Preview {
    ControlPanelView(viewModel: DrawingViewModel())
} 