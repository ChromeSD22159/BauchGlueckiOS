//
//  PreperationTimeCategoryRow.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct PreperationTimeCategoryRow: View {
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
        .padding(.horizontal, Theme.shared.padding)
        .foregroundStyle(Theme.shared.primary)
        .font(.footnote)
    }
}
