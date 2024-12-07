//
//  BenchmarksView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct Metric: Identifiable {
    let id: Int
    let name: String
}


var exampleBenchmark: Benchmark {
    .init(id: "cae202ff-61d0-4017-a9ce-37168675ea3e", dataTypeId: 1, ageRange: "20-29", gender: "male", timeFrame: "week", userDataValue: 8765, averageValue: 7748.4614, recommendedValue: 9298.154, locationName: "Dubai", createdAt: "2024-11-01T07:20:50.554942Z")
}


struct BenchmarksView: View {
    @EnvironmentObject var appState: AppState // State management
    @State private var selectedBenchmark: Benchmark? = nil // Holds the selected benchmark
    
    @State private var isLoading: Bool = false // Tracks loading state
    @State private var errorMessage: String? = nil // Tracks error messages
    @State private var shouldRefresh: Bool = false
    
    @State private var startBenchmarkExpanded: Bool = false // Toggles the expansion of the benchmark box
    @State private var selectedMetric: Int = 1 // Default to "Steps"
    @State private var metrics: [Metric] = [
        Metric(id: 1, name: "Steps"),
        Metric(id: 2, name: "Calories"),
        Metric(id: 3, name: "Resting Heartrate"),
        Metric(id: 4, name: "Sleep"),
        Metric(id: 5, name: "Exercise Minutes"),
        Metric(id: 6, name: "Distance")
    ]
    
    
    @State private var benchmarks: [Benchmark] = []

    var body: some View {
        NavigationView {
            VStack {
                HeaderView() // Add your header view here

                // Start a New Benchmark Section
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation {
                            startBenchmarkExpanded.toggle() // Expand or collapse the section
                        }
                    }) {
                        HStack {
                            Text("Start a new benchmark")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: startBenchmarkExpanded ? "chevron.down" : "chevron.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.teal, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        
                    }

                    if startBenchmarkExpanded {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack (alignment: .center){
                                // Dropdown for selecting metric
                                Text("Select a metric:")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Picker("Select Metric", selection: $selectedMetric) {
                                    ForEach(metrics) { metric in
                                        Text(metric.name).tag(metric.id) // Use `metric.id` as the tag
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(5)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            // Perform Benchmark Button
                            Button(action: {
                                isLoading = true
                                performBenchmark()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text(isLoading ? "Processing..." : "Perform Benchmark")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .background(Color.teal)
                                .cornerRadius(8)
                            }
                        }
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.teal, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        
                    }
                }

                // Previous Benchmarks Section
                Text("Previous Benchmarks")
                    .font(.system(size: 24))
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    

                ScrollView {
                    VStack(spacing: 16) {
//                        NavigationLink(destination: BenchmarkDetailView(benchmark: exampleBenchmark)) {
//                            BenchmarkCardView(
//                                date: formattedDate(from: exampleBenchmark.createdAt),
//                                title: dataTypeName(for: exampleBenchmark.dataTypeId),
//                                value: String(format: "%.0f", exampleBenchmark.userDataValue),
//                                icon: iconName(for: exampleBenchmark.dataTypeId),
//                                color: color(for: exampleBenchmark.dataTypeId)
//                            )
//                            .buttonStyle(PlainButtonStyle())
//                        }
                        
                        // Dynamic Benchmarks
                        ForEach(benchmarks) { benchmark in
                            NavigationLink(destination: BenchmarkDetailView(benchmark: benchmark)) {
                                BenchmarkCardView(
                                    date: formattedDate(from: benchmark.createdAt),
                                    title: dataTypeName(for: benchmark.dataTypeId),
                                    value: String(format: "%.0f", benchmark.userDataValue),
                                    icon: iconName(for: benchmark.dataTypeId),
                                    color: color(for: benchmark.dataTypeId)
                                )
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal, 10)
                    .onChange(of: shouldRefresh, { oldValue, newValue in
                        if newValue {
                            fetchBenchmarks()
                            shouldRefresh = false // reset after refresh
                        }
                    })

                }
            }
            .onAppear {
                fetchBenchmarks()
            }
            .padding(.horizontal)
        }
    }
    
    // Perform a new benchmark
    func performBenchmark() {
        guard let userId = appState.userId else {
            print("User ID is nil, cannot perform benchmark.")
            return
        }

        guard let userAge = appState.userData?["age"] else {
            print("User age is nil or invalid, cannot perform benchmark.")
            return
        }

        guard let userGender = appState.userData?["gender"] else {
            print("User gender is nil, cannot perform benchmark.")
            return
        }

        let locationId = 1
        let minAge = userAge as! Int - 4
        let maxAge = userAge as! Int + 4
        let timeFrame = "week"

        // Fetch the average data value from HealthKit
        HealthKitManager.shared.fetchAverageValue(for: selectedMetric, timeFrame: timeFrame) { result in
            switch result {
            case .success(let dataValue):
                // Construct the POST body
                let requestBody: [String: Any] = [
                    "userId": userId,
                    "dataValue": dataValue,
                    "dataTypeId": selectedMetric,
                    "minAge": minAge,
                    "maxAge": maxAge,
                    "timeFrame": timeFrame,
                    "gender": userGender,
                    "locationId": locationId
                ]

                guard let url = URL(string: "http://10.228.227.249:5085/api/demographicbenchmark"),
                      let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
                    print("Invalid URL or request body.")
                    return
                }

                // Perform POST request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = httpBody

                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            errorMessage = "Request failed: \(error.localizedDescription)"
                        }
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        DispatchQueue.main.async {
                            errorMessage = "Server error. Please try again."
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        // Trigger a page refresh
                        shouldRefresh = true
                    }
                }.resume()

            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = "HealthKit data fetch failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
        
    
    func fetchBenchmarks() {
        guard let userId = appState.userId else {
            print("User ID is nil, cannot upload health data.")
            return
        }

        guard let url = URL(string: "http://10.228.227.249:5085/api/demographicbenchmark/\(userId)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching benchmarks: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response from server")
                return
            }

            guard let data = data else {
                print("No data received from the server")
                return
            }

            do {
                var benchmarks = try JSONDecoder().decode([Benchmark].self, from: data)
                
                // Sort benchmarks by createdAt date in descending order (newest first)
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                benchmarks.sort {
                    let date1 = isoFormatter.date(from: $0.createdAt) ?? Date.distantPast
                    let date2 = isoFormatter.date(from: $1.createdAt) ?? Date.distantPast
                    return date1 > date2
                }

                DispatchQueue.main.async {
                    self.benchmarks = benchmarks
                    print("Benchmarks fetched successfully")
                }
            } catch {
                print("Error decoding benchmarks: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    // Map dataTypeId to metric name
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
    
    // Format the date
    func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Handle fractional seconds
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        displayFormatter.timeZone = TimeZone.current // Adjust to local timezone
        
        if let date = isoFormatter.date(from: isoDate) {
            return displayFormatter.string(from: date)
        }
        return "Unknown Date"
    }
}

// Reusable Benchmark Card View
struct BenchmarkCardView: View {
    let date: String
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(date)
                .font(.footnote)
                .foregroundColor(.gray)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your average \(title.lowercased())/day:")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        
                    Text(value)
                        .font(.system(size: 34))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer()
                VStack {
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundColor(color)
                }
            }
            .padding(.top)
            .padding(.bottom)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            HStack {
                Spacer()
                Text("View Details")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
        
    }
}


#Preview {
    BenchmarksView()
        .environmentObject(AppState())
}
