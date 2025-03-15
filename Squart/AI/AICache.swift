import Foundation

/// Класа која управља кеширањем позиција и њихових евалуација
class AICache {
    private var cache: [String: (score: Int, move: Position?)] = [:]
    private let maxSize: Int
    
    init(maxSize: Int) {
        self.maxSize = maxSize
    }
    
    /// Дохвата евалуацију позиције из кеша
    func get(key: String) -> (score: Int, move: Position?)? {
        return cache[key]
    }
    
    /// Чува евалуацију позиције у кеш
    func set(key: String, value: (score: Int, move: Position?)) {
        if cache.count >= maxSize {
            cache.removeValue(forKey: cache.keys.first!)
        }
        cache[key] = value
    }
    
    /// Брише све елементе из кеша
    func clear() {
        cache.removeAll()
    }
    
    /// Враћа број елемената у кешу
    var count: Int {
        return cache.count
    }
} 