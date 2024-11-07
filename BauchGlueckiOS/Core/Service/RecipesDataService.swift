//
//  RecipesDataService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 01.11.24.
//

import SwiftData
import Alamofire
import SwiftUI
import FirebaseAuth

@MainActor
struct RecipesDataService {
    var apiService: StrapiApiClient
    var context: ModelContext
    
    init(context: ModelContext, apiService: StrapiApiClient) {
        self.apiService = apiService
        self.context = context
    }
    
    func fetchRecipesFromBackend(
        table: Entitiy = .Recipe
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
                    
                    print("<<< \(recipes.count) Recipes fetched")
                    
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
    
    func insertOrUpdateIngredient(context: ModelContext, serverIngredient: IngredientResponse) -> Ingredient? {
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
    
    func insertOrUpdateRecipe(context: ModelContext, serverRecipe: RecipeResponse) -> Recipe? {
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
    
    func insertOrUpdateCategory(context: ModelContext, serverCategory: CategoryResponse) -> Category? {
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

    func insertOrUpdateImage(context: ModelContext, serverImage: MainImageResponse) -> MainImage? {
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
    
    func uploadRequest(
        recipeImage: UIImage,
        recipeDescription: String,
        recipeName: String,
        recipePreperation: String,
        recipePreperationTime: Int,
        ingredients: [Ingredient],
        selectedCategory: RecipeCategory,
        successFullUploadet: @escaping (Result<String, Error>) -> Void
    ) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
            
        apiService.uploadImage(
            endpoint: apiService.baseURL + "/api/upload/",
            image: recipeImage
        ) { result in
            
            switch result {
                
            case .success(let mainImage):
                
                if let image = mainImage.first {
                    let recipeUpload = RecipeUpload(
                        updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                        mealId: UUID().uuidString,
                        userId: userID,
                        description: recipeDescription,
                        isDeleted: false,
                        isPrivate: false,
                        isSnack: false,
                        name: recipeName,
                        preparation: recipePreperation,
                        preparationTimeInMinutes: recipePreperationTime,
                        ingredients: ingredients.map { ingredient in
                            IngredientResponse(id: ingredient.id, name: ingredient.name, amount: ingredient.amount, unit: ingredient.unit)
                        },
                        mainImage: MainImageUpload(id: image.id),
                        category: CategoryUpload(name: selectedCategory.displayName),
                        protein: 0.0,
                        fat: 0.0,
                        sugar: 0.0,
                        kcal: 0.0
                    )
                    
                    apiService.uploadRecipe(
                        endpoint: apiService.baseURL + "/api/recipes/createRecipe",
                        recipe: recipeUpload,
                        completion: { res in
                            
                            switch res {
                                case .success(_):
                                
                                fetchRecipesFromBackend()
                                
                                case .failure(let error): print("Error Fetching Recipes: \(error.localizedDescription)")
                            }
                            
                            successFullUploadet(res)
                        }
                    )
                }
                
                
                
                case .failure(let error): print(error)
            }
            
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
