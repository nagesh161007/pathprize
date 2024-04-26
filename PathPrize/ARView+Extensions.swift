//
//  ARView+Extensions.swift
//  LocationAnchors
//
//  Created by Mohammad Azam on 6/11/22.
//

import Foundation
import ARKit
import RealityKit

extension ARView {
    
    func addCoachingOverlay(_ delegate: Coordinator) {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.goal = .geoTracking
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = self.session
        coachingOverlay.delegate = delegate

        self.addSubview(coachingOverlay)
    }
    
}
