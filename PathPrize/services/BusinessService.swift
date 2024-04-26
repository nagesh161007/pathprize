//
//  BusinessService.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import Supabase

class BusinessService {
    private var supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // Function to fetch all businesses
    func getAllBusinesses() async throws -> [Business] {
        return try await supabaseClient
            .from("businesses")
            .select("*")
            .execute().value
    }
    
    // Function to fetch a single business by ID
    func getBusinessById(id: Int) async throws -> Business {
        return try await supabaseClient
            .from("businesses")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    // Function to create a new business
    func createBusiness(business: Business) async throws -> Business {
        return try await supabaseClient
            .from("businesses")
            .insert(business)
            .execute().value
    }

    // Function to update an existing business
    func updateBusiness(id: Int, updatedBusiness: Business) async throws -> Business {
        return try await supabaseClient
            .from("businesses")
            .update(updatedBusiness)
            .eq("id", value: id)
            .execute().value
    }

    // Function to delete a business
    func deleteBusiness(id: Int) async throws {
        _ = try await supabaseClient
            .from("businesses")
            .delete()
            .eq("id", value: id)
            .execute().value
    }
}
