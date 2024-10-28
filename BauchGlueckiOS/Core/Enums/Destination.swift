//
//  Destination.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import Foundation

enum Destination {
    case home
    case timer
    case profile
    case settings
    case addNode

    var screen: Page {
        return switch self {
            case .home: Page(title: "Home", route: "/home")
            case .profile: Page(title: "Profile", route: "/profile")
            case .timer: Page(title: "Countdown Timer", route: "/countdownTimer")
            case .settings: Page(title: "Einstellungen", route: "/settings")
            case .addNode: Page(title: "Notiz hinzufügen", route: "/addNode")
        }
    }
}

struct Page {
    let title: String
    let route: String
}
