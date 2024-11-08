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
        case .lowFat: return "Wenig Fett"
        case .lowCarb: return "Wenig Kalorien"
        }
    }
    
    static var allEntriesSortedByName: [RecipeCategory] {
        RecipeCategory.allCases.sorted { $0.displayName < $1.displayName }
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
