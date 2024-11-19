//
//  SectionShadowModifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//
import SwiftUI

struct SectionShadow: ViewModifier {
    @Environment(\.theme) private var theme
    var margin: CGFloat
    var innerPadding: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(.all, innerPadding)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(theme.color.surface)
            .cornerRadius(theme.layout.radius)
            .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3) // TODO: REFACTOR
            .padding(.horizontal, margin)
    }
}
