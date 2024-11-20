//
//  NoMedication.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI

struct NoMedication: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack {
            Text("Medikamente für \(DateFormatteUtil.formattedFullDate(Date()))")
                .font(theme.font.headlineTextSmall)
            
            Text("Du hast heute keine Medikamente zum einnehmen.")
                .font(.footnote)
        }
        .padding(theme.layout.padding)
        .foregroundStyle(theme.color.onBackground)
        .sectionShadow(margin: theme.layout.padding)
    }
}
