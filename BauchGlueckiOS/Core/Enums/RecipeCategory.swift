//
//  RecipeCategory.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI

enum RecipeCategory {
    case hauptgericht, beilage, dessert, fuehPhase, pueriertePhase, weicheKost, normaleKost, proteinreich, lowFat, lowCarb, snack
    
    var image :ImageResource {
        switch self {
            case .hauptgericht: .hauptgericht
            case .beilage: .beilage
            case .dessert: .dessert
            case .fuehPhase: .fuehPhase
            case .pueriertePhase: .pueriertePhase
            case .weicheKost: .weicheKost
            case .normaleKost: .beilage
            case .proteinreich: .proteinreich
            case .lowFat: .lowFat
            case .lowCarb: .lowCarb
            case .snack: .snack
        }
    }
    
    static func from(_ string: String) -> RecipeCategory? {
        switch string.lowercased() {
            case "hauptgericht": return .hauptgericht
            case "beilage": return .beilage
            case "dessert": return .dessert
            case "fuehphase": return .fuehPhase
            case "pueriertephase": return .pueriertePhase
            case "weichekost": return .weicheKost
            case "normaleKost": return .normaleKost
            case "proteinreich": return .proteinreich
            case "lowfat": return .lowFat
            case "lowcarb": return .lowCarb
            case "snack": return .snack
            default: return nil
        }
    }
}
