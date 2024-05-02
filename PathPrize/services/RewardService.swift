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
    static func createReward(reward: RewardModel) async throws -> Void {
        return try await supabase
            .from("rewards")
            .insert(reward)
            .single()
            .execute().value
    }

    // Function to update a reward
    static func updateReward(qrCode: String) async throws {
        do {
            // Simulate printing the QR code as part of the process
            print("qrResult", qrCode)
            // Perform the database update operation
            try await supabase
                .from("rewards")
                .update(["status": "REDEEMED"])  // Ensure the field name is correct, it was "stats" before
                .eq("qr_code", value: qrCode)
                .execute()
        } catch {
            // Handle errors by rethrowing them
            print("Failed to update reward: \(error)")
            throw error
        }
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
