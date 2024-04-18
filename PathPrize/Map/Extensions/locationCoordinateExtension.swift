//
//  locationCoordinateExtension.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/22/24.
//

import Foundation
import MapKit

extension CLLocation {
    func coordinate(at distance: CLLocationDistance, bearing: CLLocationDegrees) -> CLLocationCoordinate2D {
        let distanceRadians = distance / 6371000 // Earth's radius in meters
        let bearingRadians = bearing * .pi / 180
        
        let fromLatRadians = self.coordinate.latitude * .pi / 180
        let fromLonRadians = self.coordinate.longitude * .pi / 180
        
        let toLatRadians = asin(sin(fromLatRadians) * cos(distanceRadians)
                                + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians))
        let toLonRadians = fromLonRadians + atan2(sin(bearingRadians) * sin(distanceRadians) * cos(fromLatRadians),
                                                  cos(distanceRadians) - sin(fromLatRadians) * sin(toLatRadians))
        
        return CLLocationCoordinate2D(latitude: toLatRadians * 180 / .pi, longitude: toLonRadians * 180 / .pi)
    }
}
