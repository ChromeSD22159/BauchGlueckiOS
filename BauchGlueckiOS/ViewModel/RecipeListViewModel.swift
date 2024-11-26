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
    var context: ModelContext
    
    init(modelContext: ModelContext) {
        self.context = modelContext
    }
    
    func inizialize(categoryId: String) {
        Task {
            await loadRecipes(categoryId: categoryId)
        }
    }
    
    func loadRecipes(categoryId: String) async {
        let predicate = #Predicate<Recipe> { recipe in
            if let recipeCategory = recipe.category {
                return recipeCategory.categoryId == categoryId
            }  else { return false }
        }
        
        let fetchDescriptor = FetchDescriptor<Recipe>(
            predicate: predicate,
            sortBy: [ .init(\.name) ]
        )
        
        do {
            let results = try await MainActor.run {
                try self.context.fetch(fetchDescriptor)
            }
             
            await MainActor.run {
                self.recipes = results
            }
        } catch {
            print("Error fetching recipes: \(error)")
        }
    }
}
