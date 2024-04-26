//
//  ActivityModel.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation

struct Activity: Codable {
    let id: Int
    let createdAt: Date
    let userId: UUID
    let date: Date
    let startTime: Date?
    let endTime: Date?
    let startLocation: Double?
    let endLocation: Double?
    let rewardId: Int64?
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case userId = "user_id"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case startLocation = "start_location"
        case endLocation = "end_location"
        case rewardId = "reward_id"
        case status
    }
}
