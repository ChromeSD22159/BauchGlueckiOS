//
//  ImageCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import SwiftUI

struct ImageCard: View {
    @EnvironmentObject var firebase: FirebaseService
    @Environment(\.modelContext) var modelContext
    let theme = Theme.shared
    
    var iconLeft: String = "🤪"
    var iconRight: String = "🥳"
    var body: some View {
        ZStack {
            theme.surface
            
            Background()
            
            Content()
                .padding(theme.padding)
            
        }.sectionShadow(margin: theme.padding)
    }
    
    @ViewBuilder func Background() -> some View {
        HStack {
            Text(iconLeft)
                .offset(x: -10)
                .font(theme.iconFont)
                .rotationEffect(Angle(degrees: -10))
            
            Spacer()
            
            Text(iconRight)
                .offset(x: 10)
                .font(theme.iconFont)
        }
    }
    
    @ViewBuilder func Content() -> some View {
        VStack(spacing: 16) {
            Text("Wie war dein Tag?").font(theme.headlineTextSmall)
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
                        .foregroundStyle(theme.onPrimary)
                        .navigateTo(
                            firebase: firebase,
                            destination: Destination.addNote,
                            target: { AddNote(modelContext: modelContext) },
                            toolbarItems: {
                                //Image(systemName: "figure")
                            }
                        )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(theme.backgroundGradient)
                .cornerRadius(100)
                
                ZStack {
                    Text("Alle Einträge")
                        .font(.footnote)
                        .foregroundStyle(theme.onPrimary)
                        .navigateTo(
                            firebase: firebase,
                            destination: Destination.notes,
                            target: { AllNotes() },
                            toolbarItems: {
                                //Image(systemName: "figure")
                            }
                        )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(theme.backgroundGradient)
                .cornerRadius(100)
            }
            .foregroundStyle(theme.onBackground)
            
        }
    }
}



struct AppSection<Content: View>: View {
    var theme: Theme
       let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.theme = Theme.shared
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
        }
        .background(theme.surface)
        .foregroundStyle(theme.onBackground)
        .cornerRadius(theme.radius)
        .padding(.horizontal, 10)
    }
}
