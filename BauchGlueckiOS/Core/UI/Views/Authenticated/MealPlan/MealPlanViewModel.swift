//
//  MealPlanViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

@Observable
class MealPlanViewModel {
    var context: ModelContext
    var currentDate: Date = Date()
    var mealPlans: [MealPlanDay] = []
    
    let firebase: FirebaseService
    let theme = Theme.shared
    var dates: [Date]
    
    init(firebase: FirebaseService, context: ModelContext) {
        self.context = context
        self.firebase = firebase
        self.dates = DateService.nextThirtyDays
        self.loadMealPlans()
    }
    
    var mealPlanForSelectedDate: MealPlanDay? {
        let plan = mealPlans.filter { plan in
            return Calendar.current.isDate(plan.date, inSameDayAs: self.currentDate)
        }
        return plan.first
    }
    
    var mealPlanForSelectedDateCount: Int {
        let plan = mealPlans.filter { plan in
            return Calendar.current.isDate(plan.date, inSameDayAs: self.currentDate)
        }
        return plan.count
    }
    
    func loadMealPlans() {
        let userID: String = Auth.auth().currentUser?.uid ?? ""
        
        let predicate = #Predicate<MealPlanDay> { plan in
            plan.userId == userID && plan.isDeleted == false
        }
        
        let query = FetchDescriptor<MealPlanDay>(
            predicate: predicate
        )

        do {
            mealPlans = try context.fetch(query)
        } catch {
            mealPlans = []
        }
    }
    
    
    
    func totalNutrition(for type: NutritionType) -> Int {
        guard let mealPlan = mealPlanForSelectedDate else { return 0 }
        switch type {
            case .protein: return Int(mealPlan.slots.compactMap { $0.recipe?.protein }.reduce(0, +))
            case .carbs: return Int(mealPlan.slots.compactMap { $0.recipe?.kcal }.reduce(0, +))
            case .sugar: return Int(mealPlan.slots.compactMap { $0.recipe?.sugar }.reduce(0, +))
            case .fat: return Int(mealPlan.slots.compactMap { $0.recipe?.fat }.reduce(0, +))
        }
    }
    
    func setCurrentDate(date: Date) {
        currentDate = date
    }
    
    func getMealPlanForDate(date: Date) -> MealPlanDay? {
        let plan = mealPlans.filter { plan in
            return Calendar.current.isDate(plan.date, inSameDayAs: date)
        }
        return plan.first
    }
    
    func addToMealPlan(meal: Recipe, date: Date) {
        let userID: String = Auth.auth().currentUser?.uid ?? ""
        let currentTimestamp = Date().timeIntervalSince1970Milliseconds
        let foundMealPlan = getMealPlanForDate(date: date)
        
        if let foundMealPlan = foundMealPlan {
            // Create and add MealPlanSpot to the existing MealPlanDay
            let mealPlanSpot = MealPlanSpot(
                mealPlanDayId: foundMealPlan.mealPlanDayID.uuidString,
                mealId: meal.mealId,
                userId: userID,
                timeSlot: date.ISO8601Format(),
                isDeleted: false
            )
            
            foundMealPlan.slots.append(mealPlanSpot)
            context.insert(mealPlanSpot)
            
            do {
                try context.save()
                print("New MealPlanDay and MealPlanSpot saved successfully.")
            } catch {
                print("Error while saving new MealPlanDay and MealPlanSpot: \(error)")
            }
            
        } else {
            // Create new MealPlanDay
            let mealPlanDay = MealPlanDay(
                userId: userID,
                date: date,
                isDeleted: false,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
            )
             
            let mealPlanSpot = MealPlanSpot(
                mealPlanDayId: mealPlanDay.mealPlanDayID.uuidString,
                mealId: meal.mealId,
                userId: userID,
                timeSlot: date.ISO8601Format(),
                isDeleted: false
            )
            
            mealPlanDay.slots.append(mealPlanSpot)
            context.insert(mealPlanDay)
            context.insert(mealPlanSpot)
            
            print("New MealPlanDay created: \(mealPlanDay)")
            print("MealPlanSpot inserted for new MealPlanDay: \(mealPlanSpot)")
        }
    }
    
    func removeFromMealPlan(mealPlanDayId: String, mealPlanSpotId: String) {
        let foundMealPlan = mealPlans.first { plan in
            plan.mealPlanDayID.uuidString == mealPlanDayId
        }
        
        if let foundMealPlan = foundMealPlan {
            foundMealPlan.isDeleted = true
            foundMealPlan.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
            do {
                try context.save()
            } catch {
                print("Error updating \(foundMealPlan.mealPlanDayID)")
            }
        }
    }
}
