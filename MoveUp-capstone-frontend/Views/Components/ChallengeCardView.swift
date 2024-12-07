//
//  ChallengeCardView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/6/24.
//

import SwiftUI

struct ChallengeCardView: View {
    let challengeDetails: Challenge

    let goal: String
    let title: String
    let progress: Double
    let needed: String
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                // Determine if the challenge is active or expired
                if isChallengeActive(endDate: challengeDetails.endDate) {
                    HStack(spacing: 8) {
                        // Pulsing green circle for active challenges
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.cyan.opacity(0.5), lineWidth: 4)
                                    .scaleEffect(isAnimating ? 1.4 : 1.0) // Dynamic scaling
                                    .opacity(isAnimating ? 0.0 : 0.5) // Fade out for pulse effect
                            )
                            .animation(
                                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                value: isAnimating // Animation triggers when this value changes
                            )
                            .onAppear {
                                isAnimating = true // Start animation when the view appears
                            }
                        
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.cyan)
                            .fontWeight(.bold)
                    }
                } else {
                    HStack(spacing: 8) {
                        // Red cross for expired challenges
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("Expired")
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 8)
            Text("GOAL: \(Int(challengeDetails.goal))")
                .font(.system(size: 10))
                .foregroundColor(color(for: challengeDetails.dataType))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 2)
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(color(for: challengeDetails.dataType))
                        .padding(.bottom)
                }
                Spacer()

                // Circular Progress Bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(challengeDetails.goal - challengeDetails.totalProgress))")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Text("needed")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    ZStack {
                        // Background Circle
                        Circle()
                            .stroke(
                                Color.gray.opacity(0.2),
                                lineWidth: 10
                            )
                            .frame(width: 70, height: 70)

                        // Foreground Circle showing progress
                        Circle()
                            .trim(from: 0.0, to: CGFloat(challengeDetails.totalProgress / challengeDetails.goal)) // Progress from 0 to 1
                            .stroke(
                                color(for: challengeDetails.dataType),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90)) // Start at the top
                            .frame(width: 70, height: 70)

                        // Percentage Label
                        Text("\(Int(CGFloat(challengeDetails.totalProgress / challengeDetails.goal) * 100))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(color(for: challengeDetails.dataType))
                    }
                }
                .padding(.bottom)
            }
            HStack {
                VStack {
                    Text("Challenge type: \(challengeDetails.dataType.capitalized)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    
                    Text("Started: \(formattedDate(from: challengeDetails.startDate))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    
                    Text("End: \(formattedDate(from: challengeDetails.endDate))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Reward: 150 Challenge Points")
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                Spacer()
                Image(systemName: "\(iconName(for: challengeDetails.dataType))")
                    .font(.system(size: 40))
                    .padding(.horizontal)
                    .foregroundColor(color(for: challengeDetails.dataType))
            }
            .padding(.bottom)
            
            Text("\"\(challengeDetails.challengeDescription)\"")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.white))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
    }
    
    func isChallengeActive(endDate: String) -> Bool {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let endDate = isoFormatter.date(from: endDate) {
            return endDate > Date()
        }
        return false
    }
    
    // Map dataTypeId to icon name
    func iconName(for dataTypeName: String) -> String {
        switch dataTypeName {
        case "steps": return "figure.walk.motion"
        case "calories": return "flame.fill"
        case "resting_heartrate": return "heart.fill"
        case "sleep": return "moon.fill"
        case "exercise_minutes": return "figure.run"
        case "distance": return "map"
        default: return "questionmark.circle.fill"
        }
    }
    
    // Map dataTypeId to color
    func color(for dataTypeName: String) -> Color {
        switch dataTypeName {
        case "steps": return .green
        case "calories": return .orange
        case "resting_heartrate": return .red
        case "sleep": return .indigo
        case "exercise_minutes": return .teal
        case "distance": return .brown
        default: return .gray
        }
    }
    
    func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        displayFormatter.timeZone = TimeZone.current

        if let date = isoFormatter.date(from: isoDate) {
            return displayFormatter.string(from: date)
        }
        return "Unknown Date"
    }
}


#Preview {
    ClanChallengesView(clanId: "08613e25-1b60-4171-bb85-aab513aebc37")
        .environmentObject(AppState())
}
