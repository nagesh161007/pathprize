//
//  LocationManager.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/22/24.
//

import Foundation
import MapKit
import Observation

enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    var errorDescription: String? {
        switch self {
            case .authorizationDenied:
                return NSLocalizedString("Location access denied.", comment: "")
            case .authorizationRestricted:
                return NSLocalizedString("Location access restricted.", comment: "")
            case .unknownLocation:
                return NSLocalizedString("Unknown location.", comment: "")
            case .accessDenied:
                return NSLocalizedString("Access denied.", comment: "")
            case .network:
                return NSLocalizedString("Network failed.", comment: "")
            case .operationFailed:
                return NSLocalizedString("Operation failed.", comment: "")
        }
    }
}

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    static let shared = LocationManager()
    var error: LocationError? = nil
    
    var region: MKCoordinateRegion = MKCoordinateRegion()
    
    private override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
}

extension LocationManager {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
//            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
//                                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude), latitudinalMeters: 4828.03, longitudinalMeters: 4828.03)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestAlwaysAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .denied:
                error = .authorizationDenied
            case .restricted:
                error = .authorizationRestricted
            @unknown default:
                break
        }
    }
    
    func startMonitoringDestination(_ destination: CLLocationCoordinate2D, radius: CLLocationDistance = 100, identifier: String = "DestinationRegion") {
        // Check if the device supports geofencing
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Define a geofence region
            let geofenceRegion = CLCircularRegion(center: destination, radius: radius, identifier: identifier)
            geofenceRegion.notifyOnEntry = true
            geofenceRegion.notifyOnExit = false

            // Start monitoring the geofence region
            manager.startMonitoring(for: geofenceRegion)
        } else {
            print("Geofencing is not supported on this device!")
        }
    }

    func stopMonitoringDestination(identifier: String = "DestinationRegion") {
        // Stop monitoring the geofence region
        if let region = manager.monitoredRegions.first(where: { $0.identifier == identifier }) {
            manager.stopMonitoring(for: region)
        }
    }
    
    func generateThreeRandomLocations(currentLocation: CLLocation) -> [CLLocationCoordinate2D] {
        let distance = 402.3360
        var randomLocations: [CLLocationCoordinate2D] = []
        
        for _ in 1...3 {
            let bearing = Double.random(in: 0..<360)
            let randomLocation = currentLocation.coordinate(at: distance, bearing: bearing)
            randomLocations.append(randomLocation)
        }
        
        return randomLocations
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == "DestinationRegion" {
            // User has arrived at the destination
            NotificationManager.scheduleCongratulationsNotification()
            // Optionally stop monitoring to save power if needed
            stopMonitoringDestination(identifier: region.identifier)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if let clError = error as? CLError {
            switch clError.code {
                case .locationUnknown:
                    self.error = .unknownLocation
                case .denied:
                    self.error = .accessDenied
                case .network:
                    self.error = .network
                default:
                    self.error = .operationFailed
            }
        }
        
    }
    
}
