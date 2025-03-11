import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSection: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Glavni naslov sa animacijom
                    Text("how_to_play".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 16)
                        .transition(.scale.combined(with: .opacity))
                    
                    // Brzi pristup sekcijama
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["about_game", "game_rules", "how_to_win", "ai_opponent", "game_tips"], id: \.self) { section in
                                Button(action: {
                                    withAnimation {
                                        selectedSection = section
                                    }
                                }) {
                                    Text(section.localized)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedSection == section ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                    // Osnovni opis igre
                    HelpSection(title: "about_game".localized, icon: "gamecontroller") {
                        Text("about_game_text".localized)
                            .padding(.bottom, 8)
                            
                        Text("board_description".localized)
                            .padding(.bottom, 8)
                    }
                    
                    // Pravila igre
                    HelpSection(title: "game_rules".localized, icon: "list.bullet.clipboard") {
                        RuleItem(text: "rules_blue_first".localized)
                        RuleItem(text: "rules_blue_move".localized)
                        RuleItem(text: "rules_red_move".localized)
                        RuleItem(text: "rules_alternating".localized)
                        RuleItem(text: "rules_blocked_fields".localized)
                        RuleItem(text: "rules_valid_move".localized)
                        RuleItem(text: "rules_time_limit".localized)
                    }
                    
                    // Kako pobediti
                    HelpSection(title: "how_to_win".localized, icon: "trophy") {
                        Text("win_ways".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        RuleItem(text: "win_no_moves".localized)
                        RuleItem(text: "win_timeout".localized)
                    }
                    
                    // AI protivnik
                    HelpSection(title: "ai_opponent".localized, icon: "cpu") {
                        Text("ai_intro".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        RuleItem(text: "ai_settings".localized)
                        RuleItem(text: "ai_team_select".localized)
                        RuleItem(text: "ai_difficulty".localized)
                        RuleItem(text: "ai_first_move".localized)
                        RuleItem(text: "ai_turn_wait".localized)
                        RuleItem(text: "ai_vs_ai_mode".localized)
                        RuleItem(text: "ai_vs_ai_difficulty".localized)
                        RuleItem(text: "ai_advanced".localized)
                        RuleItem(text: "ai_vs_ai_learning".localized)
                    }
                    
                    // Saveti za igru
                    HelpSection(title: "game_tips".localized, icon: "lightbulb") {
                        RuleItem(text: "tips_planning".localized)
                        RuleItem(text: "tips_blocking".localized)
                        RuleItem(text: "tips_edges".localized)
                        RuleItem(text: "tips_blocked_fields".localized)
                        RuleItem(text: "tips_corners".localized)
                        RuleItem(text: "tips_valid_moves".localized)
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.45),
                        Color(red: 0.3, green: 0.4, blue: 0.6),
                        Color(red: 0.5, green: 0.2, blue: 0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("help".localized, displayMode: .inline)
            .navigationBarItems(trailing: Button("close".localized) {
                dismiss()
            })
            .preferredColorScheme(.dark)
        }
    }
}

// Pomoćne strukture za bolju organizaciju koda
struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 4)
            
            content
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
}

struct RuleItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .padding(.top, 8)
            Text(text)
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    HelpView()
} 