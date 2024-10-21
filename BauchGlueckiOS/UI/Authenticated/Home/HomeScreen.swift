//
//  HomeScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import FirebaseAuth
import SwiftData

struct HomeScreen: View, PageIdentifier {
    let theme = Theme()
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    var page: Destination

    @State var isSettingSheet: Bool = true
    
    @EnvironmentObject var firebase: FirebaseService
    
    @State private var path: [Destination] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                      
                        SectionImageCard(
                            image: .icMealPlan,
                            title: "MealPlaner",
                            description: "Erstelle deinen MealPlan, indifiduell auf deine bedürfnisse."
                        )
                        
                        SectionImageCard(
                            image: .icKochhut,
                            title: "Rezepte",
                            description: "Stöbere durch rezepte und füge sie zu deinem Meal plan hinzu."
                        )
                        
                        SectionImageCard(
                            image: .icCartMirrored,
                            title: "Shoppinglist",
                            description: "Erstelle aus deinem Mealplan eine Shoppingliste."
                        )
                        
                        
                        HomeCountdownTimerWidgetCard()
                        
                        ImageCard()
                    
                        
                        NavigationLink(destination: ProfileScreen(page: .profile, path: $path), label: { Text("Zu Profile") })

                    }
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
                        Image(systemName: "gear")
                            .onTapGesture {
                                isSettingSheet = !isSettingSheet
                            }
                    }
                }
                .navigationTitle("")  // Entfernt die Standardtitel-Navigation
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .settingSheet(isSettingSheet: $isSettingSheet, authManager: firebase, onDismiss: {}) 
    }
    
    @ViewBuilder func header() -> some View {
        
    }
}

/*
#Preview {
    HomeScreen(page: .home)
        .environmentObject(FirebaseService())
        .modelContainer(localDataScource)
}
*/
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
