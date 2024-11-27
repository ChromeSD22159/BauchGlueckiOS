//
//  HomeScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI
import FirebaseAuth
import SwiftData 

struct HomeScreen: View {
    @Environment(\.theme) private var theme
    
    var page: Destination
    @EnvironmentObject var services: Services
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State var mealPlanViewModel: MealPlanViewModel
    @State var weightViewModel: WeightViewModel
    
    init(page: Destination, services: Services) {
        self.page = page
        
        self._mealPlanViewModel = State(initialValue: ViewModelFactory.makeMealPlanViewModel(services: services))
        self._weightViewModel = State(initialValue: ViewModelFactory.makeWeightViewModel(startWeight: 0, services: services))
    }
    
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
                            destination: Destination.home,
                            target: { MealPlanScreen(services: services) }
                        )
                        
                        SectionImageCard(
                            image: .icCookingHutCard,
                            title: "Rezepte",
                            description: "Stöbere durch rezepte und füge sie zu deinem Meal plan hinzu."
                        )
                        .environment(mealPlanViewModel)
                        .sectionShadow(margin: theme.layout.padding)
                        .navigateTo(
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
                            destination: Destination.shoppingList,
                            target: { ShoppingListScreen() }
                        ) 
                        
                        if let userProfile = userViewModel.userProfile {
                            WeightChart()
                                .navigateTo(
                                    destination: Destination.weight,
                                    target: {
                                        WeightsScreen(startWeight: userProfile.startWeight)
                                            .environment(weightViewModel)
                                    },
                                    toolbarItems: {
                                        AddWeightSheetButton(startWeight: userProfile.startWeight)
                                            .environment(weightViewModel)
                                    }
                                )
                        }

                        HomeCountdownTimerWidgetCard()
                            .navigateTo(
                                destination: Destination.timer,
                                target: { TimerScreenButton() },
                                toolbarItems: {
                                    AddTimerSheet()
                                }
                            )
                        
                        
                        
                        ImageCard()
                        
                        NextMedication()
                            .navigateTo( 
                                destination: Destination.medication,
                                target: { MedicationScreen(services: services) },
                                toolbarItems: {
                                    AddMedicationSheet()
                                }
                            )
                        
                        if let userProfile = userViewModel.userProfile {
                            WaterIntakeCard(intakeTarget: userProfile.waterDayIntake)
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
                            .onTapGesture { homeViewModel.toggleSettingSheet() }
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppLifeCycle(appearAndActive: {
            homeViewModel.openOnboardingSheetWhenNoProfileIsGiven()
            
            services.fetchFrombackend()
        })
        .fullScreenCover(isPresented: $userViewModel.isUserProfileSheet, onDismiss: {
            services.fetchFrombackend()
        }, content: {
            OnBoardingUserProfileSheet(isUserProfileSheet: $homeViewModel.isUserProfileSheet)
        })
        .settingSheet(isSettingSheet: $homeViewModel.isSettingSheet, userViewModel: userViewModel, onDismiss: {})
    }
}

#Preview {
    SectionImageCard(
        image: .icCookingHutCard,
        title: "Shoppinglist",
        description: "Erstelle aus deinem Mealplan eine Shoppingliste."
    )
}
