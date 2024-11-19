//
//  NoMedication.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI

struct NoMedication: View {
    let theme: Theme = Theme.shared
    var body: some View {
        VStack {
            Text("Medikamente für \(DateFormatteUtil.formattedFullDate(Date()))")
                .font(theme.headlineTextSmall)
            
            Text("Du hast heute keine Medikamente zum einnehmen.")
                .font(.footnote)
        }
        .padding(theme.padding)
        .foregroundStyle(theme.onBackground)
        .sectionShadow(margin: theme.padding)
    }
}
