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
        ZStack(alignment: .bottom) {
            VStack {
                ZStack {
                      
                    if AppStorageService.backendReachableState, let image = mainImage {
                        
                        AsyncCachedImage(url: URL(string: services.apiService.baseURL + image.url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                        } placeholder: {
                            ZStack{
                                Image(uiImage: .placeholder)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipped()
                            }
                        }
                    } else {
                        Image(.placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    }
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
        }
        .sectionShadow()
    }
}

#Preview {
    RecipePreviewCard(name: "askdj", fat: 22, protein: 34)
        .environmentObject(Services(firebase: FirebaseService(), context: previewDataScource.mainContext))
}
