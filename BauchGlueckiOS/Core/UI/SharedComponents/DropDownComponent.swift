//
//  DropDownComponent.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//
import SwiftUI

@ViewBuilder func DropDownComponent(
    options: [DropDownOption] = [],
    onClick: @escaping (DropDownOption) -> Void = {_ in }
) -> some View {
    let theme = Theme.shared
    Menu(content: {
        ForEach(options, id: \.displayText) { item in
            Button(action: {
                onClick(item)
            }, label: {
                Label(item.displayText, systemImage: item.icon)
            })
        }
    }, label: {
        ZStack() {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(theme.onPrimary)
        }
        .foregroundStyle(theme.primary)
        .padding(theme.padding)
        .background(theme.backgroundGradient)
        .cornerRadius(theme.padding)
        .overlay(
            RoundedRectangle(cornerRadius: theme.padding)
                .stroke(theme.primary, lineWidth: 1)
        )
    })
}

struct DropDownOption{
    var icon: String
    var displayText: String
}
