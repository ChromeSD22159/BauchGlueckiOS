//
//  formattedDateTimer.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

func formattedDateTimer(_ date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "de_DE")
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    
    return formatter.string(from: date)
}
