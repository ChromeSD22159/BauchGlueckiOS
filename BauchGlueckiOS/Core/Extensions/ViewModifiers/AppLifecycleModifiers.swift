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
