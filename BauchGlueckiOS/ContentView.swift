//
//  ContentView.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import SwiftData
import FirebaseAuth
 
struct ContentView: View {
    @StateObject var firebase: FirebaseService
    @StateObject var services: Services
    
    @State var screen: Screen = .Launch
    @State var notificationManager: NotificationService? = nil
    @State var backendIsReachable = false
     
    let launchDelay: Double
    let localData: ModelContext
    
    init(launchDelay: Double, localData: ModelContext) {
        let firebaseService = FirebaseService()
        let services = Services(
            env: .production,
            firebase: firebaseService,
            context: localData
        )
        
        _firebase = StateObject(wrappedValue: firebaseService)
        _services = StateObject(wrappedValue: services)
        self.launchDelay = launchDelay
        self.localData = localData
    }
    
    var body: some View {
        ZStack {
            switch screen {
                case .Launch: LaunchScreen()
                case .Login: LoginScreen(navigate: handleNavigation)
                case .Register: RegisterScreen(navigate: handleNavigation)
                case .ForgotPassword: ForgotPassword(navigate: handleNavigation)
                case .Home: HomeScreen(page: .home)
                                .onAppear {
                                    // MARK: ADS
                                    //services.appStartOpenAd()
                                }
                                .onAppLifeCycle(appearAndActive: {
                                    services.recipesService.fetchRecipesFromBackend()
                                })
            }
        }
        .onAppEnterBackground { await firebase.markUserOffline() }
        .onAppEnterForeground { checkBackendIsReachable() }
        .environmentObject(firebase)
        .environmentObject(services)
        .environment(\.modelContext, localDataScource.mainContext)
        .onAppear {
            checkBackendIsReachable()
            markUserOnlineOnStart(launchDelay: launchDelay)
        }
    }
    
    private func handleNavigation(screen: Screen) {
        withAnimation(.easeInOut) {
            self.screen = screen
        }
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

#Preview {
    ContentView(launchDelay: 0.5, localData: previewDataScource.mainContext) 
}
