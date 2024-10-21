//
//  NotificationManager.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.10.24.
//

import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject{
    @Published private(set) var hasPermission = false
    
    init() {
        Task{
            await getAuthStatus()
        }
    }
    
    func request() async{
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
             await getAuthStatus()
        } catch{
            print(error)
        }
    }
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
        default:
            hasPermission = false
        }
    }
    
    func requesterNoticication(title: String, subTitle: String, min: Int = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(min * 60), repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }

}

func getSavedDeviceToken() -> String? {
    @AppStorage("DEVICE_TOKEN", store: UserDefaults(suiteName: "group.bauchglueck")) var deviceToken = ""
    return deviceToken
}

func setDeviceToken(token: String) {
    @AppStorage("DEVICE_TOKEN", store: UserDefaults(suiteName: "group.bauchglueck")) var deviceToken = ""
    deviceToken = token
}
