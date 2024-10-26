//
//  AppLifecycleModifiers.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.10.24.
//

import SwiftUI

struct OnAppEnterBackground: ViewModifier {
    var action: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                Task {
                    await action()
                }
            }
    }
}

struct OnAppEnterForeground: ViewModifier {
    var action: () async throws -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    try await action()
                }
            }
    }
}

struct AppLifeCycle: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
    
    var appear: () -> Void
    var active: () -> Void
    var inactive: () -> Void
    var background: () -> Void
    
    init(
        appear: @escaping () -> Void,
        active: @escaping () -> Void,
        inactive: @escaping () -> Void,
        background: @escaping () -> Void
    ) {
        self.appear = appear
        self.inactive = inactive
        self.active = active
        self.background = background
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear { appear() }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                   if newPhase == .active { active() }
                   else if newPhase == .inactive { inactive() }
                   else if newPhase == .background { background() }
               }
    }
}

