import Foundation
import CoreML

// Klasa koja implementira ML pristup za evaluaciju pozicije u igri Squart
class MLPositionEvaluator {
    
    // Singleton instanca
    static let shared = MLPositionEvaluator()
    
    // Privatni inicijalizator za singleton
    private init() {
        // Inicijalizacija ML modela će ići ovde
    }
    
    // Trenutni ML model (biće učitan kasnije)
    private var model: Any? = nil
    
    // Indikator da li je ML spreman za korišćenje
    var isMLReady: Bool {
        return model != nil
    }
    
    // Metoda za pripremu i učitavanje ML modela
    func prepareModel() {
        // Ovde ćemo učitati ML model kada ga budemo imali
        // TODO: Implementirati učitavanje CoreML modela
    }
    
    // Metoda za konverziju stanja igre u format prihvatljiv za ML model
    private func convertGameStateToMLInput(_ game: Game) -> [Float] {
        let board = game.board
        var input: [Float] = []
        
        // Konvertujemo stanje table u niz brojeva
        for row in 0..<board.size {
            for column in 0..<board.size {
                let cell = board.cells[row][column]
                let value: Float
                
                switch cell.type {
                case .empty: value = 0.0
                case .blocked: value = -1.0
                case .blue: value = 1.0
                case .red: value = 2.0
                }
                
                input.append(value)
            }
        }
        
        // Dodajemo informaciju o trenutnom igraču
        input.append(game.currentPlayer == .blue ? 1.0 : 2.0)
        
        return input
    }
    
    // Hibridna funkcija za evaluaciju pozicije - kombinuje ML i heuristike
    func evaluatePosition(_ game: Game, player: Player) -> Int {
        // Ako ML model nije spreman, vratimo tradicionalnu heurističku procenu
        if !isMLReady {
            return fallbackEvaluatePosition(game, player: player)
        }
        
        // Konvertujemo stanje igre u ML input
        let mlInput = convertGameStateToMLInput(game)
        
        // TODO: Implementirati poziv ML modela za evaluaciju
        // Za sada koristimo fallback metod
        return fallbackEvaluatePosition(game, player: player)
    }
    
    // Fallback metoda koja koristi tradicionalne heuristike
    private func fallbackEvaluatePosition(_ game: Game, player: Player) -> Int {
        // Privremeno - koristimo postojeću funkciju za evaluaciju
        let aiPlayer = AIPlayer(difficulty: .hard)
        
        // Ovo je hacky pristup, ali zasad će raditi
        // Prava implementacija bi trebalo da ima pristup pravoj funkciji za evaluaciju
        // Kasnije ćemo izdvojiti ovu funkcionalnost iz AIPlayer klase
        return 0 // Privremena vrednost
    }
    
    // Funkcija za trening modela (koristiće se offline)
    func trainModel(withGameData games: [GameRecord]) {
        // TODO: Implementirati offline trening na osnovu snimljenih partija
        // Ovo će biti poseban proces koji će generisati CoreML model
    }
}

// Struktura koja predstavlja snimljenu partiju za trening
struct GameRecord {
    let moves: [(row: Int, column: Int)]
    let winner: Player
    let boardSize: Int
    
    // Funkcija za serijalizaciju u JSON za skladištenje
    func toJSON() -> [String: Any] {
        var jsonMoves: [[String: Int]] = []
        for move in moves {
            jsonMoves.append(["row": move.row, "column": move.column])
        }
        
        return [
            "moves": jsonMoves,
            "winner": winner == .blue ? "blue" : "red",
            "boardSize": boardSize
        ]
    }
    
    // Funkcija za deserijalizaciju iz JSON
    static func fromJSON(_ json: [String: Any]) -> GameRecord? {
        guard let jsonMoves = json["moves"] as? [[String: Int]],
              let winnerString = json["winner"] as? String,
              let boardSize = json["boardSize"] as? Int else {
            return nil
        }
        
        let winner: Player = winnerString == "blue" ? .blue : .red
        var moves: [(row: Int, column: Int)] = []
        
        for jsonMove in jsonMoves {
            if let row = jsonMove["row"], let column = jsonMove["column"] {
                moves.append((row, column))
            }
        }
        
        return GameRecord(moves: moves, winner: winner, boardSize: boardSize)
    }
} 