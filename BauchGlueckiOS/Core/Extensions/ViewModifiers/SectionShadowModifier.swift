//
//  SectionShadowModifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//
import SwiftUI

struct SectionShadow: ViewModifier {
    let theme = Theme.shared
    var margin: CGFloat
    var innerPadding: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(.all, innerPadding)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(theme.surface)
            .cornerRadius(theme.radius)
            .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
            .padding(.horizontal, margin)
    }
}
