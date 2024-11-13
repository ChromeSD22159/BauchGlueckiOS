//
//  MealPlanViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth


@MainActor
@Observable
class MealPlanViewModel {
    var currentDate: Date = Date()
    var mealPlans: [MealPlanDay] = [] 
    
    let mealPlanService: MealPlanService
    let firebase: FirebaseService
    let theme = Theme.shared
    var dates: [Date]
    
    init(firebase: FirebaseService, service: Services) {
        self.firebase = firebase
        self.dates = DateService.nextThirtyDays
        self.mealPlanService = service.mealPlanService
 
        loadMealPlans()
    }
    
    func loadMealPlans() {
        guard let firstDate = dates.first?.startOfDate(), let lastDate = dates.last?.endOfDay() else {
            fatalError("Dates array is empty")
        }
        
        mealPlans = mealPlanService.loadMealPlans(start: firstDate, end: lastDate)
    }
    
    var mealPlanForSelectedDate: MealPlanDay? {
        mealPlanService.getMealPlanForDate(mealPlans: mealPlans, date: self.currentDate)
    }
    
    var mealPlanForSelectedDateCount: Int {
        return mealPlanService.countPlanedMealForDate(date: self.currentDate)
    }

    func totalNutrition(for type: NutritionType) -> Int {
        self.mealPlanService.totalNutrition(mealPlanForSelectedDate: mealPlanForSelectedDate, for: type)
    }
    
    func setCurrentDate(date: Date) {
        currentDate = date
    }
    
    func countPlanedMealForDate(date: Date) -> Int {
        return mealPlanService.countPlanedMealForDate(date: date)
    }
    
    func removeMealSpotFromPlan(mealPlanDay: MealPlanDay, mealPlanSpotId: String) {
        mealPlanService.removeFromMealPlan(mealPlanDay: mealPlanDay, mealPlanSpotId: mealPlanSpotId)
        
        loadMealPlans()
    }
}
