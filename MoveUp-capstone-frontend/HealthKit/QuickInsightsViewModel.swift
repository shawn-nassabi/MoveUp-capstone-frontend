//
//  QuickInsightsViewModel.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/10/24.
//


import SwiftUI
import HealthKit

class QuickInsightsViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var insightText: String = "Loading..."
    @Published var isPositive: Bool = true
    
    @Published var calorieInsightText: String = "Loading..."
    @Published var calorieIsPositive: Bool = true
    
    init() {
        fetchRestingHeartRateInsights()
        fetchCaloriesBurnedInsights()
    }
    
    func fetchRestingHeartRateInsights() {
        let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
        
        guard let heartRateType = restingHeartRateType else {
            self.insightText = "Resting heart rate data unavailable."
            return
        }
        
        // Define date ranges for current and last month
        let calendar = Calendar.current
        let now = Date()
        guard let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth),
              let endOfLastMonth = calendar.date(byAdding: .day, value: -1, to: startOfCurrentMonth) else {
            self.insightText = "Date range calculation failed."
            return
        }
        
        // Create queries for last month and current month
        let currentMonthPredicate = HKQuery.predicateForSamples(withStart: startOfCurrentMonth, end: now, options: .strictStartDate)
        let lastMonthPredicate = HKQuery.predicateForSamples(withStart: startOfLastMonth, end: endOfLastMonth, options: .strictStartDate)
        
        // Fetch averages
        fetchAverageRestingHeartRate(predicate: lastMonthPredicate) { lastMonthAverage in
            self.fetchAverageRestingHeartRate(predicate: currentMonthPredicate) { currentMonthAverage in
                DispatchQueue.main.async {
                    self.updateInsightText(lastMonthAverage: lastMonthAverage, currentMonthAverage: currentMonthAverage)
                }
            }
        }
    }
    
    func fetchCaloriesBurnedInsights() {
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        guard let calorieType = activeEnergyType else {
            self.calorieInsightText = "Calorie data unavailable."
            return
        }

        let calendar = Calendar.current
        let now = Date()
        guard let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth),
              let endOfLastMonth = calendar.date(byAdding: .day, value: -1, to: startOfCurrentMonth) else {
            self.calorieInsightText = "Date range calculation failed."
            return
        }

        let currentMonthPredicate = HKQuery.predicateForSamples(withStart: startOfCurrentMonth, end: now, options: .strictStartDate)
        let lastMonthPredicate = HKQuery.predicateForSamples(withStart: startOfLastMonth, end: endOfLastMonth, options: .strictStartDate)

        fetchSumValue(type: calorieType, predicate: lastMonthPredicate) { lastMonthSum in
            self.fetchSumValue(type: calorieType, predicate: currentMonthPredicate) { currentMonthSum in
                DispatchQueue.main.async {
                    self.updateCalorieInsight(lastMonthSum: lastMonthSum, currentMonthSum: currentMonthSum)
                }
            }
        }
    }
    
    private func fetchAverageValue(type: HKQuantityType, predicate: NSPredicate, completion: @escaping (Double?) -> Void) {
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            guard let result = result, let average = result.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) else {
                completion(nil)
                return
            }
            completion(average)
        }
        healthStore.execute(query)
    }

    private func fetchSumValue(type: HKQuantityType, predicate: NSPredicate, completion: @escaping (Double?) -> Void) {
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity()?.doubleValue(for: .kilocalorie()) else {
                completion(nil)
                return
            }
            completion(sum)
        }
        healthStore.execute(query)
    }
    
    private func fetchAverageRestingHeartRate(predicate: NSPredicate, completion: @escaping (Double?) -> Void) {
        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            guard let result = result, let average = result.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) else {
                completion(nil)
                return
            }
            completion(average)
        }
        healthStore.execute(query)
    }
    
    private func updateInsightText(lastMonthAverage: Double?, currentMonthAverage: Double?) {
        guard let last = lastMonthAverage, let current = currentMonthAverage else {
            self.insightText = "Insufficient data for resting heart rate insights."
            return
        }
        
        let difference = current - last
        if difference < 0 {
            self.isPositive = true
            self.insightText = "Your resting heart rate has improved by \(abs(Int(difference))) bpm over the past month. Keep up the good work!"
        } else {
            self.isPositive = false
            self.insightText = "Your resting heart rate increased by \(Int(difference)) bpm compared to last month. Let's focus on improving it!"
        }
    }
    
    private func updateCalorieInsight(lastMonthSum: Double?, currentMonthSum: Double?) {
        guard let last = lastMonthSum, let current = currentMonthSum else {
            self.calorieInsightText = "Insufficient data for calorie insights."
            return
        }

        let difference = current - last
        if difference > 0 {
            self.calorieIsPositive = true
            self.calorieInsightText = "You’ve burned \(Int(difference)) more calories this month than last month. Great job!"
        } else {
            self.calorieIsPositive = false
            self.calorieInsightText = "You’ve burned \(abs(Int(difference))) fewer calories this month compared to last. Let’s aim higher!"
        }
    }
}
