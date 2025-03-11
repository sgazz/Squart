import Foundation
import SwiftUI
import Combine

class Localization: ObservableObject {
    static let shared = Localization()
    
    @Published var currentLanguage: Language = GameSettingsManager.shared.language
    private var cancellables = Set<AnyCancellable>()
    
    // Rečnici prevoda za svaki jezik
    private let translations: [Language: [String: String]] = [
        .serbian: [
            "settings": "Podešavanja",
            "close": "Zatvori",
            "apply_start_new": "Primeni i započni novu igru",
            "board_size": "Veličina table",
            "appearance": "Izgled",
            "theme": "Tema",
            "time_limit": "Vreme za potez",
            "time_limit_option": "Ograničenje vremena",
            "opponent": "Protivnik",
            "play_against_computer": "Igraj protiv računara",
            "difficulty": "Težina",
            "ai_team": "AI tim",
            "blue": "Plavi",
            "red": "Crveni",
            "ai_vs_ai": "AI vs AI mod",
            "second_ai_difficulty": "Težina drugog AI",
            "first_move": "Prvi na potezu",
            "sound_vibration": "Zvuk i vibracija",
            "sound_effects": "Zvučni efekti",
            "vibration": "Vibracija",
            "language": "Jezik",
            "new_game": "Nova igra",
            "your_turn": "Vi ste na potezu",
            "ai_turn": "AI na potezu",
            "ai_thinking": "AI razmišlja...",
            "turn": "Na potezu",
            "no_valid_moves": "Nema validnih poteza!",
            "blue_timeout": "Isteklo vreme plavom igraču!",
            "red_timeout": "Isteklo vreme crvenom igraču!",
            "game_over": "Igra je završena!",
            "winner": "Pobednik",
            "easy": "Lako",
            "medium": "Srednje",
            "hard": "Teško",
            "no_limit": "Bez ograničenja",
            "minute": "minut",
            "minutes": "minuta",
            "ocean": "Okean",
            "sunset": "Zalazak sunca",
            "forest": "Šuma",
            "galaxy": "Galaksija",
            "classic": "Klasična"
        ],
        .english: [
            "settings": "Settings",
            "close": "Close",
            "apply_start_new": "Apply and Start New Game",
            "board_size": "Board Size",
            "appearance": "Appearance",
            "theme": "Theme",
            "time_limit": "Time Limit",
            "time_limit_option": "Time Limit Option",
            "opponent": "Opponent",
            "play_against_computer": "Play Against Computer",
            "difficulty": "Difficulty",
            "ai_team": "AI Team",
            "blue": "Blue",
            "red": "Red",
            "ai_vs_ai": "AI vs AI Mode",
            "second_ai_difficulty": "Second AI Difficulty",
            "first_move": "First Move",
            "sound_vibration": "Sound & Vibration",
            "sound_effects": "Sound Effects",
            "vibration": "Vibration",
            "language": "Language",
            "new_game": "New Game",
            "your_turn": "Your Turn",
            "ai_turn": "AI's Turn",
            "ai_thinking": "AI is thinking...",
            "turn": "Turn",
            "no_valid_moves": "No Valid Moves!",
            "blue_timeout": "Blue Player Timeout!",
            "red_timeout": "Red Player Timeout!",
            "game_over": "Game Over!",
            "winner": "Winner",
            "easy": "Easy",
            "medium": "Medium",
            "hard": "Hard",
            "no_limit": "No Limit",
            "minute": "minute",
            "minutes": "minutes",
            "ocean": "Ocean",
            "sunset": "Sunset",
            "forest": "Forest",
            "galaxy": "Galaxy",
            "classic": "Classic"
        ],
        .german: [
            "settings": "Einstellungen",
            "close": "Schließen",
            "apply_start_new": "Anwenden und Neues Spiel starten",
            "board_size": "Spielfeldgröße",
            "appearance": "Aussehen",
            "theme": "Thema",
            "time_limit": "Zeitlimit",
            "time_limit_option": "Zeitlimit-Option",
            "opponent": "Gegner",
            "play_against_computer": "Gegen Computer spielen",
            "difficulty": "Schwierigkeit",
            "ai_team": "KI-Team",
            "blue": "Blau",
            "red": "Rot",
            "ai_vs_ai": "KI gegen KI Modus",
            "second_ai_difficulty": "Schwierigkeit der zweiten KI",
            "first_move": "Erster Zug",
            "sound_vibration": "Ton & Vibration",
            "sound_effects": "Soundeffekte",
            "vibration": "Vibration",
            "language": "Sprache",
            "new_game": "Neues Spiel",
            "your_turn": "Du bist dran",
            "ai_turn": "KI ist dran",
            "ai_thinking": "KI denkt nach...",
            "turn": "Am Zug",
            "no_valid_moves": "Keine gültigen Züge!",
            "blue_timeout": "Zeitüberschreitung für Blau!",
            "red_timeout": "Zeitüberschreitung für Rot!",
            "game_over": "Spiel vorbei!",
            "winner": "Gewinner",
            "easy": "Leicht",
            "medium": "Mittel",
            "hard": "Schwer",
            "no_limit": "Kein Limit",
            "minute": "Minute",
            "minutes": "Minuten",
            "ocean": "Ozean",
            "sunset": "Sonnenuntergang",
            "forest": "Wald",
            "galaxy": "Galaxie",
            "classic": "Klassisch"
        ],
        .russian: [
            "settings": "Настройки",
            "close": "Закрыть",
            "apply_start_new": "Применить и начать новую игру",
            "board_size": "Размер доски",
            "appearance": "Внешний вид",
            "theme": "Тема",
            "time_limit": "Ограничение времени",
            "time_limit_option": "Вариант ограничения времени",
            "opponent": "Противник",
            "play_against_computer": "Играть против компьютера",
            "difficulty": "Сложность",
            "ai_team": "Команда ИИ",
            "blue": "Синий",
            "red": "Красный",
            "ai_vs_ai": "Режим ИИ против ИИ",
            "second_ai_difficulty": "Сложность второго ИИ",
            "first_move": "Первый ход",
            "sound_vibration": "Звук и вибрация",
            "sound_effects": "Звуковые эффекты",
            "vibration": "Вибрация",
            "language": "Язык",
            "new_game": "Новая игра",
            "your_turn": "Ваш ход",
            "ai_turn": "Ход ИИ",
            "ai_thinking": "ИИ думает...",
            "turn": "Ход",
            "no_valid_moves": "Нет допустимых ходов!",
            "blue_timeout": "Время синего игрока истекло!",
            "red_timeout": "Время красного игрока истекло!",
            "game_over": "Игра окончена!",
            "winner": "Победитель",
            "easy": "Легкий",
            "medium": "Средний",
            "hard": "Сложный",
            "no_limit": "Без ограничений",
            "minute": "минута",
            "minutes": "минут",
            "ocean": "Океан",
            "sunset": "Закат",
            "forest": "Лес",
            "galaxy": "Галактика",
            "classic": "Классический"
        ],
        .chinese: [
            "settings": "设置",
            "close": "关闭",
            "apply_start_new": "应用并开始新游戏",
            "board_size": "棋盘大小",
            "appearance": "外观",
            "theme": "主题",
            "time_limit": "时间限制",
            "time_limit_option": "时间限制选项",
            "opponent": "对手",
            "play_against_computer": "与电脑对战",
            "difficulty": "难度",
            "ai_team": "AI队伍",
            "blue": "蓝色",
            "red": "红色",
            "ai_vs_ai": "AI对战AI模式",
            "second_ai_difficulty": "第二AI难度",
            "first_move": "先手",
            "sound_vibration": "声音和振动",
            "sound_effects": "音效",
            "vibration": "振动",
            "language": "语言",
            "new_game": "新游戏",
            "your_turn": "你的回合",
            "ai_turn": "AI回合",
            "ai_thinking": "AI思考中...",
            "turn": "回合",
            "no_valid_moves": "没有有效移动！",
            "blue_timeout": "蓝方超时！",
            "red_timeout": "红方超时！",
            "game_over": "游戏结束！",
            "winner": "获胜者",
            "easy": "简单",
            "medium": "中等",
            "hard": "困难",
            "no_limit": "无限制",
            "minute": "分钟",
            "minutes": "分钟",
            "ocean": "海洋",
            "sunset": "日落",
            "forest": "森林",
            "galaxy": "星系",
            "classic": "经典"
        ]
    ]
    
    private init() {
        // Pratimo promene jezika
        NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))
            .sink { [weak self] notification in
                if let language = notification.object as? Language {
                    self?.currentLanguage = language
                }
            }
            .store(in: &cancellables)
    }
    
    // Metoda za prevođenje teksta
    func localize(_ key: String) -> String {
        if let translation = translations[currentLanguage]?[key] {
            return translation
        }
        
        // Ako prevod ne postoji, vraćamo ključ
        return key
    }
}

// Extension za String koji omogućava laku lokalizaciju
extension String {
    var localized: String {
        return Localization.shared.localize(self)
    }
} 