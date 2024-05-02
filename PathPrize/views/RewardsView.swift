//
//  RewardsView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/26/24.
//

import Foundation
import SwiftUI

struct RewardsView: View {
    @State private var rewards: [RewardModel] = []
    @State private var filteredRewards: [RewardModel] = []
    @State private var searchText = ""
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            List {
                   ForEach(filteredRewards, id: \.id) { reward in
                       if reward.status == "REDEEMED" {
                           HStack {
                               VStack(alignment: .leading) {
                                   Text(reward.name)
                                       .font(.headline)
                                       .foregroundColor(.primary)
                                   Text("Expires: \(reward.expiresAt, formatter: itemFormatter)")
                                       .font(.subheadline)
                                       .foregroundColor(.secondary)
                               }
                               Spacer()
                               Image(systemName: "checkmark.seal.fill")
                                   .foregroundColor(.green)
                           }
                           .contentShape(Rectangle())
                       } else {
                           NavigationLink(destination: RewardDetailView(rewardId: reward.id)) {
                               HStack {
                                   VStack(alignment: .leading) {
                                       Text(reward.name)
                                           .font(.headline)
                                           .foregroundColor(.primary)
                                       Text("Expires: \(reward.expiresAt, formatter: itemFormatter)")
                                           .font(.subheadline)
                                           .foregroundColor(.secondary)
                                   }
                                   Spacer()
                                   if reward.status == "NOT_REDEEMED" {
                                       Image(systemName: "hourglass")
                                           .foregroundColor(.orange)
                                   }
                               }
                           }
                       }
                   }
               }            .navigationTitle("Rewards")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText) { newValue in
                filterRewards()
            }
            .onAppear {
                loadRewards()
            }
        }
    }

    private func loadRewards() {
        Task {
            do {
                rewards = try await RewardService.getAllRewards()
                filteredRewards = rewards
                isLoading = false
            } catch {
                print("Failed to load rewards: \(error)")
            }
        }
    }

    private func filterRewards() {
        if searchText.isEmpty {
            filteredRewards = rewards
        } else {
            filteredRewards = rewards.filter { reward in
                reward.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()


#Preview {
    RewardsView()
}
