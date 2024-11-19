//
//  createPreviews.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

func createPreviews<T: View>(for view: T) -> some View {
    Group {
        view
            .previewDisplayName("Light Mode")
            .environment(\.colorScheme, .light)

        view
            .previewDisplayName("Dark Mode")
            .environment(\.colorScheme, .dark)
    }
}
