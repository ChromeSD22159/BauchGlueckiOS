//
//  PreperationTimeCategoryRow.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct PreperationTimeCategoryRow: View {
    @Environment(\.theme) private var theme
    
    let preparationTimeInMinutes: Int
    let recipeName: String
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "clock")
                    .renderingMode(.template)
                
                Text("\(preparationTimeInMinutes) Minuten")
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .renderingMode(.template)
                
                Text(recipeName)
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal, theme.layout.padding)
        .foregroundStyle(theme.color.primary)
        .font(.footnote)
    }
}
