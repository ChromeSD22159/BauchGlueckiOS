//
//  CountdownRepository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.10.24.
//

import SwiftData
import Foundation
import FirebaseAuth
import Alamofire

@MainActor
class CountdownService {
    private var context: ModelContext
    private var table: TableEntitiy
    private var apiService: StrapiApiClient
    private var syncHistoryRepository: SyncHistoryService
    private var headers: HTTPHeaders {
        [.authorization(bearerToken: apiService.bearerToken)]
    }
    
    init(context: ModelContext, apiService: StrapiApiClient) {
        self.context = context
        self.table = TableEntitiy.COUNTDOWN_TIMER
        self.apiService = apiService
        self.syncHistoryRepository = SyncHistoryService(context: context)
    }
    
    func getAll() async throws -> [CountdownTimer] {
        guard let userID = Auth.auth().currentUser?.uid else { return [] }
        
        let predicate = #Predicate { (timer: CountdownTimer) in
            timer.userID == userID
        }
        
        let query = FetchDescriptor<CountdownTimer>(
            predicate: predicate,
            sortBy: [SortDescriptor(\CountdownTimer.name)]
        )

        do {
            return try context.fetch(query)
        } catch {
            return []
        }
    }
    
    func getAllUpdatedTimers(timerStamp: Int64) -> [CountdownTimer] {
        guard let userID = Auth.auth().currentUser?.uid else { return [] }
       
        let predicate = #Predicate { (timer: CountdownTimer) in
            timer.userID == userID && timer.updatedAtOnDevice > timerStamp
        }
        
        let query = FetchDescriptor<CountdownTimer>(
            predicate: predicate,
            sortBy: [SortDescriptor(\CountdownTimer.name)]
        )

        do {
            return try context.fetch(query)
        } catch {
            return []
        }
    }
    
    func getById(timerId: String) -> CountdownTimer? {
        // Erstelle eine Predicate, um nach dem timerId zu filtern
        let predicate = #Predicate { (timer: CountdownTimer) in
            timer.timerID == timerId
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
        let existingTimer = getById(timerId: countdownTimer.timerID)
        
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
        syncTimers()
    }
    
    func fetchTimerFromBackend() {
        guard (Auth.auth().currentUser != nil), AppStorageService.whenBackendReachable() else { return }
        
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                guard let user = Auth.auth().currentUser else { return }
                
                let url = apiService.baseURL + "/api/timer/fetchItemsAfterTimeStamp?timeStamp=\(lastSync)&userId=\(user.uid)"
                
                print("")
                print("<<< URL \(url)")
                
                let response = await AF.request(url, headers: headers)
                                       .cacheResponse(using: .doNotCache)
                                       .validate()
                                       .serializingDecodable([CountdownTimerResponse].self)
                                       .response
                
                
                switch (response.result) {
                    case .success(let data):
                    
                        data.forEach { countdownTimerResponse in
                            insertOrUpdate(countdownTimer: countdownTimerResponse.toCountdownTimer())
                        }
                    
                        syncHistoryRepository.saveSyncHistoryStamp(entity: table)
                    
                    case .failure(_):
                        if response.response?.statusCode == 430 {
                            print("CountdownTimer: NothingToSync")
                            throw NetworkError.NothingToSync
                        } else {
                            throw NetworkError.unknown
                        }
                }
                
            }
        }
    }
    
    func sendUpdatedTimerToBackend() {
        guard (Auth.auth().currentUser != nil), AppStorageService.whenBackendReachable() else { return }
        
        let url = apiService.baseURL + "/api/timer/updateRemoteData"

        let headers: HTTPHeaders = [
            .authorization(bearerToken: apiService.bearerToken),
            .contentType("application/json")
        ]
        
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                
                let foundTimers = getAllUpdatedTimers(timerStamp: lastSync)

                let updatedTimers = foundTimers.map { timer in
                    timer.toCountdownTimerResponse()
                }
                
                print("")
                print("\(table) >>> URL \(url)")
                print("\(table) last Sync: \(lastSync)")
                print("\(table) send timers: \(updatedTimers.count)")
                
                AF.request(url, method: .post, parameters: updatedTimers, encoder: JSONParameterEncoder.default, headers: headers)
                    .validate()
                    .response { response in
                        switch response.result {
                            case .success: print("Daten erfolgreich gesendet!")
                            case .failure(let error): print("Fehler beim Senden der Daten: \(error)")
                        }
                    }
                
                print("")
            }
        }
    }
    
    func syncTimers() {
        guard let user = Auth.auth().currentUser, AppStorageService.whenBackendReachable() else { return }
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                
                let timerToUpdate = getAllUpdatedTimers(timerStamp: lastSync).map { timer in
                    timer.toCountdownTimerResponse()
                }
                
                
                // SEND TIMER TO BACKEND
                let sendURL = apiService.baseURL + "/api/timer/updateRemoteData"
                print("")
                print("\(table) >>> URL \(sendURL)")
                print("\(table) last Sync: \(lastSync)")
                print("\(table) send timers: \(timerToUpdate.count)")
                
                AF.request(sendURL, method: .post, parameters: timerToUpdate, encoder: JSONParameterEncoder.default, headers: headers)
                    .validate()
                    .response { response in
                        switch response.result {
                        case .success: print("Alle CountdownTimer erfolgreich gesendet!")
                        case .failure(let error): print("Fehler beim Senden der Daten: \(error)")
                        }
                    }
                
                print("")
                
                
                // FETCH CURRENT BACKEND DATA
                let fetchURL = apiService.baseURL + "/api/timer/fetchItemsAfterTimeStamp?timeStamp=\(lastSync)&userId=\(user.uid)"
                let response = await AF.request(fetchURL, headers: headers)
                    .cacheResponse(using: .doNotCache)
                    .validate()
                    .serializingDecodable([CountdownTimerResponse].self)
                    .response
                
                
                switch (response.result) {
                    case .success(let serverTimers):
                    
                        serverTimers.forEach { serverTimer in
                            
                            let localTimer = getById(timerId: serverTimer.timerID)
                            
                            
                            if let localTimer = localTimer {
                                
                                if localTimer.toTimerState != .running {
                                    localTimer.duration = Int(serverTimer.duration)
                                    localTimer.timerState = serverTimer.timerState
                                    localTimer.startDate = serverTimer.startDate
                                    localTimer.endDate = serverTimer.endDate
                                }
                                
                                localTimer.name = serverTimer.name
                                localTimer.updatedAtOnDevice = serverTimer.updatedAtOnDevice
                                localTimer.isDeleted = serverTimer.isDeleted
                                localTimer.updatedAt = serverTimer.updatedAt
                                
                            } else {
                                context.insert(
                                    CountdownTimer(
                                        timerID: serverTimer.timerID,
                                        userID: serverTimer.userID,
                                        name: serverTimer.name,
                                        duration: serverTimer.duration,
                                        timerState: serverTimer.timerState,
                                        showActivity: serverTimer.showActivity,
                                        isDeleted: serverTimer.isDeleted,
                                        updatedAtOnDevice: serverTimer.updatedAtOnDevice,
                                        createdAt: serverTimer.createdAt,
                                        updatedAt: serverTimer.updatedAt
                                    )
                                )
                            } 
                        }
                        
                        syncHistoryRepository.saveSyncHistoryStamp(entity: table)
                    
                    case .failure(_): throw NetworkError.serializationError
                }
            } catch {
                return
            }
        }
        
    }
}
