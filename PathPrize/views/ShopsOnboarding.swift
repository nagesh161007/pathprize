//
//  ShopsOnboarding.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/18/24.
//

import SwiftUI
import CoreLocation
import PhotosUI
import Storage

struct ShopsOnboarding: View {
    @EnvironmentObject var router: Router

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: AvatarImage?
    @State private var showingImagePicker = false
    @State private var address: String = ""
    @State var submit = false
    
    var body: some View {

        VStack(spacing: 15) {
            Text("Add Shop Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                           if let profileImage {
                               profileImage.image
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 100, height: 100)
                                   .clipShape(Circle())
                                   .overlay(
                                       Circle().stroke(Color.blue, lineWidth: 2)
                                   )
                           } else {
                               Circle()
                                   .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                   .frame(width: 100, height: 100)
                                   .overlay(
                                       Image(systemName: "camera.circle.fill")
                                           .font(.largeTitle)
                                           .foregroundColor(.white)
                                   )
                           }
                       }
                       .onChange(of: selectedPhoto) { _ in
                           Task {
                               await loadImage()
                           }
                       }
            
            VStack(alignment: .leading, spacing: 10) {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
//                TextField("Email", text: $username)
//                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
                TextField("Address", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
            }
            .padding(.horizontal)

            Spacer()
            
            Button(action: {
                updateProfileButtonTapped()
            }) {
                Text("Update Profile")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(40)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    func updateProfileButtonTapped() {
      Task {
        do {
          let imageURL = try await uploadImage()

          let currentUser = try await supabase.auth.session.user
            
          let userId = 1
          let geoCoder = CLGeocoder()

          geoCoder.geocodeAddressString(address) { placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            print("User Id: \(userId) Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
          }
            
          try await supabase
            .from("business")
            .update([ "name": name, "avatar_url": imageURL, "address": address, "onboading_state": "COMPLETED" ])
            .eq("id", value: currentUser.id)
            .execute()
            Router.shared.replace(to: .businessHomeView)
        } catch {
          debugPrint(error)
        }
      }
    }
    
    func loadImage() async {
        guard let selectedPhoto = selectedPhoto else { return }
        if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
            self.profileImage = AvatarImage(data: data)
        }
    }
    
    private func uploadImage() async throws -> String? {
        guard let data = profileImage?.data else { return nil }
        
        let filePath = "\(UUID().uuidString).jpeg"
        
        try await supabase.storage
            .from("avatars")
            .upload(
                path: filePath,
                file: data,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        return filePath
    }

}

#Preview {
    ShopsOnboarding()
}
