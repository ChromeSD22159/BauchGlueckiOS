//
//  NutrinIcon.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

import SwiftUI

struct NutrinIcon: View {
    let uiImage: UIImage?
    let systemName: String?
    let nutrin: Double
    
    init(uiImage: UIImage? = nil, systemName: String? = nil, nutrin: Double) {
        self.nutrin = nutrin
        self.uiImage = uiImage
        self.systemName = systemName
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .font(.title3)
                    .foregroundStyle(Theme.shared.primary)
            }
            
            if let systemName = systemName {
                Image(systemName: systemName)
                    .font(.title3)
                    .foregroundStyle(Theme.shared.primary)
            }
            
            Text(String(format: "%.0fg", nutrin))
                .foregroundStyle(Theme.shared.onBackground)
                .font(.footnote)
        }
    }
}
