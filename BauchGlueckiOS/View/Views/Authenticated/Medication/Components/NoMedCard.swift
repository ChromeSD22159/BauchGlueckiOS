//
//  NoMedCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct NoMedCard: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack {
            Spacer()
            HStack(alignment: .top) {
                Image(systemName: "pills.fill")
                    .font(.title)
                
                VStack(alignment: .leading) { 
                    HeadLineText("Noch kein Medikament")
                     
                    FootLineText("trage dein erstes Medikament ein")
                }
            }
            Spacer()
        }
        .cardStyle()
    }
}
