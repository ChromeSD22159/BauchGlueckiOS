//
//  ClippedImage.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.11.24.
//
import SwiftUI

struct ClippedImage: View {
    let image: Image
    let size: CGFloat
    var body: some View {
        Rectangle()
            .frame(width: size, height: size)
            .overlay {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
            }
    }
}

#Preview {
    ClippedImage(image: Image(.beilage), size: 100)
}
