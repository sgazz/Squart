import SwiftUI

struct ContentView: View {
    @StateObject private var game = Game(boardSize: 8, boardType: .regular)
    @State private var showSettings = false
    @State private var selectedBoardType: BoardType = .regular
    
    var body: some View {
        ZStack {
            // Позадина
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Наслов игре
                Text("Squart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // Информације о играчима и резултату
                HStack {
                    PlayerInfoView(player: .blue, score: game.blueScore, isCurrentPlayer: game.currentPlayer == .blue)
                    Spacer()
                    PlayerInfoView(player: .red, score: game.redScore, isCurrentPlayer: game.currentPlayer == .red)
                }
                .padding(.horizontal)
                
                // Табла за игру
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        BoardView(game: game, onCellTap: { position in
                            game.makeMove(at: position)
                        })
                        .frame(width: min(geometry.size.width, geometry.size.height) * 0.9,
                               height: min(geometry.size.width, geometry.size.height) * 0.9)
                        .padding()
                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                }
                
                // Контролни дугмићи
                HStack {
                    Button(action: {
                        game.resetGame()
                    }) {
                        Label("Нова игра", systemImage: "arrow.counterclockwise")
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Label("Подешавања", systemImage: "gear")
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .foregroundColor(.white)
                .padding()
            }
            
            // Порука о крају игре
            if game.gameOver {
                GameOverView(winner: game.winner, blueScore: game.blueScore, redScore: game.redScore) {
                    game.resetGame()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(game: game, selectedBoardType: $selectedBoardType)
        }
    }
}

struct PlayerInfoView: View {
    let player: Player
    let score: Int
    let isCurrentPlayer: Bool
    
    var body: some View {
        VStack {
            Text(player.name)
                .font(.headline)
                .foregroundColor(player.color)
            
            Text("\(score)")
                .font(.title)
                .foregroundColor(.white)
            
            if isCurrentPlayer {
                Text("На потезу")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(player.color.opacity(0.6))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isCurrentPlayer ? player.color : Color.clear, lineWidth: 2)
        )
    }
}

struct GameOverView: View {
    let winner: Player?
    let blueScore: Int
    let redScore: Int
    let onNewGame: () -> Void
    
    var body: some View {
        VStack {
            Text("Крај игре!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            if let winner = winner {
                Text("\(winner.name) је победио!")
                    .font(.headline)
                    .foregroundColor(winner.color)
            } else {
                Text("Нерешено!")
                    .font(.headline)
            }
            
            Text("Резултат: \(blueScore) - \(redScore)")
                .padding()
            
            Button("Нова игра") {
                onNewGame()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
        }
        .frame(width: 300, height: 250)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct SettingsView: View {
    @ObservedObject var game: Game
    @Binding var selectedBoardType: BoardType
    @Environment(\.presentationMode) var presentationMode
    @State private var boardSize: Double
    
    init(game: Game, selectedBoardType: Binding<BoardType>) {
        self.game = game
        self._selectedBoardType = selectedBoardType
        self._boardSize = State(initialValue: Double(game.boardSize))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Величина табле")) {
                    VStack {
                        Slider(value: $boardSize, in: 6...12, step: 1)
                        Text("\(Int(boardSize)) x \(Int(boardSize))")
                            .font(.headline)
                    }
                }
                
                Section(header: Text("Тип табле")) {
                    Picker("Тип табле", selection: $selectedBoardType) {
                        Text("Регуларна").tag(BoardType.regular)
                        Text("Троугаона").tag(BoardType.triangular)
                        Text("Шестоугаона").tag(BoardType.hexagonal)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Примени") {
                        applySettings()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Подешавања")
        }
    }
    
    private func applySettings() {
        game.boardSize = Int(boardSize)
        game.boardType = selectedBoardType
        game.resetGame()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 