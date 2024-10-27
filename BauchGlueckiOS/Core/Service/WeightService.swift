//
//  WeightService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//

import SwiftData
import Alamofire
import FirebaseAuth

@MainActor
class WeightService {
    private var context: ModelContext
    private var table: Entitiy
    private var apiService: StrapiApiClient
    private var syncHistoryRepository: SyncHistoryService
    private var headers: HTTPHeaders {
        [.authorization(bearerToken: apiService.bearerToken)]
    }
    
    init(context: ModelContext, apiService: StrapiApiClient) {
        self.context = context
        self.table = Entitiy.WEIGHT
        self.apiService = apiService
        self.syncHistoryRepository = SyncHistoryService(context: context)
    }
    
    func insertOrUpdate(weightId: String, serverWeight: Weight) {
        let localWeight = getById(weightId: weightId)
        if let localWeight = localWeight {
            
            localWeight.weightId = serverWeight.weightId
            localWeight.value = serverWeight.value
            localWeight.isDeleted = serverWeight.isDeleted
            localWeight.weighed = serverWeight.weighed
            localWeight.updatedAtOnDevice = serverWeight.updatedAtOnDevice
            
        } else {
            context.insert(
                Weight(
                    userID: serverWeight.userID,
                    weightId: serverWeight.weightId,
                    value: serverWeight.value,
                    isDeleted: serverWeight.isDeleted,
                    weighed: serverWeight.weighed,
                    updatedAtOnDevice: serverWeight.updatedAtOnDevice
                )
            )
        }
    }
    
    func getAll() async throws -> [Weight] {
        guard let userID = Auth.auth().currentUser?.uid else { return [] }
        
        let predicate = #Predicate { (weight: Weight) in
            weight.userID == userID
        }
        
        let query = FetchDescriptor<Weight>(
            predicate: predicate
        )

        do {
            return try context.fetch(query)
        } catch {
            return []
        }
    }
    
    func getAllUpdatedWeights(timeStamp: Int64) -> [Weight] {
        guard let userID = Auth.auth().currentUser?.uid else { return [] }
       
        let predicate = #Predicate { (weight: Weight) in
            weight.userID == userID && weight.updatedAtOnDevice > timeStamp
        }
        
        let query = FetchDescriptor<Weight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\Weight.weighed)]
        )

        do {
            return try context.fetch(query)
        } catch {
            return []
        }
    }
    
    func getById(weightId: String) -> Weight? {
        let predicate = #Predicate { (weight: Weight) in
            weight.weightId == weightId
        }

        let query = FetchDescriptor<Weight>(
            predicate: predicate
        )
        
        if let result = try? context.fetch(query).first {
            return result
        }
        
        return nil
    }
    
    func softDeleteMany(weights: [Weight]) async throws {
        weights.forEach { weight in
            weight.isDeleted = true
            weight.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
        }
        
        try context.save()
        syncWeights()
    }
    
    func insert(weight: Weight) {
        context.insert(weight)
    }
    
    func fetchWeightsFromBackend() {
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                guard let user = Auth.auth().currentUser else { return }
                
                let url = apiService.baseURL + "/api/weight/fetchItemsAfterTimeStamp?timeStamp=\(lastSync)&userId=\(user.uid)"
                
                print("")
                print("<<< URL \(url)")
                
                let response = await AF.request(url, headers: headers)
                                       .cacheResponse(using: .doNotCache)
                                       .validate()
                                       .serializingDecodable([Weight].self)
                                       .response
                
                
                print(response)
                
                switch (response.result) {
                    case .success(let data):
                    
                        data.forEach { weight in
                            insertOrUpdate(weightId: weight.weightId, serverWeight: weight)
                        }
                    
                        syncHistoryRepository.saveSyncHistoryStamp(entity: table)
                    
                    case .failure(_):
                        if response.response?.statusCode == 430 {
                            print("Weights: NothingToSync")
                            throw NetworkError.NothingToSync
                        } else {
                            throw NetworkError.unknown
                        }
                }
                
            } 
        }
    }
    
    func sendUpdatedWeightsToBackend() {
        let sendURL = apiService.baseURL + "/api/weight/updateRemoteData"

        let headers: HTTPHeaders = [
            .authorization(bearerToken: apiService.bearerToken),
            .contentType("application/json")
        ]
        
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                
                let foundWeights = getAllUpdatedWeights(timeStamp: lastSync)
                
                print("")
                print("\(table) >>> URL \(sendURL)")
                print("\(table) last Sync: \(lastSync)")
                print("\(table) send weights: \(foundWeights.count)")
                
                AF.request(sendURL, method: .post, parameters: foundWeights, encoder: JSONParameterEncoder.default, headers: headers)
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

    func syncWeights() {
        guard (Auth.auth().currentUser != nil) else { return }
        
        sendUpdatedWeightsToBackend()
        
        fetchWeightsFromBackend()
    }
}
