//
//  FullSizeImageButton.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 08.11.24.
//
import SwiftUI

struct FullSizeImageButton: View {
    let icon: String
    let title: String
    let onClick: () -> Void
    var body: some View {
        Button(action: {
            onClick()
        }, label: {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
        })
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.shared.padding)
        .padding(.vertical, Theme.shared.padding.subtractGoldenRatio)
        .foregroundStyle(Theme.shared.onPrimary)
        .background(
            Capsule()
                .fill(Theme.shared.backgroundGradient)
        )
    }
}
