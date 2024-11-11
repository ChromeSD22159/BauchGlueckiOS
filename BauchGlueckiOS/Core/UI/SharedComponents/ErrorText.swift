//
//  ErrorText.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 11.11.24.
//
import SwiftUI

struct ErrorText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(Color.red)
    }
}
