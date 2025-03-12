import SwiftUI

extension Color {
    // Inicijalizacija iz hex stringa
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    // Konvertovanje u hex string
    var toHex: String? {
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
    
    // Svetlija verzija boje
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: abs(percentage))
    }
    
    // Tamnija verzija boje
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: -abs(percentage))
    }
    
    // Pomoćna funkcija za podešavanje boje
    private func adjust(by percentage: CGFloat) -> Color {
        guard let uiColor = UIColor(self).adjust(by: percentage) else {
            return self
        }
        return Color(uiColor)
    }
}

extension UIColor {
    // Pomoćna funkcija za podešavanje UIColor
    fileprivate func adjust(by percentage: CGFloat) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        return UIColor(red: min(red + percentage/100, 1.0),
                      green: min(green + percentage/100, 1.0),
                      blue: min(blue + percentage/100, 1.0),
                      alpha: alpha)
    }
} 