//
//  SheetHolder.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct SheetHolder<Content: View>: View {
    @Environment(\.theme) private var theme
    let content: () -> Content
    let title: String
    let backgroundImage: Bool
    init(
        title: String,
        backgroundImage: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.title = title
        self.backgroundImage = backgroundImage
    }
    
    var body: some View {
        NavigationView {
                GeometryReader { geo in
                    ZStack {
                        theme.color.background.ignoresSafeArea()
                        
                        if backgroundImage {
                            theme.bubbleBackground {
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: theme.layout.padding * 3) {
                                        content()
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 10)
                                    .padding(.horizontal, 10)
                                }
                            }.ignoresSafeArea()
                        } else {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: theme.layout.padding * 3) {
                                    content()
                                    
                                    Spacer()
                                }
                                .padding(.top, 10)
                                .padding(.horizontal, 10)
                            }
                        }
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
        
    }
}
