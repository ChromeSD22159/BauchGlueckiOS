//
//  CardStyle.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct CardStyle: ViewModifier {
    @Environment(\.theme) private var theme
    func body(content: Content) -> some View {
        content
            .padding(theme.layout.padding)
            .background(theme.color.surface)
            .cornerRadius(theme.layout.radius)
            .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
    }
}
