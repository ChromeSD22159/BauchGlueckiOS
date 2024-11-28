//
//  HeadLineText.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.11.24.
//

import SwiftUI

struct HeadLineText: View {
    let text: String
    let color: Color?
    let multiLineTextAlignment: TextAlignment
    
    init(_ text: String, color: Color? = nil, multiLineTextAlignment: TextAlignment = .leading) {
        self.text = text
        self.color = color
        self.multiLineTextAlignment = multiLineTextAlignment
    }
    
    var body: some View {
        
        
        if let color = color {
            Text(text)
                .font(Theme.font.headlineTextSmall)
                .foregroundColor(color)
                .multilineTextAlignment(multiLineTextAlignment)
        } else {
            Text(text)
                .font(Theme.font.headlineTextSmall)
                .multilineTextAlignment(multiLineTextAlignment)
        }
    }
} 