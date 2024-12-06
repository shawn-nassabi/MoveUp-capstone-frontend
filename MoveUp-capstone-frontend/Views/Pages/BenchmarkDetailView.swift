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
        VStack(spacing: 10) {
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
            
            Text("Benchmark timeframe: \(benchmark.timeFrame.capitalized)")
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
            .padding(.vertical, 20)
            
            
            
            Spacer()

        }
        .padding()
        .navigationTitle("Benchmark Details")
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
