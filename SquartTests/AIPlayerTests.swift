import XCTest
@testable import Squart

final class AIPlayerTests: XCTestCase {
    // MARK: - Test Properties
    private let boardSizes = [6, 8, 10, 12]
    private let difficulties: [AIDifficulty] = [.easy, .medium, .hard]
    
    // MARK: - Test Methods
    func testAIPerformance() {
        print("\n=== Početak testiranja AI performansi ===\n")
        
        for boardSize in boardSizes {
            print("\n--- Testiranje na tabli \(boardSize)x\(boardSize) ---")
            
            for difficulty in difficulties {
                print("\nTežina: \(difficulty.description)")
                
                // Kreiramo novu igru
                let game = Game(boardSize: boardSize)
                let ai = AIPlayer(difficulty: difficulty)
                
                // Testiramo prvi potez
                let startTime = Date()
                let move = ai.findBestMove(for: game)
                let timeElapsed = Date().timeIntervalSince(startTime)
                
                // Proveravamo da li je potez validan
                XCTAssertNotNil(move, "AI treba da pronađe validan potez")
                if let move = move {
                    XCTAssertTrue(game.board.isValidMove(row: move.row, column: move.column, player: game.currentPlayer),
                                "Pronađeni potez mora biti validan")
                }
            }
        }
        
        print("\n=== Kraj testiranja AI performansi ===\n")
    }
    
    func testAIConsistency() {
        print("\n=== Početak testiranja AI konzistentnosti ===\n")
        
        for boardSize in boardSizes {
            print("\n--- Testiranje na tabli \(boardSize)x\(boardSize) ---")
            
            for difficulty in difficulties {
                print("\nTežina: \(difficulty.description)")
                
                // Kreiramo novu igru
                let game = Game(boardSize: boardSize)
                let ai = AIPlayer(difficulty: difficulty)
                
                // Testiramo isti potez više puta
                var moves: Set<String> = []
                for _ in 0..<5 {
                    if let move = ai.findBestMove(for: game) {
                        moves.insert("\(move.row),\(move.column)")
                    }
                }
                
                // Za težak nivo, očekujemo konzistentnost
                if difficulty == .hard {
                    XCTAssertEqual(moves.count, 1, "Težak AI treba da bude konzistentan u svojim potezima")
                }
                
                print("Broj različitih poteza: \(moves.count)")
            }
        }
        
        print("\n=== Kraj testiranja AI konzistentnosti ===\n")
    }
    
    func testAITimeConstraints() {
        print("\n=== Početak testiranja AI vremenskih ograničenja ===\n")
        
        for boardSize in boardSizes {
            print("\n--- Testiranje na tabli \(boardSize)x\(boardSize) ---")
            
            for difficulty in difficulties {
                print("\nTežina: \(difficulty.description)")
                
                // Kreiramo novu igru
                let game = Game(boardSize: boardSize)
                let ai = AIPlayer(difficulty: difficulty)
                
                // Testiramo vreme razmišljanja
                let startTime = Date()
                _ = ai.findBestMove(for: game)
                let timeElapsed = Date().timeIntervalSince(startTime)
                
                // Proveravamo da li je vreme u prihvatljivim granicama
                let maxTime: TimeInterval
                switch difficulty {
                case .easy:
                    maxTime = 0.1
                case .medium:
                    maxTime = 1.0
                case .hard:
                    maxTime = 2.0
                }
                
                XCTAssertLessThan(timeElapsed, maxTime,
                                "AI je prekoračio maksimalno dozvoljeno vreme razmišljanja")
                
                print("Vreme razmišljanja: \(String(format: "%.2f", timeElapsed))s")
            }
        }
        
        print("\n=== Kraj testiranja AI vremenskih ograničenja ===\n")
    }
} 