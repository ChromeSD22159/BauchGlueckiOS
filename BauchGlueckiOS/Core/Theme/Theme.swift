//
//  Theme.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//
import SwiftUI

struct Theme {
    
    let color: ThemeColor = ThemeColor()
    let font: ThemeFont = ThemeFont()
    let layout: ThemeLayout = ThemeLayout()
    
    @ViewBuilder func bubbleBackground<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            // IMAGE BACKGROUND
            VStack {
                Spacer()
                Image(uiImage: .bubbleRight)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            content()
        }
    }
}

extension Theme {
    static let color: ThemeColor = ThemeColor()
    static let font: ThemeFont = ThemeFont()
    static let layout: ThemeLayout = ThemeLayout()
    
    @ViewBuilder static func bubbleBackground<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            // IMAGE BACKGROUND
            VStack {
                Spacer()
                Image(uiImage: .bubbleRight)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            content()
        }
    }
}
