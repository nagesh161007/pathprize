//
//  DateHelper.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/18/24.
//

import Foundation

struct DateHelper {
    // The universally used DateFormatter
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
