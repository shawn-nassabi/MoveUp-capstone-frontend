//
//  DashboardView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
            ScrollView {
                VStack() {
                    HeaderView()
                    if let userData = appState.userData, let username = userData["username"] as? String {
                        Text("Welcome, \(username)!")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("Welcome")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ActivityOverviewView()
                    QuickInsightsView()
                }
                .padding(.horizontal)
            }
            .navigationTitle("MoveUp")
    }
}
