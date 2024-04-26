//
//  SelectedPlaceDetailView.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/23/24.
//

import SwiftUI
import MapKit

struct SelectedPlaceDetailView: View {
    
    @Binding var mapItem: MKMapItem?
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if let mapItem {
                    PlaceView(mapItem: mapItem)
                }
                
            }
            
            Image(systemName: "xmark.circle.fill")
                .padding([.trailing], 10)
                .onTapGesture {
                    mapItem = nil
                }
        }
        
        if let mapItem = mapItem {
            Button(action: {
                startNavigation(to: mapItem)
            }) {
                HStack {
                    Image(systemName: "car.fill")
                    Text("Start Journey")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private func startNavigation(to mapItem: MKMapItem) {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
    }
}

#Preview {
    
    let apple = Binding<MKMapItem?>(
        get: { PreviewData.apple },
        set: { _ in }
    )
    
    return SelectedPlaceDetailView(mapItem: apple)
}
