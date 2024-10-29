//
//  NextMedicationCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct NextMedicationCard: View {
    var body: some View {
        NoMedication()
    }
}

struct NoMedication: View {
    let theme: Theme = Theme.shared
    var body: some View {
        VStack {
            Text("Medikamente für \(formattedDate(Date()))")
                .font(theme.headlineTextSmall)
            
            Text("Du hast heute keine Medikamente zum einnehmen.")
                .font(.footnote)
        }
        .padding(theme.padding)
        .foregroundStyle(theme.onBackground)
        .sectionShadow(margin: theme.padding)
    }
}
