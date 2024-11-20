//
//  LaunchScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//
import SwiftUI

struct LaunchScreen: View { 
    @Environment(\.theme) private var theme
    var body: some View {
        AppBackground(color: theme.color.background) {
            theme.bubbleBackground {
                VStack {
                    Image(.magen)
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text("BauchGlück")
                        .font(Theme.font.headlineText)
                        .foregroundStyle(Theme.color.primary)
                }
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
