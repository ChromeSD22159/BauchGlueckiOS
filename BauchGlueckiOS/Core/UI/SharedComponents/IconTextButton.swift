//
//  IconTextButton.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

struct IconTextButton: View {
    
    private let theme = Theme.shared
    
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
                    .foregroundStyle(theme.onBackground)
            }
        )
        .padding(.horizontal, theme.padding + 5)
        .padding(.vertical, (theme.padding + 5) / 2)
        .background(theme.primary)
        .cornerRadius(100)
    }
}
