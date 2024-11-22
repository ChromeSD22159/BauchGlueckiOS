//
//  ScreenHolder.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//

import SwiftUI

struct ScreenHolder<Content: View>: View {
    @Environment(\.theme) private var theme
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) { 
                    content()
                }.padding(.top, 10)
            }
        }
    }
}
