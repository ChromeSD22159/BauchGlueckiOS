//
//  SectionImageCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//
import SwiftUI

#Preview {
    SectionImageCard(
        image: .icAppleTableCard,
        title: "Shoppinglist",
        description: "Erstelle aus deinem Mealplan eine Shoppingliste."
    )
}

struct SectionImageCard: View {
    private let theme = Theme.shared
    var image: UIImage
    var title: String
    var description: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(uiImage: .cardBG)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(theme.primary)
                .opacity(0.30)
            
            Image(uiImage: image)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(theme.primary)
                .opacity(0.60)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(theme.headlineTextSmall)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(description)
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
                    .lineLimit(2, reservesSpace: true)
                    .padding(.horizontal, 10)
            }
        }
        .frame(maxHeight: 120)
        .foregroundStyle(theme.onBackground)
        .background(theme.surface)
        .cornerRadius(theme.radius)
        
    }
}
