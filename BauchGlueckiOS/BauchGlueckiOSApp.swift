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

@main
struct BauchGlueckiOSApp: App, HandleNavigation {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State var notificationManager: NotificationManager? = nil
    
    @State var screen = Screen.Login
    @State private var firebase: FirebaseRepository? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch screen {
                    case .Login: LoginScreen(navigate: handleNavigation)
                    case .Register: RegisterScreen(navigate: handleNavigation)
                    case .ForgotPassword: ForgotPassword(navigate: handleNavigation)
                    case .Home: HomeScreen(page: .home)
                            .onAppear{
                                //listAllFonts()
                                markUserOnlineOnStart()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                                    GoogleAppOpenAd().requestAppOpenAd(adId: "ca-app-pub-3940256099942544/5575463023")
                                })
                            }
                            .onAppEnterForeground {
                                try await firebase?.markUserOnline()
                            }
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppEnterBackground {
                await firebase?.markUserOffline()
            }
            .environmentObject(firebase ?? FirebaseRepository())
        }
        .modelContainer(localDataScource)
    }
    
    internal func handleNavigation(screen: Screen) {
        self.screen = screen
    }
    
    private func markUserOnlineOnStart() {
        DispatchQueue.main.async {
            firebase = FirebaseRepository()
            notificationManager = NotificationManager()
            firebase?.authListener { auth, user in
                if (user != nil) {
                    screen = .Home
                    Task {
                        try await firebase?.markUserOnline()
                    }
                } else {
                    screen = .Login
                }
            }
            
            Task {
                await notificationManager?.getAuthStatus()
                await notificationManager?.request()
            }
        }
    }
}



/*
 Button("Request Notification"){
    Task{
        await notificationManager.request()
    }
}
.buttonStyle(.bordered)
.disabled(notificationManager.hasPermission)
.task {
    await notificationManager.getAuthStatus()
}
 */
