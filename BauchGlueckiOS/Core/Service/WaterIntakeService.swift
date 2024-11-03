//
//  WaterIntakeService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//

import SwiftData
import Alamofire
import FirebaseAuth



@MainActor
class WaterIntakeService {
    private var context: ModelContext
    private var table: Entitiy
    private var apiService: StrapiApiClient
    private var syncHistoryRepository: SyncHistoryService
    private var headers: HTTPHeaders {
        [.authorization(bearerToken: apiService.bearerToken)]
    }
    
    init(context: ModelContext, apiService: StrapiApiClient) {
        self.context = context
        self.table = Entitiy.WATER_INTAKE
        self.apiService = apiService
        self.syncHistoryRepository = SyncHistoryService(context: context)
    }

    private func insertOrUpdate(waterIntakeID: String, serverWaterIntake: WaterIntake) {
        let localWaterIntake = getById(waterIntakeId: waterIntakeID)
        if let localWaterIntake = localWaterIntake {
            
            localWaterIntake.waterIntakeId = serverWaterIntake.waterIntakeId
            localWaterIntake.value = serverWaterIntake.value
            localWaterIntake.isDeleted = serverWaterIntake.isDeleted
            localWaterIntake.updatedAtOnDevice = serverWaterIntake.updatedAtOnDevice
            
        } else {
            context.insert(
                Weight(
                    userID: serverWaterIntake.userId,
                    weightId: serverWaterIntake.waterIntakeId,
                    value: serverWaterIntake.value,
                    isDeleted: serverWaterIntake.isDeleted,
                    updatedAtOnDevice: serverWaterIntake.updatedAtOnDevice
                )
            )
        }
    }

    private func getAllUpdatedItems(timeStamp: Int64) -> [WaterIntake] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
       
        let predicate = #Predicate { (waterIntake: WaterIntake) in
            waterIntake.userId == userId && waterIntake.updatedAtOnDevice > timeStamp
        }
        
        let query = FetchDescriptor<WaterIntake>(
            predicate: predicate
        )

        do {
            return try context.fetch(query)
        } catch {
            return []
        }
    }
    
    private func getById(waterIntakeId: String) -> WaterIntake? {
        let predicate = #Predicate { (intake: WaterIntake) in
            intake.waterIntakeId == waterIntakeId
        }

        let query = FetchDescriptor<WaterIntake>(
            predicate: predicate
        )
        
        if let result = try? context.fetch(query).first {
            return result
        }
        
        return nil
    }

    func insertGLass() {
        guard let user = Auth.auth().currentUser else { return }
        
        let intake =  WaterIntake(
            userId: user.uid,
            value: 0.25
        )
 
        self.context.insert( intake )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.sendUpdatedWaterIntakesToBackend()
        })
        
        
    }
    
    func fetchWaterIntakesFromBackend() {
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                guard let user = Auth.auth().currentUser else { return }
                
                let fetchURL = apiService.baseURL + "/api/water-intake/fetchItemsAfterTimeStamp?timeStamp=\(lastSync)&userId=\(user.uid)"
                
                print("")
                print("<<< URL \(fetchURL)")
                
                let response = await AF.request(fetchURL, headers: headers)
                                       .cacheResponse(using: .doNotCache)
                                       .validate()
                                       .serializingDecodable([WaterIntake].self)
                                       .response
                
                
                switch (response.result) {
                    case .success(let data):
                    
                        data.forEach { waterintake in
                            insertOrUpdate(waterIntakeID: waterintake.waterIntakeId, serverWaterIntake: waterintake)
                        }
                    
                        syncHistoryRepository.saveSyncHistoryStamp(entity: table)
                    
                    case .failure(_):
                        if response.response?.statusCode == 430 {
                            print("WaterIntake: NothingToSync")
                            throw NetworkError.NothingToSync
                        } else {
                            throw NetworkError.unknown
                        }
                }
                
            } 
        }
    }
    
    func sendUpdatedWaterIntakesToBackend() {
        let sendURL = apiService.baseURL + "/api/water-intake/updateRemoteData"

        let headers: HTTPHeaders = [
            .authorization(bearerToken: apiService.bearerToken),
            .contentType("application/json")
        ]
        
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                
                let foundWaterIntakes = getAllUpdatedItems(timeStamp: lastSync)
                
                print("")
                print("\(table) >>> URL \(sendURL)")
                print("\(table) last Sync: \(lastSync)")
                print("\(table) send weights: \(foundWaterIntakes.count)")
                
                AF.request(sendURL, method: .post, parameters: foundWaterIntakes, encoder: JSONParameterEncoder.default, headers: headers)
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

    func syncWaterIntakes() {
        guard (Auth.auth().currentUser != nil) else { return }
        
        sendUpdatedWaterIntakesToBackend()
        
        fetchWaterIntakesFromBackend()
    }

}
