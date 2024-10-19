//
//  HomeScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import FirebaseAuth

struct HomeScreen: View, PageIdentifier {
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    var page: Destination

    @EnvironmentObject var firebase: FirebaseRepository
    
    @State private var path: [Destination] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: ProfileScreen(page: .profile, path: $path), label: { Text("Zu Profile") })
                
                
                Button("Logout \(firebase.userProfile?.firstName ?? "")") {
                    Task {
                        try await firebase.logout()
                    }
                }.padding(.top, Theme().padding * 2)

            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                    case .profile: ProfileScreen(page: .profile, path: $path)
                    case .settings: SettingsScreen(page: .settings, path: $path)
                    case .home: HomeScreen(page: .settings)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(page.screen.title)
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "figure.walk")  // Icon rechts im Header
                }
            }
            .navigationTitle("")  // Entfernt die Standardtitel-Navigation
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder func header() -> some View {
        
    }
}

#Preview {
    HomeScreen(page: .home)
        .environmentObject(FirebaseRepository())
}



protocol PageIdentifier {
    var page: Destination { get }
    func navigate(to destination: Destination)
}

enum Destination {
    case home
    case profile
    case settings

    var screen: Page {
        return switch self {
            case .home: Page(title: "Home", route: "/home")
            case .profile: Page(title: "Profile", route: "/profile")
            case .settings: Page(title: "Settings", route: "/settings")
        }
    }
}

struct Page {
    let title: String
    let route: String
}
