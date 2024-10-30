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
    let theme = Theme.shared
    
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    var page: Destination

    @State var isSettingSheet: Bool = false
    @State var isUserProfileSheet: Bool = false
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var firebase: FirebaseService
    @EnvironmentObject var services: Services
    
    @State private var path: [Destination] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                      
                        SectionImageCard(image: .icMealPlan,title: "MealPlaner",description: "Erstelle deinen MealPlan, indifiduell auf deine bedürfnisse.")
                            .sectionShadow(margin: theme.padding)
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen() }
                            )
                        
                        SectionImageCard(image: .icKochhut,title: "Rezepte",description: "Stöbere durch rezepte und füge sie zu deinem Meal plan hinzu.")
                            .sectionShadow(margin: theme.padding)
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen() }
                            )
                        
                        SectionImageCard(image: .icCartMirrored,title: "Shoppinglist",description: "Erstelle aus deinem Mealplan eine Shoppingliste.")
                            .sectionShadow(margin: theme.padding)
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen() }
                            )
                        
                        HomeWeightMockCard()
                            .padding(.horizontal, 10)

                        HomeCountdownTimerWidgetCard()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreen() },
                                toolbarItems: {
                                    AddTimerSheet()
                                }
                            )
                        
                        
                        
                        ImageCard()
                        
                        NextMedication()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.medication,
                                target: { MedicationScreen() },
                                toolbarItems: {
                                    AddMedicationSheet()
                                }
                            )
                        
                        if let intakeTarget = firebase.userProfile?.waterDayIntake {
                            WaterIntakeCard(intakeTarget: intakeTarget)
                                .sectionShadow(margin: theme.padding)
                        }
                    }
                    .padding(.top, 10)
                    
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
        .onAppLifeCycle(appearAndActive: {
            openOnboardingSheetWhenNoProfileIsGiven()
        })
        .fullScreenCover(isPresented: $isUserProfileSheet, onDismiss: {
            services.fetchFrombackend()
        }, content: {
            OnBoardingUserProfileSheet(isUserProfileSheet: $isUserProfileSheet)
        })
        .onAppLifeCycle(
            appear: {
                services.fetchFrombackend()
            }, active: {
                services.fetchFrombackend()
            }
        )
        .settingSheet(isSettingSheet: $isSettingSheet, authManager: firebase, services: services, onDismiss: {})
    }
    
    private func openOnboardingSheetWhenNoProfileIsGiven() {
        if let userID = Auth.auth().currentUser?.uid {
            firebase.readUserProfileById(userId: userID, completion: { profile in
                if profile == nil {
                    isUserProfileSheet = true
                }
            })
        }
    }
}


