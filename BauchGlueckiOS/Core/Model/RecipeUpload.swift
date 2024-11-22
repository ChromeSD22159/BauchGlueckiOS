//
//  RecipeUpload.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 08.11.24.
//

struct RecipeUpload: Codable {
    let updatedAtOnDevice: Int64
    let mealId: String
    let userId: String
    let description: String
    let isDeleted: Bool
    let isPrivate: Bool
    let isSnack: Bool
    let name: String
    let preparation: String
    let preparationTimeInMinutes: Int
    let ingredients: [IngredientResponse]
    let mainImage: MainImageUpload
    let category: CategoryUpload
    let protein: Double
    let fat: Double
    let sugar: Double
    let kcal: Double

    init(
        updatedAtOnDevice: Int64,
        mealId: String,
        userId: String,
        description: String,
        isDeleted: Bool = false,
        isPrivate: Bool = false,
        isSnack: Bool = false,
        name: String,
        preparation: String,
        preparationTimeInMinutes: Int,
        ingredients: [IngredientResponse],
        mainImage: MainImageUpload,
        category: CategoryUpload,
        protein: Double = 0.0,
        fat: Double = 0.0,
        sugar: Double = 0.0,
        kcal: Double = 0.0
    ) {
        self.updatedAtOnDevice = updatedAtOnDevice
        self.mealId = mealId
        self.userId = userId
        self.description = description
        self.isDeleted = isDeleted
        self.isPrivate = isPrivate
        self.isSnack = isSnack
        self.name = name
        self.preparation = preparation
        self.preparationTimeInMinutes = preparationTimeInMinutes
        self.ingredients = ingredients
        self.mainImage = mainImage
        self.category = category
        self.protein = protein
        self.fat = fat
        self.sugar = sugar
        self.kcal = kcal
    }
}

struct MainImageUpload: Codable {
    let id: Int
}

struct CategoryUpload: Codable {
    let name: String
}
