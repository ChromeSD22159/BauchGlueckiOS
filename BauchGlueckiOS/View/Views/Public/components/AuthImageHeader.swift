//
//  AuthImageHeader.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//
import SwiftUI

struct AuthImageHeader: View {
    
    @Environment(\.theme) private var theme
    
    var headline: String
    var description: String
    
    var body: some View {
        VStack {
            
            Image(uiImage: .magen)
                .resizable()
                .frame(width: 150, height: 150)
            
            VStack {
                Text(headline)
                    .font(theme.font.headlineText)
                    .foregroundStyle(theme.color.primary)
                
                Text(description)
                    .fontSytle(color: theme.color.onBackground)
            }
            
        }
    }
}

#Preview {
    AuthImageHeader(headline: "Headline", description: "description")
}
