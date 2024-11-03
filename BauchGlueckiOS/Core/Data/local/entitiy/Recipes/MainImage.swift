//
//  MainImage.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftData

@Model
class MainImage: Codable {
    @Attribute(.unique) var id: Int
    var url: String
    
    @Relationship(deleteRule: .nullify) var recipe: Recipe?
    
    init(
        id: Int,
        url: String
    ) {
        self.id = id
        self.url = url
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, url
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let url = try container.decode(String.self, forKey: .url)
        
        self.init(id: id, url: url)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url) 
    }
}
