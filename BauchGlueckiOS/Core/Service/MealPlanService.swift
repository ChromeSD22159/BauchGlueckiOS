//
//  MealPlanService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 09.11.24.
//
import SwiftData
import FirebaseAuth

class MealPlanService {
    
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func loadMealPlans(start: Date, end: Date) -> [MealPlanDay] {
        let userID: String = Auth.auth().currentUser?.uid ?? ""
        
        let predicate = #Predicate<MealPlanDay> { plan in
            plan.userId == userID &&
            plan.isDeleted == false &&
            plan.date >= start &&
            plan.date <= end
        }
        
        let query = FetchDescriptor<MealPlanDay>(
            predicate: predicate
        )

        do {
            return try context.fetch(query)
        } catch {
            return  []
        }
    }
    
    func loadMealPlan(date: Date) -> MealPlanDay? {
        let userID: String = Auth.auth().currentUser?.uid ?? ""
        
        let startDate: Date = date.startOfDate()
        let endDate: Date = date.endOfDay()
        
        let predicate = #Predicate<MealPlanDay> { plan in
            plan.userId == userID &&
            plan.isDeleted == false &&
            plan.date >= startDate &&
            plan.date <= endDate
        }
        
        let query = FetchDescriptor<MealPlanDay>(
            predicate: predicate
        )

        do {
            return try context.fetch(query).first
        } catch {
            return nil
        }
    }
    
    func getMealPlanForDate(mealPlans: [MealPlanDay], date: Date) -> MealPlanDay? {
        return mealPlans.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }
    
    /*
    func addToMealPlan(meal: Recipe, date: Date) {
        let userID: String = Auth.auth().currentUser?.uid ?? ""
        let currentTimestamp = Date().timeIntervalSince1970Milliseconds
  
        guard let foundMealPlan = loadMealPlan(date: date) else {
            let mealPlanDay = MealPlanDay(
                userId: userID,
                date: date,
                isDeleted: false,
                updatedAtOnDevice: currentTimestamp
            )
             
            let mealPlanSpot = MealPlanSpot(
                mealPlanDayId: mealPlanDay.mealPlanDayID.uuidString,
                mealId: meal.mealId,
                userId: userID,
                timeSlot: date.ISO8601Format(),
                recipe: meal,
                mealPlanDay: mealPlanDay
            )
            
            mealPlanDay.slots.append(mealPlanSpot)
            context.insert(mealPlanDay)
            context.insert(mealPlanSpot)
            
            return
        }
        
        let mealPlanSpot = MealPlanSpot(
            mealPlanDayId: foundMealPlan.mealPlanDayID.uuidString,
            mealId: meal.mealId,
            userId: userID,
            timeSlot: date.ISO8601Format(),
            recipe: meal,
            mealPlanDay: foundMealPlan
        )
        foundMealPlan.slots.append(mealPlanSpot)
        context.insert(mealPlanSpot)
        foundMealPlan.updatedAtOnDevice = currentTimestamp
    }
    */
    
    func addToMealPlan(meal: Recipe, date: Date) {
        let userID: String = Auth.auth().currentUser?.uid ?? ""
        let currentTimestamp = Date().timeIntervalSince1970Milliseconds
        
        // Prüfe, ob es bereits einen MealPlanDay für das Datum gibt
        if let foundMealPlan = loadMealPlan(date: date) {
            // Erstelle einen neuen MealPlanSpot und füge ihn dem existierenden MealPlanDay hinzu
            let mealPlanSpot = MealPlanSpot(
                mealPlanDayId: foundMealPlan.mealPlanDayID.uuidString,
                mealId: meal.mealId,
                userId: userID,
                timeSlot: date.ISO8601Format(),
                recipe: meal,
                mealPlanDay: foundMealPlan // Beziehung zum vorhandenen MealPlanDay setzen
            )
            
            foundMealPlan.slots.append(mealPlanSpot)
            foundMealPlan.updatedAtOnDevice = currentTimestamp // Aktualisiere die Updated-Zeit
            context.insert(mealPlanSpot)
        } else {
            // Erstelle einen neuen MealPlanDay
            let newMealPlanDay = MealPlanDay(
                userId: userID,
                date: date,
                isDeleted: false,
                updatedAtOnDevice: currentTimestamp
            )
            
            // Erstelle einen neuen MealPlanSpot und setze die Beziehung
            let mealPlanSpot = MealPlanSpot(
                mealPlanDayId: newMealPlanDay.mealPlanDayID.uuidString,
                mealId: meal.mealId,
                userId: userID,
                timeSlot: date.ISO8601Format(),
                recipe: meal,
                mealPlanDay: newMealPlanDay // Setze die Beziehung zum neuen MealPlanDay
            )
            
            newMealPlanDay.slots.append(mealPlanSpot)
            
            // Füge beide Objekte in den Kontext ein
            context.insert(newMealPlanDay)
            context.insert(mealPlanSpot)
        }
        
        // Speichere die Änderungen
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func removeFromMealPlan(mealPlanDay: MealPlanDay, mealPlanSpotId: String) {
        guard let spot = mealPlanDay.slots.first(where: { $0.MealPlanSpotId.uuidString == mealPlanSpotId }) else {
            print("MealPlanSpot with ID \(mealPlanDay.mealPlanDayID) not found in MealPlanDay \(mealPlanDay.mealPlanDayID)")
            return
        }
        
        spot.recipe = nil
        spot.isDeleted = true
        mealPlanDay.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
    }
    
    func countPlanedMealForDate(date: Date) -> Int {
        guard let mealPlanDay = loadMealPlan(date: date) else { return 0 }
        return mealPlanDay.slots.filter { !$0.isDeleted && $0.recipe != nil }.count
    }
    
    func totalNutrition(mealPlanForSelectedDate: MealPlanDay?,for type: NutritionType) -> Int {
        guard let mealPlan = mealPlanForSelectedDate else { return 0 }
        switch type {
            case .protein: return Int(mealPlan.slots.compactMap { $0.recipe?.protein }.reduce(0, +))
            case .carbs: return Int(mealPlan.slots.compactMap { $0.recipe?.kcal }.reduce(0, +))
            case .sugar: return Int(mealPlan.slots.compactMap { $0.recipe?.sugar }.reduce(0, +))
            case .fat: return Int(mealPlan.slots.compactMap { $0.recipe?.fat }.reduce(0, +))
        }
    }
}
