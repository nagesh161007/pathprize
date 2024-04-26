//
//  RewardService.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import Supabase

class RewardService {
    private var supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // Function to get all rewards
    func getAllRewards() async throws -> [RewardModel] {
        return try await supabaseClient
            .from("rewards")
            .select("*")
            .execute().value
    }
    
    // Function to get a single reward by ID
    func getRewardById(id: Int) async throws -> RewardModel {
        return try await supabaseClient
            .from("rewards")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    // Function to create a reward
    func createReward(reward: RewardModel) async throws -> RewardModel {
        return try await supabaseClient
            .from("rewards")
            .insert(reward)
            .execute().value
    }

    // Function to update a reward
    func updateReward(id: Int, updatedReward: RewardModel) async throws -> RewardModel {
        return try await supabaseClient
            .from("rewards")
            .update(updatedReward)
            .eq("id", value: id)
            .execute().value
    }

    // Function to delete a reward
    func deleteReward(id: Int) async throws {
        _ = try await supabaseClient
            .from("rewards")
            .delete()
            .eq("id", value: id)
            .execute().value
    }
}
