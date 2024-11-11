//
//  Destination.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import Foundation

enum Destination {
    case home
    case timer
    case profile
    case settings
    case addNote
    case notes
    case medication
    case weight
    case recipeCategories, recipeCategoryList, detailRecipes, searchRecipes
    case shoppingList, shoppingListDetail
    case mealPlan

    var screen: Page {
        return switch self {
            case .home: Page(title: "Home", route: "/home")
            case .profile: Page(title: "Profile", route: "/profile")
            case .timer: Page(title: "Countdown Timer", route: "/countdownTimer")
            case .settings: Page(title: "Einstellungen", route: "/settings")
            case .addNote: Page(title: "Notiz hinzufügen", route: "/addNote")
            case .notes: Page(title: "Notizen", route: "/Notes")
            case .medication: Page(title: "Medikation", route: "/medication")
            case .weight: Page(title: "Gewichtskontrolle", route: "/weights")
            case .recipeCategories: Page(title: "Rezept Kategorien", route: "/recipeCategories")
            case .detailRecipes: Page(title: "Rezept", route: "/datailCategories")
            case .recipeCategoryList: Page(title: "Rezepte Suchen", route: "/searchCategories")
            case .searchRecipes: Page(title: "Rezepte Suchen", route: "/searchCategories")
            case .shoppingList: Page(title: "Shopping Listen", route: "/shoppingList")
            case .shoppingListDetail: Page(title: "Shopping Liste", route: "/shoppingList")
            case .mealPlan: Page(title: "Mahlzeiten Planer", route: "/mealPlan")
        }
    }
}

struct Page {
    let title: String
    let route: String
}
