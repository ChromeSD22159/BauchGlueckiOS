//
//  TextStyleModifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//
import SwiftUI

struct TextStyle: ViewModifier {
    var fontSize: Font
    var color: Color
    func body(content: Content) -> some View {
        content
            .font(fontSize)
            .foregroundColor(color)
    }
}
