//
//  ScrollOffsetPreferenceKey.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//

import SwiftUI 


struct ScrollOffsetPreferenceKey: PreferenceKey {

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}
