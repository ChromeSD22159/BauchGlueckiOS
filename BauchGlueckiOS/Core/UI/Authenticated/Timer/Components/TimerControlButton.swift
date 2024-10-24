//
//  TimerControlButton.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//

import SwiftUI

@ViewBuilder func TimerControlButton(
    icon: String,
    onClick: @escaping () -> Void = {}
) -> some View {
    let theme = Theme.shared
    Button(
        action: {
            onClick()
        }, label: {
            Image(systemName: icon)
                .foregroundStyle(theme.onPrimary)
        }
    )
    .padding(theme.padding)
    .background(theme.backgroundGradient)
    .cornerRadius(100)
}
