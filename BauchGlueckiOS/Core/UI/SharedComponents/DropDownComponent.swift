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
        HStack {
            Image(systemName: "ellipsis")
                .foregroundStyle(theme.onBackground)
                .rotationEffect(Angle(degrees: 90))
                .padding(.leading, 10)
                .padding(.bottom, 10)
        }
    })
}

struct DropDownOption{
    var icon: String
    var displayText: String
}
