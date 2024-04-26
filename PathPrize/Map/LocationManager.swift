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
    var monitor: CLMonitor?
    var hasReachedLocation = false
    
    var region: MKCoordinateRegion = MKCoordinateRegion()
    
    private override init() {
        super.init()
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    func startRegionMonitoring(monitoringlocation: CLLocationCoordinate2D) async {
        
        print("startRegionMonitoring started")
        
        monitor = await CLMonitor("RegionMonitor")
        
        await monitor?.add( CLMonitor.CircularGeographicCondition(center: monitoringlocation, radius: 300), identifier: "quest-destination", assuming: .unsatisfied)
        
        print("Added Location to Monitor")
        
        Task {
            for try await event in await monitor!.events {
                print(event.state.rawValue)
                switch event.state {
                    case .satisfied:
                        print("satisfied")
                    hasReachedLocation = true
                    NotificationManager.scheduleCongratulationsNotification()
                    await monitor?.remove("quest-destination")
                    case .unknown, .unsatisfied:
                        print("unknown or unsatisfied")
                    @unknown default:
                        print("unknown default")
                }
            }
        }
        
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
        print(manager.authorizationStatus.rawValue)
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
    
    func generateThreeRandomLocations(currentLocation: CLLocation) -> [CLLocationCoordinate2D] {
        let distance = 202.3360
        var randomLocations: [CLLocationCoordinate2D] = []
        
//        for _ in 1...3 {
//            let bearing = Double.random(in: 0..<360)
//            let randomLocation = currentLocation.coordinate(at: distance, bearing: bearing)
//            randomLocations.append(randomLocation)
//        }
        
        
        randomLocations.append(CLLocationCoordinate2D(latitude: 42.33077439474914, longitude: -71.09583226833279))
        
        
        randomLocations.append(CLLocationCoordinate2D(latitude: 42.3325035776856, longitude: -71.09647817779118))
        
        randomLocations.append(CLLocationCoordinate2D(latitude: 42.3376185, longitude: -71.0901376))
        
        print("random location generated")

        return randomLocations
    }
    
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        if region.identifier == "DestinationRegion" {
//            // User has arrived at the destination
//            NotificationManager.scheduleCongratulationsNotification()
//            // Optionally stop monitoring to save power if needed
//            stopMonitoringDestination(identifier: region.identifier)
//        }
//    }
    
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
