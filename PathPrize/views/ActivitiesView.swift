//
//  ActivitiesView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/26/24.
//

import Foundation

import SwiftUI


struct ActivitiesView: View {
    @StateObject var viewModel = ActivitiesViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.filteredActivities) { activity in
                NavigationLink(destination: ActivityDetailView(activityId: activity.id)) {
                    ActivityRow(activity: activity)
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: viewModel.searchText) { newValue in
                viewModel.applyFilter()
            }
            .navigationTitle("Activities")
            .onAppear {
                viewModel.loadActivities()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
            }
        }
    }
}


struct ActivityRow: View {
    var activity: Activity

    var body: some View {
        VStack(alignment: .leading) {
            Text(activity.relativeFormattedDate)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.vertical, 2)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Miles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }.padding(.vertical, 2)

                    Text("\(String(format: "%.2f", activity.distanceFormatted))")
                        .font(.caption)
                        .foregroundColor(.primaryText)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Duration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }.padding(.vertical, 2)
                    Text(activity.durationFormatted)
                        .font(.caption)
                        .foregroundColor(.primaryText)
                }
                
                Spacer()
                
                if activity.status == "COMPLETED" {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        
                }
            }
        }
        .padding(.horizontal, 2)
    }
}


class ActivitiesViewModel: ObservableObject {
    @Published var activities = [Activity]()
    @Published var filteredActivities = [Activity]()
    @Published var isLoading = false
    @Published var searchText = ""

    func loadActivities() {
        isLoading = true
        Task {
            do {
                self.activities = try await ActivityService.getAllActivities()
                applyFilter()  // Apply initial filter (if any)
            } catch {
                print("Failed to load activities: \(error)")
            }
            isLoading = false
        }
    }

    func applyFilter() {
        if searchText.isEmpty {
            filteredActivities = activities
        } else {
            filteredActivities = activities.filter { activity in
                activity.status.lowercased().contains(searchText.lowercased())
                // Add more conditions to filter as per other activity properties if needed
            }
        }
    }
}
