//
//  StringExtension.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//

import Foundation

extension String {
    var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        return dateFormatter.date(from: self)
    }
}
