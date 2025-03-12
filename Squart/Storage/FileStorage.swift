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
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    // CRUD operacije
    func save<T: Encodable>(_ item: T, forKey key: String) throws {
        let url = fileURL(forKey: key)
        let data = try JSONEncoder().encode(item)
        try data.write(to: url, options: .atomic)
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T? {
        let url = fileURL(forKey: key)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
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
            return try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            return []
        }
    }
    
    // Helper metode
    private func fileURL(forKey key: String) -> URL {
        return directory.appendingPathComponent(key).appendingPathExtension("json")
    }
} 