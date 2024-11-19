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
    Button(
        action: {
            onClick()
        }, label: {
            Image(systemName: icon)
                .foregroundStyle(Theme.color.onPrimary)
        }
    )
    .padding(Theme.layout.padding)
    .background(Theme.color.backgroundGradient)
    .cornerRadius(100)
}
