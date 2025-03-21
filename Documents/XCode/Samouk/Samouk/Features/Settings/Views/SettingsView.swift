import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Opšta podešavanja")) {
                    Toggle("Zvuk", isOn: $viewModel.isSoundEnabled)
                    Toggle("Vibracija", isOn: $viewModel.isVibrationEnabled)
                }
                
                Section(header: Text("Pomoć")) {
                    NavigationLink("Kako da koristim aplikaciju") {
                        Text("Uputstvo za korišćenje")
                    }
                    
                    NavigationLink("O aplikaciji") {
                        Text("O aplikaciji")
                    }
                }
            }
            .navigationTitle("Podešavanja")
        }
    }
}

#Preview {
    SettingsView()
} 