//
//  ShopsOnboarding.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/18/24.
//

import SwiftUI
import CoreLocation

struct ShopsOnboarding: View {
    @State var name: String = "Babuaravind"
    @State var email: String = "shop@gmail.com"
    @State var address: String = "1460 Tremont St"
    @State var submit = false
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Merchant Details")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                    TextField("Address", text: $address)
                }
                Button("Submit"){
                    submit = true
//                    self.address = address
                    saveDetails(address: address)
                }
                .alert("Changes Saved!", isPresented: $submit) {
                    Button("OK", role: .cancel) { }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Onboarding Details").font(.headline)
                    }
                }
            }
    }
    }
}

func saveDetails(address: String) {
    let userId = 1
    let geoCoder = CLGeocoder()

    geoCoder.geocodeAddressString(address) { placemarks, error in
        let placemark = placemarks?.first
        let lat = placemark?.location?.coordinate.latitude
        let lon = placemark?.location?.coordinate.longitude
        print("User Id: \(userId) Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
    }
}

#Preview {
    ShopsOnboarding()
}
