//
//  TableEntitiy.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

enum TableEntitiy: String {
    case COUNTDOWN_TIMER = "countdownTimer"
    case SYNC_HISTORY = "syncHistory"
    case WEIGHT = "weight"
    case NODE = "node"
    case WATER_INTAKE = "waterIntake"
    case MEDICATION = "medication"
    case Meal, Recipe = "meal"
    case MEAL_PLAN = "mealPlan"

    func getTableName(name: String) -> TableEntitiy? {
        return TableEntitiy(rawValue: name)
    }
}
