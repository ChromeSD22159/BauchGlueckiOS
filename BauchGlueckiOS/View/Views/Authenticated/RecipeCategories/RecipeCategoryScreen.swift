//
//  RecipeCategoryScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//

import SwiftUI
import SwiftData

struct RecipeCategoryScreen: View {
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        ScreenHolder {
            
            // MARK: - CATECORY SLIDER
            CategorySlider()
                .viewSize(name: "CategorySlider")
            
            // MARK: - RANDOMRECIPE
            RandomRecipe()
                .viewSize(name: "RandomRecipe")
            
            // MARK: - RANDOMRECIPES
            RandomRecipes(recipeCount: 6) 
                .viewSize(name: "RandomRecipes")
        }
        .viewSize(name: "ScreenHolder")
    }
    
    private struct RandomRecipe: View {
        @Environment(\.theme) private var theme
        @Environment(\.modelContext) var modelContext
        @EnvironmentObject var services: Services
        
        @Query() var allRecipes: [Recipe]
        
        var randomRecipe: Recipe? {
            allRecipes.randomElement()
        }
        
        var body: some View {
            if let randomRecipe = randomRecipe {
                VStack(spacing: 10) {
                    
                    SectionHeader(title: "Zufalls Rezept")
                        .onTapGesture(count: 5) {
                            services.syncHistoryService.deleteSyncHistoryStamp(entity: .Meal)
                            services.mealPlanService.deleteAllMeals(meals: allRecipes)
                        }
                    
                    ZStack(alignment: .bottom) {
                        GeometryReader { geometry in
                            
                            if let url = randomRecipe.mainImage?.url {
                                
                                AsyncCachedImage(url: URL(string: services.apiService.baseURL + url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                } placeholder: {
                                    ZStack{
                                        Image(uiImage: .placeholder)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                    }
                                }
                                
                            } else {
                                AsyncCachedImage(url: URL(string: "https://de.m.wikipedia.org/wiki/Datei:Placeholder_view_vector.svg")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                   
                                } placeholder: {
                                    ZStack{
                                        Image(uiImage: .placeholder)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                    }
                                }
                            }
                            
                        }
                        .frame(height: 420)
                        .ignoresSafeArea()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(randomRecipe.name)
                                    .font(theme.font.headlineTextSmall)
                                
                                Spacer()
                                
                                HStack {
                                    Image(systemName: "clock")
                                    Text("\(randomRecipe.preparationTimeInMinutes) min")
                                }
                            }.foregroundStyle(theme.color.onBackground)
                            
                            IconRow(kcal: randomRecipe.kcal, fat: randomRecipe.fat, protein: randomRecipe.protein, sugar: randomRecipe.sugar, horizontalCenter: true)
                            
                        }
                        .padding(10)
                    }
                    .sectionShadow(margin: 16)
                    .navigateTo(
                        destination: Destination.recipeCategoryList,
                        showSettingButton: false,
                        target: { DetailRecipeView(recipe: randomRecipe, theme: theme) }
                    )
                    
                }
            }
        }
    }
    
    private struct CategorySlider: View {
        @Environment(\.theme) private var theme
        
        @EnvironmentObject var services: Services
        
        var body: some View {
            VStack(spacing: 10) {
                SectionHeader(title: "Kategorien")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(RecipeCategory.allCases, id: \.categoryID) { category in
                            VStack {
                                Image(category.sliderImage)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                
                                Text("\(category.displayName)")
                                    .font(theme.font.headlineTextSmall)
                                    .foregroundColor(theme.color.onBackground)
                            }
                            .frame(width: 150, height: 80)
                            .sectionShadow(innerPadding: 10)
                            .navigateTo( 
                                destination: Destination.recipeCategories,
                                target: { RecipeListScreen(categoryId: category.categoryID) },
                                toolbarItems: {
                                    AddRecipeButtonWithPicker()
                                }
                            )
                        }
                    }
                }
                .contentMargins(.bottom, 10)
                .contentMargins([.leading, .trailing], 16)
            }
        }
    }
    
    private struct SectionHeader: View {
        @Environment(\.theme) private var theme
        
        let title: String
        let trailingText: String? = nil
        
        var body: some View {
            HStack {
                Text(title)
                    .font(theme.font.headlineTextMedium)
                
                Spacer()
                
                if let trailingText = trailingText {
                    Text(trailingText)
                }
                
            }
            .padding(.horizontal, 16)
        }
    }
    
    private struct RandomRecipes: View {
        @EnvironmentObject var services: Services 
        
        @Query() var recipes: [Recipe]
        
        let recipeCount: Int
        
        var randomRecipes: [Recipe] {
            if !recipes.isEmpty {
                return Array(recipes.shuffled().prefix(self.recipeCount))
            } else {
                return []
            }
        }
        
        init(recipeCount: Int = 10) {
            self.recipeCount = recipeCount
        }
        
        let test = GridUtils.createGridItems(count: 2)
        
        var body: some View {
            VStack(spacing: 10) {
                SectionHeader(title: "Zufalls Rezepte")
                RecipeGrid(recipes: recipes, resultCount: false)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
        }
    }
} 
