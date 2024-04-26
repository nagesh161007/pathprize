//
//  ARViewExtensions.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
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
