//
//  MapOptions.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/22/24.
//

import Foundation
import SwiftUI
import MapKit

enum MapOptions : String, Identifiable, CaseIterable {
    
    case standard
    case hybrid
    case imagery
    
    var id : String {
        self.rawValue
    }
    
    var mapStyle : MapStyle {
        switch self {
        case .standard:
            return .standard
        case .hybrid:
            return .hybrid
        case .imagery:
            return .imagery
        }
    }
}
