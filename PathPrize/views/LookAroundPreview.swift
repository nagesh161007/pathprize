//
//  LookAroundPreview.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/24/24.
//

import Foundation
import MapKit
import SwiftUI

struct LocationPreviewLookAroundView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    var selectedResult: MKMapItem
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {

            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: selectedResult.placemark.coordinate)
            lookAroundScene = try? await request.scene
        }
    }
}
