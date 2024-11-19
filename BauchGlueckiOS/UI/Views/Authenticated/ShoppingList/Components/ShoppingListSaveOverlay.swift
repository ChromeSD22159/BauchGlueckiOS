//
//  ShoppingListSaveOverlay.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 11.11.24.
//
import SwiftUI

struct ShoppingListSaveOverlay: View {
    @Environment(\.theme) private var theme
    
    var geo: GeometryProxy
    var hasError: Error?
    @Binding var isPresented: Bool
    
    var body: some View {
        if isPresented {
            VStack(spacing: 20) {
                ProgressView()
                Text("Speichern")
                
                if (hasError != nil) {
                    Text("Fehler beim Speichern: \(hasError?.localizedDescription ?? "")")
                        .font(.footnote)
                        .foregroundStyle(theme.color.onBackground)
                } else {
                    Text("Einkaufsliste wird erstellt...")
                        .font(.footnote)
                        .foregroundStyle(theme.color.onBackground)
                }
                
            }
            .padding(theme.layout.padding)
            .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
            .background(Material.ultraThinMaterial)
            .cornerRadius(geo.size.width * 0.6 / 10)
            .shadow(radius: 20)
            .animation(.easeInOut, value: isPresented)
        }
    }
}