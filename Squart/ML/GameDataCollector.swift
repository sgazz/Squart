import Foundation
import SwiftUI

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
    private var currentGameRecord: GameRecordingData?
    
    // Ključ za UserDefaults
    private let gameRecordsKey = "squart_game_records"
    
    // Statistika za prikupljanje podataka
    private(set) var totalMovesSaved: Int = 0
    private(set) var gamesRecorded: Int = 0
    
    // Da li je snimanje u toku
    var isRecording: Bool {
        return currentGameRecord != nil
    }
    
    // Struktura za trenutno snimanje partije
    private struct GameRecordingData {
        var moves: [(row: Int, column: Int)]
        var boardSize: Int
        var boardStates: [[CellType]]
        var currentPlayers: [Player]
    }
    
    // Počni snimanje nove partije
    func startRecording(boardSize: Int) {
        // Ako već snimamo partiju, prvo je otkazujemo
        if isRecording {
            cancelRecording()
        }
        
        // Inicijalizujemo prazne podatke za snimanje
        let initialBoardState = Array(repeating: Array(repeating: CellType.empty, count: boardSize), count: boardSize)
        
        currentGameRecord = GameRecordingData(
            moves: [],
            boardSize: boardSize,
            boardStates: [initialBoardState], // Početno stanje table
            currentPlayers: [.blue] // Prvi igrač je plavi
        )
        
        print("ML: Započeto snimanje nove partije (veličina table: \(boardSize)x\(boardSize))")
    }
    
    // Dodaj potez u trenutno snimanje
    func recordMove(row: Int, column: Int) {
        guard var record = currentGameRecord else {
            print("ML: Greška - pokušaj snimanja poteza bez aktivne sesije snimanja")
            return
        }
        
        // Dodajemo potez u snimanje
        record.moves.append((row, column))
        totalMovesSaved += 1
        
        // Dodajemo trenutnog igrača nakon poteza (za sledeći potez)
        let nextPlayer = record.currentPlayers.last == .blue ? Player.red : Player.blue
        record.currentPlayers.append(nextPlayer)
        
        // Ažuriramo trenutno snimanje
        currentGameRecord = record
        
        print("ML: Snimljen potez (\(row), \(column)) za igrača \(record.currentPlayers.dropLast().last == .blue ? "plavi" : "crveni")")
    }
    
    // Dodaj trenutno stanje table u snimanje
    func recordBoardState(_ board: GameBoard) {
        guard var record = currentGameRecord else { return }
        
        // Konvertujemo stanje table u format za čuvanje
        var boardState: [[CellType]] = Array(repeating: Array(repeating: CellType.empty, count: board.size), count: board.size)
        
        for row in 0..<board.size {
            for column in 0..<board.size {
                boardState[row][column] = board.cells[row][column].type
            }
        }
        
        // Dodajemo novo stanje table
        record.boardStates.append(boardState)
        
        // Ažuriramo trenutno snimanje
        currentGameRecord = record
    }
    
    // Završi snimanje i sačuvaj partiju
    func finishRecording(winner: Player) {
        guard let record = currentGameRecord else {
            print("ML: Greška - pokušaj završetka snimanja bez aktivne sesije")
            return
        }
        
        // Ako nema poteza, otkazujemo snimanje
        if record.moves.isEmpty {
            print("ML: Otkazano snimanje - nema poteza")
            cancelRecording()
            return
        }
        
        // Kreiramo zapis o partiji
        let gameRecord = GameRecord(
            moves: record.moves,
            winner: winner,
            boardSize: record.boardSize,
            boardStates: record.boardStates,
            currentPlayers: record.currentPlayers
        )
        
        // Dodajemo u kolekciju i čuvamo u UserDefaults
        gameRecords.append(gameRecord)
        saveGameRecords()
        
        // Ažuriramo statistiku
        gamesRecorded += 1
        
        print("ML: Snimanje završeno - partija sačuvana (pobednik: \(winner == .blue ? "plavi" : "crveni"), broj poteza: \(record.moves.count))")
        
        // Resetujemo trenutno snimanje
        currentGameRecord = nil
        
        // Pokušavamo trening ako imamo dovoljno podataka
        if gamesRecorded % 5 == 0 && gamesRecorded > 0 {
            print("ML: Dostignut cilj od \(gamesRecorded) partija - pokušavam trening")
            MLPositionEvaluator.shared.trainModel(withGameData: gameRecords)
        }
    }
    
    // Otkaži trenutno snimanje
    func cancelRecording() {
        if currentGameRecord != nil {
            print("ML: Snimanje otkazano")
            currentGameRecord = nil
        }
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
        gamesRecorded = gameRecords.count
        totalMovesSaved = gameRecords.reduce(0) { $0 + $1.moves.count }
        
        print("ML: Učitano \(gameRecords.count) snimljenih partija (\(totalMovesSaved) poteza)")
    }
    
    // Izvezi podatke za trening u JSON fajl
    func exportTrainingData() -> URL? {
        var recordsArray: [[String: Any]] = []
        
        for record in gameRecords {
            recordsArray.append(record.toJSON())
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: recordsArray, options: .prettyPrinted) else {
            print("ML: Greška - nije moguće serijalizovati podatke")
            return nil
        }
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = temporaryDirectoryURL.appendingPathComponent("squart_training_data.json")
        
        do {
            try data.write(to: fileURL)
            print("ML: Podaci izvezeni u: \(fileURL.path)")
            return fileURL
        } catch {
            print("ML: Greška pri čuvanju podataka za trening: \(error)")
            return nil
        }
    }
    
    // Statistika podataka za trening
    func getTrainingStats() -> String {
        return """
        Ukupno partija: \(gameRecords.count)
        Ukupno poteza: \(totalMovesSaved)
        Pobede plavog igrača: \(gameRecords.filter { $0.winner == .blue }.count)
        Pobede crvenog igrača: \(gameRecords.filter { $0.winner == .red }.count)
        Prosečan broj poteza po partiji: \(gameRecords.isEmpty ? 0 : totalMovesSaved / gameRecords.count)
        """
    }
    
    // Očisti sve snimljene partije
    func clearAllGameRecords() {
        gameRecords = []
        totalMovesSaved = 0
        gamesRecorded = 0
        UserDefaults.standard.removeObject(forKey: gameRecordsKey)
        print("ML: Svi podaci za trening su obrisani")
    }
} 