//
//  FullSizeButton.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 08.11.24.
//
import SwiftUI

struct FullSizeButton: View {
    let title: String
    let onClick: () -> Void
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button(action: {
            onClick()
        }, label: {
            Text(title)
        })
        .frame(maxWidth: .infinity)
        .padding(.horizontal, theme.layout.padding)
        .padding(.vertical, GoldenRatioUtil.subtractGoldenRatio(theme.layout.padding.subtractGoldenRatio))
        .foregroundStyle(theme.color.onPrimary)
        .background(
            Capsule()
                .fill(theme.color.backgroundGradient)
        )
        
        
    }
}
