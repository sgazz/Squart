import Foundation

enum Language: String, CaseIterable, Identifiable {
    case cyrillic = "Cyrillic"
    case english = "English"
    case german = "German"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .cyrillic:
            return "Ćirilica"
        case .english:
            return "Engleski"
        case .german:
            return "Nemački"
        }
    }
    
    var availableLetters: [String] {
        switch self {
        case .cyrillic:
            return ["А", "Б", "В", "Г", "Д", "Ђ", "Е", "Ж", "З", "И", "Ј", "К", "Л", "Љ", "М", "Н", "Њ", "О", "П", "Р", "С", "Т", "Ћ", "У", "Ф", "Х", "Ц", "Ч", "Џ", "Ш"]
        case .english:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        case .german:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü", "ß"]
        }
    }
} 