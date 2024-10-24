//
//  ScreenHolder.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//

import SwiftUI

struct ScreenHolder<Content: View>: View {
    private let theme: Theme = Theme.shared
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    content()
                }.padding(.top, 10)
            }
        }
    }
}
