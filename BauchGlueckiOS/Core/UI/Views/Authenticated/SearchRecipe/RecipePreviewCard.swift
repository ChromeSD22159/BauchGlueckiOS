//
//  RecipePreviewCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 13.11.24.
//
import SwiftUI

struct RecipePreviewCard: View {
    @EnvironmentObject var services: Services
    
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
        VStack {
            if AppStorageService.backendReachableState, let image = mainImage {
                
                AsyncCachedImage(url: URL(string: services.apiService.baseURL + image.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } placeholder: {
                    Image(uiImage: .placeholder)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
                
            } else {
                Image(.placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 10) {
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
        .sectionShadow()
    }
}
 
#Preview("PRE") {
    @Previewable @State var viewModel = RecipeListViewModel(firebase: FirebaseService(), modelContext: previewDataScource.mainContext)
   
    let context = previewDataScource.mainContext
    let columns = GridUtils.createGridItems(count: 2, spacing: 10)
    
    LazyVGrid(columns: columns, spacing: 10) {
        ForEach(mockRecipes, id: \.self) { recipe in
            RecipePreviewCard(name: "sadsa", fat: 22.0, protein: 22.0 )
        }
    }
    .padding(Theme.shared.padding)
    .environmentObject(Services(firebase: FirebaseService(), context: context)) 
}
