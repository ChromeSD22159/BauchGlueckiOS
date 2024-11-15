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
    
    private func reduceShoppingListItems(mealPlans: [MealPlanDay]) -> [ShoppingListItem] {
        
        // Dictionary mit Kombination aus Name und Einheit als Schlüssel
        var ingredientSums: [String: (amount: Double, unit: String)] = [:]

        for plan in mealPlans {
            for slot in plan.slots {
                guard let recipe = slot.recipe else { continue }
                for ingredient in recipe.ingredients {
                    let lowercasedName = ingredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    let unit = ingredient.unit.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Eindeutiger Schlüssel aus Name und Einheit
                    let key = "\(lowercasedName)-\(unit)"
                    
                    // Summiere die Mengen für gleiche Zutat und Einheit
                    if let amount = ingredient.amountDouble {
                        ingredientSums[key, default: (0.0, unit)].amount += amount
                    }
                }
            }
        }

        // Convert dictionary to ShoppingListItem array with summed amounts
        var finalList: [ShoppingListItem] = []
        for (key, value) in ingredientSums {
            let parts = key.split(separator: "-")
            guard parts.count == 2 else { continue }
            let name = String(parts[0])
            let unit = String(parts[1])
            
            print("\(name) \(unit)") //  ei Stk
            
            finalList.append(ShoppingListItem(name: name, amount: String(format: "%.0f", value.amount), unit: unit, note: ""))
        }

        return finalList
    }
    
    func calculateShoppingList(startDate: Date, endDate: Date, context: ModelContext, onComplete: @escaping (Result<[ShoppingListItem], Error>) -> Void) {
        let foundMealPlans = loadMealPlans(start: startDate, end: endDate)
        
        guard !foundMealPlans.isEmpty else {
            return onComplete(.failure(ShoppingListError.noMealPlansFound))
        }
        
        guard startDate < endDate else {
            return onComplete(.failure(ShoppingListError.invalidDateRange))
        }
        
        let ingredientSums = foundMealPlans
            .flatMap { $0.slots.compactMap { $0.recipe?.ingredients.count } }
            .reduce(0, +)
        
        guard ingredientSums > 0 else {
            return onComplete(.failure(ShoppingListError.noIngredientsFound))
        }
        
        guard let userID = Auth.auth().currentUser?.uid else { return onComplete(.failure(ShoppingListError.noUserFound))}
        
        let shoppingListItems = reduceShoppingListItems(mealPlans: foundMealPlans)
        
        let newListId = UUID()
        let newList = ShoppingList(
            id: newListId,
            name: "ShoppingList vom " + formattedDate(Date()),
            shoppingListId: newListId.uuidString,
            userId: userID,
            descriptionText: "ShoppingList erstellt am: " + formattedDate(Date()),
            startDate: formattedDate(startDate),
            endDate: formattedDate(endDate),
            note: "ShoppingList erstellt am: " + formattedDate(Date()),
            isComplete: false,
            isDeleted: false,
            updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
            items: shoppingListItems
        )
        
        do {
            context.insert(newList)
            try context.save()
        } catch {
            onComplete(.failure(ShoppingListError.insertFailed))
        }
        
        onComplete(.success(shoppingListItems))
    }
    
    func deleteAllMeals(meals: [Recipe]) {
        Task {
            meals.forEach { context.delete($0) }
        }
    }
} 
