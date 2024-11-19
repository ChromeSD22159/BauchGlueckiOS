//
//  GridUtils.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

import Foundation
import SwiftUI

struct GridUtils {
    static func createGridItems(count: Int, spacing: CGFloat = 10) -> [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
}
