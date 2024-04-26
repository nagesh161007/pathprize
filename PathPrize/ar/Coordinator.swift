//
//  Coordinator.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import RealityKit
import ARKit
import CoreLocation
import Combine

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        get {
            return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
        }
        set (newValue) {
            columns.3.x = newValue.x
            columns.3.y = newValue.y
            columns.3.z = newValue.z
        }
    }
}


class Coordinator: NSObject, CLLocationManagerDelegate, ARCoachingOverlayViewDelegate {
    
    var arView: ARView?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    let modelURL = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/biplane/toy_biplane_idle.usdz")!
    var cancellable: AnyCancellable?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func setupCoachingOverlay() {
        arView?.addCoachingOverlay(self)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let view = self.arView else { return }
        
        let tapLocation = recognizer.location(in: view)
        
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
           print("object tapped")
        }
        
    }

    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
        let coordinate = CLLocationCoordinate2D(latitude: 42.33196248895828, longitude: -71.09752618431293)
        
        let geoAnchor = ARGeoAnchor(coordinate: coordinate)
        let anchor = AnchorEntity(anchor: geoAnchor)
        self.loadModel(from: modelURL, to: anchor)
        
//        downloadModel(from: modelURL) { [weak self] localURL in
//          self?.loadModel(from: localURL, to: anchor)
//        }
        print("adding Anchor")
        arView?.session.add(anchor: geoAnchor)
        arView?.scene.addAnchor(anchor)
    }
    
    private func downloadModel(from url: URL, completion: @escaping (URL) -> Void) {
            print("Downloading Model")
            let task = URLSession.shared.downloadTask(with: url) { location, response, error in
                guard let location = location else {
                    print("Failed to download model: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destination = documents.appendingPathComponent(url.lastPathComponent)
                
                try? FileManager.default.removeItem(at: destination)
                do {
                    try FileManager.default.moveItem(atPath: location.path, toPath: destination.path)
                    DispatchQueue.main.async {
                        completion(destination)
                    }
                } catch {
                    print("Could not move downloaded file: \(error)")
                }
            }
            task.resume()
        }

        private func loadModel(from url: URL, to anchor: AnchorEntity) {
            
            print("Loading model to scene")
            
            cancellable = ModelEntity.loadAsync(named: "shoe")
                .sink { loadCompletion in
                    if case let .failure(error) = loadCompletion {
                        print("Unable to load model \(error)")
                    }
                    
                    self.cancellable?.cancel()
                    
                } receiveValue: { entity in
                    anchor.name = "ShoeAnchor"
                    entity.scale =  SIMD3<Float>(0.5, 0.5, 0)
                    anchor.addChild(entity)
                }
            
            
            print("Loading model to scene")
//            cancellable = ModelEntity.loadModelAsync(contentsOf: url)
//                .sink(receiveCompletion: { [weak self] loadCompletion in
//                    if case let .failure(error) = loadCompletion {
//                        print("Unable to load model: \(error)")
//                    }
//                    self?.cancellable?.cancel()
//                }, receiveValue: { entity in
//                    print("adding Model to scene")
//
//                    entity.scale = SIMD3<Float>(2.0, 2.0, 5.0)
//
//                    anchor.name = "GeoModelAnchor"
//                    anchor.addChild(entity)
//
//
//                    // Play animations if available
//                    if let animation = entity.availableAnimations.first {
//                        entity.playAnimation(animation.repeat())
//                    }
//                })
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
   
}
