# Squart - Техничка документација

## Архитектура система

### 1. Модел података
#### GameModels.swift
- **CellType**: enum који дефинише могуће стања ћелије
  - `empty`: празна ћелија
  - `blue`: плави токен
  - `red`: црвени токен
  - `blocked`: блокирана ћелија

- **Player**: enum који дефинише играче
  - `blue`: плави играч
  - `red`: црвени играч

- **Position**: struct за позиционирање
  ```swift
  struct Position: Hashable {
      let row: Int
      let col: Int
  }
  ```

- **BoardCell**: struct за представљање ћелије
  ```swift
  struct BoardCell: Identifiable {
      let id = UUID()
      var type: CellType
      var position: Position
  }
  ```

- **GameBoard**: класа за управљање таблом
  - `cells`: матрица ћелија
  - `size`: величина табле
  - Методе за валидацију потеза и управљање стањем

- **Game**: главна класа игре
  - Управља стањем игре
  - Координира потезе
  - Управља тајмером
  - Обрађује крај игре

### 2. AI Систем
#### Архитектура AI компоненти
1. **AIPlayer**
   - Координира све AI компоненте
   - Управља нивоима тежине
   - Обрађује AI потезе

2. **AICache**
   ```swift
   class AICache {
       private var cache: [String: (score: Int, move: Position?)]
       private let maxSize: Int
       
       func get(key: String) -> (score: Int, move: Position?)?
       func set(key: String, value: (score: Int, move: Position?))
       func clear()
   }
   ```

3. **AIEvaluator**
   ```swift
   class AIEvaluator {
       static func evaluatePosition(_ game: Game, for player: Player) -> Int
       func countCenterMoves(_ game: Game, for player: Player) -> Int
       func countCornerMoves(_ game: Game, for player: Player) -> Int
   }
   ```

4. **AISearch**
   ```swift
   class AISearch {
       private let maxDepth: Int
       private let evaluator: AIEvaluator
       private let cache: AICache
       
       func findBestMove(for game: Game) -> Position?
       private func alphaBetaMinimax(...) -> Int
   }
   ```

#### Алгоритмизам претраге
1. **Минимакс са алфа-бета одсецањем**
   ```swift
   private func alphaBetaMinimax(
       game: Game,
       depth: Int,
       alpha: Int,
       beta: Int,
       isMaximizing: Bool
   ) -> Int
   ```

2. **Евалуација позиције**
   - Бројање валидних потеза
   - Тежински фактори:
     - Централне позиције: 3x
     - Угаоне позиције: 2x
     - Остале позиције: 1x

### 3. Кориснички интерфејс
#### ViewModel архитектура
1. **GameViewModel**
   - Управља стањем игре
   - Обрађује корисничке интеракције
   - Координира AI потезе

2. **SettingsViewModel**
   - Управља подешавањима игре
   - Перзистентност подешавања
   - Валидација улаза

#### SwiftUI компоненте
1. **GameBoardView**
   ```swift
   struct GameBoardView: View {
       @ObservedObject var viewModel: GameViewModel
       let board: GameBoard
   }
   ```

2. **GameCellView**
   ```swift
   struct GameCellView: View {
       let cell: BoardCell
       let action: () -> Void
   }
   ```

### 4. Перзистентност података
#### CoreData модел
1. **GameEntity**
   - Сачувана партија
   - Статистика игре
   - Подешавања

2. **StatisticsEntity**
   - Историја игара
   - Проценти победа
   - Времена игара

### 5. Правила игре - детаљна имплементација

#### Валидација потеза
```swift
func isValidMove(at position: Position) -> Bool {
    // Провера да ли је позиција у границама
    guard position.row >= 0 && position.row < size &&
          position.col >= 0 && position.col < size else {
        return false
    }
    
    // Провера да ли је ћелија празна
    guard cells[position.row][position.col].type == .empty else {
        return false
    }
    
    // Провера да ли је ћелија блокирана
    guard cells[position.row][position.col].type != .blocked else {
        return false
    }
    
    return true
}
```

#### Блокирање суседних ћелија
```swift
func blockAdjacentCells(at position: Position) {
    let directions = [
        (-1, 0), // горе
        (1, 0),  // доле
        (0, -1), // лево
        (0, 1)   // десно
    ]
    
    for (rowOffset, colOffset) in directions {
        let newRow = position.row + rowOffset
        let newCol = position.col + colOffset
        
        if isValidPosition(row: newRow, col: newCol) {
            cells[newRow][newCol].type = .blocked
        }
    }
}
```

#### Провера краја игре
```swift
func checkGameEnd() -> Bool {
    // Провера да ли има валидних потеза
    for row in 0..<size {
        for col in 0..<size {
            if isValidMove(at: Position(row: row, col: col)) {
                return false
            }
        }
    }
    return true
}
```

### 6. Оптимизације

#### Кеширање AI позиција
```swift
func getCacheKey(for game: Game) -> String {
    var key = ""
    for row in 0..<game.board.size {
        for col in 0..<game.board.size {
            key += String(describing: game.board.cells[row][col].type)
        }
    }
    return key
}
```

#### Асинхроно процесирање AI потеза
```swift
func makeAIMove() async {
    let move = await Task.detached {
        self.search.findBestMove(for: self.game)
    }.value
    
    await MainActor.run {
        self.makeMove(at: move)
    }
}
```

### 7. Тестирање

#### Unit тестови
```swift
class GameTests: XCTestCase {
    func testValidMove() {
        let game = Game()
        let position = Position(row: 0, col: 0)
        XCTAssertTrue(game.board.isValidMove(at: position))
    }
    
    func testBlockAdjacentCells() {
        let game = Game()
        let position = Position(row: 1, col: 1)
        game.board.blockAdjacentCells(at: position)
        // Провере блокираних ћелија
    }
}
```

#### UI тестови
```swift
class GameUITests: XCTestCase {
    func testGameFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Симулирање потеза
        let cell = app.buttons["cell_0_0"]
        cell.tap()
        
        // Провере UI стања
        XCTAssertTrue(app.staticTexts["currentPlayer"].exists)
    }
}
```

### 8. Планирани развој

#### Фаза 1: Основна функционалност
- [x] Имплементација правила игре
- [x] Основни UI
- [x] AI играч са једним нивоом тежине

#### Фаза 2: Проширење функционалности
- [x] Додатни нивои тежине AI-а
- [x] Разне величине табле
- [x] Статистика игре

#### Фаза 3: Побољшања
- [ ] Онлајн режим
- [ ] Достигнућа
- [ ] Локализација
- [ ] Теме

#### Фаза 4: Финализација
- [ ] Оптимизација перформанси
- [ ] Тестирање
- [ ] Публиковање на App Store

### 9. Конвенције кодирања

#### Именовање
- Класе: PascalCase (Game, BoardCell)
- Методе: camelCase (makeMove, isValidMove)
- Променљиве: camelCase (currentPlayer, boardSize)
- Константе: UPPER_SNAKE_CASE (MAX_BOARD_SIZE)

#### Структура фајлова
```
Squart/
├── Models/
│   ├── GameModels.swift
│   └── AIPlayer.swift
├── Views/
│   ├── GameBoardView.swift
│   └── GameCellView.swift
├── ViewModels/
│   ├── GameViewModel.swift
│   └── SettingsViewModel.swift
└── Utils/
    ├── AICache.swift
    └── AIEvaluator.swift
```

### 10. Познати проблеми и решења

#### Проблем 1: Memory leak у AI компоненти
**Решење**: Коришћење weak self у closure-има
```swift
weak var self = self
DispatchQueue.main.async { [weak self] in
    self?.updateUI()
}
```

#### Проблем 2: UI блокирање током AI потеза
**Решење**: Асинхроно процесирање
```swift
func makeAIMove() async {
    await Task.detached {
        // AI логика
    }.value
}
```

### 11. Перформансе и оптимизације

#### Оптимизација AI претраге
- Кеширање позиција
- Алфа-бета одсецање
- Стратешко филтрирање потеза

#### Оптимизација UI
- Lazy loading компоненти
- Ефикасно ажурирање стања
- Оптимизоване анимације

### 12. Безбедност

#### Валидација улаза
```swift
func validateInput(_ input: String) -> Bool {
    // Провере безбедности
    return true
}
```

#### Заштита података
- Безбедно чување статистике
- Валидација AI параметара
- Заштита од краша 