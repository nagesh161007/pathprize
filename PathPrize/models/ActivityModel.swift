//
//  ActivityModel.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import MapKit

struct Activity: Codable, Identifiable {
    let id: Int?
    let createdAt: Date
    let userId: UUID
    let date: Date
    let startTime: Date
    let endTime: Date?
    let startLocationLatitude: Double?
    let startLocationLongitude: Double?
    let endLocationLatitude: Double?
    let endLocationLongitude: Double?
    let rewardId: Int64?
    let status: String
    

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case userId = "user_id"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case startLocationLatitude = "start_location_latitude"
        case startLocationLongitude = "start_location_longitude"
        case endLocationLatitude  = "end_location_latitude"
        case endLocationLongitude = "end_location_longitude"
        case rewardId = "reward_id"
        case status
    }
}


extension Activity {
    var durationFormatted: String {
        guard let end = endTime else { return "N/A" }
        let interval = end.timeIntervalSince(startTime)
        let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)
        let hours = (interval / 3600)
        return String(format: "%02d:%02d hours", Int(hours), Int(minutes))
    }

    var distanceFormatted: Double {
        guard let startLat = startLocationLatitude, let startLong = startLocationLongitude,
              let endLat = endLocationLatitude, let endLong = endLocationLongitude else { return 0.0 }
        let startLocation = CLLocation(latitude: startLat, longitude: startLong)
        let endLocation = CLLocation(latitude: endLat, longitude: endLong)
        let distanceInMeters = startLocation.distance(from: endLocation)
        return distanceInMeters * 0.000621371 // Convert meters to miles
    }

    var stepsForMiles: Int {
        // Assuming an average of 2000 steps per mile as a simple conversion factor
        return Int(distanceFormatted * 2000)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private var relativeFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }

    
    private func relativeDate(from date: Date) -> String {
            let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return relativeFormatter.localizedString(for: date, relativeTo: Date())
        }
    }
    
    var relativeFormattedDate: String {
           // Use the `relativeDate(from:)` method from `ActivityRow`
           return relativeDate(from: date)
    }
}
