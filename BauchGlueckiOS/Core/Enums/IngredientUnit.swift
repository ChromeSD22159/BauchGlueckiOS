//
//  IngredientUnit.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

enum IngredientUnit: String, CaseIterable {
    case gramm, kilogramm, liter, milliliter, stueck, el, tl, prise
    
    var name: String {
        switch self {
            case .gramm: "Gramm"
            case .kilogramm: "Kilogramm"
            case .liter: "Liter"
            case .milliliter: "Milliliter"
            case .stueck: "Stück"
            case .el: "EL"
            case .tl: "TL"
            case .prise: "Prise"
        }
    }
    
    var unit: String {
        switch self {
            case .gramm: "g"
            case .kilogramm: "kg"
            case .liter: "l"
            case .milliliter: "ml"
            case .stueck: "Stück"
            case .el: "EL"
            case .tl: "TL"
            case .prise: "Prise"
        }
    }
    
    static func fromString(_ string: String) -> IngredientUnit {
        return IngredientUnit(rawValue: string) ?? .gramm
    }
    
    static func fromUnit(_ string: String) -> IngredientUnit {
        for unit in IngredientUnit.allCases {
            if unit.unit == string {
                return unit
            }
        }
        return .gramm
    }
}
