import SwiftUI

extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    // Boje za ćelije
    let cellEmpty = Color(.systemGray6)
    let cellBlocked = Color(.systemGray3)
    let cellBlue = Color.blue.opacity(0.7)
    let cellRed = Color.red.opacity(0.7)
    
    // Boje za pozadinu
    let boardBackground = Color(.systemGray5)
    let background = Color(.systemBackground)
    let secondaryBackground = Color(.systemGray4)
    
    // Boje za tekst
    let text = Color(.label)
    let secondaryText = Color(.secondaryLabel)
    
    // Boje za UI elemente
    let primary = Color.blue
    let secondary = Color.red
    
    // Boje za senke
    let shadow = Color.black.opacity(0.2)
} 