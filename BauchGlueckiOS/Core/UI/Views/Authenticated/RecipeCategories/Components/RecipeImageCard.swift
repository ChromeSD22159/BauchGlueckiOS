//
//  RecipeImageCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct RecipeImageCard: View {
    var image: ImageResource
    var name: String
    private let theme: Theme = Theme.shared
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            HStack(alignment: .center) {
                Text(name)
                    .font(theme.headlineTextSmall)
                    .foregroundStyle(theme.onBackground)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(theme.surface.opacity(0.9))
        }
        .sectionShadow()
    }
}
