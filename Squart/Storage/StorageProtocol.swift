import Foundation

protocol StorageProtocol {
    // CRUD operacije
    func save<T: Encodable>(_ item: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
    
    // Batch operacije
    func saveAll<T: Encodable>(_ items: [String: T]) throws
    func loadAll<T: Decodable>(forKeys keys: [String]) throws -> [String: T]
    func deleteAll(forKeys keys: [String]) throws
    
    // Utility
    func clear() throws
    var allKeys: [String] { get }
}

// Greške koje mogu da se dese pri radu sa storage-om
enum StorageError: Error {
    case encodingFailed
    case decodingFailed
    case itemNotFound
    case saveFailed
    case deleteFailed
    case invalidData
    case encryptionFailed
    case decryptionFailed
    
    var localizedDescription: String {
        switch self {
        case .encodingFailed:
            return "Nije uspelo kodiranje podataka"
        case .decodingFailed:
            return "Nije uspelo dekodiranje podataka"
        case .itemNotFound:
            return "Stavka nije pronađena"
        case .saveFailed:
            return "Nije uspelo čuvanje podataka"
        case .deleteFailed:
            return "Nije uspelo brisanje podataka"
        case .invalidData:
            return "Nevažeći podaci"
        case .encryptionFailed:
            return "Nije uspela enkripcija podataka"
        case .decryptionFailed:
            return "Nije uspela dekripcija podataka"
        }
    }
} 