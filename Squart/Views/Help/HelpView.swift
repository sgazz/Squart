import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSection: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Main title with animation
                    Text("How to Play")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 16)
                        .transition(.scale.combined(with: .opacity))
                    
                    // Quick access sections
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["About", "Rules", "Winning", "AI", "Tips"], id: \.self) { section in
                                Button(action: {
                                    withAnimation {
                                        selectedSection = section
                                    }
                                }) {
                                    Text(section)
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
                    
                    // Basic game description
                    HelpSection(title: "About", icon: "gamecontroller") {
                        Text("Squart is an innovative strategy game based on spatial thinking, where each move changes the course of the game as you try to outmaneuver your opponent on a board full of challenges. With dynamic AI opponents and inactive fields that reshape strategy, every match is a unique intellectual battle!")
                            .padding(.bottom, 8)
                            
                        Text("The game board consists of a grid where players take turns placing their pieces. Some cells are blocked and cannot be used. Players must carefully plan their moves to maximize their territory while limiting their opponent's options.")
                            .padding(.bottom, 8)
                    }
                    
                    // Game rules
                    HelpSection(title: "Rules", icon: "list.bullet.clipboard") {
                        RuleItem(text: "Choose which player goes first (Blue or Red)")
                        RuleItem(text: "Blue player places blue pieces")
                        RuleItem(text: "Red player places red pieces")
                        RuleItem(text: "Players take turns")
                        RuleItem(text: "Blocked fields cannot be used")
                        RuleItem(text: "Time limit is optional and can be set in Quick Setup")
                    }
                    
                    // How to win
                    HelpSection(title: "Winning", icon: "trophy") {
                        Text("There are two ways to win:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        RuleItem(text: "Opponent has no valid moves left")
                        RuleItem(text: "Opponent runs out of time (if timer is enabled)")
                    }
                    
                    // AI opponent
                    HelpSection(title: "AI", icon: "cpu") {
                        Text("You can play against an AI opponent with different difficulty levels:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        RuleItem(text: "Enable AI in Quick Setup")
                        RuleItem(text: "Choose which team the AI will play")
                        RuleItem(text: "Select AI difficulty (Easy, Medium, Hard)")
                        RuleItem(text: "AI will automatically make its moves")
                        RuleItem(text: "AI vs AI mode is available for watching computer play")
                    }
                    
                    // Game tips
                    HelpSection(title: "Tips", icon: "lightbulb") {
                        RuleItem(text: "Plan your moves ahead to create large connected areas")
                        RuleItem(text: "Block your opponent's potential expansion paths")
                        RuleItem(text: "Control the edges to limit opponent's options")
                        RuleItem(text: "Use blocked fields strategically to create barriers")
                        RuleItem(text: "Corner positions can be valuable for territory control")
                        RuleItem(text: "Always check for valid moves before making your choice")
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
            .navigationBarTitle("Help", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
            .preferredColorScheme(.dark)
        }
    }
}

// Helper structures for better code organization
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