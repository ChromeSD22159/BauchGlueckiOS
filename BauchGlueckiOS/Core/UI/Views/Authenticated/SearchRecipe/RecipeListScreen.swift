
//
//  SearchRecipesScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI
import SwiftData
import Combine

struct RecipeListScreen: View {
    let theme = Theme.shared
    
    var categoryId: String
    var firebase: FirebaseService
    
    @State var viewModel: RecipeListViewModel? = nil
    @Environment(\.modelContext) var modelContext
    
    init(firebase: FirebaseService, categoryId: String) {
        self.firebase = firebase
        self.categoryId = categoryId
    }
    
    let columns = [
       GridItem(.flexible()),
       GridItem(.flexible())
   ]
    
    var body: some View {
        ScreenHolder {
            if let viewModel = viewModel {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.recipes, id: \.self) { recipe in
                        
                        RecipePreviewCard(mainImage: recipe.mainImage, name: recipe.name, fat: recipe.fat, protein: recipe.protein)
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.recipeCategoryList,
                                showSettingButton: false,
                                target: { DetailRecipeView(firebase: firebase, recipe: recipe) }
                            )
                        
                    }
                }
                .padding(theme.padding)
            }
        }
        .onAppear {
            if viewModel == nil {
                   viewModel = RecipeListViewModel(firebase: firebase, modelContext: modelContext)
                   viewModel?.inizialize(categoryId: categoryId)
            }
        }
    }
}

@Observable
class RecipeListViewModel: ObservableObject {
    var recipes: [Recipe] = []
    var categoryId: String = ""
    var modelContext: ModelContext
    private var firebase: FirebaseService
    
    init(firebase: FirebaseService, modelContext: ModelContext) {
        self.firebase = firebase
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
