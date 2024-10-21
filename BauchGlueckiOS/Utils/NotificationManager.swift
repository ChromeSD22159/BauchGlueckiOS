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
}

func getSavedDeviceToken() -> String? {
    @AppStorage("DEVICE_TOKEN", store: UserDefaults(suiteName: "group.bauchglueck")) var deviceToken = ""
    return deviceToken
}

func setDeviceToken(token: String) {
    @AppStorage("DEVICE_TOKEN", store: UserDefaults(suiteName: "group.bauchglueck")) var deviceToken = ""
    deviceToken = token
}
