//
//  DateExtensions.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//
import SwiftUI

extension Date {
    var timeIntervalSince1970Milliseconds: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
