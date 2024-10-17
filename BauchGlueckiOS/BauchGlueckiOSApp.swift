//
//  BauchGlueckiOSApp.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import SwiftData

@main
struct BauchGlueckiOSApp: App {
    @State var screen = Screens.Login
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch screen {
                    case .Login: LoginScreen() { screen in
                        self.screen = screen
                    }
                    case .Register: RegisterScreen() { screen in
                        self.screen = screen
                    }
                    case .ForgotPassword: EmptyView()
                }
            }
            .onAppear{
                listAllFonts()
            }
        }
        .modelContainer(localDataScource)
       
    }
}

enum Screens {
    case Login, Register, ForgotPassword
}
