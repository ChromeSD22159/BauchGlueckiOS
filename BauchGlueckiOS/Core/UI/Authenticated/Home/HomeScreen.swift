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
                                target: { TimerScreen(firebase: firebase) }
                            )
                        
                        SectionImageCard(image: .icKochhut,title: "Rezepte",description: "Stöbere durch rezepte und füge sie zu deinem Meal plan hinzu.")
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen(firebase: firebase) }
                            )
                        
                        SectionImageCard(image: .icCartMirrored,title: "Shoppinglist",description: "Erstelle aus deinem Mealplan eine Shoppingliste.")
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen(firebase: firebase) }
                            )

                        HomeCountdownTimerWidgetCard()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen(firebase: firebase) },
                                toolbarItems: {
                                    Image(systemName: "figure")
                                }
                            )
                        
                        ImageCard()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen(firebase: firebase) },
                                toolbarItems: {
                                    Image(systemName: "figure")
                                }
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


struct ScreenHolder<Content: View>: View {
    let theme = Theme()
    let firebase: FirebaseService
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    content()
                }
            }
        }
    }
}
