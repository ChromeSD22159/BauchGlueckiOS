//
//  Modifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

extension View {
    func fontSytle(fontSize: Font = Font.body, color: Color = Color.black) -> some View {
        modifier(TextStyle(fontSize: fontSize, color: color))
    }
}

struct TextStyle: ViewModifier {
    var fontSize: Font
    var color: Color
    func body(content: Content) -> some View {
        content
            .font(fontSize)
            .foregroundColor(color)
    }
}
