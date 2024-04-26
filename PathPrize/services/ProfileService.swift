//
//  ProfileService.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation

import Supabase

class ProfileService {
    private var supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // Function to fetch all profiles
    func getAllProfiles() async throws -> [Profile] {
        return try await supabaseClient
            .from("profiles")
            .select("*")
            .execute().value
    }
    
    // Function to fetch a single profile by username
    func getProfileByUsername(username: String) async throws -> Profile {
        return try await supabaseClient
            .from("profiles")
            .select("*")
            .eq("username", value: username)
            .single()
            .execute().value
    }

    // Function to create a new profile
    func createProfile(profile: Profile) async throws -> Profile {
        return try await supabaseClient
            .from("profiles")
            .insert(profile)
            .execute().value
    }

    // Function to update an existing profile
    func updateProfile(username: String, updatedProfile: Profile) async throws -> Profile {
        return try await supabaseClient
            .from("profiles")
            .update(updatedProfile)
            .eq("username", value: username)
            .execute().value
    }

    // Function to delete a profile by username
    func deleteProfile(username: String) async throws {
        _ = try await supabaseClient
            .from("profiles")
            .delete()
            .eq("username", value: username)
            .execute().value
    }
}
