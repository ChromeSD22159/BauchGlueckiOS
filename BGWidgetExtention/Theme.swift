//
//  Theme.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//

import SwiftUI

struct Theme {
    static var shared: Theme = Theme()
    
    var backgroundGradient = LinearGradient(colors: [.prime, .prime.opacity(0.5)], startPoint: .top, endPoint: .bottom)
    
    var primary: Color = Color.prime
    var onPrimary: Color = Color.onPrimary
    var background: Color = Color.background
    var onBackground: Color = Color.primary
    var surface = Color.surface
    var padding: CGFloat = 10
    var radius: CGFloat = 10
    
    @ViewBuilder func bubbleBackground<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            // IMAGE BACKGROUND
            VStack {
                Spacer()
                Image(uiImage: .bubbleRight)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            content()
        }
    }
    
    
    func headlineText(size: CGFloat = 25) -> Font {
        CustomFont.Rodetta.font(size: size)
    }
    
    var headlineText = CustomFont.Rodetta.font(size: 25)
    var headlineTextMedium = CustomFont.Rodetta.font(size: 22)
    var headlineTextSmall = CustomFont.Rodetta.font(size: 16)
    
    var iconFont = CustomFont.Rodetta.font(size: 64)
    
    enum CustomFont: String {
        case Rodetta = "RodettaRegular"
        
        func font(size: CGFloat) -> Font {
            return Font.custom(self.rawValue, size: size)
        }
    }
}
