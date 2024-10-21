//
//  CountdownRepository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.10.24.
//

import SwiftData
import Foundation

class CountdownRepository {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getAll() async throws -> [CountdownTimer] {
        return try context.fetch(FetchDescriptor<CountdownTimer>())
    }
    
    func getById(timerId: String) -> CountdownTimer? {
        // Erstelle eine Predicate, um nach dem timerId zu filtern
        let predicate = #Predicate { (timer: CountdownTimer) in
            timer.timerId == timerId
        }

        // Erstelle einen FetchDescriptor mit der Predicate und Sortierung nach Name
        let query = FetchDescriptor<CountdownTimer>(
            predicate: predicate,
            sortBy: [SortDescriptor(\CountdownTimer.name)]
        )
        
        // Führe die Abfrage durch und gib das erste gefundene Ergebnis zurück
        if let result = try? context.fetch(query).first {
            return result
        }
        
        // Falls kein Ergebnis gefunden wird, gib nil zurück
        return nil
    }
    
    func insertOrUpdate(countdownTimer: CountdownTimer) {
        // Versuche, den Timer anhand der ID zu finden
        let existingTimer = getById(timerId: countdownTimer.timerId)
        
        if let existingTimer = existingTimer {
            // Timer existiert -> Update die Felder
            existingTimer.name = countdownTimer.name
            existingTimer.duration = countdownTimer.duration
            existingTimer.startDate = countdownTimer.startDate
            existingTimer.endDate = countdownTimer.endDate
            existingTimer.timerState = countdownTimer.timerState
            existingTimer.showActivity = countdownTimer.showActivity
            existingTimer.isDeleted = countdownTimer.isDeleted
            existingTimer.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
        } else {
            // Timer existiert nicht -> Füge den neuen Timer hinzu
            context.insert(countdownTimer)
        }
        
        // Speichere die Änderungen im Kontext
        do {
            try context.save()
        } catch {
            print("Fehler beim Speichern des CountdownTimers: \(error)")
        }
    }
    
    func softDeleteMany(countdownTimers: [CountdownTimer]) async throws {
        // Erstellen einer Liste der zu aktualisierenden CountdownTimer
        countdownTimers.forEach { timer in
            timer.isDeleted = true
            timer.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
        }
        
        // Speichere die Änderungen im Kontext
        try context.save()
    }
}
