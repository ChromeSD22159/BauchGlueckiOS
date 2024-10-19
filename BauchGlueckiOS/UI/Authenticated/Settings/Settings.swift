//
//  Settings.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

import SwiftUI

struct ProfileScreen: View {
    var page: Destination
    @Binding var path: [Destination]
    var body: some View {
        VStack {
            NavigationLink(destination: SettingsScreen(page: .settings, path: $path)) {
                Text(Destination.settings.screen.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .navigationTitle(page.screen.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "figure.walk")  // Icon rechts im Header
            }
        }
    }
}

struct SettingsScreen: View {
    var page: Destination
    @Binding var path: [Destination]
    var body: some View {
        VStack {
            NavigationLink(destination: ProfileScreen(page: .profile, path: $path)) {
                Text(Destination.profile.screen.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .navigationTitle(page.screen.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "figure.walk")  // Icon rechts im Header
            }
        }
    }
}
