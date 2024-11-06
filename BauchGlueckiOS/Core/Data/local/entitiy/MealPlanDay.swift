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
    @Attribute(.unique) var mealPlanDayID: Int
    @Attribute var userId: String
    @Attribute var date: Date
    @Attribute var isDeleted: Bool
    @Attribute var updatedAtOnDevice: Int64
    
    @Relationship(deleteRule: .noAction) var slots: [MealPlanSpot] = []
    
    init(mealPlanDayID: Int, userId: String, date: Date, isDeleted: Bool, updatedAtOnDevice: Int64, slots: [MealPlanSpot] = []) {
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
    @Attribute(.unique) var MealPlanSpotId: Int
    @Attribute var mealPlanDayId: Int
    @Attribute var mealId: Int
    @Attribute var userId: String
    @Attribute var timeSlot: String
    @Attribute var isDeleted: Bool
    
    @Relationship(deleteRule: .noAction) var recipe: Recipe?

    init(MealPlanSpotId: Int, mealPlanDayId: Int, mealId: Int, userId: String, timeSlot: String, isDeleted: Bool, recipe: Recipe? = nil) {
        self.MealPlanSpotId = MealPlanSpotId
        self.mealPlanDayId = mealPlanDayId
        self.mealId = mealId
        self.userId = userId
        self.timeSlot = timeSlot
        self.isDeleted = isDeleted
        self.recipe = recipe
    }
}

/*(
    @PrimaryKey val mealPlanSpotId: String = "",
    var mealPlanDayId: String = "",
    val mealId: String = "",
    val userId: String = "",
    val timeSlot: String = "",
    val isDeleted: Boolean = false,
    var meal: String? = null,
    val updatedAtOnDevice: Long = Clock.System.now().toEpochMilliseconds()
)
*/
