//
//  CapsuleButtonStyle.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import SwiftUI
import Foundation

struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Theme.color.onPrimary)
            .padding(.vertical, Theme.layout.padding * 0.618)
            .padding(.horizontal, Theme.layout.padding * 1.618)
            .background(Theme.color.backgroundGradient)
            .clipShape(Capsule())
    }
}
