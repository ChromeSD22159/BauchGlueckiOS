//
//  RecipePreviewCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 13.11.24.
//
import SwiftUI

struct RecipePreviewCard: View {
    @EnvironmentObject var services: Services
    @Environment(\.theme) private var theme
    
    var mainImage: MainImage?
    var name: String
    var fat: Double
    var protein: Double
    let width: CGFloat
    
    init(mainImage: MainImage? = nil, name: String, fat: Double, protein: Double, width: CGFloat) {
        self.mainImage = mainImage
        self.name = name
        self.fat = fat
        self.protein = protein
        self.width = width
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if AppStorageService.backendReachableState, let image = mainImage {
                
                AsyncCachedImage(url: URL(string: services.apiService.baseURL + image.url)) { image in
                    ClippedImage(image: image, size: width)
                    
                } placeholder: {
                    ClippedImage(image: Image(uiImage: .placeholder), size: width)
                }
                
            } else {
                ClippedImage(image: Image(uiImage: .placeholder), size: width)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(name)
                    .lineLimit(1)
                    .font(theme.font.headlineTextSmall)
                
                HStack {
                    HStack {
                        Image(uiImage: .fatDrop)
                            .renderingMode(.template)
                            .foregroundColor(theme.color.onBackground)
                            .font(theme.font.headlineTextSmall)
                        Text(String(format: "%0.1fg", protein))
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "fish")
                        Text(String(format: "%0.1fg", fat))
                    }
                    
                }.font(.footnote)
            }
            .font(theme.font.headlineTextSmall)
            .foregroundStyle(theme.color.onBackground)
            .padding(.vertical, theme.layout.padding / 2)
            .padding(.horizontal, theme.layout.padding)
            .background(theme.color.surface.opacity(0.9))
        }
        .sectionShadow()
    }
}
 
#Preview("PRE") {
    @Previewable @State var viewModel = RecipeListViewModel(firebase: FirebaseService(), modelContext: previewDataScource.mainContext)
   
    let context = previewDataScource.mainContext
    let columns = GridUtils.createGridItems(count: 2, spacing: 10)
    
   
    LazyVGrid(columns: columns, spacing: 10) {
        GeometryReader { geometry in
            ForEach(mockRecipes, id: \.self) { recipe in
                RecipePreviewCard(name: "sadsa", fat: 22.0, protein: 22.0, width: geometry.size.width)
                    .aspectRatio(1.0, contentMode: .fit)
            }
        }
    }
    .padding(Theme.layout.padding)
    .environmentObject(Services(firebase: FirebaseService(), context: context))
}
