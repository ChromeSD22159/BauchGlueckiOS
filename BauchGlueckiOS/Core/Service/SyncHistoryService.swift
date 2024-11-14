//
//  SnycHistoryRepository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//
import SwiftData
import Foundation

@MainActor
class SyncHistoryService {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }

    func getLastSyncHistoryByEntity(entity: Entitiy) async throws -> SyncHistory? {
        let entityString = entity.rawValue
        let predicate = #Predicate { (history: SyncHistory) in
            history.table == entityString
        }
        
        let query = FetchDescriptor<SyncHistory>(
            predicate: predicate,
            sortBy: [SortDescriptor(\SyncHistory.lastSync, order: .reverse)]
        )
        
        return try context.fetch(query).first
    }
    
    func saveSyncHistoryStamp(entity: Entitiy) {
        context.insert(
            SyncHistory(
                table: entity.rawValue,
                lastSync: Date().timeIntervalSince1970Milliseconds
            )
        )
    }
    
    func deleteSyncHistoryStamp(entity: Entitiy) {
        Task {
            if let last = try await self.getLastSyncHistoryByEntity(entity: entity) {
                context.delete(last)
            }
        }
    }
}
