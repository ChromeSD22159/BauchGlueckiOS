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

extension Int64 {
    var toDate: Date {
        return Date(timeIntervalSince1970: Double(self / 1000))
    }
}
