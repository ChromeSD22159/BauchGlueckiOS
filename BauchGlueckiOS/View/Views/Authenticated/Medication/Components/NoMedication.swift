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
            HeadLineText("Medikamente für \(DateFormatteUtil.formattedFullDate(Date()))")
            
            FootLineText("Du hast heute keine Medikamente zum einnehmen.") 
        }
        .padding(theme.layout.padding)
        .foregroundStyle(theme.color.onBackground)
        .sectionShadow(margin: theme.layout.padding)
    }
}
