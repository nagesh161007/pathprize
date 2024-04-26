//
//  Notifications.swift
//  PathPrize
//
//  Created by Babuaravind Gururaj on 4/18/24.
//

import Foundation
import UserNotifications

struct NotificationManager {
    // Request user authorization for notifications
    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notification authorization granted.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Schedule daily notification at user-selected time
    static func scheduleNotification(notificationTimeString: String) {
        // Convert the time in string to date
        guard let date = DateHelper.dateFormatter.date(from: notificationTimeString) else {
            return
        }
        
        // Instantiate a variable for UNMutableNotificationContent
        let content = UNMutableNotificationContent()
        // The notification title
        content.title = "Time for a Walk!"
        // The notification body
        content.body = "It is time to start your daily walk."
        content.sound = .default
        
        // Set the notification to repeat daily for the specified hour and minute
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "walkReminder", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request)
    }
    
    // Cancel any scheduled notifications
    static func cancelNotification() {
        // Cancel the notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["walkReminder"])
    }
    
    //Congratulations message at trip end
    static func scheduleCongratulationsNotification() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("schedueling Notification")
                let content = UNMutableNotificationContent()
                   content.title = "Congratulations!"
                   content.body = "You've reached your destination! Tap to check your reward."
                   content.sound = .default

                   // Trigger the notification in 5 seconds
                   let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                   // Create the request with a unique identifier
                   let request = UNNotificationRequest(identifier: "congratulations", content: content, trigger: trigger)

                   // Add the request to the notification center
                   UNUserNotificationCenter.current().add(request) { error in
                       if let error = error {
                           print("Error scheduling Hello notification: \(error.localizedDescription)")
                       } else {
                           print("Hello notification scheduled.")
                       }
                   }
                
            } else if let error = error {
                // Handle the error for permission denial
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }


}
