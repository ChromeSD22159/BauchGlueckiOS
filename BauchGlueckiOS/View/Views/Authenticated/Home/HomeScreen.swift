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
    @Environment(\.theme) private var theme
    
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    var page: Destination

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var firebase: FirebaseService
    @EnvironmentObject var services: Services
    
    @State var isSettingSheet: Bool = false
    @State var isUserProfileSheet: Bool = false
    @State var mealPlanViewModel: MealPlanViewModel?
    
    
    @State private var path: [Destination] = []
    
    @Query() var recipes: [Recipe]
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.color.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                      
                        SectionImageCard(
                            image: .icAppleTableCard,
                            title: "MealPlaner",
                            description: "Erstelle deinen MealPlan, indifiduell auf deine bedürfnisse."
                        )
                        .environment(mealPlanViewModel)
                        .sectionShadow(margin: theme.layout.padding)
                        .navigateTo(
                            firebase: firebase,
                            destination: Destination.home,
                            target: { MealPlanScreen(firebase: firebase, services: services) }
                        )
                        
                        SectionImageCard(
                            image: .icCookingHutCard,
                            title: "Rezepte",
                            description: "Stöbere durch rezepte und füge sie zu deinem Meal plan hinzu."
                        )
                        .environment(mealPlanViewModel)
                        .sectionShadow(margin: theme.layout.padding)
                        .navigateTo(
                            firebase: firebase,
                            destination: Destination.home,
                            target: { RecipeCategoryScreen() },
                            toolbarItems: {
                                AddRecipeButtonWithPicker()
                            }
                        )
                        
                        SectionImageCard(
                            image: .icChartCard,
                            title: "Shoppinglist",
                            description: "Erstelle aus deinem Mealplan eine Shoppingliste."
                        )
                        .sectionShadow(margin: theme.layout.padding)
                        .navigateTo(
                            firebase: firebase,
                            destination: Destination.shoppingList,
                            target: { ShoppingListScreen() }
                        )
                        
                        if let startWeight = firebase.userProfile?.startWeight {
                            WeightChart()
                                .navigateTo(
                                    firebase: firebase,
                                    destination: Destination.weight,
                                    target: { WeightsScreen(startWeight: startWeight) },
                                    toolbarItems: {
                                        AddWeightSheetButton(startWeight: startWeight)
                                    }
                                )
                        }
                       

                        HomeCountdownTimerWidgetCard()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.timer,
                                target: { TimerScreenButton() },
                                toolbarItems: {
                                    AddTimerSheet()
                                }
                            )
                        
                        
                        
                        ImageCard()
                        
                        NextMedication()
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.medication,
                                target: { MedicationScreen(modelContext: modelContext, services: services) },
                                toolbarItems: {
                                    AddMedicationSheet()
                                }
                            )
                        
                        if let intakeTarget = firebase.userProfile?.waterDayIntake {
                            WaterIntakeCard(intakeTarget: intakeTarget)
                                .sectionShadow(margin: theme.layout.padding)
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
                            .onTapGesture { isSettingSheet = !isSettingSheet }
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppLifeCycle(appearAndActive: {
            openOnboardingSheetWhenNoProfileIsGiven()
            
            if mealPlanViewModel == nil {
               mealPlanViewModel = MealPlanViewModel(firebase: firebase, service: services)
            }
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

#Preview {
    SectionImageCard(
        image: .icCookingHutCard,
        title: "Shoppinglist",
        description: "Erstelle aus deinem Mealplan eine Shoppingliste."
    )
}
