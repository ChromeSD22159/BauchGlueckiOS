//
//  BauchGlueckiOSApp.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import SwiftData

@main
struct BauchGlueckiOSApp: App, HandleNavigation {
    @State var screen = Screen.Login
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
            .onAppear{
                listAllFonts()
            }
        }
        .modelContainer(localDataScource)
    }
    
    
    func handleNavigation(screen: Screen) {
        self.screen = screen
    }
}
