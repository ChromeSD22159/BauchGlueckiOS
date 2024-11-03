//
//  RecipesDataService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 01.11.24.
//

import SwiftData
import Alamofire
import SwiftUI

@MainActor
struct RecipesDataService {
    static func fetchRecipesFromBackend(
        context: ModelContext,
        table: Entitiy = .Recipe,
        apiService: StrapiApiClient
    ) {
        let syncHistoryRepository = SyncHistoryService(context: context)
        let headers: HTTPHeaders = [.authorization(bearerToken: apiService.bearerToken)]
        
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                let fetchURL = apiService.baseURL + "/api/recipes/getUpdatedRecipesEntries?timeStamp=\(lastSync)"
                
                print("<<< URL \(fetchURL)")
                
                let response = await AF.request(fetchURL, headers: headers)
                    .cacheResponse(using: .doNotCache)
                    .validate()
                    .serializingDecodable([RecipeResponse].self)
                    .response
                
                switch response.result {
                case .success(let recipes):
                    
                    for recipeResponse in recipes {
                        
                        guard let recipe = insertOrUpdateRecipe(context: context, serverRecipe: recipeResponse) else {
                            print("Error processing recipe with ID \(recipeResponse.id)")
                            continue
                        }
                        
                        var ingredients: [Ingredient] = []
                        for ingredient in recipeResponse.ingredients {
                            if let updatesIngretient = insertOrUpdateIngredient(context: context, serverIngredient: ingredient) {
                                ingredients.append(updatesIngretient)
                            }
                        }
                        recipe.ingredients = ingredients
                        
                        if let mainImageResponse = recipeResponse.mainImage {
                            dump(recipeResponse.mainImage)
                            recipe.mainImage = insertOrUpdateImage(context: context, serverImage: mainImageResponse)
                        }
                        
                        if let categoryResponse = recipeResponse.category {
                            recipe.category = insertOrUpdateCategory(context: context, serverCategory: categoryResponse)
                        }
                    }
                    
                    try context.save()
                    
                    syncHistoryRepository.saveSyncHistoryStamp(entity: table)
                    
                case .failure(let error):
                    if response.response?.statusCode == 430 {
                        print("Recipes: NothingToSync")
                        throw NetworkError.NothingToSync
                    } else {
                        print("Recipes: \(error.localizedDescription)")
                        throw NetworkError.unknown
                    }
                }
            }
        }
    }
    
    static func insertOrUpdateIngredient(context: ModelContext, serverIngredient: IngredientResponse) -> Ingredient? {
        do {
            let existingIngredientDescriptor = FetchDescriptor<Ingredient>(
                predicate: #Predicate<Ingredient> { $0.name == serverIngredient.name && $0.amount == serverIngredient.amount }
            )
            let foundIngredient = try context.fetch(existingIngredientDescriptor)
            
            if let ingredient = foundIngredient.first {
                ingredient.name = serverIngredient.name
                ingredient.amount = serverIngredient.amount
                ingredient.unit = serverIngredient.unit
                return ingredient
            } else {
                let newIngredient = Ingredient(
                    id: serverIngredient.id,
                    component: serverIngredient.component,
                    name: serverIngredient.name,
                    amount: serverIngredient.amount,
                    unit: serverIngredient.unit
                )
                context.insert(newIngredient)
                return newIngredient
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func insertOrUpdateRecipe(context: ModelContext, serverRecipe: RecipeResponse) -> Recipe? {
        do {
            let existingCategoryDescriptor = FetchDescriptor<Recipe>(
                predicate: #Predicate<Recipe> { $0.mealId == serverRecipe.mealId }
            )
            let foundRecipe = try context.fetch(existingCategoryDescriptor)
            
            if let recipe = foundRecipe.first {
                recipe.mealId = serverRecipe.mealId
                recipe.userId = serverRecipe.userId
                recipe.name = serverRecipe.name
                recipe.recipeDescription = serverRecipe.recipeDescription
                recipe.preparation = serverRecipe.preparation
                recipe.preparationTimeInMinutes = serverRecipe.preparationTimeInMinutes
                recipe.protein = serverRecipe.protein
                recipe.fat = serverRecipe.fat
                recipe.sugar = serverRecipe.sugar
                recipe.kcal = serverRecipe.kcal
                recipe.isSnack = serverRecipe.isSnack
                recipe.isPrivate = serverRecipe.isPrivate
                recipe.isDeleted = serverRecipe.isDeleted
                recipe.updatedAtOnDevice = serverRecipe.updatedAtOnDevice
                return recipe
            } else {
                let newCategory = Recipe(
                    id: serverRecipe.id,
                    mealId: serverRecipe.mealId,
                    userId: serverRecipe.userId,
                    name: serverRecipe.name,
                    recipeDescription: serverRecipe.recipeDescription,
                    preparation: serverRecipe.preparation,
                    preparationTimeInMinutes: serverRecipe.preparationTimeInMinutes,
                    protein: serverRecipe.protein,
                    fat: serverRecipe.fat,
                    sugar: serverRecipe.sugar,
                    kcal: serverRecipe.kcal,
                    isSnack: serverRecipe.isSnack,
                    isPrivate: serverRecipe.isPrivate,
                    isDeleted: serverRecipe.isDeleted,
                    updatedAtOnDevice: serverRecipe.updatedAtOnDevice
                )
                context.insert(newCategory)
                return newCategory
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func insertOrUpdateCategory(context: ModelContext, serverCategory: CategoryResponse) -> Category? {
        do {
            let existingCategoryDescriptor = FetchDescriptor<Category>(
                predicate: #Predicate<Category> { $0.categoryId == serverCategory.categoryId }
            )
            let foundCategories = try context.fetch(existingCategoryDescriptor)
            
            if let category = foundCategories.first {
                category.name = serverCategory.name
                return category
            } else {
                let newCategory = Category(id: serverCategory.id, categoryId: serverCategory.categoryId, name: serverCategory.name)
                context.insert(newCategory)
                return newCategory
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    static func insertOrUpdateImage(context: ModelContext, serverImage: MainImageResponse) -> MainImage? {
        do {
            let existingImageDescriptor = FetchDescriptor<MainImage>(
                predicate: #Predicate<MainImage> { $0.url == serverImage.url }
            )
            let foundImage = try context.fetch(existingImageDescriptor)
            
            if let image = foundImage.first {
                image.url = serverImage.url
                return image
            } else {
                let newImage = MainImage(id: serverImage.id, url: serverImage.url)
                context.insert(newImage)
                return newImage
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

func debugJson(_ any: Any) {
    let mirror = Mirror(reflecting: any)
    for child in mirror.children {
        if let label = child.label {
            print("\(label): \(child.value)")
        }
    }
}
