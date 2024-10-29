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
    case addNote
    case notes

    var screen: Page {
        return switch self {
            case .home: Page(title: "Home", route: "/home")
            case .profile: Page(title: "Profile", route: "/profile")
            case .timer: Page(title: "Countdown Timer", route: "/countdownTimer")
            case .settings: Page(title: "Einstellungen", route: "/settings")
            case .addNote: Page(title: "Notiz hinzufügen", route: "/addNote")
            case .notes: Page(title: "Notizen", route: "/Notes")
        }
    }
}

struct Page {
    let title: String
    let route: String
}
