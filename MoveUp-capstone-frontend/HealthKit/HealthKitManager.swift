//
//  HealthKitManager.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/2/24.
//
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    // Health data types to read
    private let readDataTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        
    ]
    
    // Request permissions
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // Fetch steps
    func fetchStepCount(completion: @escaping (Double?, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Step Count Type is unavailable"]))
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            completion(steps, nil)
        }
        
        healthStore.execute(query)
    }
    
    // Fetch calories
    func fetchActiveCalories(completion: @escaping (Double?, Error?) -> Void) {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Active Energy Type is unavailable"]))
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(calories, nil)
        }
        
        healthStore.execute(query)
    }
    
    // Fetch average resting heart rate
    func fetchRestingHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resting Heart Rate Type is unavailable"]))
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            guard let result = result, let average = result.averageQuantity() else {
                completion(nil, error)
                return
            }
            
            let heartRate = average.doubleValue(for: HKUnit(from: "count/min")) // Beats per minute
            completion(heartRate, nil)
        }
        
        healthStore.execute(query)
    }
    
    // Fetch exercise minutes
    func fetchExerciseMinutes(completion: @escaping (Double?, Error?) -> Void) {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Exercise Time Type is unavailable"]))
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let exerciseMinutes = sum.doubleValue(for: HKUnit.minute())
            completion(exerciseMinutes, nil)
        }
        
        healthStore.execute(query)
    }
    
    // Fetch total distance walked or run
    func fetchTotalDistance(completion: @escaping (Double?, Error?) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Distance Walking/Running Type is unavailable"]))
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let distance = sum.doubleValue(for: HKUnit.meter()) / 1000.0 // Convert meters to kilometers
            completion(distance, nil)
        }
        
        healthStore.execute(query)
    }
    
    // Fetch sleep data
    func fetchSleepData(completion: @escaping (Double?, Error?) -> Void) {
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sleep Analysis Type is unavailable"]))
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let startOfPreviousNight = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now.addingTimeInterval(-86400))!
        let endOfPreviousNight = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfPreviousNight, end: endOfPreviousNight, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            guard let samples = samples as? [HKCategorySample] else {
                completion(nil, error)
                return
            }

            // Process the sleep samples
            let filteredSamples = samples.filter { sample in
                let source = sample.sourceRevision.source.bundleIdentifier
                return source.starts(with: "com.apple.health")
            }

            var remSleepSeconds: TimeInterval = 0
            var deepSleepSeconds: TimeInterval = 0
            var coreSleepSeconds: TimeInterval = 0
            var awakeningsCount = 0
            var totalSleepSeconds: TimeInterval = 0

            for sample in filteredSamples {
                let value = sample.value
                let duration = sample.endDate.timeIntervalSince(sample.startDate)

                switch value {
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    remSleepSeconds += duration
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    coreSleepSeconds += duration
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    deepSleepSeconds += duration
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    awakeningsCount += 1
                default:
                    break
                }
            }

            totalSleepSeconds = deepSleepSeconds + coreSleepSeconds + remSleepSeconds
            let totalSleepHours = totalSleepSeconds / 3600
            
            completion(totalSleepHours, nil)
        }

        healthStore.execute(query)
    }
    
    
    func fetchAverageValue(for metricId: Int, timeFrame: String, completion: @escaping (Result<Double, Error>) -> Void) {
        if metricId == 4 { // Special case for sleep
            fetchSleepDataForTimeFrame(timeFrame: timeFrame) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let sleepHours = result {
                    completion(.success(sleepHours))
                } else {
                    completion(.failure(NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "No sleep data available"])))
                }
            }
            return
        }

        let healthKitType = mapToHealthKitType(metricId: metricId)

        // Define the time range based on the specified timeframe
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch timeFrame.lowercased() {
        case "week":
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        default:
            completion(.failure(NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported timeframe"])))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        // Determine statistics option based on the data type
        let options: HKStatisticsOptions
        if healthKitType.identifier == HKQuantityTypeIdentifier.stepCount.rawValue ||
            healthKitType.identifier == HKQuantityTypeIdentifier.activeEnergyBurned.rawValue ||
            healthKitType.identifier == HKQuantityTypeIdentifier.appleExerciseTime.rawValue ||
            healthKitType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
            options = .cumulativeSum
        } else {
            options = .discreteAverage
        }

        // Query for cumulative sum or discrete average based on type
        let query = HKStatisticsQuery(quantityType: healthKitType, quantitySamplePredicate: predicate, options: options) { _, result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if healthKitType.identifier == HKQuantityTypeIdentifier.stepCount.rawValue ||
                healthKitType.identifier == HKQuantityTypeIdentifier.activeEnergyBurned.rawValue ||
                healthKitType.identifier == HKQuantityTypeIdentifier.appleExerciseTime.rawValue ||
                healthKitType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue{
                // Handle cumulative sum for step count and active energy burned
                if let sumQuantity = result?.sumQuantity() {
                    var totalValue = sumQuantity.doubleValue(for: self.unit(for: healthKitType))
                    // Convert meters to kilometers for distance
                    if healthKitType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
                        totalValue /= 1000
                    }
                    let days = calendar.dateComponents([.day], from: startDate, to: now).day ?? 1
                    var averageValue = totalValue / Double(days)
                    if healthKitType.identifier == HKQuantityTypeIdentifier.distanceRowing.rawValue {
                        averageValue /= 1000
                    }
                    completion(.success(averageValue))
                } else {
                    completion(.failure(NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available for this metric."])))
                }
            } else {
                // Handle discrete average for other metrics
                if let averageQuantity = result?.averageQuantity() {
                    let averageValue = averageQuantity.doubleValue(for: self.unit(for: healthKitType))
                    completion(.success(averageValue))
                } else {
                    completion(.failure(NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available for this metric."])))
                }
            }
        }

        healthStore.execute(query)
    }
    
    func fetchSleepDataForTimeFrame(timeFrame: String, completion: @escaping (Double?, Error?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sleep Analysis Type is unavailable"]))
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch timeFrame.lowercased() {
        case "week":
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        default:
            completion(nil, NSError(domain: "com.moveup.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported timeframe"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKCategorySample] else {
                completion(nil, error)
                return
            }

            var totalSleepSeconds: TimeInterval = 0

            for sample in samples {
                let value = sample.value
                let duration = sample.endDate.timeIntervalSince(sample.startDate)

                switch value {
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                     HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                     HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    totalSleepSeconds += duration
                default:
                    break
                }
            }

            let totalSleepHours = totalSleepSeconds / 3600
            completion(totalSleepHours, nil)
        }

        healthStore.execute(query)
    }

    func mapToHealthKitType(metricId: Int) -> HKQuantityType {
        switch metricId {
        case 1: return HKQuantityType.quantityType(forIdentifier: .stepCount)!
        case 2: return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        case 3: return HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        case 5: return HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        case 6: return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        default:
            fatalError("Unknown metric ID or unsupported metric")
        }
    }
    
    func unit(for type: HKQuantityType) -> HKUnit {
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return HKUnit.count()
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            return HKUnit.kilocalorie()
        case HKQuantityTypeIdentifier.restingHeartRate.rawValue:
            return HKUnit(from: "count/min")
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            return HKUnit.minute()
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            return HKUnit.meter()
        default:
            fatalError("Unsupported metric type")
        }
    }
    
}
