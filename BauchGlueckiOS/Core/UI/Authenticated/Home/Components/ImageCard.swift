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
    private let theme = Theme.shared
    var iconLeft: String = "🤪"
    var iconRight: String = "🥳"
    var body: some View {
        ZStack {
            theme.surface
            
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
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.addNode,
                                target: { AddNode(modelContext: modelContext) },
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
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(theme.backgroundGradient)
                    .cornerRadius(100)
                }.foregroundStyle(Color.white)
                
            }.padding(10)
        }
        .background(theme.surface)
        .foregroundStyle(theme.onBackground)
        .cornerRadius(theme.radius)
        .padding(.horizontal, 10)
    }
}
