//
//  RewardService.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import Supabase

class RewardService {
    
    // Function to get all rewards
    static func getAllRewards() async throws -> [RewardModel] {
        return try await supabase
            .from("rewards")
            .select("*")
            .execute().value
    }
    
    
    // Function to get a single reward by ID
    static func getRewardById(id: Int) async throws -> RewardModel {
        return try await supabase
            .from("rewards")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    // Function to create a reward
    static func createReward(reward: RewardModel) async throws -> RewardModel {
        return try await supabase
            .from("rewards")
            .insert(reward)
            .execute().value
    }

    // Function to update a reward
    static func updateReward(id: Int, updatedReward: RewardModel) async throws -> RewardModel {
        return try await supabase
            .from("rewards")
            .update(updatedReward)
            .eq("id", value: id)
            .execute().value
    }

    // Function to delete a reward
    static func deleteReward(id: Int) async throws {
        _ = try await supabase
            .from("rewards")
            .delete()
            .eq("id", value: id)
            .execute().value
    }
}
