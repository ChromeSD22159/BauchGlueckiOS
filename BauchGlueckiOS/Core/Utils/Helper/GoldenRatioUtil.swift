//
//  goldenRatio.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

import Foundation

struct GoldenRatioUtil {
    static func addGoldenRatio(_ value: Double) -> Double {
        return value.addGoldenRatio
    }
    
    static func subtractGoldenRatio(_ value: Double) -> Double {
        return value.subtractGoldenRatio
    }
    
    static func addGoldenRatio(_ value: CGFloat) -> CGFloat {
        return value.addGoldenRatio
    }
    
    static func subtractGoldenRatio(_ value: CGFloat) -> CGFloat {
        return value.subtractGoldenRatio
    }
    
    static func calculateGoldenRatio(_ value: Double) -> (larger: Double, lower: Double) {
        let phi = 1.61803398875
        let larger = value * phi
        let smaller = value - larger
        return (larger: larger, lower: smaller)
    }
    
    static func calculateGoldenRatio(_ value: CGFloat) -> (larger: CGFloat, lower: CGFloat) {
        let phi = 1.61803398875
        let larger = value * phi
        let smaller = value - larger
        return (larger: larger, lower: smaller)
    }
}

extension Numeric where Self: BinaryFloatingPoint {
    var addGoldenRatio: Double {
        return Double(self) * (13.0 / 8.0)
    }
    
    var subtractGoldenRatio: Double {
        return Double(self) / (13.0 / 8.0)
    }
}

extension Numeric where Self: BinaryInteger {
    var addGoldenRatio: Double {
        return Double(self) * (13.0 / 8.0)
    }
    
    var subtractGoldenRatio: Double {
        return Double(self) / (13.0 / 8.0)
    }
}
