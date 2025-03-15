import Foundation

/// Структура која чува податке о једном потезу АИ-ја
struct MoveAnalysis {
    let position: AIPosition
    let evaluationScore: Int
    let searchDepth: Int
    let nodesExplored: Int
    let timeSpent: TimeInterval
    let branchingFactor: Double
    let alphaCutoffs: Int
    let betaCutoffs: Int
}

/// Структура која представља позицију на табли за аналитику
struct AIPosition {
    let row: Int
    let col: Int
}

/// Класа за праћење перформанси АИ-ја
class AIAnalytics {
    static let shared = AIAnalytics()
    
    private var currentGameMoves: [MoveAnalysis] = []
    private var startTime: Date?
    private var nodeCount: Int = 0
    private var alphaCutoffs: Int = 0
    private var betaCutoffs: Int = 0
    private var maxDepthReached: Int = 0
    
    // WebSocket клијент за слање података
    private var webSocket: URLSessionWebSocketTask?
    
    private init() {
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        guard let url = URL(string: "ws://localhost:8080") else { return }
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
    
    /// Започиње праћење новог потеза
    func startMoveAnalysis() {
        startTime = Date()
        nodeCount = 0
        alphaCutoffs = 0
        betaCutoffs = 0
        maxDepthReached = 0
    }
    
    /// Бележи посету новом чвору у стаблу претраге
    func visitNode(depth: Int) {
        nodeCount += 1
        maxDepthReached = max(maxDepthReached, depth)
    }
    
    /// Бележи alpha одсецање
    func recordAlphaCutoff() {
        alphaCutoffs += 1
    }
    
    /// Бележи beta одсецање
    func recordBetaCutoff() {
        betaCutoffs += 1
    }
    
    /// Завршава анализу потеза и шаље податке
    func finishMoveAnalysis(position: AIPosition, evaluationScore: Int) {
        guard let start = startTime else { return }
        
        let timeSpent = Date().timeIntervalSince(start)
        let branchingFactor = pow(Double(nodeCount), 1.0 / Double(maxDepthReached))
        
        let analysis = MoveAnalysis(
            position: position,
            evaluationScore: evaluationScore,
            searchDepth: maxDepthReached,
            nodesExplored: nodeCount,
            timeSpent: timeSpent,
            branchingFactor: branchingFactor,
            alphaCutoffs: alphaCutoffs,
            betaCutoffs: betaCutoffs
        )
        
        currentGameMoves.append(analysis)
        sendAnalyticsData(analysis)
    }
    
    /// Шаље податке о анализи преко WebSocket-а
    private func sendAnalyticsData(_ analysis: MoveAnalysis) {
        let data: [String: Any] = [
            "position": ["row": analysis.position.row, "col": analysis.position.col],
            "evaluationScore": analysis.evaluationScore,
            "searchDepth": analysis.searchDepth,
            "nodesExplored": analysis.nodesExplored,
            "timeSpent": analysis.timeSpent,
            "branchingFactor": analysis.branchingFactor,
            "alphaCutoffs": analysis.alphaCutoffs,
            "betaCutoffs": analysis.betaCutoffs
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocket?.send(message) { error in
                    if let error = error {
                        print("WebSocket грешка: \(error)")
                    }
                }
            }
        } catch {
            print("JSON грешка: \(error)")
        }
    }
    
    /// Ресетује статистику за нову игру
    func resetGameStats() {
        currentGameMoves.removeAll()
    }
    
    /// Враћа статистику за тренутну игру
    func getCurrentGameStats() -> [MoveAnalysis] {
        return currentGameMoves
    }
} 