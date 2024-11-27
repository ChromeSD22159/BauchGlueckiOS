//
//  TextWithTitlte.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct TextWithTitlte: View {
    @Environment(\.theme) private var theme
    
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) { 
            HeadLineText(title)
            
            Text(text)
        }
    }
}
