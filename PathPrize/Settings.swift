//
//  Settings.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/18/24.
//

import SwiftUI

struct Settings: View {
    @State var notify = false
    @State var name = "Babuaravind"
    @State var submit = false
    @State var email = "user@gmail.com"
    @State var dist = 10
    @AppStorage("notificationTimeString") var notificationTimeString = ""

    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                }
                Section(header: Text("Walk Settings")) {
                    Stepper(value: $dist, in: 1...50) {
                        Text("Distance                      \(dist) mi")
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
                Button("Submit"){
                    submit = true
                }
                .alert("Changes Saved!", isPresented: $submit) {
                            Button("OK", role: .cancel) { 
                                handleNotificationTimeChange()
                            }
                        }
                }
            }
            .navigationTitle("Settings")
        }
    }


private extension Settings {
    // Handle if the user turned on/off the daily reminder feature
//    private func handleIsScheduledChange(isScheduled: Bool) {
//        if isScheduled {
//            NotificationManager.requestNotificationAuthorization()
//            NotificationManager.scheduleNotification(notificationTimeString: notificationTimeString)
//        } else {
//            NotificationManager.cancelNotification()
//        }
//    }
    
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
