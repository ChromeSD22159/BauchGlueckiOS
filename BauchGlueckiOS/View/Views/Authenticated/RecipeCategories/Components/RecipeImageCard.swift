//
//  RecipeImageCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct RecipeImageCard: View {
    @Environment(\.theme) private var theme
    
    var image: ImageResource
    var name: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            HStack(alignment: .center) {                 
                HeadLineText(name, color: theme.color.onBackground)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(theme.color.surface.opacity(0.9))
        }
        .sectionShadow()
    }
}
