//
//  ContentView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/18/24.
//

import SwiftUI
import MapKit

enum DisplayMode {
    case list
    case detail
}

struct ContentView: View {
    
    @State private var query: String = "Coffee"
    @State private var selectedDetent: PresentationDetent = .fraction(0.15)
    @State private var locationManager = LocationManager.shared
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isSearching: Bool = false
    @State private var mapItems: [MKMapItem] = []
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedMapItem: MKMapItem?
    @State private var displayMode: DisplayMode = .list
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var route: MKRoute?
    @State private var randomCoordinates: [CLLocationCoordinate2D] = []
    @State private var showAlert = false
    
    private func search() async {
        
        let searchRegion = locationManager.region
        guard let currentLocation = locationManager.manager.location else {
            print("Current location is not available.")
            isSearching = false
            return
        }
        
        do {
            let allMapItems = try await performSearch(searchTerm: query, visibleRegion: locationManager.region)
            mapItems = allMapItems.filter { mapItem in
                guard let itemLocation = mapItem.placemark.location else { return false }
                // The distance is expected to be in meters, so 3 miles is approximately 4828 meters
                let distance = itemLocation.distance(from: currentLocation)
                return distance >= 4828 - 100 && distance <= 4828 + 100 // You can adjust the range as needed
            }

            isSearching = false
        } catch {
            mapItems = []
            print(error.localizedDescription)
                        
            isSearching = false
        }
        
    }
    
//    private func search() async {
//        
//        let searchRegion = locationManager.region
//        guard let currentLocation = locationManager.manager.location else {
//            print("Current location is not available.")
//            isSearching = false
//            return
//        }
//        
//        do {
//                let allMapItems = try await performSearch(searchTerm: query, visibleRegion: locationManager.region)
//                
//                // Filter results to be about 3 miles away
//                mapItems = allMapItems.filter { mapItem in
//                    guard let itemLocation = mapItem.placemark.location else { return false }
//                    // The distance is expected to be in meters, so 3 miles is approximately 4828 meters
//                    let distance = itemLocation.distance(from: currentLocation)
//                    return distance >= 4828 - 100 && distance <= 4828 + 100 // You can adjust the range as needed
//                }
//                
//                isSearching = false
//            } catch {
//            mapItems = []
//            print(error.localizedDescription)
//            isSearching = false
//        }
//        
//    }
    
//    private func startNavigation(to mapItem: MKMapItem) {
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        mapItem.openInMaps(launchOptions: launchOptions)
//    }
    
    private func requestCalculateDirections() async {
        
        route = nil
        
        if let selectedMapItem {
            guard let currentUserLocation = locationManager.manager.location else { return }
            let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
            
            self.route = await calculateDirections(from: startingMapItem, to: selectedMapItem)
        }
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedMapItem) {
                ForEach(mapItems, id: \.self) { mapItem in
                    Marker(item: mapItem)
                }
                
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
                
                UserAnnotation()
            }
            .onChange(of: locationManager.region, {
                withAnimation {
                    position = .region(locationManager.region)
                }
            })
            .sheet(isPresented: .constant(true), content: {
                VStack {
                    
                    switch displayMode {
                        case .list:
                            SearchBarView(search: $query, isSearching: $isSearching)
                            PlaceListView(mapItems: mapItems, selectedMapItem: $selectedMapItem)
                        case .detail:
                            SelectedPlaceDetailView(mapItem: $selectedMapItem)
                                .padding()
                           
                            if selectedDetent == .medium || selectedDetent == .large {
                                LookAroundPreview(initialScene: lookAroundScene)
                            }
                               
                    }
                    
                    Spacer()
                }
                .presentationDetents([.fraction(0.05), .medium, .large], selection: $selectedDetent)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
            
        }
        
        // New Quest Button
            VStack {
                Spacer()
                Button("Ready for a new Quest") {
                    if let currentLocation = locationManager.manager.location {
                        mapItems = locationManager.generateThreeRandomLocations(currentLocation: currentLocation).map { location in
                            let placemark = MKPlacemark(coordinate: location)
                            return MKMapItem(placemark: placemark)
                        }
                        position = .region(MKCoordinateRegion(center: locationManager.manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 5000, longitudinalMeters: 5000))
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 50)
        }
        .onChange(of: selectedMapItem, {
            if selectedMapItem != nil {
                displayMode = .detail
                //requestCalculateDirections()
            } else {
                displayMode = .list
            }
        })
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .task(id: selectedMapItem) {
            lookAroundScene = nil
            if let selectedMapItem {
                let request = MKLookAroundSceneRequest(mapItem: selectedMapItem)
                lookAroundScene = try? await request.scene
                await requestCalculateDirections()
            }
        }
        .task(id: isSearching, {
            if isSearching {
                await search()
            }
        })
    }
}

#Preview {
    ContentView()
}
