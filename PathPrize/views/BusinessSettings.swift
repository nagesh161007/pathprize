//
//  BusinessSettings.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/27/24.
//

import Foundation
import SwiftUI
import Supabase
import PhotosUI

struct BusinessSettings: View {
    @EnvironmentObject var router: Router

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var address: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: AvatarImage?
    @State var submit = false

    var body: some View {
        
        NavigationView{
            
            Form {
                
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
                
                Section(header: Text("Personal Details")) {
                    TextField("First Name", text: $name)
                        .textContentType(.name)
                    TextField("Address", text: $address)
                        .textContentType(.name)
                    TextField("Email", text: $username)
                      .textContentType(.username)
                      .textInputAutocapitalization(.never)
                      .disabled(true)
                }
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
                
                Button(action: {
                    Task {
                      Router.shared.navigate(to:.landingView)
                      try? await supabase.auth.signOut()
                      
                    }
                }) {
                    Text("Sign Out")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(40)
                }
                .padding(.horizontal)
    
            }
            }
            .task {
              await getInitialProfile()
            }
        }
    func updateProfileButtonTapped() {
      Task {
        do {
          let imageURL = try await uploadImage()

          let currentUser = try await supabase.auth.session.user
            
          try await supabase
            .from("business")
            .update([ "name": name, "address": address, "avatar_url": imageURL, "onboarding_state": "COMPLETED" ])
            .eq("id", value: currentUser.id)
            .execute()
            Router.shared.replace(to: .businessHomeView)
        } catch {
          debugPrint(error)
        }
      }
    }
    
    func getInitialProfile() async {
      do {
        let currentUser = try await supabase.auth.session.user

        let profile: Business = try await supabase.database
          .from("business")
          .select()
          .eq("id", value: currentUser.id)
          .single()
          .execute()
          .value

        self.name = profile.name ?? ""
        self.username = profile.email ?? ""
        self.address = profile.address ?? ""
        if let avatarURL = profile.avatar_url, !avatarURL.isEmpty {
                  try await downloadImage(path: avatarURL)
        }

      } catch {
        debugPrint(error)
      }
    }
    
    func loadImage() async {
        guard let selectedPhoto = selectedPhoto else { return }
        if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
            self.profileImage = AvatarImage(data: data)
        }
    }
    
    private func downloadImage(path: String) async throws {
        let data = try await supabase.storage.from("avatars").download(path: path)
        profileImage = AvatarImage(data: data)
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


private extension Settings {
    // Handle if the user turned on/off the daily reminder feature
    private func handleIsScheduledChange(isScheduled: Bool) {
        if isScheduled {
            NotificationManager.requestNotificationAuthorization()
            NotificationManager.scheduleNotification(notificationTimeString: notificationTimeString)
        } else {
            NotificationManager.cancelNotification()
        }
    }
    
    // Handle if the notification time changed from DatePicker
    private func handleNotificationTimeChange() {
        NotificationManager.cancelNotification()
        NotificationManager.requestNotificationAuthorization()
        NotificationManager.scheduleNotification(notificationTimeString: notificationTimeString)
    }
}

#Preview {
    BusinessSettings()
}
