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
    let theme = Theme.shared
    
    let firebase: FirebaseService
    
    @State var vm: MealPlanViewModel
    @State var mealToAppOnMealPlan: Recipe? = nil
    
    init(firebase: FirebaseService, context: ModelContext, mealToAppOnMealPlan: Recipe? = nil) {
        self.firebase = firebase
        self.vm = MealPlanViewModel(firebase: firebase, context: context)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: theme.padding) {
                
                Text(formattedDate(vm.currentDate))
                    .padding(.horizontal, theme.padding)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(vm.dates, id: \.self) { date in
                            DayItem(
                                date: date,
                                selectedDate: vm.currentDate,
                                currentMealCount: vm.mealPlanForSelectedDateCount,
                                targetMealCount: firebase.userProfile?.totalMeals ?? 0
                            ) { date in
                                vm.setCurrentDate(date: date)
                            }
                        }
                    }
                    .padding(.vertical, theme.padding)
                }
                .contentMargins(.leading, theme.padding)
                .contentMargins(.trailing, theme.padding)
              
                if let surgeryDateTimeStamp = firebase.userProfile?.surgeryDateTimeStamp {
                    CurrentCalorienLevel(
                        operationTimestamp: Int64(surgeryDateTimeStamp),
                        protein: vm.totalNutrition(for: .protein),
                        carbs: vm.totalNutrition(for: .carbs),
                        sugar: vm.totalNutrition(for: .sugar),
                        fat: vm.totalNutrition(for: .fat)
                    )
                }
                
                if let count = firebase.userProfile?.totalMeals {
                    ForEach(0..<count, id: \.self) { index in
                        
                        let mealOrNull: MealPlanSpot? = vm.mealPlanForSelectedDate?.slots[index - 1]
                        
                        if let recipe = mealOrNull?.recipe {
                            MealPlanSpotCard(recipe: recipe)
                        } else {
                            EmptyMealSpot(index: index) {
                                // TODO: ADD RECIPE
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .onAppear { print("mealToAppOnMealPlan: \(mealToAppOnMealPlan)") }
        }
        .contentMargins(.top, theme.padding)
    }
    
    @ViewBuilder func EmptyMealSpot(
        index: Int,
        onClick: @escaping () -> Void = {}
    ) -> some View {
        HStack {
            Text("\(index + 1).")
            
            Text("Keine Mahlzeit zugewiesen")
            
            Spacer()
            
            Image(systemName: "plus")
                .padding(.horizontal, theme.padding + 5)
                .padding(.vertical, theme.padding)
                .background(theme.backgroundGradient)
                .foregroundStyle(theme.onPrimary)
                .cornerRadius(100)
                .onTapGesture { onClick() }
        }
        .font(.footnote)
        .padding(theme.padding)
        .sectionShadow()
        .padding(.horizontal, theme.padding)
    }
}
 
#Preview {
   MealPlanSpotCard(recipe: mockRecipe)
}


/*
struct MealPlanScreen: View {
    let theme = Theme.shared
    
    let firebase: FirebaseService
    
    @State private var currentDate: Date = Date()
    
    @Query() var mealPlans: [MealPlanDay]
    
    var mealPlanForSelectedDate: MealPlanDay? {
        let plan = mealPlans.filter { plan in
            return Calendar.current.isDate( plan.date , inSameDayAs: self.currentDate)
        }
        return plan.first
    }
    
    var dates: [Date] {
        let cal = Calendar.current
        let today = Date()
        
        var dates: [Date] = []
        
        for i in 0..<30 {
            let date = cal.date(byAdding: .day, value: i, to: today)!
            dates.append(date)
        }
        
        return dates
     }
    
    init(firebase: FirebaseService) {
        self.firebase = firebase
        self.currentDate = Date()

        let userID: String = Auth.auth().currentUser?.uid ?? ""
        _mealPlans = Query(
            filter: #Predicate<MealPlanDay>{ plan in
                plan.userId == userID && plan.isDeleted == false
            }
        )
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: theme.padding) {
                
                Text(formattedDate(currentDate))
                    .padding(.horizontal, theme.padding)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(dates, id: \.self) { date in
                            DayItem(date: date, selectedDate: currentDate) { date in
                                currentDate = date
                            }
                        }
                    }
                    .padding(.vertical, theme.padding)
                }
                .contentMargins(.leading, theme.padding)
                .contentMargins(.trailing, theme.padding)
              
                if let surgeryDateTimeStamp = firebase.userProfile?.surgeryDateTimeStamp {
                    let totalProteins = mealPlanForSelectedDate?.slots.compactMap { $0.recipe?.protein }.reduce(0, +) ?? 0.0
                    let totalCarbs = mealPlanForSelectedDate?.slots.compactMap { $0.recipe?.kcal }.reduce(0, +) ?? 0.0
                    let totalSugar = mealPlanForSelectedDate?.slots.compactMap { $0.recipe?.sugar }.reduce(0, +) ?? 0.0
                    let totalFat = mealPlanForSelectedDate?.slots.compactMap { $0.recipe?.fat }.reduce(0, +) ?? 0.0
                    
                    CurrentCalorienLevel(
                        operationTimestamp: Int64(surgeryDateTimeStamp),
                        protein: Int(totalProteins),
                        carbs: Int(totalCarbs),
                        sugar: Int(totalSugar),
                        fat: Int(totalFat)
                    )
                }
                
                if let count = firebase.userProfile?.totalMeals {
                    ForEach(0..<count, id: \.self) { index in
                        
                        let mealOrNull: MealPlanSpot? = mealPlanForSelectedDate?.slots[index - 1]
                        
                        if let recipe = mealOrNull?.recipe {
                            MealPlanSpotCard(recipe: recipe)
                        } else {
                            EmptyMealSpot(index: index) {
                                // TODO: ADD RECIPE
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .contentMargins(.top, theme.padding)
    }
    
    @ViewBuilder func EmptyMealSpot(
        index: Int,
        onClick: @escaping () -> Void = {}
    ) -> some View {
        HStack {
            Text("\(index + 1).")
            
            Text("Keine Mahlzeit zugewiesen")
            
            Spacer()
            
            Image(systemName: "plus")
                .padding(.horizontal, theme.padding)
                .padding(.vertical, theme.padding + 5)
                .background(theme.backgroundGradient)
                .foregroundStyle(theme.onPrimary)
                .cornerRadius(100)
                .onTapGesture { onClick() }
        }
        .font(.footnote)
        .padding(theme.padding)
        .sectionShadow()
        .padding(.horizontal, theme.padding)
    }
}
*/
