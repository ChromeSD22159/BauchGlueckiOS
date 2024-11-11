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
       GridItem(.flexible()),
       GridItem(.flexible())
    ]
    
    @Query() var recipes: [Recipe]
    
    var searchResults: [Recipe] {
        withAnimation(.easeIn) {
            if searchText.isEmpty {
                return recipes
            } else {
                return recipes.filter { $0.name.contains(searchText) }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Theme.shared.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    LazyVGrid(columns: columns, spacing: 10) {
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
                    
                    Text("\(searchResults.count) Rezepte gefunden!")
                        .font(.footnote)
                }
            }
            .padding(.horizontal, theme.padding)
        }
        .searchable(text: $searchText, isPresented: $searchIsActive, prompt: "Look for something")
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                searchIsActive.toggle()
            }
        }
        .onDisappear {
            searchIsActive.toggle()
        }
    }
}

#Preview {
    SearchRecipeScreen(firebase: FirebaseService(), date: .init(timeIntervalSince1970: 0))
        .modelContainer(previewDataScource)
}
