//
//  UserService.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation


class OfferService {
    
    // Function to get all offers
    static func getAlloffers() async throws -> [OfferModel] {
        return try await supabase
            .from("offers")
            .select("*")
            .execute().value
    }
    
    
    static func getOffersByUser() async throws -> [OfferModel] {
        do {
            let offers: [OfferModel]
            let currentUser = try await supabase.auth.session.user
            offers =  try await supabase
                .from("offers")
                .select("*")
                .eq("business_id", value: currentUser.id)
                .execute().value
            return offers
            
        } catch {
            print("Error \(error)")
            throw NSError(domain: "Supabase Offer Fetch", code: 500, userInfo: [NSLocalizedDescriptionKey : "Failed to fetch offer for business"])
        }
    }

    
    static func getOfferByBusinessId(id: Int) async throws -> OfferModel {
        return try await supabase
            .from("offers")
            .select("*")
            .eq("business_id", value: id)
            .single()
            .execute().value
    }
    
    // Function to get a single Offer by ID
    static func getOfferById(id: Int) async throws -> OfferModel {
        return try await supabase
            .from("offers")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    // Function to create a Offer
    static func createOffer(Offer: OfferModel) async throws -> OfferModel {
        return try await supabase
            .from("offers")
            .insert(Offer)
            .execute().value
    }

    // Function to update a Offer
    static func updateOffer(id: Int, updatedOffer: OfferModel) async throws -> OfferModel {
        return try await supabase
            .from("offers")
            .update(updatedOffer)
            .eq("id", value: id)
            .execute().value
    }

    // Function to delete a Offer
    static func deleteOffer(id: Int) async throws {
        _ = try await supabase
            .from("offers")
            .delete()
            .eq("id", value: id)
            .execute().value
    }
}
