//
//  UnitFormatUtils.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

struct UnitFormatUtils {
    static func formatGrammString(_ value: Double) -> String {
        return String(format: "%0.1fg", value)
    }
    
    static func formatGrammString(_ value: Int) -> String {
        return String(format: "%0.1fg", value)
    }
}
