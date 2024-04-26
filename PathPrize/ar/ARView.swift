//
//  ARView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/25/24.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

struct ARContentView : View {
    
    @State private var isSupported: Bool = true
    
    var body: some View {
        VStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
                .alert("GeoTracking is not supported in your region", isPresented: .constant(isSupported == false)) {
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("OK")
                    }

                }.onAppear {
                    ARGeoTrackingConfiguration.checkAvailability { isSupported, error in
                        if(!isSupported) {
                            self.isSupported = false
                        }
                    }
                }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        let session = arView.session
        let config = ARGeoTrackingConfiguration()
        config.planeDetection = .horizontal
        session.run(config)
        
        context.coordinator.arView = arView
        context.coordinator.setupCoachingOverlay()
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}

struct ARView_Previews : PreviewProvider {
    static var previews: some View {
        ARContentView()
    }
}
