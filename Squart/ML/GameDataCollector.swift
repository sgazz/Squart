import Foundation

// Klasa odgovorna za prikupljanje podataka iz igara za trening ML modela
class GameDataCollector {
    
    // Singleton instanca
    static let shared = GameDataCollector()
    
    // Privatni inicijalizator za singleton
    private init() {
        loadGameRecords()
    }
    
    // Kolekcija snimljenih partija
    private(set) var gameRecords: [GameRecord] = []
    
    // Trenutna partija koja se snima
    private var currentGameRecord: (moves: [(row: Int, column: Int)], boardSize: Int)?
    
    // Ključ za UserDefaults
    private let gameRecordsKey = "squart_game_records"
    
    // Počni snimanje nove partije
    func startRecording(boardSize: Int) {
        currentGameRecord = (moves: [], boardSize: boardSize)
    }
    
    // Dodaj potez u trenutno snimanje
    func recordMove(row: Int, column: Int) {
        guard var record = currentGameRecord else { return }
        record.moves.append((row, column))
        currentGameRecord = record
    }
    
    // Završi snimanje i sačuvaj partiju
    func finishRecording(winner: Player) {
        guard let record = currentGameRecord else { return }
        
        let gameRecord = GameRecord(
            moves: record.moves,
            winner: winner,
            boardSize: record.boardSize
        )
        
        gameRecords.append(gameRecord)
        saveGameRecords()
        currentGameRecord = nil
    }
    
    // Otkaži trenutno snimanje
    func cancelRecording() {
        currentGameRecord = nil
    }
    
    // Sačuvaj snimljene partije u UserDefaults
    private func saveGameRecords() {
        var recordsArray: [[String: Any]] = []
        
        for record in gameRecords {
            recordsArray.append(record.toJSON())
        }
        
        UserDefaults.standard.set(recordsArray, forKey: gameRecordsKey)
    }
    
    // Učitaj snimljene partije iz UserDefaults
    private func loadGameRecords() {
        guard let recordsArray = UserDefaults.standard.array(forKey: gameRecordsKey) as? [[String: Any]] else {
            return
        }
        
        gameRecords = recordsArray.compactMap { GameRecord.fromJSON($0) }
    }
    
    // Izvezi podatke za trening u JSON fajl
    func exportTrainingData() -> URL? {
        var recordsArray: [[String: Any]] = []
        
        for record in gameRecords {
            recordsArray.append(record.toJSON())
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: recordsArray, options: .prettyPrinted) else {
            return nil
        }
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = temporaryDirectoryURL.appendingPathComponent("squart_training_data.json")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Greška pri čuvanju podataka za trening: \(error)")
            return nil
        }
    }
    
    // Očisti sve snimljene partije
    func clearAllGameRecords() {
        gameRecords = []
        UserDefaults.standard.removeObject(forKey: gameRecordsKey)
    }
} 