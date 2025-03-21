import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }
    
    @Published var isVibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isVibrationEnabled, forKey: "isVibrationEnabled")
        }
    }
    
    init() {
        self.isSoundEnabled = UserDefaults.standard.bool(forKey: "isSoundEnabled")
        self.isVibrationEnabled = UserDefaults.standard.bool(forKey: "isVibrationEnabled")
    }
} 