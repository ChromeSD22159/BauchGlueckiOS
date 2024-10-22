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

    @State var isSettingSheet: Bool = false
    
    @EnvironmentObject var firebase: FirebaseService
    
    @State private var path: [Destination] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                      
                        SectionImageCard(image: .icMealPlan,title: "MealPlaner",description: "Erstelle deinen MealPlan, indifiduell auf deine bedürfnisse.")
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: {TimerScreen()}
                            )
                        
                        SectionImageCard(image: .icKochhut,title: "Rezepte",description: "Stöbere durch rezepte und füge sie zu deinem Meal plan hinzu.")
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: {TimerScreen()}
                            )
                        
                        SectionImageCard(image: .icCartMirrored,title: "Shoppinglist",description: "Erstelle aus deinem Mealplan eine Shoppingliste.")
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: {TimerScreen()}
                            )

                        HomeCountdownTimerWidgetCard()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: {TimerScreen()}
                            )
                        
                        ImageCard()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: {TimerScreen()}
                            )
                    
                        
                        NavigationLink(destination: ProfileScreen(page: .profile, path: $path), label: { Text("Zu Profile") })
                    }
                }
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                        case .profile: ProfileScreen(page: .profile, path: $path)
                        case .settings: SettingsScreen(page: .settings, path: $path)
                        case .home: HomeScreen(page: .settings)
                        case .timer: TimerScreen().navigationBackButton(
                                                        color: theme.onBackground,
                                                        destination: Destination.settings,
                                                        firebase: firebase,
                                                        showSettingButton: true
                                                    )
                            
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
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .settingSheet(isSettingSheet: $isSettingSheet, authManager: firebase, onDismiss: {}) 
    }
}

extension View {
    func navigateTo<Target: View>(
        firebase: FirebaseService,
        destination: Destination,
        showSettingButton: Bool = true,
        @ViewBuilder target: @escaping () -> Target = { EmptyView() }
    ) -> some View {
        modifier(
            NavigateTo<Target>(
                destination: destination,
                firebase: firebase,
                showSettingButton: showSettingButton,
                target: target
            )
        )
    }
}

struct NavigateTo<Target: View>: ViewModifier {
    var destination: Destination
    var firebase: FirebaseService
    var showSettingButton: Bool
    @ViewBuilder var target: () -> Target
    
    func body(content: Content) -> some View {
        NavigationLink {
            target()
                .navigationBackButton(
                    color: Theme().onBackground,
                    destination: destination,
                    firebase: firebase,
                    showSettingButton: showSettingButton
                )
        } label: {
            content
        }
    }
}
