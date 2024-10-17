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
    var body: some Scene {
        WindowGroup {
            LoginScreen()
                .onAppear{
                    listAllFonts()
                }
        }
        .modelContainer(localDataScource)
    }
}

func listAllFonts() {
    for family in UIFont.familyNames {
        print("Font family: \(family)")
        for font in UIFont.fontNames(forFamilyName: family) {
            print("  Font name: \(font)")
        }
    }
}
