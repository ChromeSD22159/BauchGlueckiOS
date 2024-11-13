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

@main
struct BauchGlueckiOSApp: App, HandleNavigation {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var firebase: FirebaseService
    @StateObject var services: Services
    
    @State var notificationManager: NotificationService? = nil
    @State var backendIsReachable = false
    @State var screen: Screen = Screen.Launch
    let localData: ModelContext
    
    init() {
        do {
            FirebaseApp.configure()
 
            self.localData = localDataScource.mainContext
            let firebaseService = FirebaseService()
            let services = Services(
                env: .localFrederik,
                firebase: firebaseService,
                context: self.localData
            )
            
           _firebase = StateObject(wrappedValue: firebaseService)
           _services = StateObject(wrappedValue: services)
            
        } catch {
            fatalError("Failed to create ModelContainers: \(error)")
        }
    }
     
    let launchDeay = 0.5
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                
                switch screen {
                    case .Launch: LaunchScreen()
                    case .Login: LoginScreen(navigate: handleNavigation)
                    case .Register: RegisterScreen(navigate: handleNavigation)
                    case .ForgotPassword: ForgotPassword(navigate: handleNavigation)
                    case .Home: HomeScreen(page: .home)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                                            GoogleAppOpenAd().requestAppOpenAd(adId: "ca-app-pub-3940256099942544/5575463023")
                                        })
                                    }
                                    .onAppLifeCycle(appearAndActive: {
                                        services.recipesService.fetchRecipesFromBackend()
                                    })
                }
                
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppEnterBackground {
                await firebase.markUserOffline()
            }
            .onAppEnterForeground { checkBackendIsReachable() }
            .onAppear {
                checkBackendIsReachable()
                markUserOnlineOnStart(launchDelay: launchDeay)
            }
            .environmentObject(firebase)
            .environmentObject(services)
            .environment(\.modelContext, localData)
        }
    }
    
    internal func handleNavigation(screen: Screen) {
        self.screen = screen
    }
    
    private func markUserOnlineOnStart(launchDelay: Double) {
        DispatchQueue.main.async {
            notificationManager = NotificationService()

            firebase.authListener { auth, user in
                DispatchQueue.main.asyncAfter(deadline: .now() + launchDelay, execute: {
                    if (user != nil) {
                        handleNavigation(screen: .Home)
                        Task {
                            try await firebase.markUserOnline()
                            
                            try await services.apiService.sendDeviceTokenToBackend()
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
            backendIsReachable = try await services.apiService.isServerReachable()
        }
    }
} 
 

