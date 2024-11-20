//
//  IconButton.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct IconButton: View {
    
    @Environment(\.theme) private var theme
    
    var onEditingChanged: () -> Void
    var icon: String
    
    init(
        icon: String = "arrow.right",
        onEditingChanged: @escaping () -> Void
    ){
        self.icon = icon
        self.onEditingChanged = onEditingChanged
    }
    var body: some View {
        Button(
            action: {
                onEditingChanged()
            }, label: {
                Label("", systemImage: icon)
                    .labelStyle(.iconOnly)
                    .font(.body)
                    .foregroundStyle(theme.color.onBackground)
            }
        )
        .padding(.horizontal, theme.layout.padding + 5)
        .padding(.vertical, (theme.layout.padding + 5) / 2)
        .background(theme.color.primary)
        .cornerRadius(100)
    }
}
