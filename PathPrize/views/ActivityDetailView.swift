//
//  ActivityDetailView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/26/24.
//

import Foundation
import SwiftUI
import MapKit


struct ActivityDetailView: View {
    let activityId: Int?
    @State private var activity: Activity?
    @State private var region = MKCoordinateRegion()
    @State private var isLoading = true
    @State private var route: MKRoute?
    @State private var mapItems: [MKMapItem] = []

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading...")
            } else if let activity = activity {
                Map() {
                    ForEach(mapItems, id: \.self) { mapItem in
                        Marker(item: mapItem)
                    }
                    
                    if let route = route {
                        MapPolyline(route)
                            .stroke(Color.blue, lineWidth: 5)
                    }
                    
                    UserAnnotation()
                }.frame(height: 400)
                    .cornerRadius(15)
                    .padding()

                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.headline)
                        .padding(.leading)
                        .padding(.top)

                    HStack {
                        Text("Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(activity.formattedDate)
                            .font(.body)
                    }
                    .padding([.horizontal, .bottom])

                    HStack {
                        Text("Start Time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(DateFormatter.localizedString(from: activity.startTime, dateStyle: .none, timeStyle: .short))
                            .font(.body)
                    }
                    .padding(.horizontal)

                    if let endTime = activity.endTime {
                        HStack {
                            Text("End Time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(DateFormatter.localizedString(from: endTime, dateStyle: .none, timeStyle: .short))
                                .font(.body)
                        }
                        .padding(.horizontal)
                    }
                    
                    Group {
                        Text("Status")
                            .font(.headline)
                            .padding([.horizontal])

                        HStack {
                            Text(activity.status)
                                .font(.title3)
                            Spacer()
                            Image(systemName: activity.status == "COMPLETED" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(activity.status == "COMPLETED" ? .green : .red)
                                .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    
                    Group {
                        Text("Rewards")
                            .font(.headline)
                            .padding([.horizontal])
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Activity Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadActivityDetails()
        }
    }
    
    private func loadActivityDetails() {
        guard let activityId = activityId else { return }

        // Replace with the actual method to fetch activity details
        Task {
            do {
                activity = try await ActivityService.getActivityById(id: activityId)
                await setupMap()
                isLoading = false
            } catch {
                print("Error fetching details: \(error)")
                isLoading = false
            }
        }
    }

    private func setupMap() async {
           guard let activity = activity else { return }

           // Set up the start and end locations as MKMapItems
           var startingMapItem: MKMapItem?
           var endingMapItem: MKMapItem?

           if let startLat = activity.startLocationLatitude, let startLong = activity.startLocationLongitude {
               let startCoordinate = CLLocationCoordinate2D(latitude: startLat, longitude: startLong)
               let startPlacemark = MKPlacemark(coordinate: startCoordinate)
               startingMapItem = MKMapItem(placemark: startPlacemark)
               startingMapItem?.name = "Start Location"
               mapItems.append(startingMapItem!)

               // Set the initial map region around the start location
               region = MKCoordinateRegion(center: startCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
           }

           if let endLat = activity.endLocationLatitude, let endLong = activity.endLocationLongitude {
               let endCoordinate = CLLocationCoordinate2D(latitude: endLat, longitude: endLong)
               let endPlacemark = MKPlacemark(coordinate: endCoordinate)
               endingMapItem = MKMapItem(placemark: endPlacemark)
               endingMapItem?.name = "End Location"
               mapItems.append(endingMapItem!)
           }

           // Calculate route if both start and end map items are available
           if let startMapItem = startingMapItem, let endMapItem = endingMapItem {
              route = await calculateDirections(from: startMapItem, to: endMapItem)
           }
       }
}

struct IdentifiableAnnotation: Identifiable {
    let id = UUID()
    var annotation: MKPointAnnotation
}
