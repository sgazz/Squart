import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var manager = AchievementManager.shared
    @State private var selectedFilter: AchievementStatus = .completed
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter dugmići
                Picker("Status", selection: $selectedFilter) {
                    Text("completed".localized)
                        .tag(AchievementStatus.completed)
                    Text("in_progress".localized)
                        .tag(AchievementStatus.inProgress)
                    Text("locked".localized)
                        .tag(AchievementStatus.locked)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Lista postignuća
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
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
            .navigationBarTitle("achievements".localized, displayMode: .inline)
            .navigationBarItems(trailing: Button("close".localized) {
                dismiss()
            })
        }
        .preferredColorScheme(.dark)
    }
    
    private var filteredAchievements: [Achievement] {
        manager.achievements.filter { $0.status == selectedFilter }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                
                Text(achievement.title)
                    .font(.headline)
                
                Spacer()
                
                if achievement.status == .completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(achievement.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            if achievement.status != .completed {
                ProgressView(value: achievement.progress, total: achievement.requiredProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)
                
                Text("\(Int(achievement.progressPercentage()))% completed")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            } else if let date = achievement.dateCompleted {
                Text("Completed: \(formattedDate(date))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
    }
    
    private var iconColor: Color {
        switch achievement.status {
        case .completed: return .yellow
        case .inProgress: return .blue
        case .locked: return .gray
        }
    }
    
    private var progressColor: Color {
        switch achievement.status {
        case .completed: return .green
        case .inProgress: return .blue
        case .locked: return .gray
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.1))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Preview provider
struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
    }
} 