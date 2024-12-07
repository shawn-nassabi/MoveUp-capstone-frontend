//
//  SearchClansView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//

import SwiftUI

struct SearchClansView: View {
    @State private var clans: [ClanSearchModel] = [] // Holds the list of clans from the backend
    @State private var searchText: String = "" // Text entered in the search bar
    @State private var isLoading: Bool = true // Indicates if data is being fetched

    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                TextField("Enter clan name", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Button(action: {
                    // Trigger search (filter list based on search text)
                }) {
                    Text("Search")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)

            if isLoading {
                // Loading state
                ProgressView("Loading clans...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if clans.isEmpty {
                // Empty state
                Text("No clans found.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // List of clans
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(filteredClans, id: \.id) { clan in
                            ClanCardView(clan: clan)
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical)
                }
                
            }
        }
        .padding(.horizontal)
        .navigationBarTitle("Clan Search", displayMode: .inline)
        .onAppear {
            fetchClans()
        }
    }

    // Filtered list of clans based on search text
    var filteredClans: [ClanSearchModel] {
        if searchText.isEmpty {
            return clans
        } else {
            return clans.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // Fetch clans from backend
    func fetchClans() {
        guard let url = URL(string: "http://10.228.227.249:5085/api/clan") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching clans: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            if let data = data {
                do {
                    let decodedClans = try JSONDecoder().decode([ClanSearchModel].self, from: data)
                    DispatchQueue.main.async {
                        self.clans = decodedClans
                        self.isLoading = false
                    }
                } catch {
                    print("Error decoding clans: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }.resume()
    }
}


#Preview {
    SearchClansView()
        .environmentObject(AppState())
}
