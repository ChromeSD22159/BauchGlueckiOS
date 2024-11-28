//
//  LocalDataScource.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//
import SwiftData
import Foundation
 
var localDataScource: ModelContainer = { 
    let schema = Schema([
        CountdownTimer.self,
        Node.self,
        WaterIntake.self,
        Weight.self,
        Medication.self,
        SyncHistory.self,
        
        Recipe.self,
        Ingredient.self,
        MainImage.self, 
        Category.self,
        MealPlanDay.self,
        MealPlanSpot.self,
        
        ShoppingList.self,
        ShoppingListItem.self
    ])
    
    /*
        let storeURL = URL.documentsDirectory.appending(path: "database.sqlite")
        let config = ModelConfiguration(url: storeURL)
    */
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}() 
