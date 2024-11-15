//
//  BauchGlueckiOSApp.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import SwiftData
import AppTrackingTransparency
import FirebaseMessaging

@main
struct BauchGlueckiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate 
 
    var body: some Scene {
        WindowGroup {
            ContentView(launchDelay: 0.5, localData: localDataScource.mainContext)
                .onOpenURL { GIDSignIn.sharedInstance.handle($0) }
        }
        
    } 
}
