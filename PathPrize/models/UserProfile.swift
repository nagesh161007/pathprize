//
//  UserProfile.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/22/24.
//

import Foundation

struct UserProfile: Codable {
    let id: UUID
    let updatedAt: Date?
    let firstname: String?
    let lastname: String?
    let email: String
    let avatarURL: String?
    let username: String?
    let userType: String?
    let onboardingState: String
    let distance: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstname
        case updatedAt
        case lastname
        case email
        case avatarURL = "avatar_url"
        case username
        case userType = "user_type"
        case onboardingState = "onboarding_state"
        case distance
    }
}
