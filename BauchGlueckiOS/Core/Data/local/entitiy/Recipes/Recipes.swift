//
//  Recipes.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 01.11.24.
//
import SwiftData

@Model
class Recipe: Identifiable, Hashable {
    @Attribute(.unique) var id: Int
    var mealId: String
    var userId: String
    var name: String
    var recipeDescription: String
    var preparation: String
    var preparationTimeInMinutes: Int
    var protein: Double
    var fat: Double
    var sugar: Double
    var kcal: Double
    var isSnack: Bool
    var isPrivate: Bool
    var isDeleted: Bool
    var updatedAtOnDevice: String
    
    // Relationships
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]
    @Relationship(deleteRule: .nullify) var mainImage: MainImage?
    @Relationship(deleteRule: .nullify) var category: Category?
    
    init(
        id: Int, mealId: String, userId: String, name: String, recipeDescription: String,
        preparation: String, preparationTimeInMinutes: Int, protein: Double, fat: Double,
        sugar: Double, kcal: Double, isSnack: Bool, isPrivate: Bool, isDeleted: Bool,
        updatedAtOnDevice: String, ingredients: [Ingredient] = [], mainImage: MainImage? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.mealId = mealId
        self.userId = userId
        self.name = name
        self.recipeDescription = recipeDescription
        self.preparation = preparation
        self.preparationTimeInMinutes = preparationTimeInMinutes
        self.protein = protein
        self.fat = fat
        self.sugar = sugar
        self.kcal = kcal
        self.isSnack = isSnack
        self.isPrivate = isPrivate
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.ingredients = ingredients
        self.mainImage = mainImage
        self.category = category
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, mealId, userId, name
        case recipeDescription = "description"
        case preparation, preparationTimeInMinutes, protein, fat, sugar, kcal
        case isSnack, isPrivate, isDeleted, updatedAtOnDevice
        case ingredients, mainImage, category
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let mealId = try container.decode(String.self, forKey: .mealId)
        let userId = try container.decode(String.self, forKey: .userId)
        let name = try container.decode(String.self, forKey: .name)
        let recipeDescription = try container.decode(String.self, forKey: .recipeDescription)
        let preparation = try container.decode(String.self, forKey: .preparation)
        let preparationTimeInMinutes = try container.decode(Int.self, forKey: .preparationTimeInMinutes)
        let protein = try container.decode(Double.self, forKey: .protein)
        let fat = try container.decode(Double.self, forKey: .fat)
        let sugar = try container.decode(Double.self, forKey: .sugar)
        let kcal = try container.decode(Double.self, forKey: .kcal)
        let isSnack = try container.decode(Bool.self, forKey: .isSnack)
        let isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        let isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        let updatedAtOnDevice = try container.decode(String.self, forKey: .updatedAtOnDevice)
        let ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        let mainImage = try container.decodeIfPresent(MainImage.self, forKey: .mainImage)
        let category = try container.decodeIfPresent(Category.self, forKey: .category)
        
        self.init(
            id: id, mealId: mealId, userId: userId, name: name, recipeDescription: recipeDescription,
            preparation: preparation, preparationTimeInMinutes: preparationTimeInMinutes, protein: protein,
            fat: fat, sugar: sugar, kcal: kcal, isSnack: isSnack, isPrivate: isPrivate, isDeleted: isDeleted,
            updatedAtOnDevice: updatedAtOnDevice, ingredients: ingredients, mainImage: mainImage, category: category
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(mealId, forKey: .mealId)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(recipeDescription, forKey: .recipeDescription)
        try container.encode(preparation, forKey: .preparation)
        try container.encode(preparationTimeInMinutes, forKey: .preparationTimeInMinutes)
        try container.encode(protein, forKey: .protein)
        try container.encode(fat, forKey: .fat)
        try container.encode(sugar, forKey: .sugar)
        try container.encode(kcal, forKey: .kcal)
        try container.encode(isSnack, forKey: .isSnack)
        try container.encode(isPrivate, forKey: .isPrivate)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encodeIfPresent(mainImage, forKey: .mainImage)
        try container.encodeIfPresent(category, forKey: .category)
    }
}
