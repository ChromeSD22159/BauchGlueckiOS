//
//  LocalDataScource.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//
import SwiftData

var localDataScource: ModelContainer = {
    let schema = Schema([
        CountdownTimer.self,
        SyncHistory.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

enum Entitiy: String {
    case COUNTDOWN_TIMER = "countdownTimer"
    case SYNC_HISTORY = "syncHistory"
    case WEIGHT = "weight"
    case WATER_INTAKE = "waterIntake"
    case MEDICATION = "medication"
    case Meal, Recipe = "meal"
    case MEAL_PLAN = "mealPlan"

    func getTableName(name: String) -> Entitiy? {
        return Entitiy(rawValue: name)
    }
}
