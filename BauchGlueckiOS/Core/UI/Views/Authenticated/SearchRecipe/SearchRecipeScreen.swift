//
//  SearchRecipeScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI
import SwiftData

struct SearchRecipeScreen: View {
    
    private var date: Date
    private var firebase: FirebaseService
    private let theme: Theme = Theme.shared
    
    @State var searchText: String = ""
    @State var searchIsActive: Bool = false
        
    init(firebase: FirebaseService, date: Date) {
        self.date = date
        self.firebase = firebase
    }
    
    let columns = [
       GridItem(.flexible(), spacing: 16),
       GridItem(.flexible(), spacing: 16),
       
    ]
    
    @Query() var recipes: [Recipe]
     
    var body: some View {
        ZStack {
            Theme.shared.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    VStack {
                        SectionHeader(title: "Kategorien", trailingText: "\(RecipeCategory.allCases.count.formatted(.number)) Kategrien")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(RecipeCategory.allCases, id: \.categoryID) { category in
                                    VStack {
                                        Image(category.sliderImage)
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                        
                                        Text("\(category.displayName)")
                                            .font(theme.headlineTextSmall)
                                            .foregroundColor(theme.onBackground)
                                    }
                                    .frame(width: 150, height: 80)
                                    .onTapGesture { searchText = category.displayName }
                                    .sectionShadow(innerPadding: 10)
                                }
                            }
                        }
                        .contentMargins([.leading, .trailing], 16)
                        .contentMargins([.bottom], 5)
                    }
                    
                    
                    VStack {
                        SectionHeader(title: "Rezepte", trailingText: "\(searchResults.count.formatted(.number)) Rezepte")
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(searchResults, id: \.self) { recipe in
                                RecipePreviewCard(
                                    mainImage: recipe.mainImage,
                                    name: recipe.name,
                                    fat: recipe.fat,
                                    protein: recipe.protein
                                )
                                .navigateTo(
                                    firebase: firebase,
                                    destination: Destination.recipeCategoryList,
                                    showSettingButton: false,
                                    target: { DetailRecipeView(firebase: firebase, recipe: recipe, date: date) }
                                )
                                
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Text("\(searchResults.count) Rezepte gefunden!")
                            .font(.footnote)
                            .padding(.top, 20)
                            .padding(.horizontal, theme.padding)
                    }
                    
                }
            }
            .contentMargins([.top, .bottom], 16)
        }
        .searchable(text: $searchText, isPresented: $searchIsActive, prompt: "Rezepte, Zutaten oder Zubereitung suchen")
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                searchIsActive.toggle()
            }
        }
        .onDisappear {
            searchIsActive.toggle()
        }
    }
    
    var searchResults: [Recipe] {
        withAnimation(.easeIn) {
            if searchText.isEmpty {
                return recipes
            } else {
                return filteredRecipes()
            }
        }
    }
    
    private func filteredRecipes() -> [Recipe] {
        var uniqueRecipes = Set<Recipe>()
        uniqueRecipes.formUnion(recipes.filter { recipe in
            recipe.category?.name.localizedCaseInsensitiveContains(searchText) ?? false
        })
        
        // Filter nach Rezeptname
        uniqueRecipes.formUnion(recipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(searchText)
        })
        
        // Filter nach Zutatenname
        uniqueRecipes.formUnion(recipes.filter { recipe in
            recipe.ingredients.contains { ingredient in
                ingredient.name.localizedCaseInsensitiveContains(searchText)
            }
        })
            
        return Array(uniqueRecipes).sorted { $0.name < $1.name }
    }

    
    @ViewBuilder func SectionHeader(
        title: String,
        trailingText: String?
    ) -> some View {
        HStack {
            Text(title)
                .font(theme.headlineTextMedium)
            
            Spacer()
            
            if let trailingText = trailingText {
                Text(trailingText)
            }
            
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    SearchRecipeScreen(firebase: FirebaseService(), date: .init(timeIntervalSince1970: 0))
        .modelContainer(previewDataScource)
}
