//
//  ImageOverlayGradient.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

extension View {
    func recipeImage(width: CGFloat, height: CGFloat, opacity: Double) -> some View {
        modifier(ImageOverlayGradient(
            width: width, height: height, opacity: opacity
        ))
    }
}

struct ImageOverlayGradient: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    let opacity: Double
    
    @Environment(\.theme) private var theme
    
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .opacity(opacity)
            .overlay {
                Rectangle()
                    .fill(
                        LinearGradient(colors: [
                            theme.color.background.opacity(0.7),
                            theme.color.background.opacity(0.5),
                            theme.color.background.opacity(0.0),
                            theme.color.background.opacity(0.0)
                        ], startPoint: .top, endPoint: .bottom)
                    )
            }
            .clipped()
    }
}
