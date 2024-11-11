//
//  ShoppingListItem.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftData
import Foundation

@Model
class ShoppingListItem {
    @Attribute(.unique) var shoppingListItemId: String
    var name: String
    var amount: String
    var unit: String
    var note: String
    var isComplete: Bool
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    
    init(
        shoppingListItemId: String = UUID().uuidString,
        name: String = "",
        amount: String = "",
        unit: String = "",
        note: String = "",
        isComplete: Bool = false,
        isDeleted: Bool = false,
        updatedAtOnDevice: Int64 = Date().timeIntervalSince1970Milliseconds
    ) {
        self.shoppingListItemId = shoppingListItemId
        self.name = name
        self.amount = amount
        self.unit = unit
        self.note = note
        self.isComplete = isComplete
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
    }
}

extension ShoppingListItem {
    var amountDouble: Double? {
        Double(amount)
    }
}
