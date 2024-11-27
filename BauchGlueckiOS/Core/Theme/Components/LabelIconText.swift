//
//  LabelIconText.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.11.24.
//
import SwiftUI

struct LabelIconText: View {
    let text: String
    let systemImage: String
    let color: Color?
    
    init(_ text: String, systemImage: String, color: Color? = nil) {
        self.text = text
        self.color = color
        self.systemImage = systemImage
    }
    
    var body: some View {
        if let color = color {
            Label(text, systemImage: systemImage)
                .font(.footnote)
                .foregroundColor(color)
        } else {
            Label(text, systemImage: systemImage)
                .font(.footnote)
        }
    }
}
