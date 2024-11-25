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
    @EnvironmentObject var services: Services
    
    @EnvironmentObject var userViewModel: UserViewModel
    
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
                                    target: { WeightsScreen(startWeight: userProfile.startWeight) },
                                    toolbarItems: {
                                        AddWeightSheetButton(startWeight: userProfile.startWeight)
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
                                target: { MedicationScreen(modelContext: modelContext, services: services) },
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
               mealPlanViewModel = MealPlanViewModel(service: services)
            }
        })
        .fullScreenCover(isPresented: $userViewModel.isUserProfileSheet, onDismiss: {
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
        .settingSheet(isSettingSheet: $isSettingSheet, userViewModel: userViewModel, onDismiss: {})
      
    }
     
    private func openOnboardingSheetWhenNoProfileIsGiven() {
        Task {
            do {
                let _ = try await FirebaseService.checkUserProfilExist()
            } catch {
                isUserProfileSheet = true
            }
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
