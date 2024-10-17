//
//  LocalDataScource.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 17.10.24.
//
import SwiftData

var localDataScource: ModelContainer = {
    let schema = Schema([
        Item.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
