//
//  RecipeListViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.11.24.
//
import Foundation
import SwiftData

@Observable
class RecipeListViewModel: ObservableObject {
    var recipes: [Recipe] = []
    var categoryId: String = ""
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func inizialize(categoryId: String) {
        loadRecipes(categoryId: categoryId)
    }
    
    func loadRecipes(categoryId: String) {
        let predicate = #Predicate<Recipe> { recipe in
            if let recipeCategory = recipe.category {
                return recipeCategory.categoryId == categoryId
            }  else { return false }
        }
        
        let fetch = FetchDescriptor<Recipe>(
            predicate: predicate,
            sortBy: [ .init(\.name) ]
        )
        
        do {
            recipes = try modelContext.fetch(fetch)
        } catch {
            print("Error fetching recipes: \(error)")
        }
    }
}
