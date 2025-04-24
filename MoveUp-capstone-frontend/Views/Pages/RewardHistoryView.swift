//
//  RewardHistoryView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 4/20/25.
//

import SwiftUI

struct RewardHistoryView: View {
  @EnvironmentObject var appState: AppState

  var body: some View {
    List {
      Section(header: Text("Points Earned")) {
        ForEach(appState.pointsHistory) { rec in
          HStack {
            Text(rec.timestamp, style: .date)
            Spacer()
            Text("\(rec.points) pts")
          }
        }
      }
      Section(header: Text("Tokens Minted")) {
        ForEach(appState.tokenHistory) { rec in
          HStack {
            Text(rec.timestamp, style: .date)
            Spacer()
            Text("\(rec.tokens) HDT")
          }
        }
      }
    }
    .listStyle(InsetGroupedListStyle())
    .navigationTitle("Reward History")
    .onAppear {
      appState.fetchPointsHistory()
      appState.fetchTokenHistory()
    }
  }
}

#Preview {
    RewardHistoryView()
        .environmentObject(AppState())

}
