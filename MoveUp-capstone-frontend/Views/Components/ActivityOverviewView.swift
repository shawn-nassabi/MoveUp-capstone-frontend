//
//  ActivityOverviewView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct ActivityOverviewView: View {
    @State private var steps: String = "--"
    @State private var calories: String = "--"
    @State private var sleepHours: String = "--"
    @State private var restingHeartRate: String = "--"
    @State private var exerciseMinutes: String = "--"
    @State private var distance: String = "--"
    
    let columns = [
        GridItem(.flexible(), spacing: 16), // Add spacing between the columns
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            Text("Today's Activity")
                .font(.system(size: 24))
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            LazyVGrid(columns: columns, spacing: 24) {
                ActivityCardView(title: "Steps", value: steps, goal: "10,000", icon: "figure.walk.motion", color: .green)
                ActivityCardView(title: "Calories", value: calories, goal: "650", icon: "flame.fill", color: .orange)
                ActivityCardView(title: "Sleep", value: sleepHours, goal: "8h 30m", icon: "moon.fill", color: .indigo)
                ActivityCardView(title: "Rest HR", value: restingHeartRate, goal: "54", icon: "heart.fill", color: .red)
                ActivityCardView(title: "Exercise", value: exerciseMinutes, goal: "30", icon: "figure.run", color: .teal)
                ActivityCardView(title: "Distance", value: distance, goal: "2 km", icon: "map", color: .brown)
            }
            .onAppear {
                fetchData()
            }
        }
        .padding(.bottom)
        
    }
    
    private func fetchData() {
        HealthKitManager.shared.fetchStepCount { result, error in
            if let steps = result {
                self.steps = String(Int(steps))
            }
        }
        
        HealthKitManager.shared.fetchActiveCalories { result, error in
            if let calories = result {
                self.calories = String(Int(calories))
            }
        }
        
        HealthKitManager.shared.fetchSleepData { result, error in
            if let hours = result {
                self.sleepHours = String(format: "%.1f", hours) // Format to 1 decimal place
            }
        }
        
        HealthKitManager.shared.fetchRestingHeartRate { result, error in
            if let heartRate = result {
                self.restingHeartRate = String(format: "%.0f", heartRate) // No decimals
            }
        }
        
        HealthKitManager.shared.fetchExerciseMinutes { result, error in
            if let minutes = result {
                self.exerciseMinutes = String(format: "%.0f", minutes) // No decimals
            }
        }
        
        HealthKitManager.shared.fetchTotalDistance { result, error in
            if let distance = result {
                self.distance = String(format: "%.1f", distance) // 1 decimal place
            }
        }
    }
}

struct ActivityCardView: View {
    var title: String
    var value: String
    var goal: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack {
            HStack{
                VStack {
                    Text(title)
                        .font(.system(size: 12))
                        .fontWeight(.bold) // Add this to make the text bold
                        .foregroundColor(color)
                    Spacer()
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 24))
                    
                }
                Spacer()
                VStack{
                    Text(value)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    Text("Goal: \(goal)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
            .padding(.horizontal, 10)
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.white))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
    }
}
