//
//  LaunchScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//
import SwiftUI

struct LaunchScreen: View {
    let theme: Theme
    
    init() {
        self.theme = Theme()
    }
    
    var body: some View {
        AppBackground(color: theme.background) {
            theme.bubbleBackground {
                VStack {
                    Image(.magen)
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text("BauchGlück")
                        .font(theme.headlineText)
                        .foregroundStyle(theme.primary)
                }
            }
        }
    }
}


#Preview {
    LaunchScreen()
}
