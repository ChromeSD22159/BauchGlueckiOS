//
//  ThemeFont.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//
import SwiftUI

struct ThemeFont {
    func headlineText(size: CGFloat = 25) -> Font {
        CustomFont.Rodetta.font(size: size)
    }
    
    var headlineText = CustomFont.Rodetta.font(size: 25)
    var headlineTextMedium = CustomFont.Rodetta.font(size: 22)
    var headlineTextSmall = CustomFont.Rodetta.font(size: 16)
    
    var iconFont = CustomFont.Rodetta.font(size: 64)
    
    enum CustomFont: String {
        case Rodetta = "RodettaRegular"
        
        func font(size: CGFloat) -> Font {
            return Font.custom(self.rawValue, size: size)
        }
    }
}
