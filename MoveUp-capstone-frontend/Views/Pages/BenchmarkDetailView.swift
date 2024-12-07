//
//  BenchmarkDetailView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/6/24.
//

import SwiftUI

struct BenchmarkDetailView: View {
    let benchmark: Benchmark // Pass the benchmark object

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                // Header
                Text("\(dataTypeName(for: benchmark.dataTypeId)) Benchmark")
                    .font(.system(size: 24))
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Date: \(formattedDate(from: benchmark.createdAt))")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
                
                Text("Location: \(benchmark.locationName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Benchmark timeframe: 1 \(benchmark.timeFrame.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Age range: \(benchmark.ageRange)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Bar Chart
                BarChartView(
                    userValue: benchmark.userDataValue,
                    averageValue: benchmark.averageValue,
                    recommendedValue: benchmark.recommendedValue,
                    height: 200
                )
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Insights Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Insights")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(generateBenchmarkFeedback(
                        userValue: benchmark.userDataValue,
                        averageValue: benchmark.averageValue,
                        recommendedValue: benchmark.recommendedValue,
                        isRestingHeartrate: benchmark.dataTypeId == 3 // Check if the metric is Resting Heartrate
                    ))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 20)
                
                
                Spacer()

            }
            .padding()
            .navigationTitle("Benchmark Details")
        }
    }
    
    func generateBenchmarkFeedback(userValue: Double, averageValue: Double, recommendedValue: Double, isRestingHeartrate: Bool = false) -> String {
        var insights: [String] = []

        if isRestingHeartrate {
            // Special case: Resting Heartrate
            let averageDifference = averageValue - userValue
            if averageDifference > 0 {
                let percentage = (averageDifference / averageValue) * 100
                insights.append("Your resting heartrate is \(Int(percentage))% lower than the public average. Great job!")
            } else if averageDifference < 0 {
                let percentage = abs(averageDifference / averageValue) * 100
                insights.append("Your resting heartrate is \(Int(percentage))% higher than the public average. Consider ways to reduce it.")
            }

            let recommendedDifference = recommendedValue - userValue
            if recommendedDifference > 0 {
                let percentage = (recommendedDifference / recommendedValue) * 100
                insights.append("Your resting heartrate is \(Int(percentage))% lower than the recommended value. Keep it up!")
            } else if recommendedDifference < 0 {
                let percentage = abs(recommendedDifference / recommendedValue) * 100
                insights.append("Your resting heartrate is \(Int(percentage))% higher than the recommended value. A lower resting heartrate is an indicator of better overall cardiovascular health.")
            }
        } else {
            // General case
            let averageDifference = userValue - averageValue
            if averageDifference > 0 {
                let percentage = (averageDifference / averageValue) * 100
                insights.append("Your performance in the past week was \(Int(percentage))% higher than the public average. Great job!")
            } else if averageDifference < 0 {
                let percentage = abs(averageDifference / averageValue) * 100
                insights.append("Your performance in the past week was \(Int(percentage))% lower than the public average. Consider improving in this area.")
            }

            let recommendedDifference = userValue - recommendedValue
            if recommendedDifference > 0 {
                let percentage = (recommendedDifference / recommendedValue) * 100
                insights.append("You exceeded the recommended value by \(Int(percentage))%. Keep up the fantastic effort!")
            } else if recommendedDifference < 0 {
                let percentage = abs(recommendedDifference / recommendedValue) * 100
                insights.append("You are \(Int(percentage))% below the recommended value. A small improvement could help you reach your goal.")
            }
        }

        return insights.joined(separator: "\n\n")
    }

    // Helper functions
    func dataTypeName(for id: Int) -> String {
        switch id {
        case 1: return "Steps"
        case 2: return "Calories"
        case 3: return "Resting Heartrate"
        case 4: return "Sleep"
        case 5: return "Exercise Minutes"
        case 6: return "Distance"
        default: return "Unknown"
        }
    }
    
    // Map dataTypeId to icon name
    func iconName(for id: Int) -> String {
        switch id {
        case 1: return "figure.walk.motion"
        case 2: return "flame.fill"
        case 3: return "heart.fill"
        case 4: return "moon.fill"
        case 5: return "figure.run"
        case 6: return "map"
        default: return "questionmark.circle.fill"
        }
    }
    
    // Map dataTypeId to color
    func color(for id: Int) -> Color {
        switch id {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        case 4: return .indigo
        case 5: return .teal
        case 6: return .brown
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
    
    func generateBenchmarkFeedback() {
        // TODO
    }
}
