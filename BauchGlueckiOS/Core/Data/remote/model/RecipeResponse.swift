//
//  RecipeResponse.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 01.11.24.
//

import Foundation

struct RecipeResponse: Codable {
    let id: Int
    let mealId: String
    let userId: String
    let name: String
    let recipeDescription: String
    let preparation: String
    let preparationTimeInMinutes: Int
    let protein: Double
    let fat: Double
    let sugar: Double
    let kcal: Double
    let isSnack: Bool
    let isPrivate: Bool
    let isDeleted: Bool
    let updatedAtOnDevice: String
    let ingredients: [IngredientResponse]
    let mainImage: MainImageResponse?
    let category: CategoryResponse?
    
    private enum CodingKeys: String, CodingKey {
        case id, mealId, userId, name
        case recipeDescription = "description"
        case preparation, preparationTimeInMinutes, protein, fat, sugar, kcal
        case isSnack, isPrivate, isDeleted, updatedAtOnDevice
        case ingredients, mainImage, category
    }
}

struct IngredientResponse: Codable {
    let component: String?
    let id: Int
    let name: String
    let amount: String
    let unit: String
    
    private enum CodingKeys: String, CodingKey {
        case component = "__component"
        case id, name, amount, unit
    }
}

struct MainImageResponse: Codable {
    let id: Int
    let name: String
    let alternativeText: String?
    let caption: String?
    let width: Int
    let height: Int
    let hash: String
    let ext: String
    let mime: String
    let size: Double
    let url: String
    let previewUrl: String?
    let provider: String
    let providerMetadata: String?
    let folderPath: String

    private enum CodingKeys: String, CodingKey  {
        case id, name, alternativeText, caption, width, height //, formats
        case hash, ext, mime, size, url, previewUrl, provider, providerMetadata = "provider_metadata", folderPath
    }
}

struct CategoryResponse: Codable {
    let id: Int
    let categoryId: String
    let name: String
    
    private enum CodingKeys: String, CodingKey  {
        case id, categoryId, name 
    }
}
