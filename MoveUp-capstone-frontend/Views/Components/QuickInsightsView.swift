//
//  QuickInsightsView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct QuickInsightsView: View {
    @StateObject private var viewModel = QuickInsightsViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Insights")
                .font(.system(size: 24))
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            InsightCardView(text: viewModel.insightText, isPositive: viewModel.isPositive)
            InsightCardView(text: viewModel.calorieInsightText, isPositive: viewModel.calorieIsPositive)
        }
        .padding(.top)
    }
}

struct InsightCardView: View {
    var text: String
    var isPositive: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .padding(.trailing, 25)
            Spacer()
            Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                .foregroundColor(isPositive ? .green : .red)
                .font(.system(size: 30))
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
    }
}
