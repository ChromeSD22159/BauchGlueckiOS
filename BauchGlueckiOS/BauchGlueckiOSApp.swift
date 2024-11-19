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
 
    var body: some Scene {
        WindowGroup {
            ContentView(launchDelay: 0.5, localData: localDataScource.mainContext)
                .googleSignInOnOpen()
                .environment(\.theme, Theme())
        }
    }
}

extension View {
    func googleSignInOnOpen() -> some View {
        modifier(GoogleSignInOnOpen())
    }
}

struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = Theme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

struct GoogleSignInOnOpen: ViewModifier {
    func body(content: Content) -> some View {
        content.onOpenURL { GIDSignIn.sharedInstance.handle($0) }
    }
}
