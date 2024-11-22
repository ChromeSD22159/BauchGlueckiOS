//
//  SearchRecipeScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI
import SwiftData

struct SearchRecipeScreen: View {
    @Environment(\.theme) private var theme
    private var date: Date
    private var firebase: FirebaseService
    
    @State var searchText: String = ""
    @State var searchIsActive: Bool = false
        
    init(firebase: FirebaseService, date: Date) {
        self.date = date
        self.firebase = firebase
    }
    
    @Query() var recipes: [Recipe]
     
    let spacing: CGFloat = 16
    
    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    VStack {
                        SearchRecipeSectionHeader(title: "Kategorien", trailingText: "\(RecipeCategory.allCases.count.formatted(.number)) Kategrien")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: spacing) {
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
                                    .onTapGesture { searchText = category.displayName }
                                    .sectionShadow(innerPadding: 10)
                                }
                            }
                        }
                        .contentMargins([.leading, .trailing], spacing)
                        .contentMargins([.bottom], 5)
                    }
                    
                    VStack {
                        SearchRecipeSectionHeader(title: "Rezepte", trailingText: "\(searchResults.count.formatted(.number)) Rezepte")
                        
                        RecipeGrid(recipes: searchResults, date: date, resultCount: true, firebase: firebase)
                    }
                    
                }
            }
            .contentMargins([.top, .bottom], spacing)
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
}

struct SearchRecipeSectionHeader: View {
    @Environment(\.theme) private var theme
    
    let title: String
    let trailingText: String?
    
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

#Preview {
    SearchRecipeScreen(firebase: FirebaseService(), date: .init(timeIntervalSince1970: 0))
        .previewEnvironment()
}

// TODO: REFACTOR
extension View {
    func previewEnvironment() -> some View {
        modifier(PreviewEnvironment())
    }
}

struct PreviewEnvironment: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.theme, Theme())
            .modelContainer(previewDataScource)
    }
}
