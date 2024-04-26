//
//  Settings.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/18/24.
//

import SwiftUI
import Supabase
import PhotosUI

struct Settings: View {
    @EnvironmentObject var router: Router

    @State private var firstname: String = ""
    @State private var username: String = ""
    @State private var lastname: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var distance: Int = 1
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: AvatarImage?
    @State private var showingImagePicker = false
    @State var submit = false
    @State var notify = false
    @AppStorage("notificationTimeString") var notificationTimeString = ""

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
                    TextField("First Name", text: $firstname)
                        .textContentType(.name)
                    TextField("Last Name", text: $lastname)
                        .textContentType(.name)
                    TextField("Email", text: $username)
                      .textContentType(.username)
                      .textInputAutocapitalization(.never)
                }
                Section(header: Text("Walk Settings")) {
                    Stepper(value: $distance, in: 1...50) {
                        Text("Distance                      \(distance) miles")
                    }
                    Toggle(isOn: $notify) {
                        Text("Daily Notification")
                    }
                    if notify {
                            DatePicker("Notification Time", selection: Binding(
                                get: {
                                    // Get the notification time schedule set by user
                                    DateHelper.dateFormatter.date(from: notificationTimeString) ?? Date()
                                },
                                set: {
                                    // On value set, change the notification time
                                    notificationTimeString = DateHelper.dateFormatter.string(from: $0)
                                }
                            // Only use hour and minute components, since this is a daily reminder
                            ), displayedComponents: .hourAndMinute)
                            // Use wheel date picker style, recommended by Apple
                            .datePickerStyle(WheelDatePickerStyle())
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                        }
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
                .alert("Changes Saved!", isPresented: $submit) {
                            Button("OK", role: .cancel) { 
                                handleNotificationTimeChange()
                            }
                    }
                
//                .toolbar(content: {
//                  ToolbarItem(placement: .topBarLeading){
                    Button("Sign out", role: .destructive) {
                      Task {
                        Router.shared.navigate(to:.landingView)
                        try? await supabase.auth.signOut()
                        
                      }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(40)
//                  }
//                })
                
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
            .from("profiles")
            .update([ "firstname": firstname,  "lastname": lastname,  "username": username, "avatar_url": imageURL, "onboarding_state": "COMPLETED", "distance": String(distance), "notify": String(notify) ])
            .eq("id", value: currentUser.id)
            .execute()
            Router.shared.replace(to: .homeView)
        } catch {
          debugPrint(error)
        }
      }
    }
    
    func getInitialProfile() async {
      do {
        let currentUser = try await supabase.auth.session.user

        let profile: UserProfile = try await supabase.database
          .from("profiles")
          .select()
          .eq("id", value: currentUser.id)
          .single()
          .execute()
          .value

        self.firstname = profile.firstname ?? ""
        self.lastname = profile.lastname ?? ""
        self.username = profile.username ?? ""
        self.distance = profile.distance ?? 1
        if let avatarURL = profile.avatarURL, !avatarURL.isEmpty {
                  try await downloadImage(path: avatarURL)
        }
        self.notify = profile.notify

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
    Settings()
}
