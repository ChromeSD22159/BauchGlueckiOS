//
//  PreviewDataScource.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftData
import Foundation
import SwiftUICore

@MainActor
var previewDataScource: ModelContainer = {
    let schema = Schema([
        CountdownTimer.self,
        Node.self,
        WaterIntake.self,
        Weight.self,
        Medication.self,
        SyncHistory.self,
        
        Recipe.self,
        Ingredient.self,
        MainImage.self,
        Category.self,
        MealPlanDay.self,
        MealPlanSpot.self,
        
        ShoppingList.self,
        ShoppingListItem.self
    ])
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        let context = container.mainContext
        
        let userID = UUID()
        let medicationID = UUID()
        
        let medication = Medication(
            id: medicationID,
            medicationId: medicationID.uuidString,
            userId: medicationID.uuidString,
            name: "Ibuprofen",
            dosage: "400mg",
            isDeleted: false,
            updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
            intakeTimes: []
        )
        
        let intakeTimes = [
            IntakeTime(
                id: UUID(),
                intakeTimeId: UUID().uuidString,
                intakeTime: "12:20",
                medicationId: medicationID.uuidString,
                isDeleted: false,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                medication: medication,
                intakeStatuses: []
            ),
            IntakeTime(
                id: UUID(),
                intakeTimeId: UUID().uuidString,
                intakeTime: "18:20",
                medicationId: medicationID.uuidString,
                isDeleted: false,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                medication: medication,
                intakeStatuses: []
            )
        ]

        let intakeStatuses = [
            IntakeStatus(
                intakeStatusId: UUID().uuidString,
                intakeTimeId: intakeTimes[0].intakeTimeId,
                date: DateHelper.yesterday.timeIntervalSince1970Milliseconds,
                isTaken: true,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                intakeTime: intakeTimes[0]
            ),
            IntakeStatus(
                intakeStatusId: UUID().uuidString,
                intakeTimeId: intakeTimes[1].intakeTimeId,
                date: DateHelper.today.timeIntervalSince1970Milliseconds,
                isTaken: false, 
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                intakeTime: intakeTimes[1]
            )
        ]
        
        // IntakeStatuses zur jeweiligen IntakeTime hinzufügen
        intakeTimes[0].intakeStatuses.append(intakeStatuses[0])
        intakeTimes[1].intakeStatuses.append(intakeStatuses[1])
        
        // IntakeTimes zur Medication hinzufügen
        medication.intakeTimes.append(contentsOf: intakeTimes)
        
        // IntakeTimes und Medication im Kontext speichern
        intakeTimes.forEach { intake in
            context.insert(intake)
        }
        context.insert(medication)
        
        // IntakeStatuses im Kontext speichern
        intakeStatuses.forEach { intakeStatus in
            context.insert(intakeStatus)
        }
        
        for recipe in mockRecipes {
            context.insert(recipe)
        }
        
        for shoppingList in mockShoppingLists {
            context.insert(shoppingList)
        }
       
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
 
/*
class WaterIntakeRepository: Database {
    func fetchAll() throws -> [WaterIntake] {
        return try modelContext.fetch(FetchDescriptor<WaterIntake>())
    }
}

@MainActor
class Database: RepositoryProtocoll {
    var modelContainer: ModelContainer
    
    var modelContext: ModelContext {
        modelContainer.mainContext
    }
    
    required init(databaseType: DatabaseType) {
        let schema = Schema([
            CountdownTimer.self,
            Node.self,
            WaterIntake.self,
            Weight.self,
            Medication.self,
            SyncHistory.self,
            
            Recipe.self,
            Ingredient.self,
            MainImage.self,
            Category.self,
            MealPlanDay.self,
            MealPlanSpot.self,
            
            ShoppingList.self,
            ShoppingListItem.self
        ])
        
        let modelConfiguration: ModelConfiguration
        
        switch databaseType {
            case .local: modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            case .preview: modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        
        let container = try! ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        modelContainer = container
    }
}

protocol RepositoryProtocoll {
    @MainActor var modelContainer: ModelContainer { get }
    @MainActor var modelContext: ModelContext { get }
    @MainActor init(databaseType: DatabaseType)
}


enum DatabaseType {
    case local, preview
}
 */
