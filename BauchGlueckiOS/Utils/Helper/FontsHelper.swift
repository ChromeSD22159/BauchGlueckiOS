//
//  FontsHelper.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

import UIKit

func FontsHelper() {
    for familyName in UIFont.familyNames {
        print("\(familyName)")
        
        for fontName in UIFont.fontNames(forFamilyName: familyName) {
            print("-- \(fontName)")
        }
    }
}
