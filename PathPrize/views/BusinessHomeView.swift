//
//  BusinessHomeView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/27/24.
//

import Foundation

import Foundation
import SwiftUI
import MapKit

struct BusinessHomeView: View {
    @State private var selectedTab: String = "home" // Default to Home

    var body: some View {
        TabView(selection: $selectedTab) {
            
            OffersView()
                .tabItem {
                    Image(systemName: "gift")
                    Text("Offers")
                }
                .tag("offer").navigationTitle("Offers")
            
            BusinessSettings()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag("settings").navigationTitle("Settings")
            
            QRView()
                .tabItem {
                    Image(systemName: "qrcode")
                    Text("Scan QR")
                }
                .tag("scanqr").navigationTitle("Scan QR")

        }.onAppear {
            NotificationManager.requestNotificationAuthorization()
        }
    }
}

struct BusinessView: View { var body: some View { Text("Settings") } }

struct Business_HomePage_Previews: PreviewProvider {
    static var previews: some View {
        BusinessHomeView()
    }
}
