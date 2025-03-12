import Foundation

class UserDefaultsStorage: StorageProtocol {
    private let defaults: UserDefaults
    private let prefix: String
    
    init(defaults: UserDefaults = .standard, prefix: String = "squart_") {
        self.defaults = defaults
        self.prefix = prefix
    }
    
    // CRUD operacije
    func save<T: Encodable>(_ item: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(item)
        defaults.set(data, forKey: prefix + key)
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: prefix + key) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func delete(forKey key: String) throws {
        defaults.removeObject(forKey: prefix + key)
    }
    
    func exists(forKey key: String) -> Bool {
        defaults.object(forKey: prefix + key) != nil
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
        keys.forEach { key in
            try? delete(forKey: key)
        }
    }
    
    // Utility
    func clear() throws {
        let keys = allKeys
        try deleteAll(forKeys: keys)
    }
    
    var allKeys: [String] {
        defaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(prefix) }
            .map { String($0.dropFirst(prefix.count)) }
    }
} 