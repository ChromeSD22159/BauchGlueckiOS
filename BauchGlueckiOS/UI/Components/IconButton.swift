//
//  IconButton.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct IconButton: View {
    var onEditingChanged: () -> Void
    var icon: String
    var theme: Theme = Theme()
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
                    .foregroundStyle(theme.onBackground)
            }
        )
        .padding(.horizontal, theme.padding + 5)
        .padding(.vertical, (theme.padding + 5) / 2)
        .background(theme.primary)
        .cornerRadius(100)
    }
}
