//
//  goldenRatio.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

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
