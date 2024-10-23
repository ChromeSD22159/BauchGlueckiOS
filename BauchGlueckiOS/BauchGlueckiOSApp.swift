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

    let client = StrapiApiClient(environment: .production)
    @State var notificationManager: NotificationService? = nil
    
    @State var screen: Screen = Screen.Launch
    @State private var firebase: FirebaseService? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch screen {
                    case .Launch: LaunchScreen()
                    case .Login: LoginScreen(navigate: handleNavigation)
                    case .Register: RegisterScreen(navigate: handleNavigation)
                    case .ForgotPassword: ForgotPassword(navigate: handleNavigation)
                    case .Home: HomeScreen(page: .home)
                            .onAppear{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                                    GoogleAppOpenAd().requestAppOpenAd(adId: "ca-app-pub-3940256099942544/5575463023")
                                })
                            }
                            .onAppEnterForeground {
                                try await firebase?.markUserOnline()
                                fetchBackendData()
                            }
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppEnterBackground {
                await firebase?.markUserOffline()
            }
            .onAppear {
                markUserOnlineOnStart(launchDelay: 1.5)
                
                checkBackendIsReachable()
            }
            .environmentObject(firebase ?? FirebaseService())
        }
        .modelContainer(localDataScource)
    }
    
    internal func handleNavigation(screen: Screen) {
        self.screen = screen
    }
    
    private func markUserOnlineOnStart(launchDelay: Double) {
        DispatchQueue.main.async {
            firebase = FirebaseService()
            notificationManager = NotificationService()
            
            guard let fb = firebase else { return }

            fb.authListener { auth, user in
                DispatchQueue.main.asyncAfter(deadline: .now() + launchDelay, execute: {
                    if (user != nil) {
                        handleNavigation(screen: .Home)
                        Task {
                            try await firebase?.markUserOnline()
                        }
                       
                    } else {
                        handleNavigation(screen: .Login)
                    }
                })
            }
            
            Task {
                await notificationManager?.getAuthStatus()
                await notificationManager?.request()
            }
        }
    }
    
    private func checkBackendIsReachable() {
        Task {
            try await isServerReachable(client: client)
        }
    }
    
    // TODO: SYNC REMOTE
    private func fetchBackendData() {
        let repo = Services()
        repo.countdownRepository.fetchTimerFromBackend()
    }
}
