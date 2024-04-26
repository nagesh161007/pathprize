//
//  ActivityService.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import Supabase

class ActivityService {
    private var supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // Function to get all activities
    func getAllActivities() async throws -> [Activity] {
        return try await supabaseClient
            .from("activities")
            .select("*")
            .order("date", ascending: false)
            .execute().value
    }
    
    // Function to get a single activity by ID
    func getActivityById(id: Int) async throws -> Activity {
        return try await supabaseClient
            .from("activities")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    // Function to create an activity
    func createActivity(activity: Activity) async throws -> Activity {
        return try await supabaseClient
            .from("activities")
            .insert(activity)
            .execute().value
    }

    // Function to update an activity
    func updateActivity(id: Int, updatedActivity: Activity) async throws -> Activity {
        return try await supabaseClient
            .from("activities")
            .update(updatedActivity)
            .eq("id", value: id)
            .execute().value
    }

    // Function to delete an activity
    func deleteActivity(id: Int) async throws {
        _ = try await supabaseClient
            .from("activities")
            .delete()
            .eq("id", value: id)
            .execute().value
    }
}
