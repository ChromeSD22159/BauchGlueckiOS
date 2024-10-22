//
//  listAllFonts.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//

import SwiftUI

func listAllFonts() {
    for family in UIFont.familyNames {
        print("Font family: \(family)")
        for font in UIFont.fontNames(forFamilyName: family) {
            print("  Font name: \(font)")
        }
    }
}
