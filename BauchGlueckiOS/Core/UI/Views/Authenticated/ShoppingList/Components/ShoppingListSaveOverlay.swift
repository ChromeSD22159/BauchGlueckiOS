//
//  ShoppingListSaveOverlay.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 11.11.24.
//
import SwiftUI

struct ShoppingListSaveOverlay: View {
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
                        .foregroundStyle(Theme.shared.onBackground)
                } else {
                    Text("Einkaufsliste wird erstellt...")
                        .font(.footnote)
                        .foregroundStyle(Theme.shared.onBackground)
                }
                
            }
            .padding(Theme.shared.padding)
            .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
            .background(Material.ultraThinMaterial)
            .cornerRadius(geo.size.width * 0.6 / 10)
            .shadow(radius: 20)
            .animation(.easeInOut, value: isPresented)
        }
    }
}
