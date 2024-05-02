//
//  HomePage.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/21/24.
//

import Foundation
import SwiftUI
import MapKit

struct HomePage: View {
    @State private var selectedTab: String = "home" // Default to Home

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag("home")
            
            RewardsView()
                .tabItem {
                    Image(systemName: "giftcard")
                    Text("Rewards")
                }
                .tag("reward").navigationTitle("Rewards")

            ActivitiesView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Activity")
                }
                .tag("activity").navigationTitle("Recent Activity")
            
            Settings()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag("settings").navigationTitle("Settings")

        }.onAppear {
            NotificationManager.requestNotificationAuthorization()
        }
    }
}


struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
