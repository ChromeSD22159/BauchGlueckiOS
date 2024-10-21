//
//  SectionImageCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//
import SwiftUI

struct SectionImageCard: View {
    var image: ImageResource
    var title: String
    var description: String
    let theme = Theme()
    
    var body: some View {
        ZStack(alignment: .leading) {
            // HStack für das Bild rechts und Spacer links
            HStack {
                Spacer()
                Image(image)
                    .resizable()
                    .foregroundStyle(theme.primary)
                    .opacity(0.25)
                    .frame(width: 170, height: 170)
                    .padding(.trailing, 20)
                    .rotationEffect(Angle(degrees: 15))
                    .clipShape(Rectangle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(theme.headlineTextSmall)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(description)
                    .font(.footnote)
                    .lineLimit(2)
            }
            .padding(.horizontal, 10)
        }
        .frame(maxHeight: 120)
        .background(theme.surface)
        .cornerRadius(theme.radius)
        .padding(.horizontal, 10)
        
    }
}
