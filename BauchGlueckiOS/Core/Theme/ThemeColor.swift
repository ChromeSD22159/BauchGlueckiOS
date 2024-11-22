//
//  ThemeColor.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

import SwiftUI 

struct ThemeColor {
    var primary: Color = Color.prime
    var onPrimary: Color = Color.onPrimary
    var background: Color = Color.background
    var onBackground: Color = Color.primary 
    var surface = Color.surface
    
    var backgroundGradient = LinearGradient(colors: [.prime, .prime.opacity(0.5)], startPoint: .top, endPoint: .bottom)
}
