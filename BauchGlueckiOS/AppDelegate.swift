//
//  AppDelegate.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    let deviceTokenService = DeviceTokenService.shared
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        //FirebaseApp.configure()
        
        requestTrackingPermission()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "527fdd25b08283eff613d67c9d301665" ]
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, willEnterForegroundNotification deviceToken: Data) {
        let hexString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(hexString, forKey: "DEVICE_TOKEN")
        
        print("AppDelegate: deviceToken = \(hexString)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            deviceTokenService.setDeviceToken(token: fcm)
        }
    }
}
