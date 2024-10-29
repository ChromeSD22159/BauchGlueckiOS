//
//  CardStyle.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct CardStyle: ViewModifier {
    let theme = Theme.shared
    func body(content: Content) -> some View {
        content
            .padding(theme.padding)
            .background(theme.surface)
            .cornerRadius(theme.radius)
            .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
    }
}
