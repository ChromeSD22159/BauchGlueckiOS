//
//  Category.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 01.11.24.
//
import SwiftData

@Model
class Category: Codable {
    @Attribute(.unique) var id: Int
    var categoryId: String
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case id, categoryId, name
    }
    
    init(id: Int, categoryId: String, name: String) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(name, forKey: .name)
    }
}
