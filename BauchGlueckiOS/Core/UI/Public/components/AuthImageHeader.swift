//
//  AuthImageHeader.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//
import SwiftUI

struct AuthImageHeader: View {
    
    private let theme = Theme.shared
    
    var headline: String
    var description: String
    
    var body: some View {
        VStack {
            
            Image(uiImage: .magen)
                .resizable()
                .frame(width: 150, height: 150)
            
            VStack {
                Text(headline)
                    .font(theme.headlineText)
                    .foregroundStyle(theme.primary)
                
                Text(description)
                    .fontSytle(color: theme.onBackground)
            }
            
        }
    }
}

#Preview {
    AuthImageHeader(headline: "Headline", description: "description")
}
