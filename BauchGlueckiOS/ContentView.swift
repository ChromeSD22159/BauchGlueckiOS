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
    @EnvironmentObject var errorHandling: ErrorHandling
     
    @StateObject var services: Services
    
    @State var screen: Screen = .Launch
    @State var notificationManager: NotificationService? = nil
    @State var backendIsReachable = false
     
    var userViewModel: UserViewModel = UserViewModel()
    
    let launchDelay: Double
    let localData: ModelContext
    
    init(launchDelay: Double, localData: ModelContext) {
        let services = Services(
            env: .production,
            context: localData
        )
         
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
            }
        }
        .onAppEnterBackground { markUserOnline() }
        .environmentObject(services)
        .environmentObject(userViewModel)
        .environment(\.modelContext, localDataScource.mainContext)
        .onAppear {
            Task {
                do {
                    try await checkBackendIsReachable()
                    
                    try await userViewModel.checkIfUserIsLoggedIn()
                } catch {
                    userViewModel.isUserProfileSheet = true
                }
            }
             
            markUserOnlineOnStart(launchDelay: launchDelay)
        }
    }
    
    private func markUserOnline() {
        Task {
            do {
                if let user = Auth.auth().currentUser {
                    try await FirebaseService.markUserOnline(user: user)
                }
            } catch {
                //print(error)
            }
        }
    }
    
    private func handleNavigation(screen: Screen) {
        withAnimation(.easeInOut) {
            self.screen = screen
        }
    }
    
    private func markUserOnlineOnStart(launchDelay: Double) {
        Task {
            notificationManager = NotificationService()
            
            do {
                if let user = Auth.auth().currentUser {
                    handleNavigation(screen: .Home)
                    try await FirebaseService.markUserOnline(user: user)
                    
                    try await services.apiService.sendDeviceTokenToBackend()
                } else {
                    handleNavigation(screen: .Login)
                }
                
                await notificationManager?.getAuthStatus()
                await notificationManager?.request()
            } catch {
                errorHandling.handle(error: error)
            }
        }
    }
    
    private func checkBackendIsReachable() async throws {
        backendIsReachable = try await services.apiService.isServerReachable() 
    }
}

#Preview {
    ContentView(launchDelay: 0.5, localData: previewDataScource.mainContext) 
}
