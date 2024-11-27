//
//  NutrinIcon.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

import SwiftUI

struct NutrinIcon: View {
    @Environment(\.theme) private var theme
    
    let uiImage: UIImage?
    let systemName: String?
    let icon: String?
    let nutrin: Double
    
    init(uiImage: UIImage? = nil, systemName: String? = nil, icon: String? = nil, nutrin: Double) {
        self.nutrin = nutrin
        self.uiImage = uiImage
        self.systemName = systemName
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .font(.title3)
                    .foregroundStyle(theme.color.primary)
            }
            
            if let systemName = systemName {
                Image(systemName: systemName)
                    .font(.title3)
                    .foregroundStyle(theme.color.primary)
            }
            
            if let icon = icon {
                Image(icon)
                    .font(.title3)
                    .foregroundStyle(theme.color.primary)
            }
            
            FootLineText(String(format: "%.0fg", nutrin), color: theme.color.onBackground)
        }
    }
}
