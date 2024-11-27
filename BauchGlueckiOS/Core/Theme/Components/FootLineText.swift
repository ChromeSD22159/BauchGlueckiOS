//
//  FootLineText.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.11.24.
//
import SwiftUI

struct FootLineText: View {
    let text: String
    let color: Color?
    
    init(_ text: String, color: Color? = nil) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        if let color = color {
            Text(text)
                .font(.footnote)
                .foregroundColor(color)
        } else {
            Text(text)
                .font(.footnote)
        }
    }
} 
