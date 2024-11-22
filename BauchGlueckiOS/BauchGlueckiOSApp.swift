//
//  BauchGlueckiOSApp.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import GoogleSignIn

@main
struct BauchGlueckiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate 
 
    @StateObject var errorHandling = ErrorHandling()
    
    var body: some Scene {
        WindowGroup {
            ContentView(launchDelay: 0.5, localData: localDataScource.mainContext)
                .googleSignInOnOpen()
                .environment(\.theme, Theme())
                .environmentObject(errorHandling)
        }
    }
}

extension View {
    func googleSignInOnOpen() -> some View {
        modifier(GoogleSignInOnOpen())
    }
}

struct GoogleSignInOnOpen: ViewModifier {
    func body(content: Content) -> some View {
        content.onOpenURL { GIDSignIn.sharedInstance.handle($0) }
    }
}
