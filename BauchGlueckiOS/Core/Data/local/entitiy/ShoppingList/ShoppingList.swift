//
//  ShoppingList.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftData
import Foundation

@Model
class ShoppingList {
    @Attribute(.unique) var id: UUID
    var name: String
    var shoppingListId: String
    var userId: String
    var descriptionText: String
    var startDate: String
    var endDate: String
    var note: String
    var isComplete: Bool
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    @Relationship(deleteRule: .cascade) var items: [ShoppingListItem]
    
    init(
        id: UUID = UUID(),
        name: String = "",
        shoppingListId: String = UUID().uuidString,
        userId: String = "",
        descriptionText: String = "",
        startDate: String = "",
        endDate: String = "",
        note: String = "",
        isComplete: Bool = false,
        isDeleted: Bool = false,
        updatedAtOnDevice: Int64 = Date().timeIntervalSince1970Milliseconds,
        items: [ShoppingListItem] = []
    ) {
        self.id = id
        self.name = name
        self.shoppingListId = shoppingListId
        self.userId = userId
        self.descriptionText = descriptionText
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.isComplete = isComplete
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.items = items
    }
}


