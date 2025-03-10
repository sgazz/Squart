import SwiftUI

struct GameControlsView: View {
    @ObservedObject var game: Game
    @State private var showingSettings = false
    @State private var selectedSize = GameSettings.defaultBoardSize
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Status igre
            GameStatusView(game: game, showConfetti: $showConfetti)
            
            // Kontrole
            GameButtonsView(game: game, showingSettings: $showingSettings, showConfetti: $showConfetti)
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingSettings) {
            SettingsView(selectedSize: $selectedSize, game: game)
        }
    }
}

// Izdvojena komponenta za prikaz statusa igre
struct GameStatusView: View {
    @ObservedObject var game: Game
    @Binding var showConfetti: Bool
    @ObservedObject var settings = GameSettingsManager.shared
    
    var body: some View {
        HStack {
            PlayerScoreView(player: .blue, score: game.blueScore)
            Spacer()
            if game.isGameOver {
                VStack(spacing: 4) {
                    Text(gameOverMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        
                    Text(winnerMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(8)
                .overlay(
                    showConfetti ? ConfettiView() : nil
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            showConfetti = true
                        }
                    }
                }
            } else {
                VStack {
                    Text("Na potezu: \(game.currentPlayer == .blue ? "Plavi" : "Crveni")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(game.currentPlayer == .blue ? Color.blue.opacity(0.3) : Color.red.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(
                            game.aiEnabled ? 
                            Text(getAIStatusText())
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(4)
                                .offset(y: 20)
                            : nil
                        )
                    
                    // ML status indikator (prikazuje se samo ako je ML uključen i treba da se prikaže)
                    if game.useMachineLearning && settings.showMLFeedback {
                        Text("ML aktivno")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.5))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.purple, lineWidth: 1)
                            )
                            .padding(.top, 4)
                    }
                }
            }
            Spacer()
            PlayerScoreView(player: .red, score: game.redScore)
        }
    }
    
    // Tekst za AI status
    private func getAIStatusText() -> String {
        if game.aiVsAiMode {
            let mlTag = game.useMachineLearning ? " (ML)" : ""
            return "AI\(mlTag) (\(game.currentPlayer == .blue ? "plavi" : "crveni")) razmišlja"
        } else {
            return game.currentPlayer == game.aiTeam ? 
                   "AI\(game.useMachineLearning ? " (ML)" : "") na potezu" : 
                   "Vi ste na potezu"
        }
    }
    
    // Poruka za kraj igre u zavisnosti od razloga završetka
    private var gameOverMessage: String {
        switch game.gameEndReason {
        case .noValidMoves:
            return "Nema validnih poteza!"
        case .blueTimeout:
            return "Isteklo vreme plavom igraču!"
        case .redTimeout:
            return "Isteklo vreme crvenom igraču!"
        case .none:
            return "Igra je završena!"
        }
    }
    
    // Poruka o pobedniku
    private var winnerMessage: String {
        let lastPlayer = game.currentPlayer == .blue ? Player.red : Player.blue
        return "Pobednik: \(lastPlayer == .blue ? "Plavi" : "Crveni")"
    }
}

// Izdvojena komponenta za dugmiće
struct GameButtonsView: View {
    @ObservedObject var game: Game
    @Binding var showingSettings: Bool
    @Binding var showConfetti: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                showingSettings = true
            }) {
                Text("Podešavanja")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Button(action: {
                withAnimation {
                    showConfetti = false
                    game.resetGame()
                }
            }) {
                Text("Nova igra")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}

struct PlayerScoreView: View {
    let player: Player
    let score: Int
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(player == .blue ? Color.blue : Color.red)
                .frame(width: 30, height: 30)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 3)
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    init() {
        // Kreiraj inicijalne čestice
        var initialParticles: [ConfettiParticle] = []
        for _ in 0..<50 {
            initialParticles.append(ConfettiParticle.random(colors: colors))
        }
        _particles = State(initialValue: initialParticles)
    }
    
    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                ConfettiParticleView(particle: particles[index], isAnimating: isAnimating)
            }
        }
        .allowsHitTesting(false) // Ignorišemo dodire
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isAnimating = true
            }
        }
    }
}

struct ConfettiParticle {
    let position: CGPoint
    let color: Color
    let rotation: Double
    let scale: CGFloat
    
    static func random(colors: [Color]) -> ConfettiParticle {
        let randomX = CGFloat.random(in: 0...1)
        let randomY = CGFloat.random(in: -0.1...0.1)
        let randomRotation = Double.random(in: 0...360)
        let randomScale = CGFloat.random(in: 0.4...1.0)
        let randomColor = colors.randomElement() ?? .blue
        
        return ConfettiParticle(
            position: CGPoint(x: randomX, y: randomY),
            color: randomColor,
            rotation: randomRotation,
            scale: randomScale
        )
    }
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    let isAnimating: Bool
    
    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: 5, height: 10)
            .scaleEffect(particle.scale)
            .position(
                x: particle.position.x * UIScreen.main.bounds.width,
                y: isAnimating ? 
                    UIScreen.main.bounds.height * (1 + particle.position.y) : 
                    -10
            )
            .rotationEffect(.degrees(isAnimating ? particle.rotation + 360 : particle.rotation))
            .opacity(isAnimating ? 0 : 1)
    }
}

struct SettingsView: View {
    @Binding var selectedSize: Int
    @ObservedObject var game: Game
    @ObservedObject var settings = GameSettingsManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                BoardSizeSection(selectedSize: $selectedSize)
                
                ThemeSection(settings: settings)
                
                TimerSection(settings: settings)
                
                OpponentSection(game: game, settings: settings)
                
                MLSection(settings: settings)
                
                SoundSection(settings: settings)
                
                ApplySettingsSection(selectedSize: selectedSize, game: game, settings: settings, dismiss: dismiss)
            }
            .navigationTitle("Podešavanja")
            .navigationBarItems(trailing: Button("Zatvori") {
                dismiss()
            })
        }
    }
}

// Izdvojena sekcija za veličinu table
struct BoardSizeSection: View {
    @Binding var selectedSize: Int
    
    var body: some View {
        Section(header: Text("Veličina table")) {
            Picker("Veličina", selection: $selectedSize) {
                ForEach(GameSettings.minBoardSize...GameSettings.maxBoardSize, id: \.self) { size in
                    Text("\(size)x\(size)")
                }
            }
        }
    }
}

// Izdvojena sekcija za temu
struct ThemeSection: View {
    @ObservedObject var settings: GameSettingsManager
    
    var body: some View {
        Section(header: Text("Izgled")) {
            Picker("Tema", selection: $settings.currentTheme) {
                ForEach(ThemeType.allCases, id: \.self) { theme in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: theme.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 50, height: 24)
                        Text(theme.rawValue)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

// Izdvojena sekcija za tajmer
struct TimerSection: View {
    @ObservedObject var settings: GameSettingsManager
    
    var body: some View {
        Section(header: Text("Vreme za potez")) {
            Picker("Ograničenje vremena", selection: $settings.timerOption) {
                ForEach(TimerOption.allCases, id: \.self) { option in
                    Text(option.description)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

// Izdvojena sekcija za protivnika (AI)
struct OpponentSection: View {
    @ObservedObject var game: Game
    @ObservedObject var settings: GameSettingsManager
    
    var body: some View {
        Section(header: Text("Protivnik")) {
            Toggle("Igraj protiv računara", isOn: $settings.aiEnabled)
            
            if settings.aiEnabled {
                Picker("Težina", selection: $settings.aiDifficulty) {
                    ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.description)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("AI tim", selection: $settings.aiTeam) {
                    Text("Plavi").tag(Player.blue)
                    Text("Crveni").tag(Player.red)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle("AI vs AI mod", isOn: $settings.aiVsAiMode)
                
                if settings.aiVsAiMode {
                    Picker("Težina drugog AI", selection: $settings.secondAiDifficulty) {
                        ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.description)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Text("Prvi na potezu: \(game.startingPlayer == .blue ? "Plavi" : "Crveni")")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

// Izdvojena sekcija za zvuk
struct SoundSection: View {
    @ObservedObject var settings: GameSettingsManager
    
    var body: some View {
        Section(header: Text("Zvuk i vibracija")) {
            Toggle("Zvučni efekti", isOn: $settings.soundEnabled)
            Toggle("Vibracija", isOn: $settings.hapticFeedbackEnabled)
        }
    }
}

// Izdvojena sekcija za primenu podešavanja
struct ApplySettingsSection: View {
    let selectedSize: Int
    @ObservedObject var game: Game
    @ObservedObject var settings: GameSettingsManager
    var dismiss: DismissAction
    
    var body: some View {
        Section {
            Button("Primeni i započni novu igru") {
                game.board = GameBoard(size: selectedSize)
                
                // Postavljamo ML opciju
                game.useMachineLearning = settings.useMachineLearning
                
                // Inicijalizacija AI ako je uključen
                if settings.aiEnabled {
                    game.aiVsAiMode = settings.aiVsAiMode
                    game.secondAiDifficulty = settings.secondAiDifficulty
                    game.initializeAI(difficulty: settings.aiDifficulty, team: settings.aiTeam)
                    
                    // Za AI vs AI mod, odmah pokrećemo igru ako je AI na potezu
                    if game.aiVsAiMode {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            game.makeAIMove()
                        }
                    }
                }
                
                game.resetGame()
                dismiss()
            }
            .foregroundColor(.blue)
        }
    }
}

// Nova sekcija za ML podešavanja
struct MLSection: View {
    @ObservedObject var settings: GameSettingsManager
    @State private var showMLInfo = false
    @State private var showExportSheet = false
    @State private var exportURL: URL? = nil
    @State private var showConfirmClear = false
    
    var body: some View {
        Section(header: Text("Mašinsko učenje (ML)")) {
            Toggle("Koristi Mašinsko Učenje", isOn: $settings.useMachineLearning)
                .onChange(of: settings.useMachineLearning) { newValue in
                    if newValue && !MLPositionEvaluator.shared.isMLReady {
                        MLPositionEvaluator.shared.prepareModel()
                    }
                }
            
            if settings.useMachineLearning {
                Toggle("Prikaži ML povratne informacije", isOn: $settings.showMLFeedback)
                
                HStack {
                    Text("Status ML modela:")
                    Spacer()
                    Text(MLPositionEvaluator.shared.isMLReady ? "Aktivan" : "Nije učitan")
                        .foregroundColor(MLPositionEvaluator.shared.isMLReady ? .green : .gray)
                }
                
                HStack {
                    Text("Snimljene partije:")
                    Spacer()
                    Text("\(GameDataCollector.shared.gameRecords.count)")
                }
                
                Button(action: {
                    exportURL = GameDataCollector.shared.exportTrainingData()
                    showExportSheet = exportURL != nil
                }) {
                    Label("Izvezi podatke za treniranje", systemImage: "square.and.arrow.up")
                }
                .sheet(isPresented: $showExportSheet) {
                    if let url = exportURL {
                        NavigationView {
                            VStack(spacing: 20) {
                                Text("Podaci su izvezeni")
                                    .font(.headline)
                                
                                Text("Lokacija fajla:")
                                Text(url.path)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(8)
                                    .background(Color.black.opacity(0.05))
                                    .cornerRadius(4)
                                
                                Text("Koristite ove podatke sa Python skriptom za treniranje ML modela.")
                                
                                Spacer()
                            }
                            .padding()
                            .navigationBarItems(trailing: Button("Zatvori") {
                                showExportSheet = false
                            })
                        }
                    }
                }
                
                Button(action: {
                    showConfirmClear = true
                }) {
                    Label("Očisti podatke treninga", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showConfirmClear) {
                    Alert(
                        title: Text("Obriši podatke za trening"),
                        message: Text("Da li ste sigurni da želite obrisati sve podatke prikupljene za trening ML modela?"),
                        primaryButton: .destructive(Text("Obriši")) {
                            GameDataCollector.shared.clearAllGameRecords()
                        },
                        secondaryButton: .cancel(Text("Otkaži"))
                    )
                }
                
                Button(action: {
                    showMLInfo = true
                }) {
                    Label("O mašinskom učenju", systemImage: "info.circle")
                }
                .sheet(isPresented: $showMLInfo) {
                    MLInfoView()
                }
            } else {
                Text("ML daje AI igraču naprednu sposobnost da uči iz partija i donosi bolje odluke.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Prikaz informacija o ML-u
struct MLInfoView: View {
    @Environment(\.dismiss) var dismiss
    @State private var trainingStats: String = "Učitavanje..."
    @State private var isMLReady: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("O mašinskom učenju")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Squart koristi mašinsko učenje za unapređenje AI igrača. Kada je opcija ML uključena, AI će koristiti neuronsku mrežu za procenu pozicije i donošenje odluka.")
                    
                    Text("Trenutni status")
                        .font(.headline)
                    
                    HStack {
                        Text("ML model:")
                        Spacer()
                        Text(isMLReady ? "Spreman" : "Nije dostupan")
                            .foregroundColor(isMLReady ? .green : .red)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                    
                    Text("Statistika treninga")
                        .font(.headline)
                    
                    Text(trainingStats)
                        .font(.system(.body, design: .monospaced))
                        .padding(10)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                    
                    Text("Kako radi")
                        .font(.headline)
                    
                    Text("1. Prikupljanje podataka: Tokom igranja, aplikacija beleži vaše poteze i poteze AI igrača.")
                    Text("2. Treniranje: Prikupljeni podaci se mogu izvesti i koristiti za treniranje ML modela.")
                    Text("3. Predviđanje: Trenirani model može da proceni kvalitet različitih poteza i pomogne AI da donese bolje odluke.")
                    
                    Text("Privatnost")
                        .font(.headline)
                    
                    Text("Svi podaci se čuvaju lokalno na vašem uređaju. Možete ih izvesti za analizu ili obrisati u bilo kom trenutku.")
                    
                    Text("Napredne opcije")
                        .font(.headline)
                    
                    Text("Za napredne korisnike, moguće je trenirati sopstveni model koristeći izvezene podatke i Python skriptu koju obezbeđujemo.")
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Zatvori") {
                dismiss()
            })
            .onAppear {
                // Učitavamo statistiku na pojavi ekrana
                trainingStats = GameDataCollector.shared.getTrainingStats()
                isMLReady = MLPositionEvaluator.shared.isMLReady
            }
        }
    }
}

#Preview {
    GameControlsView(game: Game())
        .padding()
        .background(Color.black.opacity(0.8))
} 