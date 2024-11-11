//
//  mockShoppingList.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//

import Foundation

let mockShoppingListItems = [
    ShoppingListItem(
        shoppingListItemId: UUID().uuidString,
        name: "Apples",
        amount: "1.5",
        unit: "kg",
        note: "Prefer organic",
        isComplete: false,
        isDeleted: false,
        updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
    ),
    ShoppingListItem(
        shoppingListItemId: UUID().uuidString,
        name: "Milk",
        amount: "2",
        unit: "liters",
        note: "Low fat",
        isComplete: true,
        isDeleted: false,
        updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
    ),
    ShoppingListItem(
        shoppingListItemId: UUID().uuidString,
        name: "Bread",
        amount: "1",
        unit: "loaf",
        note: "Whole grain",
        isComplete: false,
        isDeleted: false,
        updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
    )
]

let mockShoppingLists = [
    ShoppingList(
        id: UUID(),
        name: "Weekly Groceries",
        shoppingListId: UUID().uuidString,
        userId: "user1",
        descriptionText: "Groceries for the week",
        startDate: "2024-11-10",
        endDate: "2024-11-17",
        note: "Don't forget snacks",
        isComplete: false,
        isDeleted: false,
        updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
        items: mockShoppingListItems
    ),
    ShoppingList(
        id: UUID(),
        name: "Party Supplies",
        shoppingListId: UUID().uuidString,
        userId: "user2",
        descriptionText: "Shopping for the weekend party",
        startDate: "2024-11-11",
        endDate: "2024-11-12",
        note: "Focus on drinks and snacks",
        isComplete: false,
        isDeleted: false,
        updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
        items: [
            ShoppingListItem(
                shoppingListItemId: UUID().uuidString,
                name: "Chips",
                amount: "3",
                unit: "packs",
                note: "Assorted flavors",
                isComplete: false,
                isDeleted: false,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
            ),
            ShoppingListItem(
                shoppingListItemId: UUID().uuidString,
                name: "Soda",
                amount: "5",
                unit: "bottles",
                note: "1.5 liters each",
                isComplete: false,
                isDeleted: false,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
            )
        ]
    )
]
