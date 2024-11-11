//
//  Ingredient.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 01.11.24.
//

import SwiftData


@Model
class Ingredient: Codable {
    @Attribute(.unique) var id: Int
    var component: String?
    var name: String
    var amount: String
    var unit: String
    @Relationship(deleteRule: .nullify) var recipe: Recipe?
    
    init(id: Int, component: String?, name: String, amount: String, unit: String) {
        self.id = id
        self.component = component
        self.name = name
        self.amount = amount
        self.unit = unit
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, component = "__component", name, amount, unit, recipe
    }
        
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let component = try container.decodeIfPresent(String.self, forKey: .component)
        let name = try container.decode(String.self, forKey: .name)
        let amount = try container.decode(String.self, forKey: .amount)
        let unit = try container.decode(String.self, forKey: .unit)
        
        self.init(id: id, component: component, name: name, amount: amount, unit: unit)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(component, forKey: .component)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(unit, forKey: .unit)
    }
}

extension Ingredient {
    var amountDouble: Double? {
        Double(amount)
    }
}
