import SwiftUI

// Секција за избор првог играча
private struct FirstPlayerPickerView: View {
    @ObservedObject var settings: GameSettingsManager
    
    var body: some View {
        HStack(spacing: 12) {
            Text("First Player")
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { settings.firstPlayer = .blue }) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 30)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(settings.firstPlayer == .blue ? Color.white : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: settings.firstPlayer == .blue ? Color.blue.opacity(0.5) : .clear, radius: 5)
            }
            
            Button(action: { settings.firstPlayer = .red }) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 60, height: 30)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(settings.firstPlayer == .red ? Color.white : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: settings.firstPlayer == .red ? Color.red.opacity(0.5) : .clear, radius: 5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Секција за AI подешавања
private struct AISettingsView: View {
    @ObservedObject var settings: GameSettingsManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text("AI Opponent")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Toggle("", isOn: $settings.aiEnabled)
                    .labelsHidden()
                    .tint(.blue)
            }
            .frame(maxWidth: .infinity)
            
            if settings.aiEnabled {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Text("AI Team")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: { settings.aiTeam = .blue }) {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 20)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(settings.aiTeam == .blue ? Color.white : Color.clear, lineWidth: 2)
                                )
                        }
                        
                        Button(action: { settings.aiTeam = .red }) {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 40, height: 20)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(settings.aiTeam == .red ? Color.white : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Menu {
                            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                Button(action: { settings.aiDifficulty = difficulty }) {
                                    HStack {
                                        Text(difficulty.localizedString)
                                        if settings.aiDifficulty == difficulty {
                                            Image(systemName: "checkmark")
                                        }
                                        Spacer()
                                        difficultyStars(for: difficulty)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "cpu")
                                    .foregroundColor(.blue)
                                Text(settings.aiDifficulty.localizedString)
                                    .font(.system(size: 14, weight: .medium))
                                difficultyStars(for: settings.aiDifficulty)
                                    .foregroundColor(.yellow)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Text("AI vs AI")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.aiVsAiMode)
                            .labelsHidden()
                            .tint(.blue)
                    }
                    
                    if settings.aiVsAiMode {
                        Menu {
                            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                Button(action: { settings.secondAiDifficulty = difficulty }) {
                                    HStack {
                                        Text(difficulty.localizedString)
                                        if settings.secondAiDifficulty == difficulty {
                                            Image(systemName: "checkmark")
                                        }
                                        Spacer()
                                        difficultyStars(for: difficulty)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "cpu")
                                    .foregroundColor(.red)
                                Text(settings.secondAiDifficulty.localizedString)
                                    .font(.system(size: 14, weight: .medium))
                                difficultyStars(for: settings.secondAiDifficulty)
                                    .foregroundColor(.yellow)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
    }
    
    private func difficultyStars(for difficulty: AIDifficulty) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<difficulty.stars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.caption)
            }
        }
    }
}

// Секција за величину табле
private struct BoardSizePickerView: View {
    @ObservedObject var settings: GameSettingsManager
    @ObservedObject var game: Game
    
    private let sizes = Array(5...20)
    
    var body: some View {
        HStack(spacing: 12) {
            Text("Board Size")
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
            
            Menu {
                ForEach(sizes, id: \.self) { size in
                    Button(action: {
                        settings.boardSize = size
                        game.board = GameBoard(size: size)
                    }) {
                        HStack {
                            Text("\(size)×\(size)")
                            if settings.boardSize == size {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text("\(settings.boardSize)×\(settings.boardSize)")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .frame(width: 80)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Секција за тајмер
private struct TimerPickerView: View {
    @ObservedObject var settings: GameSettingsManager
    @State private var isTimerEnabled = false
    
    private let options = [
        (TimerOption.oneMinute, "1 min"),
        (TimerOption.twoMinutes, "2 min"),
        (TimerOption.threeMinutes, "3 min"),
        (TimerOption.fiveMinutes, "5 min")
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            Text("Timer")
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
            
            Toggle("", isOn: $isTimerEnabled)
                .labelsHidden()
                .tint(.blue)
                .onChange(of: isTimerEnabled) { newValue in
                    settings.timerOption = newValue ? .oneMinute : .none
                }
            
            if isTimerEnabled {
                Menu {
                    ForEach(options, id: \.0) { option in
                        Button(action: { settings.timerOption = option.0 }) {
                            HStack {
                                Text(option.1)
                                if settings.timerOption == option.0 {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(options.first { $0.0 == settings.timerOption }?.1 ?? "1 min")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .frame(width: 80)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isTimerEnabled = settings.timerOption != .none
        }
    }
}

struct QuickSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var game: Game
    @ObservedObject var settings: GameSettingsManager
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, game: Game) {
        self._isPresented = isPresented
        self.game = game
        self.settings = GameSettingsManager.shared
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Quick Setup")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        FirstPlayerPickerView(settings: settings)
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                        
                        BoardSizePickerView(settings: settings, game: game)
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                        
                        TimerPickerView(settings: settings)
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                        
                        AISettingsView(settings: settings)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 400)
                
                // Footer
                Button(action: {
                    startGame()
                }) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.blue, .red]), 
                                         startPoint: .leading, 
                                         endPoint: .trailing)
                                .cornerRadius(10)
                        )
                }
                .keyboardShortcut(.return, modifiers: [])
                .padding()
                .background(Color.white.opacity(0.05))
            }
            .frame(width: 300)
            .background(Color(.systemGray6).opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
        }
        .padding()
    }
    
    private func startGame() {
        // Primeni veličinu table
        game.board = GameBoard(size: settings.boardSize)
        
        // Primeni podešavanja tajmera
        game.timerOption = settings.timerOption
        
        // Primeni AI podešavanja
        game.aiEnabled = settings.aiEnabled
        if settings.aiEnabled {
            game.aiVsAiMode = settings.aiVsAiMode
            game.secondAiDifficulty = settings.secondAiDifficulty
            game.initializeAI(difficulty: settings.aiDifficulty, team: settings.aiTeam)
        }
        
        // Postavi prvog igrača
        game.currentPlayer = settings.firstPlayer
        
        // Resetuj igru
        game.resetGame()
        
        // Ako je AI vs AI mod i AI je na potezu, pokreni prvi potez
        if settings.aiEnabled && game.aiVsAiMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                game.makeAIMove()
            }
        }
        
        // Zatvori setup view
        withAnimation(.spring()) {
            isPresented = false
        }
    }
}

#Preview {
    QuickSetupView(isPresented: .constant(true), game: Game())
        .preferredColorScheme(.dark)
} 
