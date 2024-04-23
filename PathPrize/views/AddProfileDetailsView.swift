//
//  AddProfileDetailsView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/21/24.
//

import Foundation

import SwiftUI
import PhotosUI
import Supabase

struct PersonalInfoView: View {
    @EnvironmentObject var router: Router

    @State private var firstname: String = ""
    @State private var username: String = ""
    @State private var lastname: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var distance: Double = 2 // Default to 2 miles
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: AvatarImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Add Profile Details")
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
                TextField("First Name", text: $firstname)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
                TextField("Last Name", text: $lastname)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
                TextField("User Name", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
                
                VStack {
                    Slider(value: $distance, in: 1...10, step: 1).padding(.vertical)
                    Text("Set your goal: \(Int(distance)) miles").padding(.vertical)
                }
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
            
          try await supabase
            .from("profiles")
            .update([ "firstname": firstname,  "lastname": lastname,  "username": username, "avatar_url": imageURL, "onboarding_state": "COMPLETED" ])
            .eq("id", value: currentUser.id)
            .execute()
            Router.shared.replace(to: .homeView)
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


struct PersonalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalInfoView()
    }
}
