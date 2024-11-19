//
//  MealPlanScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth


struct MealPlanScreen: View {
    @Environment(\.theme) private var theme
    
    let firebase: FirebaseService
    let services: Services
    let currentDate: Date?
    @State var vm: MealPlanViewModel
    
    init(firebase: FirebaseService, services: Services, currentDate: Date? = nil) {
        self.firebase = firebase
        self.services = services
        self.vm = MealPlanViewModel(firebase: firebase, service: services)
        self.currentDate = currentDate
    }
    
    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: theme.layout.padding) {
                    
                    // CURRENT DATE 
                    Text( DateFormatteUtil.formattedFullDate(vm.currentDate))
                        .padding(.horizontal, theme.layout.padding)
                    
                    // Calendar HorizontalScroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(vm.dates, id: \.self) { date in
                                DayItem(
                                    date: date,
                                    selectedDate: vm.currentDate,
                                    currentMealCount: vm.countPlanedMealForDate(date: date),
                                    targetMealCount: firebase.userProfile?.totalMeals ?? 0
                                ) { date in
                                    vm.setCurrentDate(date: date)
                                }
                            }
                        }
                        .padding(.vertical, theme.layout.padding)
                    }
                    .contentMargins(.leading, theme.layout.padding)
                    .contentMargins(.trailing, theme.layout.padding)
                    
                    // Nutrition CARD
                    if let surgeryDateTimeStamp = firebase.userProfile?.surgeryDateTimeStamp {
                        CurrentCalorienLevel(
                            operationTimestamp: Int64(surgeryDateTimeStamp),
                            protein: vm.totalNutrition(for: .protein),
                            carbs: vm.totalNutrition(for: .carbs),
                            sugar: vm.totalNutrition(for: .sugar),
                            fat: vm.totalNutrition(for: .fat)
                        )
                    }
                    
                    // MEALSPOTS
                    if let count = firebase.userProfile?.totalMeals {
                 
                        if let spot = vm.mealPlanForSelectedDate?.slots {
                            ForEach(spot) {
                                let _ = print("--")
                                let _ = print($0.recipe?.name ?? "No recipe")
                            }
                        }
                        
                        
                        ForEach(0..<count, id: \.self) { index in
                            if let mealPlan = vm.mealPlanForSelectedDate, mealPlan.slots.count > index {
                                let spot = mealPlan.slots[index]
                                
                                if let recipe = spot.recipe {
                                    MealPlanSpotCard(recipe: recipe)
                                        .onLongPressGesture {
                                            vm.removeMealSpotFromPlan(mealPlanDay: mealPlan, mealPlanSpotId: spot.MealPlanSpotId.uuidString)
                                        }
                                } else {
                                    EmptyMealSpot(index: index, firebase: firebase, date: vm.currentDate)
                                }
                            } else {
                                EmptyMealSpot(index: index, firebase: firebase, date: vm.currentDate)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .contentMargins(.top, theme.layout.padding)
            .onAppLifeCycle(appearAndActive: {
                vm.loadMealPlans()
            })
            .onAppear {
                if let currentDate = currentDate {
                    vm.currentDate = currentDate
                }
            }
        }
    }
}

#Preview {
   MealPlanSpotCard(recipe: mockRecipe)
}