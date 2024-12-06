//
//  BarChartView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/6/24.
//

import SwiftUI

struct BarChartView: View {
    let userValue: Double
    let averageValue: Double
    let recommendedValue: Double
    let height: Double

    // Calculate the upper bound for scaling
    private var upperBound: Double {
        max(userValue, averageValue, recommendedValue) * 1.1
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 25) {
                // Bar for "You"
                BarView(
                    value: userValue,
                    label: "You",
                    color: .blue,
                    height: CGFloat(height * (userValue / upperBound))
                )

                // Bar for "Average"
                BarView(
                    value: averageValue,
                    label: "Public Average",
                    color: .gray,
                    height: CGFloat(height * (averageValue / upperBound))
                )

                // Bar for "Goal"
                BarView(
                    value: recommendedValue,
                    label: "Target",
                    color: .green,
                    height: CGFloat(height * (recommendedValue / upperBound))
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Reusable Bar for Chart
struct BarView: View {
    let value: Double
    let label: String
    let color: Color
    let height: CGFloat // Pass the calculated height for this bar

    var body: some View {
        VStack {
            // Display the value above the bar
            Text("\(Int(ceil(value)))")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.black)

            // Rectangle for the bar, with dynamic height
            Rectangle()
                .fill(color)
                .frame(width: 70, height: height)

            // Display the label below the bar
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(height: 20)
        }
    }
}
