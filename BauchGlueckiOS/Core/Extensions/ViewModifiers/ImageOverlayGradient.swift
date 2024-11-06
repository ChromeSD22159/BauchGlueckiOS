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
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .opacity(opacity)
            .overlay {
                Rectangle()
                    .fill(
                        LinearGradient(colors: [
                            Theme.shared.background.opacity(0.7),
                            Theme.shared.background.opacity(0.5),
                            Theme.shared.background.opacity(0.0),
                            Theme.shared.background.opacity(0.0)
                        ], startPoint: .top, endPoint: .bottom)
                    )
            }
            .clipped()
    }
}
