//
//  IconTextButton.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct IconTextButton: View {
    
    @Environment(\.theme) private var theme
    
    var onEditingChanged: () -> Void
    var text: String
    
    init(
        text: String = "",
        onEditingChanged: @escaping () -> Void
    ){
        self.text = text
        self.onEditingChanged = onEditingChanged
    }
    var body: some View {
        Button(
            action: {
                onEditingChanged()
            }, label: {
                Text(text)
                    .font(.body)
                    .foregroundStyle(theme.color.onPrimary)
            }
        )
        .padding(.horizontal, theme.layout.padding + 5)
        .padding(.vertical, (theme.layout.padding + 5) / 2)
        .background(theme.color.primary)
        .cornerRadius(100)
    }
}
