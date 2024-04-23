//
//  HomePage.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/21/24.
//

import Foundation
import SwiftUI

struct HomePage: View {
    @State private var selectedTab: String = "home" // Default to Home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
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
                .tag("reward")

            ActivityView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Activity")
                }
                .tag("activity")
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag("settings")

        }
    }
}


struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager  // Assuming AuthManager handles Supabase auth
    
    var body: some View {
        VStack {
            Text("Home")
            Button("Sign Out") {
                Task {
                    await authManager.signOut()
                    Router.shared.navigate(to: .landingView)
                }
            }
        }
    }
}



// Dummy views for each tab
struct SettingsView: View { var body: some View { Text("Settings") } }
struct RewardsView: View { var body: some View { Text("Rewards") } }
struct ActivityView: View { var body: some View { Text("Activity") } }
