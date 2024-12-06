//
//  Benchmark.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/6/24.
//

import Foundation

struct Benchmark: Identifiable, Codable, Hashable {
    let id: String
    let dataTypeId: Int
    let ageRange: String
    let gender: String
    let timeFrame: String
    let userDataValue: Double
    let averageValue: Double
    let recommendedValue: Double
    let locationName: String
    let createdAt: String
}
