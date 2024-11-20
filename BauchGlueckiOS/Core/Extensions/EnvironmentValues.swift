//
//  EnvironmentValues.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

import SwiftUI

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
