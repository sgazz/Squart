class GameBoard {
    // ... existing code ...
    
    /// Враћа стање табле као матрицу CellType вредности
    func getCellTypeArray() -> [[CellType]] {
        var cellTypes = [[CellType]](repeating: [CellType](repeating: .empty, count: size), count: size)
        
        for row in 0..<size {
            for column in 0..<size {
                cellTypes[row][column] = cells[row][column].type
            }
        }
        
        return cellTypes
    }
    
    // ... existing code ...
} 