//
//  SearchRecipesScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI
import SwiftData
import Combine

struct SearchRecipesScreen: View {
    let theme = Theme.shared
    
    var firebase: FirebaseService
    
    @Query() var recipes: [Recipe]
    
    init(firebase: FirebaseService, category: Category) {
        self.firebase = firebase
        
        let predicate = #Predicate<Recipe> { recipe in
            if let recipeCategory = recipe.category {
                return recipeCategory.id == category.id
            }  else { return false }
        }

        _recipes = Query(filter: predicate)
    }
    
    let columns = [
       GridItem(.flexible()),
       GridItem(.flexible())
   ]
    
    var body: some View {
        ScreenHolder {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(recipes, id: \.self) { recipe in
                        
                        NavigationLink(destination: {
                            DetailView(recipe: recipe)
                        }, label: {
                            RecipePreviewCard(mainImage: recipe.mainImage, name: recipe.name, fat: recipe.fat, protein: recipe.protein)
                        })
                        
                    }
                }
                .padding(theme.padding)
            }
        }
    }
}

struct RecipePreviewCard: View {
    var mainImage: MainImage?
    var name: String
    var fat: Double
    var protein: Double
    let theme: Theme
    
    init(mainImage: MainImage? = nil, name: String, fat: Double, protein: Double) {
        self.mainImage = mainImage
        self.name = name
        self.fat = fat
        self.protein = protein
        self.theme = Theme.shared
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                ZStack {
                    if let image = mainImage {
                        CachedAsyncImage(url: URL(string: "https://bauchglueck.appsbyfrederikkohler.de" + image.url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 80)
                                .clipped()
                        } placeholder: { }
                    } else {
                        Image(.placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 80)
                            .clipped()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(name)
                        .lineLimit(1)
                        .font(theme.headlineTextSmall)
                    
                    HStack {
                        HStack {
                            Image(uiImage: .fatDrop)
                                .renderingMode(.template)
                                .foregroundColor(theme.onBackground)
                                .font(theme.headlineTextSmall)
                            Text(String(format: "%0.1fg", protein))
                        }
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "fish")
                            Text(String(format: "%0.1fg", fat))
                        }
                        
                    }.font(.footnote)
                }
                .font(theme.headlineTextSmall)
                .foregroundStyle(theme.onBackground)
                .padding(.vertical, theme.padding / 2)
                .padding(.horizontal, theme.padding)
                .frame(maxWidth: .infinity)
                .background(theme.surface.opacity(0.9))
            }
        }
        .sectionShadow()
    }
}
