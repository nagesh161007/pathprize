//
//  MapView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/24/24.
//

import Foundation
import SwiftUI
import MapKit

enum QuestStatus {
    case locked
    case unlocked
    case completed
}


struct MapView: View {
    @State private var mapItems: [MKMapItem] = []
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedMapItem: MKMapItem?
    @State private var questStatus: QuestStatus = .locked

    @State private var route: MKRoute?
    @State private var isPresented = true
    @State private var sheetHeight: CGFloat = 120
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var isLookAroundPresented = false
    @State private var isArViewPresented = false

    private let locationManager = LocationManager.shared

    var body: some View {
        ZStack(alignment: .bottom)  {
            Map(position: $position, selection: $selectedMapItem) {
                ForEach(mapItems, id: \.self) { mapItem in
                    Marker(item: mapItem)
                }
                
                if let route = route {
                    MapPolyline(route)
                        .stroke(Color.blue, lineWidth: 5)
                }
                
                ForEach(mapItems, id: \.self) { mapItem in
                    MapCircle(center: mapItem.placemark.coordinate, radius: 300)
                        .foregroundStyle(.accent.opacity(0.4))
                }
                
                UserAnnotation()
            }.mapControls{
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }.onChange(of: locationManager.hasReachedLocation) {
                updateQuestStatusIfNeeded()
            }
            .onChange(of: locationManager.region, {
                withAnimation {
                    position = .region(locationManager.region)
                }
            })
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            .task(id: selectedMapItem) {
                lookAroundScene = nil
                if let selectedMapItem = selectedMapItem {
                    let request = MKLookAroundSceneRequest(mapItem: selectedMapItem)
                    lookAroundScene = try? await request.scene
                    await requestCalculateDirections()
                }
            }
            
            VStack {
                Spacer()
                // Icon at the top of the bottom sheet
                Button(action: {
                    isLookAroundPresented = true
                }) {
                    Image(systemName: "binoculars.fill")
                        .font(.title3)
                        .padding()
                        .background(Color.black.opacity(selectedMapItem == nil ? 0.2 : 0.5))
                        .foregroundColor(.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .opacity(selectedMapItem == nil ? 0.5 : 1)
                        .disabled(selectedMapItem == nil)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                BottomSheetView(sheetHeight: $sheetHeight, questStatus: $questStatus, 
                                selectedMapItem: $selectedMapItem, startAction: startNewQuest, claimReward: claimReward,  startNavigation: {
                    Task {
                        print("starting Navigation")
                        await startNavigation()
                    }
                })
            }.sheet(isPresented: $isLookAroundPresented) {
                if let mapItem = selectedMapItem {
                    LocationPreviewLookAroundView(selectedResult: mapItem)
                } else {
                    Text("No Location Selected")
                }
            }.sheet(isPresented: $isArViewPresented) {
                ARContentView()
            }
        }
    }

    private func claimReward(){
        isArViewPresented = true
    }
    
    private func updateQuestStatusIfNeeded() {
        if locationManager.hasReachedLocation {
            questStatus = .completed // Adjust as necessary for your `QuestStatus` values
            print("Quest status updated to unlocked")
        }
    }
    
    private func startNewQuest() {
        print("start New Quest")
        print(locationManager.manager.location)
        if let currentLocation = locationManager.manager.location {
            mapItems = locationManager.generateThreeRandomLocations(currentLocation: currentLocation).map { location in
                MKMapItem(placemark: MKPlacemark(coordinate: location))
            }
            print("mapItem count", mapItems.count)
            position = .region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000))
        }
    }
    
    private func startNavigation() async {
        print("Going to call monitoing for selected Location")
        await locationManager.startRegionMonitoring(monitoringlocation: (selectedMapItem?.placemark.coordinate)!)
       let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        selectedMapItem?.openInMaps(launchOptions: launchOptions)
    }

    private func requestCalculateDirections() async {
        guard let selectedMapItem = selectedMapItem,
              let currentUserLocation = locationManager.manager.location else { return }

        let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
        route = await calculateDirections(from: startingMapItem, to: selectedMapItem)
    }
}

struct BottomSheetView: View {
    @Binding var sheetHeight: CGFloat
    @Binding var questStatus: QuestStatus
    @Binding var selectedMapItem: MKMapItem?
    var startAction: () -> Void
    var claimReward: () -> Void
    var startNavigation: () -> Void
    var minHeight: CGFloat = 120  // Default minimum height
    var maxHeight: CGFloat = 400  // Maximum height when expanded

    var body: some View {
        VStack {
            HStack {
                Text("Embark on Today's Adventure")
                    .font(.title2)
                    .foregroundColor(.primaryText)
                    .padding()
                    .fontWeight(.bold)

                Spacer()

                if questStatus == .unlocked {
                    Button(action: selectedMapItem != nil ? startNavigation : {},
                           label: {
                               HStack {
                                   Image(systemName: selectedMapItem != nil ? "play.circle.fill" : "play.circle")
                                       .font(.title2)
                                   Text("Start").fontWeight(.bold)
                               }
                               .padding()
                               .foregroundColor(.white)
                               .background(selectedMapItem != nil ? Color.green : Color.gray)
                               .cornerRadius(8)
                           })
                           .disabled(selectedMapItem == nil) // Disable the button if no map item is selected
                           .opacity(selectedMapItem != nil ? 1.0 : 0.5) // Reduced opacity if no map item is selected
                } else if questStatus == .completed {
                    Button(action: {
                        claimReward()
                    }) {
                        HStack {
                            Image(systemName: "arkit")
                                .font(.title2)
                            Text("Claim Reward").fontWeight(.bold)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                } else {
                    Button(action: {
                        questStatus = .unlocked
                        startAction()
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                            Text("Unlock").fontWeight(.bold)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: sheetHeight)
        .background(Color.white)
        .cornerRadius(15)
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

