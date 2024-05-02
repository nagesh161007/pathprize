//
//  BusinessService.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import Supabase

class BusinessService {
    
    static func getBusinessIdForUser(userUUID: UUID) async throws -> Business {
        do {
            let business: Business = try await supabase
                .from("business")
                .select("*")
                .eq("user_id", value: userUUID.uuidString)
                .single()
                .execute().value
            return business
        } catch {
            // Log the error or handle it as needed
            print("Failed to fetch business for user: \(error)")
            throw error  // Rethrowing the error to be handled by the caller
        }
    }
    
    // Function to fetch all businesses
    static func getAllBusinesses() async throws -> [Business] {
        return try await supabase
            .from("business")
            .select("*")
            .execute().value
    }
    
    
    // Function to fetch a single business by ID
    static func getBusinessById(id: Int) async throws -> Business {
        return try await supabase
            .from("business")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    // Function to create a new business
    static func createBusiness(business: Business) async throws -> Business {
        return try await supabase
            .from("business")
            .insert(business)
            .execute().value
    }

    // Function to update an existing business
    static func updateBusiness(id: Int, updatedBusiness: Business) async throws -> Business {
        return try await supabase
            .from("business")
            .update(updatedBusiness)
            .eq("id", value: id)
            .execute().value
    }

    // Function to delete a business
    static func deleteBusiness(id: Int) async throws {
        _ = try await supabase
            .from("business")
            .delete()
            .eq("id", value: id)
            .execute().value
    }
}
