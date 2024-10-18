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
    
    @State var screen = Screen.Login
    @State private var firebase: FirebaseRepository? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch screen {
                    case .Login: LoginScreen(navigate: handleNavigation)
                    case .Register: RegisterScreen(navigate: handleNavigation)
                    case .ForgotPassword: ForgotPassword(navigate: handleNavigation)
                    case .Home: HomeScreen(navigate: handleNavigation)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppear{
                listAllFonts()
                
                DispatchQueue.main.async {
                    firebase = FirebaseRepository()
                    firebase?.authListener { auth, user in
                        if (user != nil) {
                            screen = .Home
                        } else {
                            screen = .Login
                        }
                    }
                }
            }
            .environmentObject(firebase ?? FirebaseRepository())
        }
        .modelContainer(localDataScource)
    }
    
    func handleNavigation(screen: Screen) {
        self.screen = screen
    }
}
