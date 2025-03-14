import Foundation

class FileStorage: StorageProtocol {
    private let directory: URL
    private let fileManager: FileManager
    
    init(directory: String = "GameSaves", fileManager: FileManager = .default) throws {
        self.fileManager = fileManager
        
        // Kreiramo URL za direktorijum u Documents folderu
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw StorageError.invalidData
        }
        
        self.directory = documentsDirectory.appendingPathComponent(directory)
        
        // Kreiramo direktorijum ako ne postoji
        if !fileManager.fileExists(atPath: self.directory.path) {
            try fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)
        }
    }
    
    // CRUD operacije
    func save<T: Encodable>(_ item: T, forKey key: String) throws {
        let url = fileURL(forKey: key)
        print("Čuvanje u fajl: \(url.path)")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(item)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON za čuvanje: \(jsonString)")
        }
        
        try data.write(to: url, options: .atomic)
        print("Uspešno sačuvano u fajl")
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T? {
        let url = fileURL(forKey: key)
        print("Учитавање из фајла: \(url.path)")
        guard fileManager.fileExists(atPath: url.path) else {
            print("Фајл не постоји на путањи: \(url.path)")
            return nil
        }
        
        let data = try Data(contentsOf: url)
        print("Подаци учитани из фајла, величина: \(data.count) бајтова")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            if let timestamp = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: timestamp)
            }
            let dateStr = try container.decode(String.self)
            if let date = ISO8601DateFormatter().date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
        }
        return try decoder.decode(T.self, from: data)
    }
    
    func delete(forKey key: String) throws {
        let url = fileURL(forKey: key)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    func exists(forKey key: String) -> Bool {
        let url = fileURL(forKey: key)
        return fileManager.fileExists(atPath: url.path)
    }
    
    // Batch operacije
    func saveAll<T: Encodable>(_ items: [String: T]) throws {
        try items.forEach { key, value in
            try save(value, forKey: key)
        }
    }
    
    func loadAll<T: Decodable>(forKeys keys: [String]) throws -> [String: T] {
        var result = [String: T]()
        for key in keys {
            if let item: T = try load(forKey: key) {
                result[key] = item
            }
        }
        return result
    }
    
    func deleteAll(forKeys keys: [String]) throws {
        try keys.forEach { key in
            try delete(forKey: key)
        }
    }
    
    // Utility
    func clear() throws {
        let keys = allKeys
        try deleteAll(forKeys: keys)
    }
    
    var allKeys: [String] {
        do {
            guard fileManager.fileExists(atPath: directory.path) else {
                print("Директоријум не постоји: \(directory.path)")
                return []
            }
            
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "json" }
                .map { $0.deletingPathExtension().lastPathComponent }
                .sorted(by: >)
            
            print("Пронађени фајлови: \(files)")
            return files
        } catch {
            print("Грешка при читању директоријума: \(error)")
            return []
        }
    }
    
    // Helper metode
    private func fileURL(forKey key: String) -> URL {
        return directory.appendingPathComponent(key).appendingPathExtension("json")
    }
} 