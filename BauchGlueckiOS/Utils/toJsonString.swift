//
//  toJsonString.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//

import Foundation

func toJsonString<T: Encodable>(data: T) -> String? {
    do {
        let jsonData = try JSONEncoder().encode(data)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            return nil
        }
    } catch {
        return nil
    }
}
