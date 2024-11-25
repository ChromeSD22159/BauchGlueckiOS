
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
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) var modelContext
    
    var categoryId: String
    
    @State var viewModel: RecipeListViewModel? = nil
    
    init(categoryId: String) {
        self.categoryId = categoryId
    }
    
    let spacing: CGFloat = 16
    
    var body: some View {
        ScreenHolder {
            if let viewModel = viewModel {
                RecipeGrid(recipes: viewModel.recipes, resultCount: false)
            }
        }
        .onAppear {
            if viewModel == nil {
                   viewModel = RecipeListViewModel(modelContext: modelContext)
                   viewModel?.inizialize(categoryId: categoryId)
            }
        }
    }
} 
