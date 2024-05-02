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
    case started
    case completed
    case captured
}

let questNames = [
    "The Lost Chalice of Surnia",
    "Goblin's Hollow Retreat",
    "The Crystal Caves of Torm",
    "Echoes of the Fallen Knight",
    "The Forgotten Library Ruins",
    "Search for the Sunken City",
    "Journey to the Enchanted Glade",
    "Riddle of the Sphinx's Lair",
    "The Dragon's Egg Nest",
    "Secrets of the Ancient Monument"
]


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
    @State private var activityId: Int?
    @State private var isArViewPresented = false
    @State private var isQuestCompleted = false
    
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
                    MapCircle(center: mapItem.placemark.coordinate, radius: 100)
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
                
                if !isQuestCompleted {
                    ActivityStatusView(sheetHeight: $sheetHeight, questStatus: $questStatus,
                                       selectedMapItem: $selectedMapItem, isArViewPresented: $isArViewPresented, startAction: unlockQuest, claimReward: claimReward,   startNavigation: {
                        Task {
                            print("starting Navigation")
                            await startNavigation()
                        }
                    })
                }
            }.sheet(isPresented: $isLookAroundPresented) {
                if let mapItem = selectedMapItem {
                    LocationPreviewLookAroundView(selectedResult: mapItem)
                } else {
                    Text("No Location Selected")
                }
            }.sheet(isPresented: $isArViewPresented, onDismiss: {
                questStatus = .completed
            }) {
                ARContentView()
            }
        }
    }

    private func claimReward() {
        Task {
            do {
                let currentUser = try await supabase.auth.session.user
                // Ensure selectedMapItem and activityId are not nil
                guard let activityId = activityId, let selectedMapItem = selectedMapItem else {
                    print("Error: Missing activityId or selectedMapItem")
                    return
                }
                
                print("Updaing Activity")
                
                print(activityId)

                // Await the updateActivity call
                try await ActivityService.updateActivity(
                    id: activityId,
                    endTime: Date(),
                    endLocationLongitude: selectedMapItem.placemark.coordinate.longitude,
                    endLocationLatitude: selectedMapItem.placemark.coordinate.latitude,
                    status: "COMPLETED"
                )
                
                print("Activity updated successfully.")
                
                let newReward = RewardModel(
                    id: nil,
                    createdAt: Date(),
                    userId: currentUser.id,
                    activityId:  Int64(activityId),
                    rewardObjectUrl: "",
                    status: "NOT_REDEEMED",
                    offerId: 1,
                    qrCode: UUID(),
                    name: "Nike April Sale 30% Off",
                    expiresAt: Date()
                )
                
                try await RewardService.createReward(reward: newReward)
                print("Reward updated successfully.")
                isQuestCompleted = true
            } catch {
                // Handle any errors that occur during the update
                print("Error updating activity: \(error)")
            }
        }
    }
    
    

    
    private func updateQuestStatusIfNeeded() {
        if locationManager.hasReachedLocation {
            questStatus = .captured // Adjust as necessary for your `QuestStatus` values
            print("Quest status updated to unlocked")
        }
    }
    
    private func unlockQuest() async {
        print("start New Quest")
        
        if let currentLocation = locationManager.manager.location {
            mapItems = locationManager.generateThreeRandomLocations(currentLocation: currentLocation).map { location in
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
                let questName = questNames.randomElement()
                mapItem.name = questName
                return mapItem
            }
            print("mapItem count", mapItems.count)
            position = .region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000))
        }
        
        if let currentLocation = locationManager.manager.location {
            // Prepare map items as before
            mapItems = locationManager.generateThreeRandomLocations(currentLocation: currentLocation).map { location in
                MKMapItem(placemark: MKPlacemark(coordinate: location))
            }
            position = .region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000))

        } else {
            print("Current location is not available.")
        }
        
    }
    
    
    private func createActivity(currentLocation: CLLocation) {
        print("Creating Acitivty")
        Task {
            do {
                // Asynchronous fetch of the current user
                let currentUser = try await supabase.auth.session.user
                // Create an Activity with the current user's ID
                let newActivity = Activity(
                    id: nil,
                    createdAt: Date(),
                    userId: currentUser.id,  // Convert user ID to UUID
                    date: Date(),
                    startTime: Date(),
                    endTime: nil,
                    startLocationLatitude: currentLocation.coordinate.latitude,
                    startLocationLongitude: currentLocation.coordinate.longitude,
                    endLocationLatitude: nil,
                    endLocationLongitude: nil,
                    rewardId: nil,
                    status: "STARTED"
                )

                // Attempt to create an activity in the database
                let createdActivity: Activity = try await ActivityService.createActivity(activity: newActivity)
                print(createdActivity)
                activityId = createdActivity.id
                print("Activity created successfully: \(createdActivity)")
            } catch {
                print("Error occurred: \(error)")
            }
        }
    }
    
    private func startNavigation() async {
        questStatus = .started
        if let currentLocation = locationManager.manager.location {
            createActivity(currentLocation: currentLocation)
        }
        print("Going to call monitoing for selected Location")
        await locationManager.startRegionMonitoring(monitoringlocation: (selectedMapItem?.placemark.coordinate)!)
       let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
//        selectedMapItem?.openInMaps(launchOptions: launchOptions)
    }

    private func requestCalculateDirections() async {
        guard let selectedMapItem = selectedMapItem,
              let currentUserLocation = locationManager.manager.location else { return }

        let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
        route = await calculateDirections(from: startingMapItem, to: selectedMapItem)
    }
}

struct ActivityStatusView: View {
    @Binding var sheetHeight: CGFloat
    @Binding var questStatus: QuestStatus
    @Binding var selectedMapItem: MKMapItem?
    @Binding var isArViewPresented: Bool
    var startAction: () async -> Void
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
                } else if questStatus == .started {
                    Button(action: {},
                           label: {
                               HStack {
                                   Image(systemName: selectedMapItem != nil ? "play.circle.fill" : "play.circle")
                                       .font(.title2)
                                   Text("Walk").fontWeight(.bold)
                               }
                               .padding()
                               .foregroundColor(.white)
                               .background(Color.blue)
                               .cornerRadius(8)
                           })
                           .disabled(true) // Disable the button if no map item is selected
                           .opacity(0.5) // Reduced opacity if no map item is selected
                }else if questStatus == .captured {
                    Button(action: {
                        print("reward claim clicked")
                        isArViewPresented = true
                    }) {
                        HStack {
                            Image(systemName: "arkit")
                                .font(.title2)
                            Text("Capture").fontWeight(.bold)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
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
                        Task {
                            await startAction()
                        }
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

