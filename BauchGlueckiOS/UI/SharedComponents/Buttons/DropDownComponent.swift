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
                .foregroundStyle(Theme.color.onPrimary)
        }
        .foregroundStyle(Theme.color.primary)
        .padding(Theme.layout.padding)
        .background(Theme.color.backgroundGradient)
        .cornerRadius(Theme.layout.padding)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.layout.padding)
                .stroke(Theme.color.primary, lineWidth: 1)
        )
    })
}

struct DropDownOption{
    var icon: String
    var displayText: String
}
