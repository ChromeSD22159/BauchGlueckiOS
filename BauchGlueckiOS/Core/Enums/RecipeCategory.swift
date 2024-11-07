//
//  RecipeCategory.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI

enum RecipeCategory: String, CaseIterable {
    case snack, hauptgericht, beilage, dessert, fruehPhase, pueriertePhase, weicheKost, normaleKost, proteinreich, lowFat, lowCarb
    
    var categoryID: String {
        switch self {
        case .snack: return "snack"
        case .hauptgericht: return "hauptgericht"
        case .beilage: return "beilage"
        case .dessert: return "dessert"
        case .fruehPhase: return "frueh-phase"
        case .pueriertePhase: return "puerierte-phase"
        case .weicheKost: return "weiche-kost"
        case .normaleKost: return "normale-kost"
        case .proteinreich: return "proteinreich"
        case .lowFat: return "low-fat"
        case .lowCarb: return "low-carb"
        }
    }
    
    var displayName: String {
        switch self {
        case .snack: return "Snack"
        case .hauptgericht: return "Hauptgericht"
        case .beilage: return "Beilage"
        case .dessert: return "Dessert"
        case .fruehPhase: return "Früh-Phase"
        case .pueriertePhase: return "Pürierte Phase"
        case .weicheKost: return "Weiche Kost"
        case .normaleKost: return "Normale Kost"
        case .proteinreich: return "Proteinreich"
        case .lowFat: return "Low Fat"
        case .lowCarb: return "Low Carb"
        }
    }

    static func fromDisplayName(_ displayName: String) -> RecipeCategory? {
        return RecipeCategory.allCases.first { $0.displayName.lowercased() == displayName.lowercased() }
    }
    
    var image :ImageResource { 
        switch self {
            case .hauptgericht: .hauptgericht
            case .beilage: .beilage
            case .dessert: .dessert
            case .fruehPhase: .fuehPhase
            case .pueriertePhase: .pueriertePhase
            case .weicheKost: .weicheKost
            case .normaleKost: .beilage
            case .proteinreich: .proteinreich
            case .lowFat: .lowFat
            case .lowCarb: .lowCarb
            case .snack: .snack
        }
    }
    
    static func fromCategoryID(_ id: String) -> RecipeCategory? {
        RecipeCategory.allCases.first { $0.categoryID  == id }
    }
}
/*
enum RecipeCategory: String, CaseIterable {
    case snack = "snack"
    case hauptgericht = "hauptgericht"
    case beilage = "beilage"
    case dessert = "dessert"
    case fruehPhase = "frueh-phase"
    case pueriertePhase = "puerierte-phase"
    case weicheKost = "weiche-kost"
    case normaleKost = "normale-kost"
    case proteinreich = "proteinreich"
    case lowFat = "low-fat"
    case lowCarb = "low-carb"

    var displayName: String {
        switch self {
        case .snack: return "Snack"
        case .hauptgericht: return "Hauptgericht"
        case .beilage: return "Beilage"
        case .dessert: return "Dessert"
        case .fruehPhase: return "Früh-Phase"
        case .pueriertePhase: return "Pürierte Phase"
        case .weicheKost: return "Weiche Kost"
        case .normaleKost: return "Normale Kost"
        case .proteinreich: return "Proteinreich"
        case .lowFat: return "Low Fat"
        case .lowCarb: return "Low Carb"
        }
    }

    static func fromDisplayName(_ displayName: String) -> RecipeCategory? {
        return RecipeCategory.allCases.first { $0.displayName.lowercased() == displayName.lowercased() }
    }
}
*/
