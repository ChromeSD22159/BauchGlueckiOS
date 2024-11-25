//
//  ImageCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import SwiftUI

struct ImageCard: View { 
    @Environment(\.modelContext) var modelContext
    @Environment(\.theme) private var theme
    
    var iconLeft: String = "🤪"
    var iconRight: String = "🥳"
    var body: some View {
        ZStack {
            theme.color.surface
            
            Background()
            
            Content()
                .padding(theme.layout.padding)
            
        }.sectionShadow(margin: theme.layout.padding)
    }
    
    @ViewBuilder func Background() -> some View {
        HStack {
            Text(iconLeft)
                .offset(x: -10)
                .font(theme.font.iconFont)
                .rotationEffect(Angle(degrees: -10))
            
            Spacer()
            
            Text(iconRight)
                .offset(x: 10)
                .font(theme.font.iconFont)
        }
    }
    
    @ViewBuilder func Content() -> some View {
        VStack(spacing: 16) {
            Text("Wie war dein Tag?").font(theme.font.headlineTextSmall)
            Text("Erfasse Notizen, Gefühle")
                .multilineTextAlignment(.center)
                .font(.footnote)
            Text("oder gedanken.")
                .multilineTextAlignment(.center)
                .font(.footnote)
            
            HStack {
                ZStack {
                    Text("Notiz eintragen")
                        .font(.footnote)
                        .foregroundStyle(theme.color.onPrimary)
                        .navigateTo(
                            destination: Destination.addNote,
                            target: { AddNote(modelContext: modelContext) },
                            toolbarItems: {
                                //Image(systemName: "figure")
                            }
                        )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(theme.color.backgroundGradient)
                .cornerRadius(100)
                
                ZStack {
                    Text("Alle Einträge")
                        .font(.footnote)
                        .foregroundStyle(theme.color.onPrimary)
                        .navigateTo( 
                            destination: Destination.notes,
                            target: { AllNotes() },
                            toolbarItems: {
                                //Image(systemName: "figure")
                            }
                        )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(theme.color.backgroundGradient)
                .cornerRadius(100)
            }
            .foregroundStyle(theme.color.onBackground)
            
        }
    }
}



struct AppSection<Content: View>: View {
    @Environment(\.theme) private var theme
       let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
        }
        .background(theme.color.surface)
        .foregroundStyle(theme.color.onBackground)
        .cornerRadius(theme.layout.radius)
        .padding(.horizontal, 10)
    }
}
