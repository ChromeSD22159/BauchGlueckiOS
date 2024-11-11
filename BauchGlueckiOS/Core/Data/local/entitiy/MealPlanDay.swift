//
//  MealPlanDay.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 06.11.24.
//
import SwiftData
import Foundation

@Model
class MealPlanDay {
    @Attribute(.unique) var mealPlanDayID: UUID
    @Attribute var userId: String
    @Attribute var date: Date
    @Attribute var isDeleted: Bool
    @Attribute var updatedAtOnDevice: Int64
    @Relationship(deleteRule: .cascade) var slots: [MealPlanSpot]
    
    init(mealPlanDayID: UUID = UUID(), userId: String, date: Date, isDeleted: Bool, updatedAtOnDevice: Int64, slots: [MealPlanSpot] = []) {
        self.mealPlanDayID = mealPlanDayID
        self.userId = userId
        self.date = date
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.slots = slots
    }
}

@Model
class MealPlanSpot {
    @Attribute(.unique) var MealPlanSpotId: UUID
    @Attribute var mealPlanDayId: String
    @Attribute var mealId: String
    @Attribute var userId: String
    @Attribute var timeSlot: String
    @Attribute var isDeleted: Bool
    @Relationship(inverse: \MealPlanDay.slots) var mealPlanDay: MealPlanDay
    
    @Relationship(deleteRule: .noAction) var recipe: Recipe?

    init(MealPlanSpotId: UUID = UUID(), mealPlanDayId: String, mealId: String, userId: String, timeSlot: String, isDeleted: Bool = false, recipe: Recipe? = nil, mealPlanDay: MealPlanDay) {
        self.MealPlanSpotId = MealPlanSpotId
        self.mealPlanDayId = mealPlanDayId
        self.mealId = mealId
        self.userId = userId
        self.timeSlot = timeSlot
        self.isDeleted = isDeleted
        self.recipe = recipe
        self.mealPlanDay = mealPlanDay
    }
}
