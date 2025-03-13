# API документација

## Преглед

Squart API пружа програмски интерфејс за интеграцију Squart игре у друге апликације. API је организован око следећих главних компоненти:

## Модели

### Game

Представља стање игре.

```swift
class Game {
    var board: GameBoard
    var currentPlayer: Player
    var isGameOver: Bool
    var winner: Player?
    
    func makeMove(row: Int, column: Int) -> Bool
    func undoLastMove() -> Bool
    func reset()
}
```

### GameBoard

Представља таблу за игру.

```swift
class GameBoard {
    let size: Int
    var cells: [[Cell]]
    
    func isValidMove(row: Int, column: Int, player: Player) -> Bool
    func makeMove(row: Int, column: Int, player: Player) -> Bool
    func clearCell(row: Int, column: Int)
}
```

### AIPlayer

Имплементира вештачку интелигенцију.

```swift
class AIPlayer {
    let difficulty: AIDifficulty
    
    func generateMove(board: [[Int]], currentPlayer: Int, boardSize: Int) -> (row: Int, column: Int)?
    func findBestMove(for game: Game) -> (row: Int, column: Int)?
}
```

## Енумерације

### AIDifficulty

```swift
enum AIDifficulty: Int, CaseIterable, Codable {
    case easy = 0
    case medium = 1
    case hard = 2
}
```

### Player

```swift
enum Player: Int, Codable {
    case blue = 1
    case red = 2
    
    var isHorizontal: Bool
}
```

## Протоколи

### GameStorage

```swift
protocol GameStorage {
    func saveGame(_ game: Game, withId id: String) throws
    func loadGame(withId id: String) throws -> Game
    func deleteGame(withId id: String) throws
    func listSavedGames() throws -> [String]
}
```

## Примери коришћења

### Креирање нове игре

```swift
let game = Game(boardSize: 7)
```

### Играње потеза

```swift
if game.makeMove(row: 0, column: 0) {
    print("Потез успешно одигран")
} else {
    print("Неважећи потез")
}
```

### Коришћење AI играча

```swift
let ai = AIPlayer(difficulty: .medium)
if let move = ai.generateMove(board: game.board.cells, currentPlayer: game.currentPlayer.rawValue, boardSize: game.board.size) {
    _ = game.makeMove(row: move.row, column: move.column)
}
```

### Чување игре

```swift
let storage = FileGameStorage()
try storage.saveGame(game, withId: "game1")
```

## Обрада грешака

API користи Swift's `Error` протокол за обраду грешака. Главне грешке су:

```swift
enum GameError: Error {
    case invalidMove
    case gameOver
    case invalidBoardSize
    case storageError
}
```

## Перформансе

- AI генерисање потеза: < 1s за табле до 10x10
- Чување/учитавање игре: < 100ms
- Меморијско заузеће: ~10MB за стандардну игру

## Ограничења

- Максимална величина табле: 30x30
- Максимално време за AI потез: 2s
- Максимална величина сачуване игре: 1MB

## Безбедност

- Сви подаци се чувају локално
- Нема мрежне комуникације
- Сигурно руковање корисничким подацима

## Верзионирање

API прати семантичко верзионирање (MAJOR.MINOR.PATCH).

## Будуће измене

- Подршка за онлајн игру
- Додатни AI алгоритми
- Статистика игре
- Репродукција партија 